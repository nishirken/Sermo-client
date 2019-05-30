module App.Models.User exposing (..)

import Json.Decode as JD
import App.Models.Friend exposing (Friend, friendDecoder)

type alias User =
  { id : Int
  , email : String
  , friends : List String
  }

userDecoder : JD.Decoder (Maybe User)
userDecoder = JD.nullable (
  JD.map3 User
    (JD.field "id" JD.int)
    (JD.field "email" JD.string)
    (JD.field "friends" (JD.list JD.string))
  )
