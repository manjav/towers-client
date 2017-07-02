package com.gerantech.towercraft.controls.buttons
{
	import com.gerantech.towercraft.controls.TowersLayout;
	
	import flash.geom.Point;
	import flash.utils.getTimer;
	
	import feathers.controls.ButtonState;
	import feathers.events.FeathersEventType;
	import feathers.skins.ImageSkin;
	
	import starling.events.Event;
	import starling.events.Touch;
	import starling.events.TouchEvent;
	import starling.events.TouchPhase;
	
	[Event(name="triggered",type="starling.events.Event")]
	[Event(name="longPress",type="starling.events.Event")]
	
	public class SimpleLayoutButton extends TowersLayout
	{
		
		public var stateNames:Vector.<String> = new <String>
			[
				ButtonState.UP, ButtonState.DOWN, ButtonState.DISABLED
			];
		
		private static const HELPER_POINT:Point = new Point();
		
		private var touchPointID:int;
		protected var _touchBeginTime:int;
		public var isLongPressEnabled:Boolean = false;
		protected var _hasLongPressed:Boolean = false;
		public var longPressDuration:Number = 0.5;
		public var keepDownStateOnRollOut:Boolean = false;
		private var _currentState:String = ButtonState.UP;

		protected var skin:ImageSkin;

		public function SimpleLayoutButton()
		{
			super();
			this.isQuickHitAreaEnabled = true;
			this.addEventListener(TouchEvent.TOUCH, button_touchHandler);
			this.addEventListener(Event.REMOVED_FROM_STAGE, button_removedFromStageHandler);
		}
		
		protected function set isEnabled(value:Boolean):void
		{
			super.isEnabled = value;
			currentState = value ? ButtonState.UP : ButtonState.DISABLED;
		}
		
		protected function get isEnabled():Boolean
		{
			return super.isEnabled;
		}
		
		public function get currentState():String
		{
			return _currentState;
		}
		public function set currentState(value:String):void
		{
			if(this._currentState == value)
				return;
			
			if(this.stateNames.indexOf(value) < 0)
				throw new ArgumentError("Invalid state: " + value + ".");
			
			_currentState = value;
			if(skin)
				skin.defaultTexture = skin.getTextureForState(_currentState);
			//trace(name, _currentState)
		}

		/**
		 * @private
		 */
		protected function resetTouchState(touch:Touch = null):void
		{
			this.touchPointID = -1;
			this.removeEventListener(Event.ENTER_FRAME, longPress_enterFrameHandler);
			if(this._isEnabled)
				this.currentState = ButtonState.UP;
			else
				this.currentState = ButtonState.DISABLED;
		}
		
		/**
		 * Triggers the button.
		 */
		protected function trigger():void
		{
			if(hasEventListener(Event.TRIGGERED))
				this.dispatchEventWith(Event.TRIGGERED, false, this);
		}
		
				
		/**
		 * @private
		 */
		protected function button_removedFromStageHandler(event:Event):void
		{
			this.resetTouchState();
		}
		
		/**
		 * @private
		 */
		protected function button_touchHandler(event:TouchEvent):void
		{
			if(!this._isEnabled)
			{
				this.touchPointID = -1;
				return;
			}
			
			if(this.touchPointID >= 0)
			{
				var touch:Touch = event.getTouch(this, null, this.touchPointID);
				if(!touch)
				{
					//this should never happen
					return;
				}
				
				touch.getLocation(this.stage, HELPER_POINT);
				var isInBounds:Boolean = this.contains(this.stage.hitTest(HELPER_POINT));
				if(touch.phase == TouchPhase.MOVED)
				{
					if(isInBounds || this.keepDownStateOnRollOut)
						this.currentState = ButtonState.DOWN;
					else
						this.currentState = ButtonState.UP;
				}
				else if(touch.phase == TouchPhase.ENDED)
				{
					this.resetTouchState(touch);
					//we we dispatched a long press, then triggered and change
					//won't be able to happen until the next touch begins
					if(!this._hasLongPressed && isInBounds)
					{
						this.trigger();
					}
				}
				return;
			}
			else //if we get here, we don't have a saved touch ID yet
			{
				touch = event.getTouch(this, TouchPhase.BEGAN);
				if(touch)
				{
					this.currentState = ButtonState.DOWN;
					this.touchPointID = touch.id;
					if(this.isLongPressEnabled)
					{
						this._touchBeginTime = getTimer();
						this._hasLongPressed = false;
						this.addEventListener(Event.ENTER_FRAME, longPress_enterFrameHandler);
					}
					return;
				}
				/*touch = event.getTouch(this, TouchPhase.HOVER);
				if(touch)
				{
					this.currentState = ButtonState.HOVER;
					return;
				}*/
				
				//end of hover
				this.currentState = ButtonState.UP;
			}
		}
		
		/**
		 * @private
		 */
		protected function longPress_enterFrameHandler(event:Event):void
		{
			var accumulatedTime:Number = (getTimer() - this._touchBeginTime) / 1000;
			if(accumulatedTime >= this.longPressDuration)
			{
				this.removeEventListener(Event.ENTER_FRAME, longPress_enterFrameHandler);
				this._hasLongPressed = true;
				this.dispatchEventWith(FeathersEventType.LONG_PRESS);
			}
		}
	}
}