import * as React from "react"
import { Component } from "react"
import { Link } from "react-router-dom"

import { css, StyleSheet } from "aphrodite"

import { Book } from "../definitions/book"

const styles = StyleSheet.create({
  book: {
    marginBottom: "10px"
  }
})

type Props = Pick<Book, "guid" | "name">

export default function BookTitle(props: Props) {
  return (
    <h1 className={css(styles.book)} key={props.guid}>
      <Link to={`/book/${props.guid}`}>
        {props.name}
      </Link>
    </h1>
  )
}
