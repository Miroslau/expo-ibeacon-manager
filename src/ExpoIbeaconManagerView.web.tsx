import * as React from 'react';

import { ExpoIbeaconManagerViewProps } from './ExpoIbeaconManager.types';

export default function ExpoIbeaconManagerView(props: ExpoIbeaconManagerViewProps) {
  return (
    <div>
      <iframe
        style={{ flex: 1 }}
        src={props.url}
        onLoad={() => props.onLoad({ nativeEvent: { url: props.url } })}
      />
    </div>
  );
}
