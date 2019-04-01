import * as React from "react"
import { HTMLAttributes } from "react"

import { css, StyleSheet } from "aphrodite"

const styles = StyleSheet.create({
  item: {
    fontSize: ".85rem",
    marginLeft: "6px",
    border: "1px solid #0D28F2",
    padding: "2px 6px"
  },

  data: {
    float: "right"
  },

  entry: {
    fontSize: "1.1rem",
    padding: "16px 0"
  }
})

interface Props {
  text: string
  data?: { [index: string]: string }
}

const mmap = <V, R>(xs: { [index: string]: V }, fn: (k: string, v: V, i: number) => R) =>
  Object.keys(xs).map((k, i) => fn(k, xs[k], i))

export const Entry = (props: Props & HTMLAttributes<HTMLDivElement>) => {
  const className = css(styles.entry) + " " + props.className

  const datalist = !props.data ? null : mmap(props.data, (key, val, i) =>
    <span key={i} className={css(styles.item)}>{key}: {val}</span>)

  return (
    <div className={className}>
      <span>{props.text}</span>
      <span className={css(styles.data)}>{datalist}</span>
    </div>
  )
}
