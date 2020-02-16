import React from "react"

import {
  FunctionComponent,
  useState,
} from "react"

import {
  ScrollView,
  Text,
  TextInput,
  TouchableHighlight,
  View,
} from "react-native"

import { createToken } from "./network"
import styles from "./styles"
import strings from "./strings"

export default function App() {
  return (
    <View style={styles.containerWrapper}>
      <LoginForm />
    </View>
  )
}

const AppView: FunctionComponent<{}> = (props) =>
  <View style={styles.scrollViewWrapper}>
    <ScrollView>
      <View style={styles.viewWrapper}>
        {props.children}
      </View>
    </ScrollView>
  </View>

const LoginForm = () => {
  const [email, setEmail] = useState("")
  const [password, setPassword] = useState("")
  const [errorMessage, setErrorMessage] = useState("")

  const login = () => {
    setErrorMessage("")

    if (!email && !password) {
      setErrorMessage(strings.missingValues(strings.email, strings.password))
    } else if (!email) {
      setErrorMessage(strings.missingValues(strings.email))
    } else if (!password) {
      setErrorMessage(strings.missingValues(strings.password))
    } else {
      createToken(email, password)
        .then((token) => console.log("token:", token))
        .catch((err) => {
          console.log("login error:", err)
          setErrorMessage(strings.invalidLogin)
        })
    }
  }

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
      <Button label={strings.login} onPress={login} />
    </FormField>
  </AppView>
}

const FormField: FunctionComponent<{}> = (props) =>
  <View style={styles.formField}>{props.children}</View>

const Button = (props: { label: string, onPress: () => void }) =>
  <TouchableHighlight style={styles.button} onPress={props.onPress}>
    <Text>{props.label}</Text>
  </TouchableHighlight>

const Header: FunctionComponent<{}> = (props) =>
    <Text style={styles.header}>{props.children}</Text>
