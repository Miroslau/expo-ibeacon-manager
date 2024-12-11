import ExpoIbeaconManagerModule from "./ExpoIbeaconManagerModule";

export function startScanning(uuid: string): void {
  return ExpoIbeaconManagerModule.startScanning(uuid);
}

export function requestWhenInUseAuthorization(): void {
  return ExpoIbeaconManagerModule.requestWhenInUseAuthorization();
}