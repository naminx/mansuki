{-# LANGUAGE OverloadedStrings #-}
{-# LANGUAGE QuasiQuotes #-}
{-# LANGUAGE NoImplicitPrelude #-}

module App.Lib.ANSI where

import Data.String.QM (qt)
import qualified Data.Text.IO as T
import RIO


default' :: Text
default' = "\ESC[0m"


black :: Text
black = "\ESC[30m"


red :: Text
red = "\ESC[31m"


green :: Text
green = "\ESC[32m"


yellow :: Text
yellow = "\ESC[33m"


blue :: Text
blue = "\ESC[34m"


magenta :: Text
magenta = "\ESC[35m"


cyan :: Text
cyan = "\ESC[36m"


white :: Text
white = "\ESC[37m"


black' :: Text
black' = "\ESC[90m"


red' :: Text
red' = "\ESC[91m"


green' :: Text
green' = "\ESC[92m"


yellow' :: Text
yellow' = "\ESC[93m"


blue' :: Text
blue' = "\ESC[94m"


magenta' :: Text
magenta' = "\ESC[95m"


cyan' :: Text
cyan' = "\ESC[96m"


white' :: Text
white' = "\ESC[97m"


showColors :: IO ()
showColors =
  T.putStrLn
    [qt|${default'}default'
${black}black
${red}red
${green}green
${yellow}yellow
${blue}blue
${magenta}magenta
${cyan}cyan
${white}white
${black'}black'
${red'}red'
${green'}green'
${yellow'}yellow'
${blue'}blue'
${magenta'}magenta'
${cyan'}cyan'
${white'}white'
${default'}|]
