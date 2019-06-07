module Auth.SigninForm exposing (..)

import Browser
import Auth.Common as AuthCommon
import Common as Common
import Http
import Html.Styled exposing (Html, toUnstyled)
import Routes
import LocalStorage

main = Browser.element
  { init = \() -> (AuthCommon.initialInFormModel, Cmd.none)
  , update = update
  , view = toUnstyled << view
  , subscriptions = \_ -> Sub.none
  }

update : AuthCommon.InFormMsg -> AuthCommon.InFormModel -> (AuthCommon.InFormModel, Cmd AuthCommon.InFormMsg)
update msg model =
  case msg of
    AuthCommon.Email email -> ({ model | email = email }, Cmd.none)
    AuthCommon.Password password -> ({ model | password = password }, Cmd.none)
    AuthCommon.Send -> (model, Http.post
      { url = "http://localhost:8080/signin"
      , body = AuthCommon.inRequest model
      , expect = Common.expectJsonResponse AuthCommon.authDecoder AuthCommon.DataReseived
      })
    AuthCommon.DataReseived result ->
      case result of
        Ok res -> let error = Common.getJsonError result in
          case error of
            (Just e) -> ({ model | error = Maybe.withDefault "" e.message }, Cmd.none)
            Nothing -> let data = Common.getJsonData result in
              case data of
                (Just { token }) -> (AuthCommon.initialInFormModel, LocalStorage.writeModel (LocalStorage.LocalStorageState token))
                Nothing -> (model, Cmd.none)
        Err httpError ->
            ({ model | error = Common.errorMessage httpError }, Cmd.none)

-- outMsg : AuthCommon.InFormMsg -> Common.GlobalMsg
-- outMsg msg =
--   case msg of
--     (AuthCommon.DataReseived res) -> let data = Common.getJsonData res in case data of
--       (Just d) -> Common.SigninSuccess d
--       _ -> Common.None
--     _ -> Common.None

view : AuthCommon.InFormModel -> Html AuthCommon.InFormMsg
view model = AuthCommon.inFormView model "Signin"
