module Main

import Data.Vect
import IR
import IR.Layout
import IR.StackSet

-- A display-free benchmark around Brian McKenna's actual Iridium data structures
-- and pure window-management operations.  The upstream source is cloned and
-- imported at build time; this file does not copy or relicense Iridium.

emptyStackSet : StackSet Int Int
emptyStackSet =
  let workspace = MkWorkspace (single columnLayout) Nothing
      screen = MkScreen workspace 0 (MkRectangle 0.0 0.0 1920.0 1080.0)
  in MkStackSet screen [] []

insertCount : Int -> StackSet Int Int -> StackSet Int Int
insertCount n s =
  if n <= 0
    then s
    else insertCount (n - 1) (insertUp n s)

step : StackSet Int Int -> StackSet Int Int
step = swapDown . focusDown

runSteps : Int -> StackSet Int Int -> StackSet Int Int
runSteps n s =
  if n <= 0
    then s
    else runSteps (n - 1) (step s)

rectChecksum : Vect n (wid, Rectangle) -> Float
rectChecksum [] = 0.0
rectChecksum ((_, MkRectangle x y w h) :: xs) =
  x + y + w + h + rectChecksum xs

sampleStack : Stack Int
sampleStack = MkStack 1 [] [2, 3, 4, 5, 6, 7, 8]

main : IO ()
main = do
  let final = runSteps 200000 (insertCount 64 emptyStackSet)
  case stackSetPeek final of
    Just wid => printLn wid
    Nothing => putStrLn "empty"
  printLn (rectChecksum (columnLayout (MkRectangle 0.0 0.0 1920.0 1080.0) sampleStack))
