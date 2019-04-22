import * as React from "react"
import { Component } from "react"
import { Link } from "react-router-dom"

import { css, StyleSheet } from "aphrodite"

import { Book } from "../definitions/book"
import { getBooks } from "../service/book"

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
      this.setState({ loaded: true, books }))
  }

  render() {
    const { books } = this.state

    const booksElem = books.map((book) => (
      <h1 className={css(styles.book)} key={book.guid}>
        <Link to={`/book/${book.guid}`}>
          {book.name}
        </Link>
      </h1>
    ))

    return <div className={css(styles.wrapper)}>{booksElem}</div>
  }
}
