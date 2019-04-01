import axios from "axios"

import { Entry, EntryCreateRequest, EntryCreateResponse } from "../definitions/entry"

export const retrieveEntriesForBook = (bookGuid: string): Promise<Entry[]> =>
  axios.get(`/api/entry?book=${bookGuid}`).then((res) => res.data.entries)

export const createEntry = (entry: EntryCreateRequest): Promise<EntryCreateResponse> =>
  axios.post(`/api/entry`, entry).then((res) => res.data)
