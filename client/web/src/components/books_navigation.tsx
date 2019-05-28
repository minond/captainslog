import * as React from "react"
import { Component } from "react"
import { Link } from "react-router-dom"

import BookTitle from "./book_title"

import { Book } from "../definitions/book"
import { getBooks } from "../remote"

import { link } from "../styles"

interface State {
  loaded: boolean
  books: Book[]
}

export default class BooksNavigation extends Component<{}, State> {
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
    const links = books.map((book) =>
      <Link key={book.guid} to={`/${book.guid}`} style={link}>
        <BookTitle name={book.name} />
      </Link>)

    return <div>{links}</div>
  }
}
