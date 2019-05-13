module App.FriendsList exposing (..)

import Browser
import Html.Styled exposing (Html, div, text, toUnstyled)
import App.Common as AppCommon

main = Browser.sandbox
  { init = initialModel
  , update = update
  , view = toUnstyled << view
  }

type Msg = None

type alias Model =
  { friends : List AppCommon.Friend }
testFriend = AppCommon.Friend "test@mail.ru"
initialModel : Model
initialModel = { friends = [testFriend, testFriend, testFriend] }

update : Msg -> Model -> Model
update _ model = model

view : Model -> Html Msg
view model =
  div [] (List.map (\{ email } -> div [] [text email]) model.friends)
