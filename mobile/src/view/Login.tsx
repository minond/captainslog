import React, { useState } from "react"
import { Text, TextInput } from "react-native"

import { CreateToken, SetToken } from "../repository/token"
import styles from "../styles"
import strings from "../strings"

import AppView from "../component/AppView"
import Button from "../component/Button"
import FormField from "../component/FormField"
import Header from "../component/Header"

const login = (
  email: string,
  password: string,
  setErrorMessage: (_: string) => void,
  createToken: CreateToken,
  setToken: SetToken
) => {
  setErrorMessage("")

  if (!email && !password) {
    setErrorMessage(strings.missingValues(strings.email, strings.password))
    return
  } else if (!email) {
    setErrorMessage(strings.missingValues(strings.email))
    return
  } else if (!password) {
    setErrorMessage(strings.missingValues(strings.password))
    return
  }

  createToken(email, password)
    .then((token) => {
      setToken(token)
        .then(() => {
          console.log("saved token to secure store")
        })
        .catch((err) => {
          console.log("storage error:", err)
          setErrorMessage(strings.loginError)
        })
    })
    .catch((err) => {
      console.log("login error:", err)
      setErrorMessage(strings.invalidLogin)
    })
}

type LoginProps = {
  setToken: SetToken
  createToken: CreateToken
}

export default function Login(props: LoginProps) {
  const [email, setEmail] = useState("")
  const [password, setPassword] = useState("")
  const [errorMessage, setErrorMessage] = useState("")

  const onLoginButtonPress = () =>
    login(
      email,
      password,
      setErrorMessage,
      props.createToken,
      props.setToken
    )

  return <AppView>
    <Header>{strings.login}</Header>

    <FormField>
      <Text style={styles.inputLabel}>{strings.email}</Text>
      <TextInput
        style={styles.textInput}
        onChangeText={(val) => setEmail(val)}
      />
    </FormField>

    <FormField>
      <Text style={styles.inputLabel}>{strings.password}</Text>
      <TextInput
        style={styles.textInput}
        onChangeText={(val) => setPassword(val)}
        secureTextEntry={true}
      />
    </FormField>

    {!errorMessage ? null :
      <FormField>
        <Text style={styles.errorMessage}>{errorMessage}</Text>
      </FormField>}

    <FormField>
      <Button label={strings.login} onPress={onLoginButtonPress} />
    </FormField>
  </AppView>
}