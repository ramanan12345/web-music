module Models exposing (..)

import RemoteData exposing (WebData)
import Routing exposing (Route)
import Discogs exposing (PagedResults, SearchResult, Track, Album)
import Debounce exposing (Debounce)


type alias Model =
    { route : Route
    , debounce : Debounce String
    , albums : WebData (List SearchResult)
    , album : WebData Album
    }


initialModel : Route -> Model
initialModel r =
    { route = r
    , debounce = Debounce.init
    , albums = RemoteData.NotAsked
    , album = RemoteData.NotAsked
    }
