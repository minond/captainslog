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
  data?: QueryResult[][]
}

export type QueryResult = {
  Bool?: boolean
  Float64?: number
  Int64?: number
  String?: string
  Valid: boolean
}

export type SavedQuery = {
  guid: string
  label: string
  content: string
}

export type SavedQueriesRetrieveResponse = {
  queries: SavedQuery[]
}

export type SavedQueryRequest = Pick<SavedQuery, "label" | "content">

export enum SchemaFieldType {
  String,
  Number,
  Boolean,
}

export type SchemaField = {
  name: string
  type: SchemaFieldType
}

export type SchemaBook = {
  name: string
  fields: SchemaField[]
}

export type Schema = {
  books: SchemaBook[]
}