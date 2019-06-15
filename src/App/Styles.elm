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

styledMessages : List (Attribute msg) -> List (Html msg) -> Html msg
styledMessages = styled div
  [ displayFlex
  , flexDirection column
  , justifyContent flexEnd
  , height <| pct 100
  , marginBottom <| px 50
  ]

styledMessage : Bool -> List (Attribute msg) -> List (Html msg) -> Html msg
styledMessage isOwn = styled div
  [ minHeight <| px 20
  , padding2 (px 10) (px 5)
  , marginBottom <| px 10
  , borderRadius <| px 3
  , color <| Styles.getColor Styles.Text
  , if isOwn == True then marginLeft auto else marginRight auto
  , cursor pointer 
  ]

messageRow : List (Attribute msg) -> List (Html msg) -> Html msg
messageRow = styled div
  [ marginBottom <| px 10
  , displayFlex
  , lastChild [ marginBottom <| px 0 ]
  ]

chatTextArea : List (Attribute msg) -> List (Html msg) -> Html msg
chatTextArea = styled textarea
  [ display inlineBlock
  , verticalAlign top
  , height <| px 150
  , padding <| px 10
  , border3 (px 1) solid (Styles.getColor Styles.Secondary)
  , Styles.getFont Styles.Anson
  , fontSize <| px 18
  , outline none
  , overflow auto
  , resize none
  ]

