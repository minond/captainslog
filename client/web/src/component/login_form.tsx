import * as React from "react"

export const LoginForm = () =>
  <form method="post" action="/" className="login-form">
    <div className="login-form-wrapper">
      <input placeholder="Email" name="email" />
      <input placeholder="Password" name="password" type="password" />
      <button>Login</button>
    </div>
  </form>
