module Main exposing (..)

import Animator exposing (Animator, Timeline)
import Animator.Inline as Inline
import Browser
import Element exposing (Element, centerX, centerY, htmlAttribute, text)
import Element.Input as Input
import Html exposing (Html)
import Time


type Msg
    = Tick Time.Posix
    | OnClick


type alias Model =
    { countOfClick : Timeline Int
    }


initialModel : Model
initialModel =
    { countOfClick = Animator.init 0
    }


animator : Animator Model
animator =
    Animator.animator
        |> Animator.watching .countOfClick (\countOfClick model -> { model | countOfClick = countOfClick })


subscriptions : Model -> Sub Msg
subscriptions model =
    Animator.toSubscription Tick model animator


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        Tick posix ->
            ( Animator.update posix animator model, Cmd.none )

        OnClick ->
            let
                current =
                    Animator.current model.countOfClick
            in
            ( { model
                | countOfClick = Animator.go Animator.slowly (current + 1) model.countOfClick
              }
            , Cmd.none
            )


viewButton : Model -> Element Msg
viewButton model =
    Input.button
        [ htmlAttribute <|
            Inline.scale model.countOfClick <|
                \state ->
                    Animator.at (toFloat state + 1.0)
        ]
        { onPress = Just OnClick
        , label = text "Enlarge"
        }


view : Model -> Html Msg
view model =
    Element.layout [] <|
        Element.column [ centerX, centerY ]
            [ viewButton model ]


main : Program () Model Msg
main =
    Browser.element
        { init = \_ -> ( initialModel, Cmd.none )
        , view = view
        , update = update
        , subscriptions = subscriptions
        }
