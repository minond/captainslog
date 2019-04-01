import axios from "axios"

import { Entry } from "../definitions/entry"

export const getEntriesForBook = (bookGuid: string): Promise<Entry[]> =>
  axios.get(`/api/entry?book=${bookGuid}`).then((res) => res.data.entries)
