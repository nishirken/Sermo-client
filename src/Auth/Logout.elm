module Auth.Logout exposing (..)

import Browser
import Common
import Html
import Html.Styled.Events exposing (onClick)
import LocalStorage
import Html.Styled exposing (Html, toUnstyled, button, text)

type alias Model = {}

type Msg = Logout

initialModel : Model
initialModel = {}

main = Browser.element
  { init = \() -> (initialModel, Cmd.none)
  , update = update
  , view = toUnstyled << view
  , subscriptions = \_ -> Sub.none
  }

update : Msg -> Model -> (Model, Cmd Msg)
update _ model = (model, LocalStorage.writeModel (LocalStorage.LocalStorageState ""))

-- outMsg : Msg -> Common.GlobalMsg
-- outMsg msg = case msg of
--   Logout -> Common.Logout

view : Model -> Html Msg
view _ =
  button [onClick Logout] [text "Logout"]
