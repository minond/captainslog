import * as React from "react"
import { Component } from "react"
import { Link } from "react-router-dom"

import { css, StyleSheet } from "aphrodite"

import { largerText, mainTextColor } from "../styles"

const styles = StyleSheet.create({
  active: {
    borderBottom: "1px solid #00449e",
    color: "#00449e",
  },

  book: {
    ...largerText,
    borderBottom: "1px solid transparent",
    color: "#357edd",
    display: "inline-block",
    margin: "0 10px 10px 0",
    outline: "none",
    transition: "color .2s",

    ":hover": {
      borderBottom: "1px solid #00449e",
      color: "#00449e",
    }
  },
})

interface Props {
  name: string
  active?: boolean
}

export default function BookTitle(props: Props) {
  return (
    <div className={css(styles.book, props.active ? styles.active : styles.book)}>
      {props.name}
    </div>
  )
}
