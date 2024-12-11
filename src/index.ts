// Reexport the native module. On web, it will be resolved to ExpoIbeaconManagerModule.web.ts
// and on native platforms to ExpoIbeaconManagerModule.ts
export { default } from './ExpoIbeaconManagerModule';
export { default as ExpoIbeaconManagerView } from './ExpoIbeaconManagerView';
export * from  './ExpoIbeaconManager.types';
