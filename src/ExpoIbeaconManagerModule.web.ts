import { registerWebModule, NativeModule } from 'expo';

import { ExpoIbeaconManagerModuleEvents } from './ExpoIbeaconManager.types';

class ExpoIbeaconManagerModule extends NativeModule<ExpoIbeaconManagerModuleEvents> {
  PI = Math.PI;
  async setValueAsync(value: string): Promise<void> {
    this.emit('onChange', { value });
  }
  hello() {
    return 'Hello world! 👋';
  }
}

export default registerWebModule(ExpoIbeaconManagerModule);
