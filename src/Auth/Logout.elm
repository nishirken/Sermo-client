module Auth.Logout exposing (..)

import Browser
import Common
import Html
import Html.Events exposing (onClick)
import LocalStorage

type alias Model = {}

type Msg = Logout

initialModel : Model
initialModel = {}

main = Browser.element
  { init = \() -> (initialModel, Cmd.none)
  , update = update
  , view = view
  , subscriptions = \_ -> Sub.none
  }

update : Msg -> Model -> (Model, Cmd Msg)
update _ model = (model, LocalStorage.writeModel (LocalStorage.LocalStorageState ""))

outMsg : Msg -> Common.GlobalMsg
outMsg msg = case msg of
  Logout -> Common.Logout

view : Model -> Html.Html Msg
view _ =
  Html.button [onClick Logout] [Html.text "Logout"]
