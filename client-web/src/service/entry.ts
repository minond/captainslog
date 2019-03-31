import axios from "axios"

import { Entry } from "../definitions/entry"

export const getEntriesForBook = (book_guid: string): Promise<Entry[]> =>
  axios.get(`/api/entry?book_guid=${book_guid}`).then((res) => res.data.entries)
