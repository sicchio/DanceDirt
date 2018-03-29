-- \vlc --no-video-title-show --no-loop --no-random -I oldrc --rc-unix /dev/shm/vlc-control-shit
--
-- better: vim ~/newnewlife/Intake/VidsInPieces.hs ~/t/pick_music/pick_music.hs


{-# LANGUAGE OverloadedStrings #-}

module DanceDirt where

import Control.Concurrent
import Control.Monad
import qualified Data.ByteString.Char8 as BS8
import Data.Monoid
import Network.Socket hiding (send, recv) -- (Socket, SockAddr(..), connect, SocketType(Stream), Family(AF_UNIX, AF_INET), socket, defaultProtocol, addrFamily, getAddrInfo, SocketType(Datagram), iNADDR_ANY, bindSocket)
import Network.Socket.ByteString
import System.Directory (getCurrentDirectory)

import Sound.Tidal.Tempo (Tempo)
import Sound.Tidal.Transition (transition)
import Sound.Tidal.Stream -- (start, state) -- start is probably better but w/e
import Sound.Tidal.OscStream (OscSlang(..), makeConnection, TimeStamp(NoStamp))

import qualified Control.Exception as E


socketLocation :: FilePath
socketLocation = "/tmp/vlc-control-shit"

makeVLCSocket :: IO Socket
makeVLCSocket = do
   soc <- socket AF_UNIX Stream 0
   connect soc (SockAddrUnix socketLocation)
   _ <- forkIO $ forever $
      recv soc 1024 >>= (BS8.putStrLn) -- appendFile "/dev/shm/vlc-log"
   return soc

playChunk :: Socket -> FilePath -> IO ()
playChunk soc fPath = do
   _ <- send soc ("enqueue " <> BS8.pack fPath <> "\n")
   -- threadDelay $ 15 * 10 ^ 4
   _ <- send soc "next\n"
   _ <- send soc ("play\n")
   pure ()

makeListenSocket :: IO Socket
makeListenSocket = do
  -- protoUDP <- getProtocolNumber "udp"
   E.bracketOnError
      (socket AF_INET Datagram 0) -- 1) -- protoUDP)
      sClose
      (\sock -> do
         setSocketOption sock ReuseAddr 1
         bindSocket sock (SockAddrInet 44134 iNADDR_ANY)
         pure sock)

-- From ask.tidalcycles.org/question/367:
danceDirtShape = Shape {
     params = [ S "img" Nothing ]
   , cpsStamp = False
   , latency = 0
   }
danceDirtSlang = OscSlang {
     path = "/dance_dirt"
   , timestamp = NoStamp
   , namedParams = True
   , preamble = []
   }
danceDirtStream = do
   s <- makeConnection "127.0.0.1" 44134 danceDirtSlang
   stream (Backend s $ (\_ _ _ -> pure ())) danceDirtShape

pic = makeS danceDirtShape
