module Auth.Logout exposing (..)

import Browser
import Common
import Html
import Html.Styled.Events exposing (onClick)
import LocalStorage
import Html.Styled exposing (Html, toUnstyled, button, text)
import SharedState

type alias Model = {}

type Msg = Logout

initialModel : Model
initialModel = {}

update : Msg -> Model -> (Model, Cmd Msg, Maybe SharedState.Msg)
update _ model = (model, LocalStorage.writeModel (LocalStorage.LocalStorageState ""), Just SharedState.Logout)

view : Model -> Html Msg
view _ =
  button [onClick Logout] [text "Logout"]
