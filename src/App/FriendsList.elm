module App.FriendsList exposing (..)

import Browser
import Html.Styled exposing (Html, div, text, toUnstyled)
import App.Models.Friend exposing (Friend)
import App.Styles as AppStyles

main = Browser.sandbox
  { init = initialModel
  , update = update
  , view = toUnstyled << view
  }

type Msg = None

type alias Model =
  { friends : List String }

initialModel = Model [ "test@mail.ru", "vasya@gmail.com" ]

update : Msg -> Model -> Model
update _ model = model

friendView : String -> Html msg
friendView t = AppStyles.styledFriend False [] [ text t ]

view : Model -> Html Msg
view model =
  AppStyles.friendsListContainer [] <| List.map friendView model.friends
