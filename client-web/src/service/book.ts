import axios from "axios"

import { Book } from "../definitions/book"

export const getBooks = (): Promise<Book[]> =>
  axios.get("/api/book").then((res) => res.data.books)
