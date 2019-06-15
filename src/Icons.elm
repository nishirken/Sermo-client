module Icons exposing (..)

import Css
import Svg.Styled exposing (..)
import Svg.Styled.Attributes exposing (..)
import Styles

logoIcon : Svg msg
logoIcon = (styled svg
  [ Css.width <| Styles.logoSize
  , Css.height <| Styles.logoSize
  , Css.fill <| Styles.getColor Styles.Primary
  , Css.transform <| Css.rotate <| Css.deg 270
  ])
  [ version "1.1"
  , x "0px"
  , y "0px"
  , viewBox "0 0 469.038 469.038"
  ]
  [ g []
    [ Svg.Styled.path
      [ d <| "M465.023,4.079c-3.9-3.9-9.9-5-14.9-2.8l-442,193.7c-4.7,2.1-7.8,6.6-8.1,11.7s2.4,9.9,6.8,12." ++
        "4l154.1,87.4l91.5,155.7c2.4,4.1,6.9,6.7,11.6,6.7c0.3,0,0.5,0,0.8,0c5.1-0.3,9.5-" ++
        "3.4,11.6-8.1l191.5-441.8C470.123,13.879,469.023,7.979,465.023,4.079z" ++
        "M394.723,54.979l-226.2,224.7l-124.9-70.8L394.723,54.979z M262.223,425.579l-74.5-126.9l227.5-" ++
        "226L262.223,425.579z"
      ]
    []
    ]
  ]
