module Shared.Update exposing (..)

import Routes.Msg as RoutesMsg
import Shared.State

type alias Update innerMsg innerModel = innerMsg -> innerModel -> Shared.State.Model -> UpdateResult innerModel innerMsg

type alias UpdateResult innerModel innerMsg =
  { updatedModel : innerModel
  , updatedCmd : Cmd innerMsg
  , stateMsg : Maybe Shared.State.Msg
  , routeCmd : Cmd RoutesMsg.Msg
  }
