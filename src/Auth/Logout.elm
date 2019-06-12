module Auth.Logout exposing (..)

import Browser
import Common
import Html
import Html.Styled.Events exposing (onClick)
import LocalStorage
import Html.Styled exposing (Html, toUnstyled, button, text)
import Shared.Update exposing (Update, UpdateResult)
import Shared.State
import Routes.Main exposing (goToRoute)
import Routes.Route exposing (Route (..), AuthRoute (..))

type alias Model = {}

type Msg = Logout

initialModel : Model
initialModel = {}

update : Update Msg Model
update _ model { navigationKey } = UpdateResult
  model
  (LocalStorage.writeModel (LocalStorage.LocalStorageState "" Nothing))
  (Just Shared.State.Logout)
  (goToRoute navigationKey (Auth Login))

view : Model -> Html Msg
view _ =
  button [onClick Logout] [text "Logout"]
