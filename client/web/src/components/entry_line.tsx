import * as React from "react"
import { HTMLAttributes } from "react"

import { css, StyleSheet } from "aphrodite"

import { accentColor, mediumText, normalText } from "../styles"

const styles = StyleSheet.create({
  item: {
    ...mediumText,
    border: `1px solid ${accentColor}`,
    display: "inline-block",
    margin: "2px 0px 2px 4px",
    padding: "3px 6px",
    whiteSpace: "nowrap",
  },

  data: {
    display: "inline-block",
    textAlign: "right",
    width: "65%",
  },

  text: {
    display: "inline-block",
    lineHeight: 2,
    width: "35%",
  },

  entry: {
    ...normalText,
    display: "flex",
    padding: "5px 0",
  }
})

interface Props {
  text: string
  data?: { [index: string]: string }
}

const mmap = <V, R>(xs: { [index: string]: V }, fn: (k: string, v: V, i: number) => R) =>
  Object.keys(xs).map((k, i) => fn(k, xs[k], i))

export default function EntryLine(props: Props & HTMLAttributes<HTMLDivElement>) {
  const className = css(styles.entry) + " " + props.className

  const datalist = !props.data ? null : mmap(props.data, (key, val, i) =>
    <span key={i} className={css(styles.item)}>{key}: {val}</span>)

  return (
    <div className={className}>
      <div className={css(styles.text)}>{props.text}</div>
      <div className={css(styles.data)}>{datalist}</div>
    </div>
  )
}
