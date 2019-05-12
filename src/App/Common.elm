module App.Common exposing (..)

type alias User =
  { id : Int
  , email : String
  , friends : List Friend
  }

type alias Friend = { email : String }
