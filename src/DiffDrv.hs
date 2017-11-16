{-# language TypeSynonymInstances #-}
{-# language FlexibleInstances #-}

import qualified Data.Attoparsec.Text.Lazy as Parse
import qualified Data.Text.Lazy.IO
import qualified Data.Text.Lazy.IO as LazyText
import Data.TreeDiff
import Filesystem.Path (FilePath)
import Nix.Derivation
import qualified Prelude
import Prelude hiding (FilePath)
import System.Environment
import Text.PrettyPrint.ANSI.Leijen (putDoc)

instance ToExpr Derivation
instance ToExpr DerivationOutput
instance ToExpr FilePath where
  toExpr path = App "FilePath" [ toExpr (show path) ]

diffFiles :: Prelude.FilePath -> Prelude.FilePath -> IO (Edit EditExpr)
diffFiles a b = do
  Parse.Done _ drvA <- Parse.parse Nix.Derivation.parseDerivation <$> LazyText.readFile a
  Parse.Done _ drvB <- Parse.parse Nix.Derivation.parseDerivation <$> LazyText.readFile b
  return (ediff drvA drvB)

main :: IO ()
main = do
  (f1:f2:_) <- getArgs
  diffFiles f1 f2 >>= putDoc . ansiWlEditExpr
