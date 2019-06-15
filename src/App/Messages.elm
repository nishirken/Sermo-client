module App.Messages exposing (..)

import Browser
import Html.Styled exposing (Html, text)
import App.Styles as AppStyles

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
messageView t = AppStyles.messageRow []
  [ AppStyles.styledMessage True [] [ text t ] ]

view : Model -> Html Msg
view model = AppStyles.styledMessages [] <| List.map messageView model.messages
