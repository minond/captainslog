import * as React from "react"
import { Component } from "react"
import { Link } from "react-router-dom"

import BookTitle from "./book_title"

import { Book } from "../definitions/book"
import { getBooks } from "../service/book"

interface State {
  loaded: boolean
  books: Book[]
}

export default class Books extends Component<{}, State> {
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
    return <div>{books.map(BookTitle)}</div>
  }
}
