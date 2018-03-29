{-# LANGUAGE OverloadedStrings #-}

module Main where

import qualified Control.Exception as E
import Control.Monad
import qualified Data.ByteString.Char8 as BS8
import Network.Socket.ByteString (recv)
import System.Directory
import System.Process

import Vivid.OSC

import DanceDirt

main :: IO ()
main = do

         dir <- getCurrentDirectory
         vlcSoc <- makeVLCSocket
         listenSock <- makeListenSocket
         forever $ recv listenSock 65536 >>= \msg -> do
            case decodeOSC msg of
               Right (OSC "/dance_dirt" [OSC_S "s",OSC_S picName]) -> do
                  let fPath = dir++"/"++BS8.unpack picName++".jpg"
                  print fPath
                  playChunk vlcSoc fPath
               _ -> pure ()
