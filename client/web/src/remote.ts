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

const ttls = {
  [getBook.toString()]: 5000,
  [getBooks.toString()]: 5000,
  [getEntriesForBook.toString()]: 500,
}

const ttlFor = <T extends Function>(fn: T) =>
  fn.toString() in ttls ? ttls[fn.toString()] : 100

type ArgTy<T> = T extends (...a: infer A) => any ? A : never
type CachePouch<T> = { [index: string]: CacheEntry<T> }
type CacheEntry<T> = { ttd: number, val: T, pro: boolean }

export const cached = <T extends Function>(fn: T, ttl: number = ttlFor(fn)) => {
  // NOTE Not thread safe but that's ok
  // TODO find a way to extract T from ReturnType<Promise<T>> and replace the
  // `any` used here.
  let cache: CachePouch<any> = {}

  return (...args: ArgTy<T>) => {
    let key = args.join("-")
    let entry = cache[key] = cache[key] || {
      ttd: 0,
      val: null,
      pro: false,
    }

    if (entry.ttd >= Date.now()) {
      if (entry.pro) {
        return new Promise((resolve, reject) => resolve(entry.val))
      }

      return entry.val
    }

    delete entry.val
    entry.ttd = Date.now() + ttl
    entry.pro = false

    let val = fn(...args)
    if (val instanceof Promise) {
      entry.pro = true
      val.then((res) => {
        entry.val = res
        return res
      })
    } else {
      entry.val = val
    }

    return val
  }
}

export const cachedGetBook = cached(getBook)
export const cachedGetBooks = cached(getBooks)
export const cachedGetEntriesForBook = cached(getEntriesForBook)
