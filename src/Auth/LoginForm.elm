module Auth.LoginForm exposing (..)

import Browser
import Auth.Common as AuthCommon
import Common as Common
import Http
import Html
import Routes
import Json.Decode as JsonDecode

main = Browser.element
  { init = \() -> (AuthCommon.initialInFormModel, Cmd.none)
  , update = update
  , view = view
  , subscriptions = \_ -> Sub.none
  }

type alias LoginFormMsg = AuthCommon.InFormMsg String

loginDecoder : JsonDecode.Decoder String
loginDecoder = JsonDecode.field "token" JsonDecode.string

update : LoginFormMsg -> AuthCommon.InFormModel -> (AuthCommon.InFormModel, Cmd LoginFormMsg)
update msg model =
  case msg of
    AuthCommon.Email email -> ({ model | email = email }, Cmd.none)
    AuthCommon.Password password -> ({ model | password = password }, Cmd.none)
    AuthCommon.Send -> (model, Http.post
      { url = "http://localhost:8080/login"
      , body = AuthCommon.inRequest model
      , expect = Common.expectJsonResponse loginDecoder AuthCommon.DataReseived
      })
    AuthCommon.DataReseived result -> let initModel = AuthCommon.initialInFormModel in
      case result of
        Ok res -> let error = Common.getJsonError result in
          case error of
            (Just e) -> ({ model | error = Maybe.withDefault "" e.message }, Cmd.none)
            Nothing -> (initModel, Cmd.none)
        Err httpError ->
            ({ model | error = Common.errorMessage httpError }, Cmd.none)

outMsg : LoginFormMsg -> Common.GlobalMsg
outMsg msg =
  case msg of
    (AuthCommon.DataReseived res) -> let data = Common.getJsonData res in case data of
      (Just token) -> Common.LoginSuccess token
      Nothing -> Common.None
    _ -> Common.None

view : AuthCommon.InFormModel -> Html.Html LoginFormMsg
view model = AuthCommon.inFormView model "Login"
