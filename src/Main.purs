module Main where

import Prelude
import Data.Argonaut (Json, _Array, _Object, _String)
import Data.Array (mapMaybe)
import Data.Either (Either, either)
import Data.Lens (preview)
import Data.Lens.Index (ix)
import Data.Maybe (Maybe(..))
import Data.String (joinWith)
import Data.String.Regex (Regex, regex, test)
import Data.String.Regex.Flags (noFlags)
import Effect (Effect)
import Effect.Class.Console (logShow)
import Node.Encoding (Encoding(..))
import Node.FS.Async (writeTextFile)
import Node.FS.Sync (readTextFile)

foreign import createJson :: String -> Json

re :: Either String Regex
re = regex "(youtube|youtu.be)" noFlags

res :: String -> Boolean
res str = either (const false) identity $ test <$> re <@> str

filterUrl :: Maybe String -> Maybe String
filterUrl str = do
  s <- str
  case res s of
    true -> Just s
    false -> Nothing

getLink :: Json -> Maybe String
getLink =
  preview
    ( _Object
        <<< ix "attachments"
        <<< _Array
        <<< ix 0
        <<< _Object
        <<< ix "data"
        <<< _Array
        <<< ix 0
        <<< _Object
        <<< ix "external_context"
        <<< _Object
        <<< ix "url"
        <<< _String
    )

getLinks :: Json -> Maybe (Array String)
getLinks j = do
  arr <- preview (_Array) j
  pure $ mapMaybe (filterUrl <<< getLink) arr

unlines :: Array String -> String
unlines = joinWith "\n"

main :: Effect Unit
main = do
  text <- readTextFile UTF8 "data/your_posts_1.json"
  case getLinks $ createJson text of
    Just txts -> writeTextFile UTF8 "data/results.txt" (unlines txts) (\_ -> pure unit)
    Nothing -> logShow "Error"
