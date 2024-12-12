import ExpoModulesCore
import CoreLocation
import CoreBluetooth

private class LocationManagerDelegate: NSObject, CLLocationManagerDelegate, CBCentralManagerDelegate {
    private var locationManager: CLLocationManager!
    private var beaconRegion: CLBeaconRegion!
    private var centralManager: CBCentralManager!
    private var sendEvent: ((String, [String: Any]) -> Void)?
    
    func setEventEmitter(_ emitter: @escaping (String, [String: Any]) -> Void) {
        self.sendEvent = emitter
    }
    
    func startScanning(_ uuid: String) {
        DispatchQueue.main.async {
            self.locationManager = CLLocationManager()
            self.locationManager.delegate = self
            self.locationManager.requestAlwaysAuthorization()
            
            self.locationManager.allowsBackgroundLocationUpdates = true
            self.locationManager.pausesLocationUpdatesAutomatically = false
            
            let uuid = UUID(uuidString: uuid)!
            let beaconConstraint = CLBeaconIdentityConstraint(uuid: uuid)
            self.beaconRegion = CLBeaconRegion(beaconIdentityConstraint: beaconConstraint, identifier: "com.zipplabs.beacon")
            self.beaconRegion.notifyOnEntry = true
            self.beaconRegion.notifyOnExit = true
            self.locationManager.startMonitoring(for: self.beaconRegion)
            self.locationManager.startRangingBeacons(satisfying: beaconConstraint)
            self.locationManager.requestState(for: self.beaconRegion)
            self.locationManager.startUpdatingLocation()
        }
    }
    
    func stopScanning() {
        if let beaconRegion = self.beaconRegion {
            self.locationManager.stopMonitoring(for: beaconRegion)
            self.locationManager.stopRangingBeacons(in: beaconRegion)
            self.beaconRegion = nil
            self.locationManager = nil
        }
    }
    
    func initializeBluetoothManager() {
        centralManager = CBCentralManager(delegate: self, queue: nil, options: [CBCentralManagerOptionShowPowerAlertKey: false])
    }
    
    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        var msg = ""
        switch central.state {
        case .unknown: msg = "unknown"
        case .resetting: msg = "resetting"
        case .unsupported: msg = "unsupported"
        case .unauthorized: msg = "unauthorized"
        case .poweredOff: msg = "poweredOff"
        case .poweredOn: msg = "poweredOn"
        @unknown default: msg = "unknown"
        }
        
        // bridge send event
    }
    
    func requestAlwaysAuthorization(_ resolve: @escaping RCTPromiseResolveBlock) {
        let locationManager = CLLocationManager()
        locationManager.delegate = self
        locationManager.requestAlwaysAuthorization()
        let status = CLLocationManager.authorizationStatus()
        let statusString = statusToString(status)
        resolve(["status": statusString])
    }
    
    func requestWhenInUseAuthorization(_ resolve: @escaping RCTPromiseResolveBlock) {
        let locationManager = CLLocationManager()
        locationManager.delegate = self
        locationManager.requestWhenInUseAuthorization()
        let status = CLLocationManager.authorizationStatus()
        let statusString = statusToString(status)
        resolve(["status": statusString])
    }
    
    func getAuthorizationStatus(_ resolve: @escaping RCTPromiseResolveBlock) {
        let status = CLLocationManager.authorizationStatus()
        resolve(statusToString(status))
    }
    
    // Handle detection of beacons in the region
    func locationManager(
         _ manager: CLLocationManager, didRangeBeacons beacons: [CLBeacon], in region: CLBeaconRegion
       ) {
           print("beacons: ", beacons)
         let beaconArray = beacons.map { beacon -> [String: Any] in
           return [
             "uuid": beacon.uuid.uuidString, // UUID of the beacon
             "major": beacon.major.intValue, // Major beacon value
             "minor": beacon.minor.intValue, // Minor beacon value
             "distance": beacon.accuracy, // Accuracy of the distance to the beacon
             "rssi": beacon.rssi, // Beacon signal strength
           ]
         }
         sendEvent?("beaconsDidRange", ["beacons": beaconArray])
    }
    
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        if #available(iOS 14.0, *) {
            if manager.authorizationStatus == .authorizedAlways || manager.authorizationStatus == .authorizedWhenInUse {
                locationManager.startMonitoring(for: beaconRegion)
                locationManager.startRangingBeacons(in: beaconRegion)
            }
        } else {
            if CLLocationManager.authorizationStatus() == .authorizedAlways || CLLocationManager.authorizationStatus() == .authorizedWhenInUse {
                locationManager.startMonitoring(for: beaconRegion)
                locationManager.startRangingBeacons(in: beaconRegion)
            }
        }
    }
    
    private func statusToString(_ status: CLAuthorizationStatus) -> String {
        switch status {
          case .notDetermined: return "notDetermined"
          case .restricted: return "restricted"
          case .denied: return "denied"
          case .authorizedAlways: return "authorizedAlways"
          case .authorizedWhenInUse: return "authorizedWhenInUse"
          @unknown default: return "unknown"
        }
    }
}

public class ExpoIbeaconManagerModule: Module {
  private let locationManagerDelegate = LocationManagerDelegate()
  public func definition() -> ModuleDefinition {
    Name("ExpoIbeaconManager")
      
    Events("beaconsDidRange")
      
    Function("startScanning") { (uuid: String) in
      return locationManagerDelegate.startScanning(uuid)
    }
    
    Function("stopScanning") {
      return locationManagerDelegate.stopScanning()
    }
      
    AsyncFunction("requestWhenInUseAuthorization") { (promise: Promise) in
      return locationManagerDelegate.requestWhenInUseAuthorization(promise.resolve)
    }
    
    AsyncFunction("requestAlwaysAuthorization") { (promise: Promise) in
      return locationManagerDelegate.requestAlwaysAuthorization(promise.resolve)
    }
      
    AsyncFunction("getAuthorizationStatus") { (promise: Promise) in
       return locationManagerDelegate.getAuthorizationStatus(promise.resolve)
    }
      
    OnStartObserving {
      locationManagerDelegate.setEventEmitter { eventName, eventData in
        self.sendEvent(eventName, eventData)
      }
    }
  }
}
