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
  data?: { [index: string]: string }
}

export type EntriesRetrieveResponse = {
  entries: Entry[]
}

export type EntryUnsaved = {
  text: string
  createdAt: string
}

export type EntriesCreateRequest = {
  bookGuid: string
  offset: number
  entries: EntryUnsaved[]
}

export type EntriesCreateResponse = {
  entries: Entry[]
}

export type QueryExecuteRequest = {
  query: string
}

export type QueryResults = {
  columns: string[]
  results: QueryResult[][] | null
}

export type QueryResult = {
  Bool?: boolean
  Float64?: number
  Int64?: number
  String?: string
  Time?: Date
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
  books: SchemaBook[] | null
}

export type ReportsRetrieveResponse = {
  reports: Report[]
}

export type Report = {
  label: string
  outputs: Output[]
  variables: Variable[]
}

export type Variable = {
  id: string
  label: string
  query: string
  defaultValue?: string
  options?: string[]
}

export enum OutputKind {
  InvalidOutput = -1,
  TableOutput = "table",
  ChartOutput = "chart",
  ValueOutput = "value",
}

export type Output = {
  id: string
  label: string
  kind: OutputKind
  query: string
  width: string
  reload?: boolean
  loading?: boolean
  results?: QueryResults
}

export type Input = {
  variable: Variable
  value: string
  changeHandled?: boolean
}
