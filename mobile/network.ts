enum Header {
  Accept = "Accept",
  ContentType = "ContentType",
}

enum MimeType {
  Json = "application/json"
}

type endpoint = "token" | "books"
type endpointValues = { [x in endpoint]: string }
const Base = "https://logs.minond.xyz"
const Endpoint: endpointValues = {
  token: "/api/v1/token",
  books: "/api/v1/books",
}

const urlFor = (ep: endpoint): string =>
  Base + Endpoint[ep]

function jsonPost(url: string, content: {}) {
  const method = "POST"
  const body = JSON.stringify(content)
  const headers = {
    [Header.Accept]: MimeType.Json,
    [Header.ContentType]: MimeType.Json,
  }

  return fetch(url, { method, body, headers })
}

export async function createToken(email: string, password: string): Promise<string> {
  const response = await jsonPost(urlFor("token"), { email, password })
  if (!response) {
    throw new Error("empty response")
  }

  const body = await response.json()
  if (!body.token) {
    throw new Error("bad response")
  }

  return body.token
}
