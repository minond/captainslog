import history from "./history"

declare var config: { token: string }

export const logout = () => {
  localStorage.setItem("token", "")
  history.replace("/")
  window.location.reload()
}

export const isLoggedIn = () =>
  'config' in window && config && !!config.token

export const getAuthToken = () =>
  config.token

const getConfigToken = () =>
  config.token || ""

const getUrlToken = () =>
  (window.location.search.match(/key=(.+)/) || [])[1]

if (getUrlToken()) {
  localStorage.setItem("token", getUrlToken())
  history.replace("/")
} else if (getConfigToken()) {
  localStorage.setItem("token", getConfigToken())
}

if (!config || !config.token) {
  config = config || {}
  config.token = localStorage.getItem("token") || ""
}
