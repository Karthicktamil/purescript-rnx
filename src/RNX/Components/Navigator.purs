module Navigator where

import React (ReactElement, ReactState, ReactThis, ReadWrite)
import RNX.Styles (Style)
import RNX.Events (UnitEventHandler) 
import RNX.PropTypes (RefType)
import Prelude
import Control.Monad.Eff (Eff)
import Data.Function.Uncurried (Fn2, mkFn2)

newtype Navigator r = Navigator (forall props state. ReactThis props state)

type NavigatorProps r eff =
  { ref :: RefType (Navigator r)
  , configureScene :: SceneConfigurer r
  , initialRoute :: r
  , initialRouteStack :: Array r
  , navigationBar :: ReactElement
  , navigator :: ReactElement
  , onDidFocus :: UnitEventHandler eff
  , onWillFocus :: UnitEventHandler eff
  , renderScene :: SceneRenderer r
  , sceneStyle :: Style
  , style :: Style
  }

foreign import data SceneConfig :: *

newtype SceneRenderer r = SceneRenderer (Fn2 r (Navigator r) ReactElement)
newtype SceneConfigurer r = SceneConfigurer (Fn2 r (Array r) SceneConfig)

sceneConfig' :: forall r. (r -> Array r -> SceneConfig) -> SceneConfigurer r
sceneConfig' = SceneConfigurer <<< mkFn2

sceneConfig :: forall r. SceneConfig -> SceneConfigurer r
sceneConfig c = sceneConfig' \_ _ -> c

sceneConfigs ::
  { pushFromRight :: SceneConfig
  , fadeAndroid :: SceneConfig
  , floatFromRight :: SceneConfig
  , floatFromLeft :: SceneConfig
  , floatFromBottom :: SceneConfig
  , floatFromBottomAndroid :: SceneConfig
  , swipeFromLeft :: SceneConfig
  , horizontalSwipeJump :: SceneConfig
  , horizontalSwipeJumpFromRight :: SceneConfig
  , horizontalSwipeJumpFromLeft :: SceneConfig
  , verticalUpSwipeJump :: SceneConfig
  , verticalDownSwipeJump :: SceneConfig
  }
sceneConfigs =
  { pushFromRight: sceneConfigEnum "PushFromRight"
  , fadeAndroid: sceneConfigEnum "FadeAndroid"
  , floatFromRight: sceneConfigEnum "FloatFromRight"
  , floatFromLeft: sceneConfigEnum "FloatFromLeft"
  , floatFromBottom: sceneConfigEnum "FloatFromBottom"
  , floatFromBottomAndroid: sceneConfigEnum "FloatFromBottomAndroid"
  , swipeFromLeft: sceneConfigEnum "SwipeFromLeft"
  , horizontalSwipeJump: sceneConfigEnum "HorizontalSwipeJump"
  , horizontalSwipeJumpFromRight: sceneConfigEnum "HorizontalSwipeJumpFromRight"
  , horizontalSwipeJumpFromLeft: sceneConfigEnum "HorizontalSwipeJumpFromLeft"
  , verticalUpSwipeJump: sceneConfigEnum "VerticalUpSwipeJump"
  , verticalDownSwipeJump: sceneConfigEnum "VerticalDownSwipeJump"
  }

sceneRenderer :: forall r. (r -> (Navigator r) -> ReactElement) -> SceneRenderer r
sceneRenderer = SceneRenderer <<< mkFn2

foreign import sceneConfigEnum :: String -> SceneConfig
foreign import getCurrentRoutes :: forall r. (Navigator r) -> Array r
foreign import push :: forall r eff. (Navigator r) -> r -> Eff (state::ReactState ReadWrite|eff) Unit
foreign import pop :: forall r eff. (Navigator r) -> Eff (state::ReactState ReadWrite|eff) Unit
