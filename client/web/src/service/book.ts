import axios from "axios"

import { Book } from "../definitions/book"

export const getBook = (guid: string): Promise<Book> =>
  axios.get(`/api/books?guid=${guid}`).then((res) => res.data.books[0])

export const getBooks = (): Promise<Book[]> =>
  axios.get("/api/books").then((res) => res.data.books)
