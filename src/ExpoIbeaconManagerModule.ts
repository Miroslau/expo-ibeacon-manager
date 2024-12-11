import { NativeModule, requireNativeModule } from 'expo';

import { ExpoIbeaconManagerModuleEvents } from './ExpoIbeaconManager.types';

declare class ExpoIbeaconManagerModule extends NativeModule<ExpoIbeaconManagerModuleEvents> {
  PI: number;
  hello(): string;
  setValueAsync(value: string): Promise<void>;
}

// This call loads the native module object from the JSI.
export default requireNativeModule<ExpoIbeaconManagerModule>('ExpoIbeaconManager');