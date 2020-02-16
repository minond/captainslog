import React from "react"
import { View } from "react-native"

import Login from "./src/view/Login"
import styles from "./src/styles"

export default function App() {
  return (
    <View style={styles.containerWrapper}>
      <Login />
    </View>
  )
}
