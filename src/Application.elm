module Application exposing (..)

import Http

type alias User =
  { id : Int
    , email : String
    , friends : Friends
  }

type Friends = Friends (List User)

type alias Model = { user : User }

type Msg
  = LoadUser
  | DataReceived (Result Http.Error User)
