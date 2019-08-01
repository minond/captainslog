import axios from "axios"

import {
  Book,
  BooksRetrieveResponse,
} from "./definitions/book"

import {
  EntriesRetrieveResponse,
  Entry,
  EntryCreateRequest,
  EntryCreateResponse,
} from "./definitions/entry"

enum uris {
  books = "/api/books",
  entries = "/api/entries",
}

export const getBook = (guid: string): Promise<Book | null> =>
  axios.get<BooksRetrieveResponse>(`${uris.books}?guid=${guid}`)
    .then((res) => (res.data.books || [])[0])

export const getBooks = (): Promise<Book[]> =>
  axios.get<BooksRetrieveResponse>(uris.books)
    .then((res) => res.data.books)

export const getEntriesForBook = (bookGuid: string, at: Date): Promise<Entry[]> =>
  axios.get<EntriesRetrieveResponse>(`${uris.entries}?book=${bookGuid}&at=${Math.floor(+at / 1000)}`)
    .then((res) => res.data.entries)

export const createEntry = (entry: EntryCreateRequest): Promise<EntryCreateResponse> =>
  axios.post<EntryCreateResponse>(uris.entries, entry)
    .then((res) => res.data)
