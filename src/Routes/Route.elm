module Routes.Route exposing (..)

type AuthRoute = Login | Signin

type Route
  = Auth AuthRoute
  | Application
  | NotFound
