module Auth.LoginForm exposing (..)

import Browser
import Auth.Common as AuthCommon
import Common
import Http
import Html.Styled exposing (Html, toUnstyled, div)
import Routes
import LocalStorage

main = Browser.element
  { init = \() -> (AuthCommon.initialInFormModel, Cmd.none)
  , update = update
  , view = view
  , subscriptions = \_ -> Sub.none
  }

type OutMsg = LoginSuccess Common.AuthResponse

type Msg = ForSelf AuthCommon.InFormMsg | ForParent OutMsg

type alias TranslationDictionary msg =
  { onInternalMsg : AuthCommon.InFormMsg -> msg
  , onLoginSuccess : Common.AuthResponse -> msg
  }

type alias Translator parentMsg = Msg -> parentMsg

update : AuthCommon.InFormMsg -> AuthCommon.InFormModel -> (AuthCommon.InFormModel, Cmd Msg)
update msg model =
  case msg of
    AuthCommon.Email email -> ({ model | email = email }, Cmd.none)
    AuthCommon.Password password -> ({ model | password = password }, Cmd.none)
    AuthCommon.Send -> (model, Http.post
      { url = "http://localhost:8080/login"
      , body = AuthCommon.inRequest model
      , expect = Common.expectJsonResponse AuthCommon.authDecoder (AuthCommon.DataReseived >> ForSelf)
      })
    AuthCommon.DataReseived result -> let initModel = AuthCommon.initialInFormModel in
      case result of
        Ok res -> let error = Common.getJsonError result in
          case error of
            (Just e) -> ({ model | error = Maybe.withDefault "" e.message }, Cmd.none)
            Nothing -> let data = Common.getJsonData result in
              case data of
                (Just { token }) -> (initModel, LocalStorage.writeModel (LocalStorage.LocalStorageState token))
                Nothing -> (model, Cmd.none)
        Err httpError ->
            ({ model | error = Common.errorMessage httpError }, Cmd.none)

translator : TranslationDictionary msg -> Translator msg
translator { onInternalMsg, onLoginSuccess } msg =
  case msg of
    ForSelf internal -> onInternalMsg internal
    ForParent (LoginSuccess response) -> onLoginSuccess response

view : AuthCommon.InFormModel -> Html Msg
view model =
  -- AuthCommon.inFormView model (AuthCommon.Email >> ForSelf) (AuthCommon.Password >> ForSelf) (ForSelf AuthCommon.Send) "Login"
  div [] []
