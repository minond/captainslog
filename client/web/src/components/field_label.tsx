import * as React from "react"
import { PureComponent } from "react"

import { css, StyleSheet } from "aphrodite"

import { labelTextColor, normalText } from "../styles"

const styles = StyleSheet.create({
  label: {
    ...normalText,
    ...labelTextColor,
    fontStyle: "italic",
    marginBottom: "4px",
  }
})

type Props = {
  text: string
}

export default class FieldLabel extends PureComponent<Props> {
  render() {
    return (
      <span>
        <label>
          <div className={css(styles.label)}>{this.props.text}</div>
          {this.props.children}
        </label>
      </span>
    )
  }
}
