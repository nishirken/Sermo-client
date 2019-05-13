module App.Chat exposing (..)

import Browser
import Html.Styled exposing (Html, div, text, toUnstyled)
import App.Styles as Styles

main = Browser.sandbox
  { init = initialModel
  , update = update
  , view = toUnstyled << view
  }

type Msg = None

type alias Model = { messages : List String }

initialModel : Model
initialModel = { messages = ["test message", "test message", "test message"] }

update : Msg -> Model -> Model
update _ model = model

view : Model -> Html Msg
view model = Styles.chatWrapper [] (List.map (\message -> div [] [text message]) model.messages)
