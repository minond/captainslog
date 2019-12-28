import history from "./history"

type Config = { token: string }

declare var config: Config

declare global {
  interface Window {
    config: Config
  }
}

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

if (!window.config || !config.token) {
  window.config = window.config || {}
  window.config.token = localStorage.getItem("token") || ""
}

if (getUrlToken()) {
  localStorage.setItem("token", getUrlToken())
  history.replace("/")
} else if (getConfigToken()) {
  localStorage.setItem("token", getConfigToken())
}
