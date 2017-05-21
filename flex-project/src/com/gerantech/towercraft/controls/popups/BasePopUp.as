package com.gerantech.towercraft.controls.popups
{
	import com.gerantech.towercraft.models.AppModel;
	import com.gt.towers.Game;
	import com.gt.towers.Player;
	
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import flash.ui.Keyboard;
	
	import mx.resources.ResourceManager;
	
	import feathers.controls.Button;
	import feathers.controls.LayoutGroup;
	import feathers.events.FeathersEventType;
	
	import starling.animation.Transitions;
	import starling.core.Starling;
	import starling.display.DisplayObject;
	import starling.events.Event;
	import starling.events.KeyboardEvent;
	import starling.events.Touch;
	import starling.events.TouchEvent;
	import starling.events.TouchPhase;
	
	public class BasePopUp extends LayoutGroup
	{
		public var closable:Boolean = true;
		public var overlayFactory:Function;
		public var transitionIn:PopupTransitionData;
		public var transitionOut:PopupTransitionData;
		
		protected var overlay:DisplayObject;
		private static const HELPER_POINT:Point = new Point();

		public function BasePopUp()
		{
			addEventListener(Event.ADDED_TO_STAGE, addedToStageHandler);
		}
		
		override protected function initialize():void
		{
			super.initialize();
			//autoSizeMode = AutoSizeMode.STAGE; 
			//stage_resizeHandler(null);
			
			if(overlayFactory == null)
				overlayFactory = defaultOverlayFactory;
			
			if(transitionIn == null)
			{
				transitionIn = new PopupTransitionData();
				transitionIn.destinationBound = transitionIn.sourceBound = new Rectangle(0,0,stage.stageWidth, stage.stageHeight);
			}
			if(transitionOut== null)
			{
				transitionOut = new PopupTransitionData();
				transitionOut.transition = Transitions.EASE_IN;
				transitionOut.destinationBound = transitionOut.sourceBound = new Rectangle(0,0,stage.stageWidth, stage.stageHeight);
			}
			
			
			if(overlay == null)
				overlay = overlayFactory();
			
			if(closable)
				overlay.addEventListener(Event.TRIGGERED, close);
			
			// execute popup transition
			x = transitionIn.sourceBound.x;
			y = transitionIn.sourceBound.y;
			width = transitionIn.sourceBound.width;
			height = transitionIn.sourceBound.height;
			
			Starling.juggler.tween(this, transitionIn.time,
				{
					delay:transitionIn.delay,
					alpha:transitionIn.destinationAlpha,
					x:transitionIn.destinationBound.x, 
					y:transitionIn.destinationBound.y, 
					width:transitionIn.destinationBound.width, 
					height:transitionIn.destinationBound.height, 
					transition:transitionIn.transition,
					onStart:transitionInStated,
					onComplete:transitionInCompleted
				}
			);
		}
		protected function transitionInStated():void
		{
			if(hasEventListener(FeathersEventType.TRANSITION_IN_START))
				dispatchEventWith(FeathersEventType.TRANSITION_IN_START);
		}
		protected function transitionInCompleted():void
		{
			if(hasEventListener(FeathersEventType.TRANSITION_IN_COMPLETE))
				dispatchEventWith(FeathersEventType.TRANSITION_IN_COMPLETE);
		}		

		
		private function defaultOverlayFactory():DisplayObject
		{
			var overlay:Button = new Button();
			//overlay.sk = appModel.theme.backgroundSkinTexture;
				
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
			if( !touch )
				return;
			
			touch.getLocation( stage, HELPER_POINT );
			if(!this.contains( stage.hitTest( HELPER_POINT ) ))
				close();
		}
		
		public function close(dispose:Boolean=true):void
		{
			if(!dispose)
				addEventListener( Event.ADDED_TO_STAGE, addedToStageHandler);
			
			if(hasEventListener(Event.CLOSE))
				dispatchEventWith(Event.CLOSE);
			
			Starling.juggler.removeTweens(this);
			Starling.juggler.tween(this, transitionOut.time,
				{
					delay:transitionOut.delay,
					alpha:transitionOut.destinationAlpha,
					x:transitionOut.destinationBound.x, 
					y:transitionOut.destinationBound.y, 
					width:transitionOut.destinationBound.width, 
					height:transitionOut.destinationBound.height, 
					transition:transitionOut.transition,
					onStart:transitionOutStated,
					onComplete:transitionOutCompleted,
					onCompleteArgs:[dispose]
				}
			);
		}
		protected function transitionOutStated():void
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
		
		
		protected function loc(resourceName:String, parameters:Array=null, locale:String=null):String
		{
			return ResourceManager.getInstance().getString("loc", resourceName, parameters, locale);
		}
		protected function get appModel():		AppModel		{	return AppModel.instance;			}
		protected function get core():			Game			{	return Game.get_instance();		}
		protected function get player():		Player			{	return core.get_player();		}
		/*protected function get userModel():		UserModel		{	return UserModel.instance;		}
		protected function get configModel():	ConfigModel		{	return ConfigModel.instance;	}
		protected function get resourceModel():	ResourceModel	{	return ResourceModel.instance;	}*/
		
	}
}