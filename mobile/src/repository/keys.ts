export const TOKEN = genKey("token")

function genKey(label: string): string {
  return `CaptainsLog.${label}`
}
