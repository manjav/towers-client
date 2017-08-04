package com.gerantech.towercraft.controls.overlays
{
	import com.gerantech.towercraft.controls.ChestReward;
	import com.gerantech.towercraft.controls.buttons.SimpleLayoutButton;
	import com.gt.towers.exchanges.ExchangeItem;
	
	import flash.utils.setTimeout;
	
	import dragonBones.events.EventObject;
	import dragonBones.objects.DragonBonesData;
	import dragonBones.starling.StarlingArmatureDisplay;
	import dragonBones.starling.StarlingEvent;
	import dragonBones.starling.StarlingFactory;
	
	import feathers.controls.AutoSizeMode;
	import feathers.layout.AnchorLayout;
	import feathers.layout.AnchorLayoutData;
	
	import starling.animation.Transitions;
	import starling.core.Starling;
	import starling.display.DisplayObject;
	import starling.events.Event;
	
	public class OpenChestOverlay extends BaseOverlay
	{
		[Embed(source = "../../../../../assets/animations/chests/chests_ske.json", mimeType = "application/octet-stream")]
		public static const skeletonClass: Class;
		[Embed(source = "../../../../../assets/animations/chests/chests_tex.json", mimeType = "application/octet-stream")]
		public static const atlasDataClass: Class;
		[Embed(source = "../../../../../assets/animations/chests/chests_tex.png")]
		public static const atlasImageClass: Class;
		
		public static var factory: StarlingFactory;
		public static var dragonBonesData:DragonBonesData;
		public var item:ExchangeItem;

		private var rewardKeys:Vector.<int>;
		private var rewardItems:Vector.<ChestReward>;
		private var openAnimation:StarlingArmatureDisplay ;
		private var collectedItemIndex:int = 0;
		private var buttonOverlay:SimpleLayoutButton;

		public function OpenChestOverlay(item:ExchangeItem)
		{
			super();
			
			this.item = item;
			createFactory();
		}
		
		public static function createFactory():void
		{
			if(factory != null)
				return;
			factory = new StarlingFactory();
			dragonBonesData = factory.parseDragonBonesData( JSON.parse(new skeletonClass()) );
			factory.parseTextureAtlasData( JSON.parse(new atlasDataClass()), new atlasImageClass() );
		}			
		
		override protected function initialize():void
		{
			super.initialize();
			autoSizeMode = AutoSizeMode.STAGE;
			
			layout = new AnchorLayout();
			overlay.alpha = 0;
			Starling.juggler.tween(overlay, 0.5,
				{
					alpha:1,
					onStart:transitionInStarted,
					onComplete:transitionInCompleted
				}
			);
		}
		override protected function defaultOverlayFactory():DisplayObject
		{
			var overlay:DisplayObject = super.defaultOverlayFactory();
			overlay.alpha = 1;
			overlay.touchable = true;
			return overlay;
		}
	
		override protected function addedToStageHandler(event:Event):void
		{
			super.addedToStageHandler(event);
			closable = false;
			if(dragonBonesData == null)
				return;
			
			appModel.sounds.setVolume("main-theme", 0.3);
			
			openAnimation = factory.buildArmatureDisplay(dragonBonesData.armatureNames[(item.type%10)-1]);
			openAnimation.touchable = openAnimation.touchGroup = false
			openAnimation.scale = appModel.scale;
			openAnimation.addEventListener(EventObject.COMPLETE, openAnimation_completeHandler);
			openAnimation.addEventListener(EventObject.SOUND_EVENT, openAnimation_soundEventHandler);
			openAnimation.animation.gotoAndPlayByTime("fall", 0, 1);
			addChild(openAnimation);

			buttonOverlay = new SimpleLayoutButton();
			buttonOverlay.addEventListener(Event.TRIGGERED, buttonOverlay_triggeredHandler);
			buttonOverlay.layoutData = new AnchorLayoutData(0,0,0,0);
			addChild(buttonOverlay);
			
			rewardItems = new Vector.<ChestReward>();
			rewardKeys = item.outcomes.keys();
		}
		
		private function openAnimation_soundEventHandler(event:StarlingEvent):void
		{
			appModel.sounds.addAndPlaySound(event.eventObject.name)
		}
		
		protected function openAnimation_completeHandler(event:StarlingEvent):void
		{
			if(event.eventObject.animationState.name == "fall")
				openAnimation.animation.gotoAndPlayByTime("wait", 0, -1);
			else if(event.eventObject.animationState.name == "hide")
				close();
		}		
		
		protected function buttonOverlay_triggeredHandler():void
		{
			grabAllRewards();
			if( collectedItemIndex < item.outcomes.keys().length )
			{
				openAnimation.animation.gotoAndPlayByTime(collectedItemIndex < rewardKeys.length-1?"open":"openLast", 0, 1);
				buttonOverlay.touchable = false;
				showReward();
			}
			else if(collectedItemIndex == rewardKeys.length+1)
			{
				setTimeout(openAnimation.animation.gotoAndPlayByTime, 500, "hide", 0, 1);
				hideAllRewards();
			}
			collectedItemIndex ++;
		}
		
		private function hideAllRewards():void
		{
			for(var i:int=0; i<rewardItems.length; i++)
				Starling.juggler.tween(rewardItems[i], 0.4, {delay:0.1*i, y:0, alpha:0, transition:Transitions.EASE_IN_BACK});
		}
		private function grabAllRewards():void
		{
			for(var i:int=0; i<rewardItems.length; i++)
				grabReward(rewardItems[i]);
		}
		
		private function showReward():void
		{
			var chestReward:ChestReward = new ChestReward(collectedItemIndex, rewardKeys[collectedItemIndex], item.outcomes.get(rewardKeys[collectedItemIndex]));
			chestReward.y = stage.height * 0.7;
			rewardItems[collectedItemIndex] = chestReward;
			addChild(chestReward);
			
			Starling.juggler.tween(chestReward, 0.5, {delay:0.2, scale:1, x:stage.width*0.5, y:stage.height*0.5, transition:Transitions.EASE_OUT_BACK, onComplete:chestRewardShown});
			chestReward.scale = 0;
			chestReward.x = stage.width/2;
			function chestRewardShown():void
			{
				chestReward.showDetails();
				buttonOverlay.touchable = true;
			}
		}
		
		private function grabReward(chestReward:ChestReward):void
		{
			if( chestReward == null || chestReward.state!=1)
				return;
			
			chestReward.hideDetails();
			var scal:Number = 0.8;
			var numCol:int = rewardKeys.length==2||rewardKeys.length==4 ? 2 : 3;
			var paddingH:int = (appModel.isLTR?chestReward.width*0.4:0)*scal + 80*appModel.scale;
			var paddingV:int = chestReward.height*0.5*scal + 80*appModel.scale;
			var cellH:int = ((stage.stageWidth-chestReward.width*0.4*scal-paddingH*2) / (numCol-1));
			Starling.juggler.tween(chestReward, 0.5, {scale:scal, x:(chestReward.index%numCol)*cellH + paddingH, y:Math.floor(chestReward.index/numCol)*chestReward.height*scal + paddingV, transition:Transitions.EASE_OUT_BACK, onComplete:grabCompleted});
			function grabCompleted():void
			{
			}
		}
		
		override public function dispose():void
		{
			appModel.sounds.setVolume("main-theme", 1);
			buttonOverlay.removeEventListener(Event.TRIGGERED, buttonOverlay_triggeredHandler);
			openAnimation.removeEventListener(EventObject.SOUND_EVENT, openAnimation_soundEventHandler);
			openAnimation.removeEventListener(dragonBones.events.EventObject.COMPLETE, openAnimation_completeHandler);
			super.dispose();
		}
	}
}