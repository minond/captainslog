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

const urlFor = (resource: resource): string =>
  Base + Endpoint[resource]

export function jsonPost(resource: resource, content: {}) {
  const url = urlFor(resource)
  const method = "POST"
  const body = JSON.stringify(content)
  const headers = {
    [Header.Accept]: MimeType.Json,
    [Header.ContentType]: MimeType.Json,
  }

  return fetch(url, { method, body, headers })
}
