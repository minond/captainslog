import * as SecureStore from "expo-secure-store"

import { TOKEN } from "./keys"
import { jsonPost } from "./network"

export type SetToken = (token: string) => Promise<void>
export type GetToken = () => Promise<string | null>
export type ClearToken = () => Promise<void>
export type CreateToken = (email: string, password: string) => Promise<string>

export const setToken: SetToken = (token) =>
  SecureStore.setItemAsync(TOKEN, token)

export const getToken: GetToken = () =>
  SecureStore.getItemAsync(TOKEN)

export const clearToken: ClearToken = () =>
  SecureStore.deleteItemAsync(TOKEN)

var _: CreateToken = createToken
export async function createToken(email: string, password: string): Promise<string> {
  const response = await jsonPost("token", { email, password })
  if (!response) {
    throw new Error("empty response")
  }

  const body = await response.json()
  if (!body.token) {
    throw new Error("bad response")
  }

  return body.token
}
