/**
 * Sample React Native App
 * https://github.com/facebook/react-native
 *
 * @format
 */

import React from 'react';
import {
  StyleSheet,
  Button,
  View,
  SafeAreaView,
  Text,
  Alert,
  NativeEventEmitter,
} from 'react-native';
import NVibeNavigation from './NVibeNavigation';

const Separator = () => <View style={styles.separator} />;

const origin = {
  address: "27 Rue du chemin Vert",
  position: {
    latitude: 48.858605690397226,
    longitude: 2.3730326633100916,
  },
  access: {
    latitude: 48.858605690397226,
    longitude: 2.3730326633100916,
  }
}

const destination = {
  address: "5 Rue de l\'Asile Popincourt",
  position: {
    latitude: 48.85984957956969,
    longitude: 2.37408359088719,
  },
  access: {
    latitude: 48.85984957956969,
    longitude: 2.37408359088719,
  }
}

const event = new NativeEventEmitter(NVibeNavigation)

const App = () => (
  <SafeAreaView style={styles.container}>
    <View>
      <View style={styles.fixToText}>
        <Button
          title="Test"
          onPress={() => {
            event.addListener('onTest', (data) => {
              event.removeAllListeners("onTest")
              console.log(`onTest : ${data}`)
            })

            NVibeNavigation.test({ artist: "Bruce Springsteen", title: "Born in the USA" })
          }}
        />
        <Button
          title="Get route"
          onPress={() => {
            NVibeNavigation.getRoute(origin, destination, (error: any, eventId: any) => {
              if (error) {
                console.error(`Error found! ${error}`)
              } else {
                console.log(`Route found with geometry ${eventId}`)
              }
            })
          }}
        />
        <Button
          title="Start"
          onPress={() => {
            event.addListener("onWalkingNavigationStarted", () => console.log("onWalkingNavigationStarted"))
            event.addListener("onTokenError", () => console.log("onTokenError"))

            NVibeNavigation.startNavigation(origin, destination)
          }}
        />
        <Button
          title="Stop"
          onPress={() => {
            event.removeAllListeners("onWalkingNavigationStarted")
            event.removeAllListeners("onTokenError")
            NVibeNavigation.stopNavigation()
          }}
        />
      </View>
    </View>
  </SafeAreaView>
);

const styles = StyleSheet.create({
  container: {
    flex: 1,
    justifyContent: 'center',
    marginHorizontal: 16,
  },
  title: {
    textAlign: 'center',
    marginVertical: 8,
  },
  fixToText: {
    flexDirection: 'row',
    justifyContent: 'space-between',
  },
  separator: {
    marginVertical: 8,
    borderBottomColor: '#737373',
    borderBottomWidth: StyleSheet.hairlineWidth,
  },
});

export default App;