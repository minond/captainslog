import React, { useState, useEffect } from "react"
import { Text, View } from "react-native"

import Login from "./src/view/Login"
import styles from "./src/styles"

import { createToken, getToken, setToken } from "./src/repository/token"

export default function App() {
  const [loadingToken, setLoadingToken] = useState(true)
  const [sessionToken, setSessionToken] = useState<string | null>(null)

  useEffect(() => {
    getToken().then((token) => {
      if (token && typeof token === "string") {
        setSessionToken(token)
      }

      setLoadingToken(false)
    }).catch(() => setLoadingToken(false))
  })

  if (loadingToken) {
    return (
      <View style={styles.containerWrapper}>
        <Text>loading...</Text>
      </View>
    )
  } else if (!sessionToken) {
    return (
      <View style={styles.containerWrapper}>
        <Login setToken={setToken} createToken={createToken} afterLogin={setSessionToken} />
      </View>
    )
  } else {
    return (
      <View style={styles.containerWrapper}>
        <Text>ok.</Text>
      </View>
    )
  }
}
