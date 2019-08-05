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

export type EntriesCreateRequest = {
  entries: EntryCreateRequest[]
}

export type EntriesCreateResponse = {
  ok: boolean
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

export type QueryExecuteRequest = {
  query: string
}

export type QueryResults = {
  cols: string[]
  data: QueryResult[][]
}

export type QueryResult = {
  Valid: boolean
  String?: string
  Int64?: number
  Float64?: number
}
