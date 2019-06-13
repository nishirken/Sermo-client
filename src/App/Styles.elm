module App.Styles exposing (..)

import Css exposing (..)
import Html.Styled exposing (..)

appContainer : List (Attribute msg) -> List (Html msg) -> Html msg
appContainer = styled div
  [ displayFlex
  , height (pct 70)
  ]

friendsListContainer : List (Attribute msg) -> List (Html msg) -> Html msg
friendsListContainer = styled div
  [ width (pct 30)
  ]

chatContainer : List (Attribute msg) -> List (Html msg) -> Html msg
chatContainer = styled div
  [ displayFlex
  , flexDirection column
  , width (pct 70)
  ]

chatWrapper : List (Attribute msg) -> List (Html msg) -> Html msg
chatWrapper = styled div
  [ displayFlex
  , flexDirection column
  , height (pct 100)
  ]

chatTextArea : List (Attribute msg) -> List (Html msg) -> Html msg
chatTextArea = styled input
  [ height (px 200) ]

