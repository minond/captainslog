import React, { FunctionComponent } from "react"
import { Text } from "react-native"

import styles from "../styles"

const Header: FunctionComponent<{}> = (props) =>
    <Text style={styles.header}>{props.children}</Text>

export default Header
