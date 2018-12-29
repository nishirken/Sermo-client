module Common exposing (..)

import Http exposing (Error (..))

type Route
  = Signin
  | Login
  | Application
  | NotFound

errorMessage : Http.Error -> String
errorMessage error = case error of
  Timeout -> "Timeout error"
  NetworkError -> "Network error"
  (BadPayload code msg) -> "Error with decoding"
  _ -> "Something went wrong..."