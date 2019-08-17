import * as React from "react"
import { useState, useEffect } from "react"
import { Link } from "react-router-dom"

import { Book } from "../definitions"
import { cachedGetBooks } from "../remote"

type BooksProps = {
  active?: string
}

export const Books = (props: BooksProps) => {
  const [books, setBooks] = useState<Book[]>([])

  useEffect(() => {
    cachedGetBooks().then(setBooks)
  }, [])

  const links = books.map((book) =>
    <Link
      key={book.guid}
      to={`/${book.guid}`}
      className={props.active === book.guid ? "active" : ""}
    >{book.name}</Link>)

  return <>{links}</>
}
