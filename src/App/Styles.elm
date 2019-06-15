module App.Styles exposing (..)

import Css exposing (..)
import Html.Styled exposing (..)
import Styles

appContainer : List (Attribute msg) -> List (Html msg) -> Html msg
appContainer = styled div
  [ displayFlex
  , maxWidth <| px 1000
  , height <| pct 70
  , margin3 (px 150) auto (px 0)
  , Styles.getFont Styles.Anson
  ]

friendsListContainer : List (Attribute msg) -> List (Html msg) -> Html msg
friendsListContainer = styled ul
  [ displayFlex
  , flexDirection column
  , minWidth <| px 250
  , height <| pct 100
  , marginRight <| px 30
  , overflow auto
  , padding <| px 10
  , borderRight3 (px 1) solid (Styles.getColor Styles.Text)
  ]

styledFriend : Bool -> List (Attribute msg) -> List (Html msg) -> Html msg
styledFriend isSelected = styled li
  [ marginBottom <| px 10
  , padding2 (px 10) (px 15)
  , borderBottom3 (px 1) solid (if isSelected == True then (Styles.getColor Styles.Primary) else (rgba 0 0 0 0))
  , color <| Styles.getColor Styles.Text
  , cursor pointer
  , hover [ color <| Styles.getColor Styles.Accent ]  
  ]

chatContainer : List (Attribute msg) -> List (Html msg) -> Html msg
chatContainer = styled div
  [ displayFlex
  , flexDirection column
  , width (pct 100)
  , padding <| px 10
  ]

messages : List (Attribute msg) -> List (Html msg) -> Html msg
messages = styled div
  [ displayFlex
  , flexDirection column
  , alignItems right
  , height (pct 100)
  ]

message : Bool -> List (Attribute msg) -> List (Html msg) -> Html msg
message isOwn = styled div
  [ minHeight <| px 20
  , borderRadius <| px 3
  , color <| Styles.getColor Styles.Text
  , backgroundColor <| Styles.getColor Styles.Secondary
  , alignSelf <| if isOwn == True then right else left
  ]

chatTextArea : List (Attribute msg) -> List (Html msg) -> Html msg
chatTextArea = styled input
  [ height (px 200) ]

