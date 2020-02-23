import React, { useState, useEffect } from "react"
import { Text, View } from "react-native"

import AppView from "./src/component/AppView"
import Button from "./src/component/Button"
import Authenticated from "./src/view/Authenticated"

import { clearToken, createToken, getToken, setToken } from "./src/repository/token"

export default function App() {
  return (
    <Authenticated
      clearToken={clearToken}
      createToken={createToken}
      getToken={getToken}
      setToken={setToken}
    >
      {(sessionToken, logout) =>
        <AppView>
          <Text>ok</Text>
          <Button label="logout" onPress={logout} />
        </AppView>}
    </Authenticated>
  )
}
