import * as React from "react"
import { Component } from "react"

import { css, StyleSheet } from "aphrodite"

import { Entries } from "./Entries"
import { Book } from "../definitions/book"
import { getBooks } from "../service/book"

const styles = StyleSheet.create({
  book: {
    marginBottom: "10px",
  }
})

interface Props {}

interface State {
  loaded: boolean
  books: Book[]
  viewing?: string
}

export class Books extends Component<Props, State> {
  constructor(props: Props) {
    super(props)

    this.state = {
      loaded: false,
      books: [],
    }
  }

  componentWillMount() {
    getBooks().then((books) =>
      this.setState({ loaded: true, books }))
  }

  viewBook(viewing: string) {
    this.setState({ viewing })
  }

  render() {
    const { loaded, books, viewing } = this.state

    if (!loaded) {
      return <h1>Loading...</h1>
    }

    return (
      <div>
        {books.map((book) => {
          let header = (
            <h1
              className={css(styles.book)}
              onClick={(ev) => this.viewBook(book.guid)}
            >{book.name}</h1>
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
        })}
      </div>
    )
  }
}
