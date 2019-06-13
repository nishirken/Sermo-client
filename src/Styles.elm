module Styles exposing (..)

import Css exposing (..)
import Html.Styled exposing (..)

type Color
  = Primary
  | Secondary
  | Accent
  | Error

getColor : Color -> Css.Color
getColor color = hex <| case color of
  Primary -> "#212121"
  Secondary -> "#FAFAFA"
  Accent -> "#6200EE"
  Error -> "#B00020"

title : List (Attribute msg) -> List (Html msg) -> Html msg
title = styled h1
  [ fontSize (px 30)
  , margin3 (px 10) (px 0) (px 15)
  ]

errorTitle : List (Attribute msg) -> List (Html msg) -> Html msg
errorTitle = styled h6
  [ fontSize (px 14)
  , color <| getColor Error
  ]

styledButton : List (Attribute msg) -> List (Html msg) -> Html msg
styledButton = styled button
  [ backgroundColor <| getColor Accent
  , padding2 (px 10) (px 20)
  , color <| getColor Secondary
  , border (px 0)
  , outline none
  , cursor pointer
  ]

styledInput : List (Attribute msg) -> List (Html msg) -> Html msg
styledInput = let placeholderStyles = [ color <| getColor Primary ] in styled input
  [ border3 (px 1) solid transparent
  , backgroundColor <| getColor Secondary
  , outline none
  , padding2 (px 5) (px 10)
  , focus [ borderColor <| getColor Accent ]
  , property "::-webkit-input-placeholder" "#FAFAFA"
  , property "::-moz-placeholder" "#FAFAFA"
  ]
