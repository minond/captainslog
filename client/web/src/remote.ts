import axios from "axios"

import { Book } from "./definitions/book"
import { Entry, EntryCreateRequest, EntryCreateResponse } from "./definitions/entry"

export const getBook = (guid: string): Promise<Book> =>
  axios.get(`/api/books?guid=${guid}`).then((res) => res.data.books[0])

export const getBooks = (): Promise<Book[]> =>
  axios.get("/api/books").then((res) => res.data.books)

export const getEntriesForBook = (bookGuid: string, at: number): Promise<Entry[]> =>
  axios.get(`/api/entries?book=${bookGuid}&at=${at}`).then((res) => res.data.entries)

export const createEntry = (entry: EntryCreateRequest): Promise<EntryCreateResponse> =>
  axios.post(`/api/entries`, entry).then((res) => res.data)
