module Discogs exposing (..)

import Erl exposing (Url)
import Http exposing (Request)
import Json.Decode as Json exposing (Decoder, int, list, string)
import Json.Decode.Pipeline exposing (decode, required, optional)


key : String
key =
    "LTqIFhZklJdwmYiUBdxW"


secret : String
secret =
    "VcVwADZImxxamwwsbMzHsRXtOlQtKgrK"


baseUrl : Url
baseUrl =
    Erl.parse "https://api.discogs.com"


sign : Url -> Url
sign =
    Erl.setQuery "secret" secret
        << Erl.setQuery "key" key


searchUrl : String -> Url
searchUrl q =
    baseUrl
        |> Erl.appendPathSegments [ "database", "search" ]
        |> Erl.setQuery "type" "master"
        |> Erl.setQuery "q" q
        |> sign


searchRequest : String -> Request (PagedResults SearchResult)
searchRequest q =
    Http.get (searchUrl q |> Erl.toString) (pagedResults searchResult)


albumUrl : Int -> Url
albumUrl id =
    baseUrl
        |> Erl.appendPathSegments [ "masters", toString id ]
        |> sign


albumRequest : Int -> Request Album
albumRequest id =
    Http.get (Erl.toString <| albumUrl id) album


type alias Track =
    { title : String
    }


track : Decoder Track
track =
    decode Track
        |> required "title" string


type alias Image =
    { width : Int
    , height : Int
    , tpe : String
    , uri : String
    , uri150 : String
    }


image : Decoder Image
image =
    decode Image
        |> required "width" int
        |> required "height" int
        |> required "type" string
        |> required "uri" string
        |> required "uri150" string


type alias Artist =
    { id : Int
    , name : String
    }


artist : Decoder Artist
artist =
    decode Artist
        |> required "id" int
        |> required "name" string


type alias Album =
    { id : Int
    , tracklist : List Track
    , images : List Image
    , title : String
    , artists : List Artist
    }


album : Decoder Album
album =
    decode Album
        |> required "id" int
        |> required "tracklist" (list track)
        |> required "images" (list image)
        |> required "title" string
        |> required "artists" (list artist)


type alias Pagination =
    { per_page : Int
    }


pagination : Decoder Pagination
pagination =
    decode Pagination
        |> required "per_page" int


type alias PagedResults a =
    { pagination : Pagination
    , results : List a
    }


pagedResults : Decoder a -> Decoder (PagedResults a)
pagedResults dec =
    decode PagedResults
        |> required "pagination" pagination
        |> required "results" (list dec)


type alias SearchResult =
    { id : Int
    , title : String
    , thumb : String
    }


searchResult : Decoder SearchResult
searchResult =
    decode SearchResult
        |> required "id" int
        |> required "title" string
        |> required "thumb" string
