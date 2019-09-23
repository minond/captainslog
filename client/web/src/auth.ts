declare var config: { token: string }

export const isLoggedIn = () =>
  'config' in window && config && !!config.token

export const getAuthToken = () =>
  config.token || ""

if (isLoggedIn()) {
  localStorage.setItem("token", getAuthToken())
} else {
  config = config || {}
  config.token = localStorage.getItem("token") || ""
}
