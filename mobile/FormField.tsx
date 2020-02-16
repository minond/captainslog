import React, { FunctionComponent } from "react"
import { View } from "react-native"

import styles from "./styles"

const FormField: FunctionComponent<{}> = (props) =>
  <View style={styles.formField}>{props.children}</View>

export default FormField
