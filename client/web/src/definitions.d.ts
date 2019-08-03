export type Book = {
  guid: string
  name: string
  grouping: number
}

export type BooksRetrieveResponse = {
  books: Book[]
}

export type Entry = {
  guid: string
  text: string
  createdAt: string
  updatedAt: string
  data?: { [index: string]: string }
}

export type EntriesRetrieveResponse = {
  entries: Entry[]
}

export type EntryCreateRequest = {
  guid: string
  text: string
  createdAt: string
  bookGuid: string
}

export type EntryCreateResponse = {
  guid: string
  entry: Entry
}
