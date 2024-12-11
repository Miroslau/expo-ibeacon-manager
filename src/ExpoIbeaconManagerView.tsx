import { requireNativeView } from 'expo';
import * as React from 'react';

import { ExpoIbeaconManagerViewProps } from './ExpoIbeaconManager.types';

const NativeView: React.ComponentType<ExpoIbeaconManagerViewProps> =
  requireNativeView('ExpoIbeaconManager');

export default function ExpoIbeaconManagerView(props: ExpoIbeaconManagerViewProps) {
  return <NativeView {...props} />;
}
