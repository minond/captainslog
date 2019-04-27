import * as React from "react"
import { Component } from "react"
import { Link } from "react-router-dom"

import { css, StyleSheet } from "aphrodite"

import { Book } from "../definitions/book"

import { largeText, link, mainTextColor } from "../styles"

const styles = StyleSheet.create({
  book: {
    ...largeText,
    borderBottom: "1px solid transparent",
    display: "inline-block",
    margin: "0 10px 10px 0",
    transition: "border-color .2s",

    ":hover": {
      borderBottom: "1px solid black",
    }
  }
})

type Props = Pick<Book, "guid" | "name">

export default function BookTitle(props: Props) {
  return (
    <Link key={props.guid} to={`/book/${props.guid}`} style={link}>
      <div className={css(styles.book)}>
        {props.name}
      </div>
    </Link>
  )
}
