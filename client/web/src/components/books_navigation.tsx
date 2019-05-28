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

interface Props {
  active?: string
}

export default class BooksNavigation extends Component<Props, State> {
  constructor(props: Props) {
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
    const { active } = this.props
    const links = books.map((book) =>
      <Link key={book.guid} to={`/${book.guid}`} style={link}>
        <BookTitle name={book.name} active={book.guid === active} />
      </Link>)

    return <div>{links}</div>
  }
}
