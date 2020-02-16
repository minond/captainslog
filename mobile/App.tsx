import React from "react"
import { View } from "react-native"

import LoginForm from "./LoginForm"
import styles from "./styles"

export default function App() {
  return (
    <View style={styles.containerWrapper}>
      <LoginForm />
    </View>
  )
}
