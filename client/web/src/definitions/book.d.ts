export type Book = {
  guid: string
  name: string
  grouping: number
}

export type BooksRetrieveResponse = {
  books: Book[]
}
