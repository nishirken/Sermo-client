module Auth.Common exposing (..)

import Http
import Html.Styled exposing (div, h3, button, text, Html, input)
import Html.Styled.Attributes exposing (type_, placeholder, required, value)
import Html.Styled.Events exposing (onInput, onClick)
import Common
import Routes
import Json.Encode as JE
import Json.Decode as JD

initialInFormModel = InFormModel "" "" ""

type alias InFormModel =
  { email : String
  , password : String
  , error : String
  }

type InFormMsg
  = Send
  | Email String
  | Password String
  | DataReseived (Result Http.Error (Common.JSONResponse Common.AuthResponse))

authDecoder : JD.Decoder Common.AuthResponse
authDecoder = JD.map2 Common.AuthResponse JD.int JD.string 

inRequest : InFormModel -> Http.Body
inRequest { email, password } =
  Http.jsonBody (JE.object [("email", JE.string email), ("password", JE.string password)])

formInput : String -> String -> (String -> msg) -> Html msg
formInput p v toMsg =
  input
  [type_ "text", onInput toMsg, placeholder p, required True, value v]
  []

inFormView : InFormModel -> String -> Html InFormMsg
inFormView model formTitle =
    div [] [
      h3 [] [text formTitle]
      , formInput "email" model.email Email
      , formInput "password" model.password Password
      , button [onClick Send] [text formTitle]
      , div [] [text model.error]
    ]
