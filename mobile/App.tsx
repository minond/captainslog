import React from "react"
import { View } from "react-native"

import Login from "./src/view/Login"
import styles from "./src/styles"

import { createToken, setToken } from "./src/repository/token"

export default function App() {
  return (
    <View style={styles.containerWrapper}>
      <Login setToken={setToken} createToken={createToken} />
    </View>
  )
}
