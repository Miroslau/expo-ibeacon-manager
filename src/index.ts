import { EventEmitter } from 'expo';

import ExpoIbeaconManagerModule from "./ExpoIbeaconManagerModule";

type iBeacon = {
  uuid: string;
  major: number;
  minor: number;
  distance: number;
  rssi: number;
};

type ExpoIbeaconManagerEvents = {
  beaconDidRange: { beacon: iBeacon };
};

const eventEmitter = new EventEmitter(ExpoIbeaconManagerModule);

export function startScanning(uuid: string): void {
  return ExpoIbeaconManagerModule.startScanning(uuid);
}

export function stopScanning(): void {
  return ExpoIbeaconManagerModule.stopScanning();
}

export async function getAuthorizationStatus(): Promise<string> {
  return ExpoIbeaconManagerModule.getAuthorizationStatus();
}

export async function requestWhenInUseAuthorization(): Promise<string> {
  return ExpoIbeaconManagerModule.requestWhenInUseAuthorization();
}

export async function requestAlwaysAuthorization(): Promise<string> {
  return ExpoIbeaconManagerModule.requestAlwaysAuthorization();
}

export function addBeaconListener(listener: (event: ExpoIbeaconManagerEvents['beaconDidRange']) => void) {
  // @ts-ignore
  return eventEmitter.addListener<ExpoIbeaconManagerEvents['beaconDidRange']>('beaconDidRange', listener);
}
