import * as React from "react"
import { useState } from "react"
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

export default function BooksNavigation(props: Props) {
  const [books, setBooks] = useState<Book[]>([])
  const [loaded, setLoaded] = useState(false)

  if (!loaded) {
    getBooks().then((res) => {
      setBooks(res)
      setLoaded(true)
    })
  }

  const { active } = props
  const links = books.map((book) =>
    <Link key={book.guid} to={`/${book.guid}`} style={link}>
      <BookTitle name={book.name} active={book.guid === active} />
    </Link>)

  return <div>{links}</div>
}
