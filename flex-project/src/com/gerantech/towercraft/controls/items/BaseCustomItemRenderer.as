package com.gerantech.towercraft.controls.items
{
	import com.gerantech.towercraft.managers.TutorialManager;
	import com.gerantech.towercraft.models.AppModel;
	import com.gt.towers.Game;
	import com.gt.towers.Player;
	
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import flash.utils.clearInterval;
	import flash.utils.setInterval;
	
	import mx.resources.ResourceManager;
	
	import feathers.controls.renderers.LayoutGroupListItemRenderer;
	import feathers.skins.ImageSkin;
	
	import starling.display.DisplayObjectContainer;
	import starling.events.Event;
	import starling.events.Touch;
	import starling.events.TouchEvent;
	import starling.events.TouchPhase;
	
	public class BaseCustomItemRenderer extends LayoutGroupListItemRenderer
	{
		public static const STATE_NORMAL:String = "normal";
		public static const STATE_DOWN:String = "down";
		public static const STATE_SELECTED:String = "selected";
		public static const STATE_DISABLED:String = "disabled";
		public var stateNames:Vector.<String> = new <String>
			[
				STATE_NORMAL, STATE_DOWN, STATE_SELECTED, STATE_DISABLED
			];
		
		public var deleyCommit:Boolean = true;
		public static var FAST_COMMIT_TIMEOUT:uint = 0;
		public static var SLOW_COMMIT_TIMEOUT:uint = 400;
		
		private var _currentState:String = STATE_NORMAL;
		private var intevalId:uint;
		
		private var touchID:int = -1;
		private static const HELPER_POINT:Point = new Point();
		private var tempY:Number;
		
		private var screenRect:Rectangle;
		private var commitPhase:uint;

		protected var touchTarget:DisplayObjectContainer;
		protected var touch:Touch;
		protected var skin:ImageSkin;
		
		override protected function initialize():void
		{
			touchTarget = this;
			addEventListener( TouchEvent.TOUCH, touchHandler);
			addEventListener( Event.REMOVED_FROM_STAGE, removedFromStageHandler );
		}
		
		/*protected function createSkin():void
		{
			skin = new ImageSkin(Assets.getBackgroundTexture());
			for each(var s:String in stateNames)
				skin.setTextureForState(s, Assets.getBackgroundTexture(s));
			skin.scale9Grid = Assets.BACKGROUND_GRID;
			backgroundSkin = skin;
		}*/
		
		override protected function commitData():void
		{
			super.commitData();
			if(deleyCommit)
			{
				//clearInterval(intevalId);
				//intevalId = setInterval(checkScrolling, SLOW_COMMIT_TIMEOUT);
				commitPhase = 0;
			}
		}		
		/*protected function get isShow():Boolean
		{
			if(screenRect==null)
				screenRect = appModel.navigator.activeScreen.getBounds(stage);
			try
			{
				var rect:Rectangle = getBounds(appModel.navigator.activeScreen);
				return rect.x<(screenRect.x+screenRect.width) && (rect.x+rect.width)>screenRect.x && rect.y<(screenRect.y+screenRect.height) && (rect.y+rect.height)>screenRect.y;		
			}
			catch(error:Error){}
			return false;
		}
		private function checkScrolling():void
		{
			var rect:Rectangle = getBounds(_owner);
			var speed:Number = Math.abs(tempY-rect.y);
			if(commitPhase==0 && speed<AppModel.instance.sizes.twoLineItem*5)
			{
				commitPhase = 1;
				commitBeforeStopScrolling();
			}
			else if(commitPhase==1 && speed<AppModel.instance.sizes.twoLineItem)
			{
				commitPhase = 2;
				clearInterval(intevalId);
				commitAfterStopScrolling();
			}
			tempY = rect.y;
		}*/		
		
		protected function commitBeforeStopScrolling():void
		{
		}
		protected function commitAfterStopScrolling():void
		{
		}
	
		
		protected function touchHandler( event:TouchEvent ):void
		{
			if( !_isEnabled || _currentState == STATE_DISABLED)
			{
				touchID = -1;
				return;
			}
			//trace("touchHandler", index, touchID)
			if( touchID >= 0 )
			{
				touch = event.getTouch( touchTarget, null, touchID );
				if( !touch )
					return;
			
				if( touch.phase == TouchPhase.ENDED )
				{
					touch.getLocation( touchTarget.stage, HELPER_POINT );
					var isInBounds:Boolean = touchTarget.contains( touchTarget.stage.hitTest( HELPER_POINT ) );
					if( isInBounds )
					{
						dispatchEventWith(Event.TRIGGERED);
						if(_owner.allowMultipleSelection)
							isSelected = !isSelected;
						else
							isSelected = true;
					}
					// the touch has ended, so now we can start watching for a new one.
					touchID = -1;
				}
				return;
			}
			else
			{
				// we aren't tracking another touch, so let's look for a new one.
				touch = event.getTouch( touchTarget, TouchPhase.BEGAN );
				if(touch)
				{
					currentState = STATE_DOWN;
				}
				else
				{
					// we only care about the began phase. ignore all other phases.
					return;
				}
				// save the touch ID so that we can track this touch's phases.
				touchID = touch.id;
			}
		}
		protected function removedFromStageHandler( event:Event ):void
		{
			clearInterval(intevalId);
			touchID = -1;
		}
		
		override public function set isSelected(value:Boolean):void
		{
			if(currentState == STATE_DISABLED)
				return;	
			super.isSelected = value;

			currentState = value ? STATE_SELECTED : STATE_NORMAL;
		}
		
		public function get currentState():String
		{
			return _currentState;
		}
		public function set currentState(value:String):void
		{
			//trace(index, _currentState, value)
			if(_currentState == value)
				return;
			
			if(stateNames.indexOf(value) < 0)
			{
				throw new ArgumentError("Invalid state: " + value + ".");
				return;
			}
			
			_currentState = value;
			
			if(_currentState == STATE_DISABLED && isEnabled)
				isEnabled = false;
			else if(_currentState != STATE_DISABLED && !isEnabled)
				isEnabled = true;
			
			if(skin)
				skin.defaultTexture = skin.getTextureForState(_currentState);
		}	
		
		protected function loc(resourceName:String, parameters:Array=null, locale:String=null):String
		{
			return ResourceManager.getInstance().getString("loc", resourceName, parameters, locale);
		}
		protected function get appModel():		AppModel		{	return AppModel.instance;			}
		protected function get tutorials():		TutorialManager	{	return TutorialManager.instance;	}
		protected function get core():			Game			{	return Game.get_instance();			}
		protected function get player():		Player			{	return core.get_player();			}
	}
}