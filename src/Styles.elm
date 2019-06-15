module Styles exposing (..)

import Css exposing (..)
import Css.Global as CssGlobal
import Html.Styled exposing (..)

type Color
  = Primary
  | Secondary
  | Text
  | Background
  | Accent
  | Error

type Font
  = Anson

getColor : Color -> Css.Color
getColor color = hex <| case color of
  Primary -> "#E85A4F"
  Secondary -> "#8E8D8A"
  Text -> "#19181A"
  Background -> "#FAFAFA"
  Accent -> "#4056A1"
  Error -> "#B00020"

getFont : Font -> Style
getFont f =
  let
    customFont = case f of
      Anson -> "Anson" in fontFamilies [ customFont, sansSerif.value ]

title : List (Attribute msg) -> List (Html msg) -> Html msg
title = styled h1
  [ fontSize <| px 30
  , getFont Anson
  , margin3 (px 10) (px 0) (px 15)
  ]

errorTitle : List (Attribute msg) -> List (Html msg) -> Html msg
errorTitle = styled h6
  [ fontSize <| px 14
  , getFont Anson
  , margin3 (px 7) auto (px 14)
  , color <| getColor Error
  ]

styledButton : List (Attribute msg) -> List (Html msg) -> Html msg
styledButton = styled button
  [ borderRadius <| px 3
  , minWidth <| px 100
  , minHeight <| px 40
  , fontSize <| px 18
  , getFont Anson
  , padding2 (px 10) (px 20)
  , outline none
  , cursor pointer
  , backgroundColor <| getColor Background
  , border3 (px 1) solid (getColor Text)
  , color <| getColor Text
  , hover [ color <| getColor Accent, borderColor <| getColor Accent ]
  ]

styledInput : List (Attribute msg) -> List (Html msg) -> Html msg
styledInput = let placeholderStyles = [ color <| getColor Secondary, getFont Anson ] in styled input
  [ border3 (px 1) solid (getColor Secondary)
  , borderRadius <| px 3
  , backgroundColor <| getColor Background
  , minWidth <| px 300
  , outline none
  , padding2 (px 8) (px 15)
  , focus [ borderColor <| getColor Accent ]
  , fontSize <| px 18
  , getFont Anson
  , pseudoElement "-webkit-input-placeholder" placeholderStyles
  , pseudoElement "-moz-placeholder" placeholderStyles
  ]

appContainer : List (Attribute msg) -> List (Html msg) -> Html msg
appContainer = styled div
  [ width <| pct 100
  , height <| pct 100
  , backgroundColor <| getColor <| Background
  , position relative
  ]

logoBackdrop : List (Attribute msg) -> List (Html msg) -> Html msg
logoBackdrop = let s = 200 in
  styled div
    [ width <| px <| s / 2
    , height <| px <| s / 2
    , position absolute
    , top <| px 0
    , left <| px 0
    , borderLeft3 (px <| s / 4) solid (getColor Text)
    , borderTop3 (px <| s / 4) solid (getColor Text)
    , borderRight3 (px <| s / 4) solid (getColor Background)
    , borderBottom3 (px <| s / 4) solid (getColor Background)
    , backgroundColor <| getColor Text
    ]

absoluteButton : List (Attribute msg) -> List (Html msg) -> Html msg
absoluteButton = styled styledButton
  [ position absolute
  , top <| px 10
  , right <| px 10
  ]

globalStyles : Html msg
globalStyles = CssGlobal.global
  [ CssGlobal.html [ height <| pct 100 ]
  , CssGlobal.body
    [ height <| pct 100
    , margin <| px 0
    , displayFlex
    ]
  , CssGlobal.selector "a" [ color inherit, textDecoration none ]
  , CssGlobal.selector "*" [ boxSizing borderBox ]
  ]
