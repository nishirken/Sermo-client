module App.Models.Friend exposing (..)

import Json.Decode as JD

type alias Friend = { email : String }

friendDecoder : JD.Decoder Friend
friendDecoder = JD.map Friend (JD.field "email" JD.string)
