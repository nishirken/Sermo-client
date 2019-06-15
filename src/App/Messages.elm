module App.Messages exposing (..)

import Browser
import Html.Styled exposing (Html, div, text, toUnstyled)
import App.Styles as Styles

type Msg = None

type alias Model = { messages : List String }

initialModel : Model
initialModel =
  { messages =
    [ "test message"
    , "test messagetest message"
    , "test message test message test message"
    ]
  }

update : Msg -> Model -> Model
update _ model = model

messageView : String -> Html msg
messageView t = Styles.message True [] [ text t ]

view : Model -> Html Msg
view model = Styles.messages [] <| List.map messageView model.messages
