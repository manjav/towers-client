package com.gerantech.towercraft.controls.overlays
{
	import com.gerantech.towercraft.controls.Devider;
	import com.gerantech.towercraft.controls.TowersLayout;
	
	import flash.geom.Point;
	import flash.ui.Keyboard;
	
	import feathers.events.FeathersEventType;
	
	import starling.core.Starling;
	import starling.display.DisplayObject;
	import starling.events.Event;
	import starling.events.KeyboardEvent;
	import starling.events.Touch;
	import starling.events.TouchEvent;
	import starling.events.TouchPhase;
	
	public class BaseOverlay extends TowersLayout
	{
		public var overlayFactory:Function;
		public var transitionIn:TransitionData;
		public var transitionOut:TransitionData;
		public var data:Object;
		public var isOpen:Boolean;
		
		public var closeOnOverlay:Boolean = false;
		protected var _closeOnStage:Boolean = true;
		
		protected var overlay:DisplayObject;
		protected var transitionState:int;
		
		protected static const HELPER_POINT:Point = new Point();
		protected var initializingStarted:Boolean;
		protected var initializingCompleted:Boolean;
		
		public function BaseOverlay()
		{
			addEventListener(Event.ADDED_TO_STAGE, addedToStageHandler);
		}
		
		override protected function initialize():void
		{
			super.initialize();
			initializingStarted = true;
			
			if(overlayFactory == null)
				overlayFactory = defaultOverlayFactory;
			
			if(overlay == null)
				overlay = overlayFactory();
			addChildAt(overlay, 0);
		}
		protected function transitionInStarted():void
		{
			transitionState = TransitionData.STATE_IN_STARTED;
			isOpen = true;
			if(hasEventListener(FeathersEventType.TRANSITION_IN_START))
				dispatchEventWith(FeathersEventType.TRANSITION_IN_START);
		}
		protected function transitionInCompleted():void
		{
			transitionState = TransitionData.STATE_IN_FINISHED;
			if(hasEventListener(FeathersEventType.TRANSITION_IN_COMPLETE))
				dispatchEventWith(FeathersEventType.TRANSITION_IN_COMPLETE);
		}
		
		protected function defaultOverlayFactory():DisplayObject
		{
			var overlay:Devider = new Devider();
			overlay.alpha = 0.4;
			overlay.width = stage.width * 3;
			overlay.height = stage.height * 3;
			overlay.x = -overlay.width / 2;
			overlay.y = -overlay.height / 2;
			return overlay;
		}
		
		protected function addedToStageHandler(event:Event):void
		{
			removeEventListener( Event.ADDED_TO_STAGE, addedToStageHandler);
			addEventListener( Event.REMOVED_FROM_STAGE, removeFromStageHandler);
			stage.addEventListener( KeyboardEvent.KEY_DOWN, stage_keyUpHandler);
			stage.addEventListener( TouchEvent.TOUCH, stage_touchHandler);
		}
		
		protected function removeFromStageHandler(event:Event):void
		{
			removeEventListener( Event.REMOVED_FROM_STAGE, removeFromStageHandler);
			stage.removeEventListener( KeyboardEvent.KEY_DOWN, stage_keyUpHandler);
			stage.removeEventListener( TouchEvent.TOUCH, stage_touchHandler);
		}
		
		protected function stage_keyUpHandler(event:KeyboardEvent):void
		{
			if( event.keyCode == Keyboard.BACK )
			{
				event.preventDefault();
				if( ( closeOnStage || closeOnOverlay ) && _isEnabled )
					close();
			}
		}
		protected function stage_touchHandler(event:TouchEvent):void
		{
			if( !_isEnabled )
				return;
			
			var touch:Touch;
			if( closeOnOverlay )
			{
				touch = event.getTouch(overlay, TouchPhase.ENDED);
				if( touch != null )
				{
					close();
					return;
				}
			}
			
			if( !closeOnStage )
				return;

			// we aren't tracking another touch, so let's look for a new one.
			touch = event.getTouch(stage, TouchPhase.BEGAN);
			if( touch == null )
				return;

			/*touch.getLocation( overlay, HELPER_POINT );
			if(!this.contains( stage.hitTest( HELPER_POINT ) ))*/
			close();
		}
		
		public function close(dispose:Boolean=true):void
		{
			if(!dispose)
				addEventListener( Event.ADDED_TO_STAGE, addedToStageHandler);
			
			if(hasEventListener(Event.CLOSE))
				dispatchEventWith(Event.CLOSE);
			
			Starling.juggler.removeTweens(this);
			
			if(transitionOut == null)
				transitionOutCompleted(dispose);
			isOpen = false;
		}
		protected function transitionOutStarted():void
		{
			transitionState = TransitionData.STATE_OUT_STARTED;
			if(hasEventListener(FeathersEventType.TRANSITION_OUT_START))
				dispatchEventWith(FeathersEventType.TRANSITION_OUT_START);
		}
		protected function transitionOutCompleted(dispose:Boolean=true):void
		{
			transitionState = TransitionData.STATE_OUT_FINISHED;
			if(hasEventListener(FeathersEventType.TRANSITION_OUT_COMPLETE))
				dispatchEventWith(FeathersEventType.TRANSITION_OUT_COMPLETE);
			removeFromParent(dispose);
		}
		
		
		public function get closeOnStage():Boolean
		{
			return _closeOnStage;
		}
		public function set closeOnStage(value:Boolean):void
		{
			_closeOnStage = value;
		}
	
	}
}