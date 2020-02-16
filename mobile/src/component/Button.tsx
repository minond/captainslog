import React from "react"
import { Text, TouchableHighlight } from "react-native"

import styles from "../styles"

const Button = (props: { label: string, onPress: () => void }) =>
  <TouchableHighlight style={styles.button} onPress={props.onPress}>
    <Text>{props.label}</Text>
  </TouchableHighlight>

export default Button
