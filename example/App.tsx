import * as IbeaconManager from 'expo-ibeacon-manager';
import { SafeAreaView, Text } from 'react-native';

IbeaconManager.requestWhenInUseAuthorization();

IbeaconManager.startScanning("DE62C6D0-005E-4F32-B019-AA45124005CA");

export default function App() {

  return (
    <SafeAreaView style={styles.container}>
      <Text>123ß</Text>
    </SafeAreaView>
  );
}

const styles = {
  header: {
    fontSize: 30,
    margin: 20,
  },
  groupHeader: {
    fontSize: 20,
    marginBottom: 20,
  },
  group: {
    margin: 20,
    backgroundColor: '#fff',
    borderRadius: 10,
    padding: 20,
  },
  container: {
    flex: 1,
    backgroundColor: '#eee',
  },
  view: {
    flex: 1,
    height: 200,
  },
};
