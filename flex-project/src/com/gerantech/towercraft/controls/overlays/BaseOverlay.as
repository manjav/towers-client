package com.gerantech.towercraft.controls.overlays
{
	import com.gerantech.towercraft.controls.Devider;
	import com.gerantech.towercraft.models.AppModel;
	import com.gt.towers.Game;
	import com.gt.towers.Player;
	
	import flash.geom.Point;
	import flash.ui.Keyboard;
	
	import mx.resources.ResourceManager;
	
	import feathers.controls.LayoutGroup;
	import feathers.events.FeathersEventType;
	
	import starling.core.Starling;
	import starling.display.DisplayObject;
	import starling.events.Event;
	import starling.events.KeyboardEvent;
	import starling.events.Touch;
	import starling.events.TouchEvent;
	import starling.events.TouchPhase;
	
	public class BaseOverlay extends LayoutGroup
	{



		public var overlayFactory:Function;
		public var transitionIn:TransitionData;
		public var transitionOut:TransitionData;
		
		protected var overlay:DisplayObject;
		
		protected static const HELPER_POINT:Point = new Point();
		private var _closable:Boolean = true;
		
		public function BaseOverlay()
		{
			addEventListener(Event.ADDED_TO_STAGE, addedToStageHandler);
		}
		
		override protected function initialize():void
		{
			super.initialize();
			
			if(overlayFactory == null)
				overlayFactory = defaultOverlayFactory;
			
			if(overlay == null)
				overlay = overlayFactory();
			addChildAt(overlay, 0);
		}
		protected function transitionInStarted():void
		{
			if(hasEventListener(FeathersEventType.TRANSITION_IN_START))
				dispatchEventWith(FeathersEventType.TRANSITION_IN_START);
		}
		protected function transitionInCompleted():void
		{
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
			overlay.touchable = false;
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
			if( !closable || !_isEnabled )
				return;
			if(event.keyCode==Keyboard.BACK)
			{
				event.preventDefault();
				close();
			}
		}
		protected function stage_touchHandler(event:TouchEvent):void
		{
			if( !closable || !_isEnabled )
				return;
			
			// we aren't tracking another touch, so let's look for a new one.
			var touch:Touch = event.getTouch( stage, TouchPhase.BEGAN);
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

		}
		protected function transitionOutStarted():void
		{
			if(hasEventListener(FeathersEventType.TRANSITION_OUT_START))
				dispatchEventWith(FeathersEventType.TRANSITION_OUT_START);
		}
		protected function transitionOutCompleted(dispose:Boolean=true):void
		{
			if(hasEventListener(FeathersEventType.TRANSITION_OUT_COMPLETE))
				dispatchEventWith(FeathersEventType.TRANSITION_OUT_COMPLETE);
			removeFromParent(dispose);
		}
		
		public function get closable():Boolean
		{
			return _closable;
		}
		public function set closable(value:Boolean):void
		{
			_closable = value;
		}
		
		protected function loc(resourceName:String, parameters:Array=null, locale:String=null):String
		{
			return ResourceManager.getInstance().getString("loc", resourceName, parameters, locale);
		}
		protected function get appModel():		AppModel		{	return AppModel.instance;		}
		protected function get core():			Game			{	return Game.get_instance();		}
		protected function get player():		Player			{	return core.get_player();		}
		
	}
}