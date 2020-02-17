const enUS = {
  login: "Login",
  email: "Email",
  password: "Password",

  invalidLogin: "Invalid login.",
  loginError: "There was an error while trying to login in, please try again later.",
  missingValues: (...vals: string[]) => `Missing required values: ${vals.join(", ")}.`,
}

export default enUS
