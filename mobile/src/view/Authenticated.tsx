import React, { ReactElement, useState, useEffect } from "react"
import { Text, TextInput, View } from "react-native"

import { ClearToken, CreateToken, GetToken, SetToken } from "../repository/token"

import AppView from "../component/AppView"
import Button from "../component/Button"
import FormField from "../component/FormField"
import Header from "../component/Header"

import styles from "../styles"
import strings from "../strings"

type AuthenticatedChild = (token: string, logout: () => void) => ReactElement
type AfterLogin = (token: string) => void
type StringSetter = (_: string | null) => void

const logout = (
  clearToken: ClearToken,
  setSessionToken: StringSetter
) => {
  clearToken().then(() => setSessionToken(null))
}

const login = (
  email: string,
  password: string,
  setErrorMessage: (_: string) => void,
  createToken: CreateToken,
  setToken: SetToken,
  afterLogin: AfterLogin
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
    .then((token) =>
      setToken(token)
        .then(() => afterLogin(token))
        .catch((err) => setErrorMessage(strings.loginError)))
    .catch((err) => setErrorMessage(strings.invalidLogin))
}

type AuthenticatedProps = {
  setToken: SetToken
  createToken: CreateToken
  clearToken: ClearToken
  getToken: GetToken
  children: AuthenticatedChild
}

export default function Authenticated(props: AuthenticatedProps) {
  const [loadingToken, setLoadingToken] = useState(true)
  const [sessionToken, setSessionToken] = useState<string | null>(null)

  const onLogout = () =>
    logout(
      props.clearToken,
      setSessionToken,
    )

  useEffect(() => {
    props.getToken().then((token) => {
      if (token && typeof token === "string") {
        setSessionToken(token)
      }

      setLoadingToken(false)
    }).catch(() => setLoadingToken(false))
  })

  if (loadingToken) {
    return (
      <AppView>
        <Text>loading...</Text>
      </AppView>
    )
  } else if (!sessionToken) {
    return <LoginForm setToken={props.setToken} createToken={props.createToken} afterLogin={setSessionToken} />
  } else {
    return props.children(sessionToken, onLogout)
  }
}

export type LoginFormProps = {
  setToken: SetToken
  createToken: CreateToken
  afterLogin: AfterLogin
}

function LoginForm(props: LoginFormProps) {
  const [email, setEmail] = useState("")
  const [password, setPassword] = useState("")
  const [errorMessage, setErrorMessage] = useState("")

  const onLogin = () =>
    login(
      email,
      password,
      setErrorMessage,
      props.createToken,
      props.setToken,
      props.afterLogin,
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
      <Button label={strings.login} onPress={onLogin} />
    </FormField>
  </AppView>
}
