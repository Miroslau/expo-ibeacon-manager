import ExpoModulesCore
import CoreLocation
import CoreBluetooth

private class LocationManagerDelegate: NSObject, CLLocationManagerDelegate {
    private var locationManager: CLLocationManager!
    private var beaconRegion: CLBeaconRegion!
    
    func requestWhenInUseAuthorization(_ resolve: @escaping RCTPromiseResolveBlock) {
        let locationManager = CLLocationManager()
        locationManager.delegate = self
        locationManager.requestWhenInUseAuthorization()
        let status = CLLocationManager.authorizationStatus()
        let statusString = statusToString(status)
        resolve(["status": statusString])
        
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
      
    Events("onBluetoothStateChanged")
      
      Function("startScanning") { (uuid: String) in
          locationManagerDelegate.startScanning(uuid)
      }
      
    AsyncFunction("requestWhenInUseAuthorization") { (promise: Promise) in
      locationManagerDelegate.requestWhenInUseAuthorization(promise.resolve)
    }
  }
}
