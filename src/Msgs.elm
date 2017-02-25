module Msgs exposing (..)

import RemoteData exposing (WebData)
import Discogs exposing (PagedResults, SearchResult, Album)
import Debounce exposing (Debounce)
import Navigation exposing (Location)
import Moosic


type Msg
    = Input String
    | Albums String (WebData (PagedResults SearchResult))
    | DebounceMsg Debounce.Msg
    | Click SearchResult
    | OnLocationChange Location
    | Album (WebData Album)
    | Play Album Discogs.Track
    | GotUrl Discogs.Track (WebData Moosic.Track)
