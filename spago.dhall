{-
Welcome to a Spago project!
You can edit this file as you like.
-}
{ name = "my-project"
, dependencies =
  [ "argonaut"
  , "arrays"
  , "console"
  , "effect"
  , "either"
  , "maybe"
  , "node-buffer"
  , "node-fs"
  , "prelude"
  , "profunctor-lenses"
  , "psci-support"
  , "strings"
  ]
, packages = ./packages.dhall
, sources = [ "src/**/*.purs", "test/**/*.purs" ]
}
