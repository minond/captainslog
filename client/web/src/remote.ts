import axios from "axios"

import {
  Book,
  BooksRetrieveResponse,
  EntriesCreateRequest,
  EntriesCreateResponse,
  EntriesRetrieveResponse,
  Entry,
  EntryCreateRequest,
  EntryCreateResponse,
  QueryExecuteRequest,
  QueryResults,
} from "./definitions"

enum uris {
  books   = "/api/books",
  entries = "/api/entries",
  query   = "/api/query",
}

export const getBook = (guid: string): Promise<Book | null> =>
  axios.get<BooksRetrieveResponse>(`${uris.books}?guid=${guid}`)
    .then((res) => (res.data.books || [])[0])

export const getBooks = (): Promise<Book[]> =>
  axios.get<BooksRetrieveResponse>(uris.books)
    .then((res) => res.data.books)

export const getEntriesForBook = (bookGuid: string, at: Date): Promise<Entry[]> =>
  axios.get<EntriesRetrieveResponse>(`${uris.entries}?book=${bookGuid}&at=${Math.floor(+at / 1000)}`)
    .then((res) => res.data.entries || [])

// FIXME This is a hack to get aroung the lack of a real "create entries"
// endpoint. Once it's created make sure to use it here.
export const createEntries = (req: EntriesCreateRequest): Promise<EntriesCreateResponse> =>
  req.entries.splice(1).reduce((prev, curr) =>
    prev.then(() => createEntry(curr)), createEntry(req.entries[0]))
    .then(() => ({ ok: true }))

export const createEntry = (entry: EntryCreateRequest): Promise<EntryCreateResponse> =>
  axios.post<EntryCreateResponse>(uris.entries, entry)
    .then((res) => res.data)

export const executeQuery = (query: string): Promise<QueryResults> =>
  axios.post<QueryResults>(uris.query, { query } as QueryExecuteRequest)
    .then((res) => res.data)

const ttls = {
  [executeQuery.toString()]: 100,
  [getBook.toString()]: 5000,
  [getBooks.toString()]: 5000,
  [getEntriesForBook.toString()]: 500,
}

const ttlFor = <T extends Function>(fn: T) =>
  fn.toString() in ttls ? ttls[fn.toString()] : 100

type CachePouch<T> = { [index: string]: CacheEntry<T> }
type CacheEntry<T> = { ttd: number, val: T }

type ArgTy<T> = T extends (...a: infer A) => any ? A : never
type RetTy<T> = T extends (...a: any[]) => infer R ? R : never
type PromiseOf<T> = T extends Promise<infer V> ? V : T

export const cached = <T extends Function>(fn: T, ttl: number = ttlFor(fn)) => {
  type Value = PromiseOf<RetTy<T>>
  let cache: CachePouch<Value> = {}

  return (...args: ArgTy<T>): Promise<Value> => {
    let key = args.join("-")
    let entry = cache[key] = cache[key] || {
      ttd: 0,
      val: null,
    }

    if (entry.ttd >= Date.now()) {
      return new Promise((resolve, reject) => resolve(entry.val))
    }

    delete entry.val
    entry.ttd = Date.now() + ttl

    return fn(...args).then((res: Value) => {
      entry.val = res
      return res
    })
  }
}

export const cachedExecuteQuery = cached(executeQuery)
export const cachedGetBook = cached(getBook)
export const cachedGetBooks = cached(getBooks)
export const cachedGetEntriesForBook = cached(getEntriesForBook)
