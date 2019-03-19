import * as React from "react"

import { css, StyleSheet } from "aphrodite"

const styles = StyleSheet.create({
  wrapper: {
    boxSizing: "border-box",
    height: "100vh",
    margin: "0 auto",
    maxWidth: "720px",
    padding: "10px",
    position: "relative",
  },

  input: {
    bottom: "10px",
    padding: "10px",
    position: "absolute",
    width: "100%",
  }
})

interface Props {
  name: string
}

export const Logbook = (props: Props) =>
  <div className={css(styles.wrapper)}>
    <h1>{props.name}</h1>
    <input className={css(styles.input)} type="text" />
  </div>
