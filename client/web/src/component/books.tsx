import * as React from "react"
import { useEffect, useState } from "react"
import { Link } from "react-router-dom"

import { Book } from "../definitions"
import { cachedGetBooks } from "../remote"

type BooksProps = {
  active?: string
}

let memBooks: Book[] = []

export const Books = (props: BooksProps) => {
  const [books, setBooks] = useState<Book[]>(memBooks)

  useEffect(() => {
    cachedGetBooks().then((allBooks) => {
      memBooks = allBooks
      setBooks(allBooks)
    })
  }, [])

  const links = books.map((book) =>
    <Link
      key={book.guid}
      to={`/${book.guid}`}
      className={props.active === book.guid ? "active" : ""}
    >
      {book.name}
    </Link>)

  return <>{links}</>
}
