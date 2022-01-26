//
//  bluetoothManager.swift
//  Home
//
//  Created by David Bohaumilitzky on 30.09.21.
//

import Foundation
import Combine
import CoreBluetooth
import SwiftUI


extension Set where Element: Cancellable {

    func cancel() {
        forEach { $0.cancel() }
    }
}

final class BluetoothManager: NSObject {
    
    static let shared: BluetoothManager = .init()
    
    var stateSubject: PassthroughSubject<CBManagerState, Never> = .init()
    var peripheralSubject: PassthroughSubject<CBPeripheral, Never> = .init()
    var servicesSubject: PassthroughSubject<[CBService], Never> = .init()
    var characteristicsSubject: PassthroughSubject<(CBService, [CBCharacteristic]), Never> = .init()

    private var centralManager: CBCentralManager!

    //MARK: - Lifecycle
    
    func start() {
        centralManager = .init(delegate: self, queue: .main)
    }
    
    func scan() {
        centralManager.scanForPeripherals(withServices: [CBUUID(string: CBUUIDCharacteristicExtendedPropertiesString)])
    }
    
    func connect(_ peripheral: CBPeripheral) {
        centralManager.stopScan()
        peripheral.delegate = self
        centralManager.connect(peripheral)
    }
}

extension BluetoothManager: CBCentralManagerDelegate {
    
    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        stateSubject.send(central.state)
    }
    
    func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String : Any], rssi RSSI: NSNumber) {
        print(peripheral.debugDescription)
        
        peripheralSubject.send(peripheral)
    }
    
    func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
        peripheral.discoverServices(nil)
    }
}

extension BluetoothManager: CBPeripheralDelegate {
    
    func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: Error?) {
        guard let services = peripheral.services else {
            return
        }
        servicesSubject.send(services)
    }
    
    func peripheral(_ peripheral: CBPeripheral, didDiscoverCharacteristicsFor service: CBService, error: Error?) {
        guard let characteristics = service.characteristics else {
            return
        }
        characteristicsSubject.send((service, characteristics))
    }
}


final class MainViewModel: ObservableObject {

    @Published var state: CBManagerState = .unknown {
        didSet {
            update(with: state)
        }
    }
    @AppStorage("identifier") private var identifier: String = ""
    @Published var peripheral: CBPeripheral?

    private lazy var manager: BluetoothManager = .shared
    private lazy var cancellables: Set<AnyCancellable> = .init()

    //MARK: - Lifecycle
    
    deinit {
        cancellables.cancel()
    }
    
    func start() {
        manager.stateSubject.sink { [weak self] state in
            self?.state = state
        }
        .store(in: &cancellables)
        manager.start()
    }

    //MARK: - Private
    
    private func update(with state: CBManagerState) {
        guard peripheral == nil else {
            return
        }
        guard state == .poweredOn else {
            return
        }
        manager.peripheralSubject
            .filter { $0.identifier == UUID(uuidString: self.identifier) }
            .sink { [weak self] in self?.peripheral = $0 }
            .store(in: &cancellables)
        manager.scan()
    }
}

struct MainViewww: View {
    
    @StateObject private var viewModel: MainViewModel = .init()
    @State private var devicesViewIsPresented = false

    //MARK: - Lifecycle
    
    var body: some View {
        NavigationView {
            content()
                .navigationTitle(viewModel.peripheral?.name ?? "Main")
                .toolbar {
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Button(action: add) {
                            Image(systemName: "plus")
                        }
                        .disabled(viewModel.state != .poweredOn)
                    }
                }
        }
        .onAppear {
            viewModel.start()
        }
        .sheet(isPresented: $devicesViewIsPresented) {
            DevicesView(peripheral: $viewModel.peripheral)
        }
    }

    //MARK: - Private
    
    @ViewBuilder
    private func content() -> some View {
        if viewModel.state != .poweredOn {
            Text("Enable Bluetooth to start scanning")
        }
        else if let peripheral = viewModel.peripheral {
//            DevicesView(peripheral: peripheral)
        }
        else {
            Text("There are no connected devices")
        }
    }
    
    private func add() {
        devicesViewIsPresented = true
    }
}

//struct MainView_Previews: PreviewProvider {
//    static var previews: some View {
//        MainView()
//    }
//}


struct DevicesView: View {
    
    @StateObject private var viewModel: DevicesViewModel = .init()
    @Binding var peripheral: CBPeripheral?
    @Environment(\.presentationMode) private var presentationMode
    
    private var peripherals: [CBPeripheral] {
        viewModel.peripherals.sorted { left, right in
            guard let leftName = left.name else {
                return false
            }
            guard let rightName = right.name else {
                return true
            }
            return leftName < rightName
        }
    }
    
    //MARK: - Lifecycle
    
    var body: some View {
        NavigationView {
            contentView
                .navigationTitle("Devices")
        }
        .onAppear {
            viewModel.start()
        }
    }
    
    //MARK: - Private
    
    @ViewBuilder
    private var contentView: some View {
        if viewModel.state == .poweredOn {
            List(peripherals, id: \.identifier) { peripheral in
                HStack {
                    if let peripheralName = peripheral.name {
                        Text(peripheralName)
                    } else {
                        Text("Unknown")
                            .opacity(0.2)
                    }
                    Spacer()
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical)
                .contentShape(Rectangle())
                .onTapGesture {
                    self.peripheral = peripheral
                    viewModel.identifier = peripheral.identifier.uuidString
                    presentationMode.wrappedValue.dismiss()
                }
            }
            
        } else {
            Text("Please enable bluetooth to search devices")
        }
    }
}

final class DevicesViewModel: ObservableObject {
    
    @AppStorage("identifier") var identifier: String = ""
    @Published var state: CBManagerState = .unknown
    @Published var peripherals: [CBPeripheral] = []

    private lazy var manager: BluetoothManager = .shared
    private lazy var cancellables: Set<AnyCancellable> = .init()

    //MARK: - Lifecycle
    
    deinit {
        cancellables.cancel()
    }
    
    func start() {
        manager.stateSubject
            .sink { [weak self] state in
                self?.state = state
                if state == .poweredOn {
                    self?.manager.scan()
                }
            }
            .store(in: &cancellables)
        manager.peripheralSubject
            .filter { [weak self] in self?.peripherals.contains($0) == false }
            .sink { [weak self] in
                print($0)
                self?.peripherals.append($0)
            }
            .store(in: &cancellables)
        manager.start()
    }
}

//struct DeviceView: View {
//
//    @StateObject private var viewModel: DeviceViewModel
//    @State private var modeSelectionIsPresented = false
//    @State private var didAppear = false
//
//    //MARK: - Lifecycle
//
//    init(peripheral: CBPeripheral) {
//        let viewModel = DeviceViewModel(peripheral: peripheral)
//        _viewModel = .init(wrappedValue: viewModel)
//    }
//
//    var body: some View {
//        content()
//            .onAppear {
//                guard didAppear == false else {
//                    return
//                }
//                didAppear = true
//                viewModel.connect()
//            }
//            .actionSheet(isPresented: $modeSelectionIsPresented) {
//                var buttons: [ActionSheet.Button] = StripeData.Mode.allCases.map { mode in
//                    ActionSheet.Button.default(Text("\(mode.title)")) {
//                        viewModel.state.mode = mode
//                    }
//                }
//                buttons.append(.cancel())
//                return ActionSheet(title: Text("Select Mode"), message: nil, buttons: buttons)
//            }
//    }
//
//    //MARK: - Private
//
//    @ViewBuilder
//    private func content() -> some View {
//        if viewModel.isReady {
//            List {
//                Toggle("On", isOn: $viewModel.state.isOn)
////                ColorPicker("Change stripe color",
////                            selection: $viewModel.state.color,
////                            supportsOpacity: false)
//                HStack {
//                    Text("Mode")
//                    Spacer()
////                    Button(viewModel.state.mode?.title ?? "Solid Color") {
////                        modeSelectionIsPresented.toggle()
////                    }.foregroundColor(.accentColor)
//                }
//                HStack {
//                    Text("Speed")
//                    Slider(value: $viewModel.state.speed, in: 0...1)
//                }
//            }
//        }
//        else {
//            Text("Connecting...")
//        }
//    }
//}


//final class DeviceViewModel: ObservableObject {
//
//    @Published var isReady = false
////    @Published var state: StripeState = .init()
//
//    private enum Constants {
//        static let readServiceUUID: CBUUID = .init(string: "FFD0")
//        static let writeServiceUUID: CBUUID = .init(string: "FFD5")
//        static let serviceUUIDs: [CBUUID] = [readServiceUUID, writeServiceUUID]
//        static let readCharacteristicUUID: CBUUID = .init(string: "FFD4")
//        static let writeCharacteristicUUID: CBUUID = .init(string: "FFD9")
//    }
//
//    private lazy var manager: BluetoothManager = .shared
//    private lazy var cancellables: Set<AnyCancellable> = .init()
//
//    private let peripheral: CBPeripheral
//    private var readCharacteristic: CBCharacteristic?
//    private var writeCharacteristic: CBCharacteristic?
//
//    //MARK: - Lifecycle
//    init(peripheral: CBPeripheral) {
//        self.peripheral = peripheral
//    }
//
//    deinit {
//        cancellables.cancel()
//    }
//
//    func connect() {
//        manager.servicesSubject
//            .map { $0.filter { Constants.serviceUUIDs.contains($0.uuid) } }
//            .sink { [weak self] services in
//                services.forEach { service in
//                    self?.peripheral.discoverCharacteristics(nil, for: service)
//                }
//            }
//            .store(in: &cancellables)
//
//        manager.characteristicsSubject
//            .filter { $0.0.uuid == Constants.readServiceUUID }
//            .compactMap { $0.1.first(where: \.uuid == Constants.readCharacteristicUUID) }
//            .sink { [weak self] characteristic in
//                self?.readCharacteristic = characteristic
//                self?.update(StripeData.state(from: characteristic.value))
//            }
//            .store(in: &cancellables)
//
//        manager.characteristicsSubject
//            .filter { $0.0.uuid == Constants.writeServiceUUID }
//            .compactMap { $0.1.first(where: \.uuid == Constants.writeCharacteristicUUID) }
//            .sink { [weak self] characteristic in
//                self?.writeCharacteristic = characteristic
//            }
//            .store(in: &cancellables)
//
//        manager.connect(peripheral)
//    }
//
//    private func update(_ state: StripeState) {
//        let onPublisher = state.$isOn
//            .map { StripeData.powerData(isOn: $0) }
//
//        let colorPublisher = state.$color
//            .compactMap { try? StripeData.staticColorData(from: $0) }
//
//        let modePublisher = state.$mode
//            .compactMap { $0 }
//            .combineLatest(state.$speed)
//            .map { StripeData.modeData(with: $0, speed: $1) }
//
//        onPublisher.merge(with: colorPublisher, modePublisher)
//            .dropFirst(3)
//            .sink { [weak self] in self?.write($0) }
//            .store(in: &cancellables)
//        self.state = state
//        self.isReady = true
//    }
//
//    private func write(_ data: Data) {
//        guard let characteristic = writeCharacteristic else {
//            return
//        }
//        peripheral.writeValue(data, for: characteristic, type: .withoutResponse)
//    }
//}

func ==<Root, Value: Equatable>(lhs: KeyPath<Root, Value>, rhs: Value) -> (Root) -> Bool {
    { $0[keyPath: lhs] == rhs }
}

func ==<Root, Value: Equatable>(lhs: KeyPath<Root, Value>, rhs: Value?) -> (Root) -> Bool {
    { $0[keyPath: lhs] == rhs }
}
