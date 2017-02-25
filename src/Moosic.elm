module Moosic exposing (..)

import Erl exposing (Url, setQuery)
import Json.Decode as Json exposing (..)
import Json.Decode.Pipeline exposing (decode, required, optional)
import Http exposing (Request)


baseUrl : Url
baseUrl =
    Erl.parse "my.mail.ru/cgi-bin/my/ajax"


query : String -> Url -> Url
query q =
    setQuery "ajax_call" "1"
        << setQuery "func_name" "music.search"
        << setQuery "arg_query" q
        << setQuery "arg_extended" "1"
        << setQuery
            "arg_search_params"
            """{"music":{"limit":100},"playlist":{"limit":50},"album":{"limit":10},"artist":{"limit":10}}"""
        << setQuery "arg_offset" "0"
        << setQuery "arg_limit" "100"


type alias Track =
    { url : String
    , name : String
    , author : String
    , isHq : Int
    , albumCoverUrl : Maybe String
    }


track : Decoder Track
track =
    decode Track
        |> required "URL" string
        |> required "Name" string
        |> required "Author" string
        |> required "IsHQ" int
        |> required "AlbumCoverURL" (nullable string)


tracks : Decoder (List Track)
tracks =
    field "MusicData" (list track)
        |> index 3


searchRequest : String -> Request (List Track)
searchRequest q =
    Http.request
        { method = "GET"
        , headers = [ Http.header "X-Requested-With" "XMLHttpRequest" ]
        , url = "http://localhost:1337/" ++ (Erl.toString <| query q baseUrl)
        , body = Http.emptyBody
        , expect = Http.expectJson tracks
        , timeout = Nothing
        , withCredentials = False
        }
