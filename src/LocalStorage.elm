port module LocalStorage exposing (..)

import Task
import Json.Encode as JsonEncode
import Json.Decode as JsonDecode
import Common

port setStorage : JsonEncode.Value -> Cmd msg

type alias LocalStorageState = { authToken : String }

encodedModel : LocalStorageState -> JsonEncode.Value
encodedModel { authToken } = JsonEncode.object
  [ ("authToken", JsonEncode.string authToken)
  ]

writeModel : LocalStorageState -> Cmd msg
writeModel model = setStorage (encodedModel model)

modelDecoder : JsonDecode.Decoder LocalStorageState
modelDecoder = JsonDecode.map LocalStorageState (JsonDecode.field "authToken" JsonDecode.string)

decodeModel : String -> LocalStorageState
decodeModel value = case JsonDecode.decodeString modelDecoder value of
  (Ok x) -> x
  (Err _) -> defaultModel

key = "sermo"

defaultModel : LocalStorageState
defaultModel = LocalStorageState ""
