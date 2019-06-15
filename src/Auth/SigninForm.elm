module Auth.SigninForm exposing (..)

import Browser
import Auth.Common as AuthCommon
import Common as Common
import Http
import Html.Styled exposing (Html, toUnstyled, div, h3, button, text, Html)
import Html.Styled.Events exposing (onInput, onClick)
import Routes.Main as Routes
import Routes.Route as Route
import LocalStorage
import Shared.Update exposing (Update, UpdateResult)
import Shared.State
import Styles
import Auth.Styles as AuthStyles

update : Update AuthCommon.InFormMsg AuthCommon.InFormModel
update msg model { navigationKey } =
  case msg of
    AuthCommon.Email email -> UpdateResult { model | email = email } Cmd.none Nothing Cmd.none
    AuthCommon.Password password -> UpdateResult { model | password = password } Cmd.none Nothing Cmd.none
    AuthCommon.Send -> UpdateResult
      model
      (Http.post
        { url = "http://localhost:8080/signin"
        , body = AuthCommon.inRequest model
        , expect = Common.expectJsonResponse AuthCommon.authDecoder AuthCommon.DataReseived
        })
      Nothing
      Cmd.none
    AuthCommon.DataReseived result ->
      case result of
        Ok res -> let error = Common.getJsonError result in
          case error of
            (Just e) -> UpdateResult { model | error = Maybe.withDefault "" e.message } Cmd.none Nothing Cmd.none
            Nothing -> let data = Common.getJsonData result in
              case data of
                (Just response) ->
                  UpdateResult
                    AuthCommon.initialInFormModel
                    (LocalStorage.writeModel (LocalStorage.LocalStorageState response.token (Just response.id)))
                    (Just (Shared.State.Login response))
                    (Routes.goToRoute navigationKey Route.Application)
                Nothing -> UpdateResult model Cmd.none Nothing Cmd.none
        Err httpError ->
          UpdateResult { model | error = Common.errorMessage httpError } Cmd.none Nothing Cmd.none

view : AuthCommon.InFormModel -> Html AuthCommon.InFormMsg
view model =
  AuthStyles.formContainer [] [
    AuthStyles.formTitle [] [ text "Signin" ]
    , AuthStyles.formRow [] [ AuthCommon.formInput "email" "email" model.email AuthCommon.Email ]
    , AuthStyles.formRow [] [ AuthCommon.formInput "password" "password" model.password AuthCommon.Password ]
    , AuthStyles.formRow [] [ AuthStyles.submitButton [ onClick AuthCommon.Send ] [text "Signin"] ]
    , Styles.errorTitle [] [ text model.error ]
    ]
