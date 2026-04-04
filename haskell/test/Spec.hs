module Main where

import Template (message)
import Test.Hspec

main :: IO ()
main = hspec $ do
    describe "message" $ do
        it "is not empty" $ do
            message `shouldNotBe` ""
