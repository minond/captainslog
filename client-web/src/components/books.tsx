import * as React from "react"
import { Component } from "react"

import { css, StyleSheet } from "aphrodite"

import { Book } from "../definitions/book"
import { getBooks } from "../service/book"

import { Entries } from "./entries"

const styles = StyleSheet.create({
  book: {
    marginBottom: "10px"
  },

  wrapper: {
    padding: "30px"
  }
})

interface State {
  loaded: boolean
  books: Book[]
  viewing?: string
}

export class Books extends Component<{}, State> {
  constructor(props: {}) {
    super(props)

    this.state = {
      books: [],
      loaded: false,
    }
  }

  componentWillMount() {
    getBooks().then((books) =>
      // XXX remove viewing hardcoded test
      this.setState({ viewing: books[0].guid, loaded: true, books }))
  }

  viewBook(viewing: string) {
    this.setState({ viewing })
  }

  render() {
    const { loaded, books, viewing } = this.state

    if (!loaded) {
      return null
    }

    const booksElem = books.map((book) => {
      const header = (
        <h1 className={css(styles.book)} onClick={(ev) => this.viewBook(book.guid)}>
          {book.name}
        </h1>
      )

      if (viewing !== book.guid) {
        return <div key={book.guid}>{header}</div>
      }

      return (
        <div key={book.guid}>
          {header}
          <Entries guid={book.guid} />
        </div>
      )
    })

    return <div className={css(styles.wrapper)}>{booksElem}</div>
  }
}