export type endpoint = "token" | "books"
const BASE = "https://logs.minond.xyz"
// const BASE = "http://192.168.1.6:3000"
const API: { [x in endpoint]: string } = {
  token: "/api/v1/token",
  books: "/api/v1/books",
}

const url = (ep: endpoint): string =>
  BASE + API[ep]

export async function createToken(email: string, password: string): Promise<string> {
  const response = await fetch(url("token"), {
    method: "POST",
    body: JSON.stringify({ email, password }),
    headers: {
      Accept: "application/json",
      "Content-Type": "application/json",
    },
  })

  if (!response) {
    throw new Error("empty response")
  }

  const body = await response.json()

  if (!body.token) {
    throw new Error("bad response")
  }

  return body.token
}
