module Auth.LoginForm exposing (..)

import Browser
import Auth.Common as AuthCommon
import Common
import Http
import Html.Styled exposing (Html, toUnstyled, div, h3, button, text, Html)
import Html.Styled.Events exposing (onInput, onClick)
import Routes
import LocalStorage
import SharedState

update :
  AuthCommon.InFormMsg ->
  AuthCommon.InFormModel ->
  (AuthCommon.InFormModel, Cmd AuthCommon.InFormMsg, Maybe SharedState.Msg)
update msg model =
  case msg of
    AuthCommon.Email email -> ({ model | email = email }, Cmd.none, Nothing)
    AuthCommon.Password password -> ({ model | password = password }, Cmd.none, Nothing)
    AuthCommon.Send -> (model, Http.post
      { url = "http://localhost:8080/login"
      , body = AuthCommon.inRequest model
      , expect = Common.expectJsonResponse AuthCommon.authDecoder AuthCommon.DataReseived
      }, Nothing)
    AuthCommon.DataReseived result -> let initModel = AuthCommon.initialInFormModel in
      case result of
        Ok res -> let error = Common.getJsonError result in
          case error of
            (Just e) -> ({ model | error = Maybe.withDefault "" e.message }, Cmd.none, Nothing)
            Nothing -> let data = Common.getJsonData result in
              case data of
                (Just response) ->
                  ( initModel
                  , LocalStorage.writeModel (LocalStorage.LocalStorageState response.token)
                  , Just (SharedState.Login response)
                  )
                Nothing -> (model, Cmd.none, Nothing)
        Err httpError ->
          ({ model | error = Common.errorMessage httpError }, Cmd.none, Nothing)

view : AuthCommon.InFormModel -> Html AuthCommon.InFormMsg
view model =
  div [] [
    h3 [] [text "Login"]
    , AuthCommon.formInput "email" model.email AuthCommon.Email
    , AuthCommon.formInput "password" model.password AuthCommon.Password
    , button [onClick AuthCommon.Send] [text "login"]
    , div [] [text model.error]
    ]
