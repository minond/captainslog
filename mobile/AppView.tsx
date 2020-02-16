import React, { FunctionComponent } from "react"
import { ScrollView, View } from "react-native"

import styles from "./styles"

const AppView: FunctionComponent<{}> = (props) =>
  <View style={styles.scrollViewWrapper}>
    <ScrollView>
      <View style={styles.viewWrapper}>
        {props.children}
      </View>
    </ScrollView>
  </View>

export default AppView
