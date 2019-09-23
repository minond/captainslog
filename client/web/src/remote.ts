import axios from "axios"

import {
  Book,
  BooksRetrieveResponse,
  EntriesCreateRequest,
  EntriesCreateResponse,
  EntriesRetrieveResponse,
  Entry,
  EntryUnsaved,
  QueryExecuteRequest,
  QueryResults,
  Report,
  ReportsRetrieveResponse,
  SavedQueriesRetrieveResponse,
  SavedQuery,
  SavedQueryRequest,
  Schema,
} from "./definitions"

enum uris {
  books      = "/api/books",
  entries    = "/api/entries",
  query      = "/api/query",
  reports    = "/api/reports",
  savedQuery = "/api/saved_query",
}

declare var config: { token: string }
export const isLoggedIn = () =>
  'config' in window && config && !!config.token

const offset = () =>
  new Date().getTimezoneOffset() * -1

const authenticated = axios.create({ baseURL: '/' })
if (isLoggedIn()) {
  authenticated.defaults.headers.common['Authorization'] = `Bearer ${config.token}`
}

export const getBook = (guid: string): Promise<Book | null> =>
  authenticated.get<BooksRetrieveResponse>(`${uris.books}?guid=${guid}`)
    .then((res) => (res.data.books || [])[0])

export const getBooks = (): Promise<Book[]> =>
  authenticated.get<BooksRetrieveResponse>(uris.books)
    .then((res) => res.data.books || [])

export const getEntriesForBook = (bookGuid: string, at: Date): Promise<Entry[]> =>
  authenticated.get<EntriesRetrieveResponse>(`${uris.entries}?book=${bookGuid}&at=${Math.floor(+at / 1000)}&offset=${offset()}`)
    .then((res) => res.data.entries || [])

export const createEntries = (bookGuid: string, entries: EntryUnsaved[]): Promise<EntriesCreateResponse> =>
  authenticated.post<EntriesCreateResponse>(uris.entries, { offset: offset(), bookGuid, entries })
    .then((res) => res.data)

export const executeQuery = (query: string): Promise<QueryResults> =>
  authenticated.post<QueryResults>(uris.query, { query } as QueryExecuteRequest)
    .then((res) => res.data)

export const createSavedQuery = (entry: SavedQueryRequest): Promise<SavedQuery> =>
  authenticated.post<SavedQuery>(uris.savedQuery, entry)
    .then((res) => res.data)

export const updateSavedQuery = (entry: SavedQuery): Promise<SavedQuery> =>
  authenticated.put<SavedQuery>(uris.savedQuery, entry)
    .then((res) => res.data)

export const getSavedQueries = (): Promise<SavedQuery[]> =>
  authenticated.get<SavedQueriesRetrieveResponse>(uris.savedQuery)
    .then((res) => res.data.queries || [])

export const getSchema = (): Promise<Schema> =>
  authenticated.get<Schema>(uris.query)
    .then((res) => res.data)

export const getReport = (guid: string): Promise<Report | null> =>
  authenticated.get<ReportsRetrieveResponse>(`${uris.reports}?guid=${guid}`)
    .then((res) => (res.data.reports || [])[0])

export const getReports = (): Promise<Report[]> =>
  authenticated.get<ReportsRetrieveResponse>(uris.reports)
    .then((res) => res.data.reports || [])

const ttls = {
  [executeQuery.toString()]: 100,
  [getBook.toString()]: 5000,
  [getBooks.toString()]: 5000,
  [getEntriesForBook.toString()]: 500,
  [getReport.toString()]: 60000,
  [getReports.toString()]: 60000,
  [getSavedQueries.toString()]: 1000,
}

const ttlFor = <T extends Function>(fn: T) =>
  fn.toString() in ttls ? ttls[fn.toString()] : 100

type CachePouch<T> = { [index: string]: CacheEntry<T> }
type CacheEntry<T> = { ttd: number, wip: Promise<T>; val: T }

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

    if (!entry.wip && entry.ttd >= Date.now()) {
      return new Promise((resolve, reject) => resolve(entry.val))
    } else if (entry.wip) {
      return entry.wip
    }

    delete entry.val
    entry.ttd = Date.now() + ttl
    entry.wip = fn(...args)

    entry.wip.then((res: Value) => {
      delete entry.wip
      entry.val = res
      return res
    })

    return entry.wip
  }
}

export const cachedExecuteQuery = cached(executeQuery)
export const cachedGetBook = cached(getBook)
export const cachedGetBooks = cached(getBooks)
export const cachedGetEntriesForBook = cached(getEntriesForBook)
export const cachedGetReport = cached(getReport)
export const cachedGetReports = cached(getReports)
export const cachedGetSavedQueries = cached(getSavedQueries)
export const cachedGetSchema = cached(getSchema)
