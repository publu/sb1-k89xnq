import SwiftUI

struct ContentView: View {
    @StateObject private var bluetoothManager = BluetoothManager()
    
    var body: some View {
        NavigationView {
            VStack {
                if bluetoothManager.isConnected {
                    ConnectedView(bluetoothManager: bluetoothManager)
                } else {
                    ScanningView(bluetoothManager: bluetoothManager)
                }
            }
            .navigationTitle("Audio Recorder")
        }
    }
}

struct ScanningView: View {
    @ObservedObject var bluetoothManager: BluetoothManager
    
    var body: some View {
        List(bluetoothManager.discoveredDevices, id: \.identifier) { device in
            Button(action: {
                bluetoothManager.connect(to: device)
            }) {
                Text(device.name ?? "Unknown Device")
            }
        }
        .overlay(Group {
            if bluetoothManager.discoveredDevices.isEmpty {
                ContentUnavailableView(
                    "No Devices Found",
                    systemImage: "bluetooth.slash",
                    description: Text("Make sure your audio device is nearby and powered on")
                )
            }
        })
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                Button(action: {
                    if bluetoothManager.isScanning {
                        bluetoothManager.stopScanning()
                    } else {
                        bluetoothManager.startScanning()
                    }
                }) {
                    Label(
                        bluetoothManager.isScanning ? "Stop Scanning" : "Start Scanning",
                        systemImage: bluetoothManager.isScanning ? "stop.fill" : "play.fill"
                    )
                }
            }
        }
    }
}

struct ConnectedView: View {
    @ObservedObject var bluetoothManager: BluetoothManager
    
    var body: some View {
        VStack(spacing: 20) {
            Image(systemName: "waveform")
                .font(.system(size: 100))
                .foregroundColor(.blue)
            
            Text("Recording in progress...")
                .font(.headline)
            
            Button(action: {
                bluetoothManager.disconnect()
            }) {
                Text("Disconnect")
                    .foregroundColor(.red)
                    .font(.headline)
                    .padding()
                    .background(
                        RoundedRectangle(cornerRadius: 10)
                            .stroke(Color.red, lineWidth: 2)
                    )
            }
        }
        .padding()
    }
}

#Preview {
    ContentView()
}