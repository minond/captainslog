enum Header {
  Accept = "Accept",
  ContentType = "Content-Type"
}

enum MimeType {
  Json = "application/json"
}

type resource = "token" | "books"
type endpointValues = { [item in resource]: string }
const Base = "https://logs.minond.xyz"
const Endpoint: endpointValues = {
  token: "/api/v1/token",
  books: "/api/v1/books",
}

const urlFor = (r: resource): string =>
  Base + Endpoint[r]

export function jsonPost(r: resource, content: {}) {
  const url = urlFor(r)
  const method = "POST"
  const body = JSON.stringify(content)
  const headers = {
    [Header.Accept]: MimeType.Json,
    [Header.ContentType]: MimeType.Json,
  }

  return fetch(url, { method, body, headers })
}
