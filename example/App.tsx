import * as IbeaconManager from "expo-ibeacon-manager";
import { useEffect, useState } from "react";
import { SafeAreaView, Text, View, Button } from "react-native";

IbeaconManager.requestAlwaysAuthorization();

export default function App() {
  const handleGetBeaconsByUUID = async () => {
    const status = await IbeaconManager.getAuthorizationStatus();

    console.log("status: ", status);

    if (status && status !== "unknown" && status !== "denied") {
      IbeaconManager.startScanning("DE62C6D0-005E-4F32-B019-AA45124005CA");
    }
  };

  useEffect(() => {
    handleGetBeaconsByUUID();
    const subscription = IbeaconManager.addBeaconListener(({ beacon }) => {
      console.log("beacons: ", beacon);
    });

    return () => subscription.remove();
  }, []);

  return (
    <SafeAreaView style={styles.container}>
      <Text>123ß</Text>
      <View
        style={{
          flex: 1,
          justifyContent: "center",
          alignItems: "center",
        }}
      >
        <Button title="stop" onPress={() => IbeaconManager.stopScanning()} />
      </View>
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
    backgroundColor: "#fff",
    borderRadius: 10,
    padding: 20,
  },
  container: {
    flex: 1,
    backgroundColor: "#eee",
  },
  view: {
    flex: 1,
    height: 200,
  },
};
