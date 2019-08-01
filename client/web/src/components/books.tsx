import * as React from "react"
import { useState } from "react"
import { Link } from "react-router-dom"

import { Book } from "../definitions/book"
import { getBooks } from "../remote"

interface State {
  loaded: boolean
  books: Book[]
}

export default function Books(props: {}) {
  const [books, setBooks] = useState<Book[]>([])
  const [loaded, setLoaded] = useState(false)

  if (!loaded) {
    getBooks().then((res) => {
      setBooks(res)
      setLoaded(true)
    })
  }

  const links = books.map((book) =>
    <Link key={book.guid} to={`/${book.guid}`}>
      <div>{book.name}</div>
    </Link>)

  return <div>{links}</div>
}
