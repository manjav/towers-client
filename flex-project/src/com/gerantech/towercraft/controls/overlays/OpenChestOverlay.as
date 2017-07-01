package com.gerantech.towercraft.controls.overlays
{
	import com.gerantech.towercraft.controls.ChestReward;
	import com.gerantech.towercraft.controls.buttons.SimpleLayoutButton;
	import com.smartfoxserver.v2.entities.data.ISFSArray;
	
	import flash.utils.setTimeout;
	
	import dragonBones.events.EventObject;
	import dragonBones.objects.DragonBonesData;
	import dragonBones.starling.StarlingArmatureDisplay;
	import dragonBones.starling.StarlingEvent;
	import dragonBones.starling.StarlingFactory;
	
	import feathers.controls.AutoSizeMode;
	import feathers.layout.AnchorLayout;
	import feathers.layout.AnchorLayoutData;
	import feathers.layout.HorizontalAlign;
	import feathers.layout.HorizontalLayout;
	import feathers.layout.VerticalAlign;
	
	import starling.animation.Transitions;
	import starling.core.Starling;
	import starling.events.Event;
	
	public class OpenChestOverlay extends BaseOverlay
	{
		[Embed(source = "../../../../../assets/animations/chests/chests_ske.json", mimeType = "application/octet-stream")]
		public static const skeletonClass: Class;
		[Embed(source = "../../../../../assets/animations/chests/chests_tex.json", mimeType = "application/octet-stream")]
		public static const atlasDataClass: Class;
		[Embed(source = "../../../../../assets/animations/chests/chests_tex.png")]
		public static const atlasImageClass: Class;
		
		public var type:int;
		private var rewards:ISFSArray;
		private var rewardItems:Vector.<ChestReward>;
		
		private var factory: StarlingFactory;
		private var dragonBonesData:DragonBonesData;
		private var openAnimation:StarlingArmatureDisplay ;
		private var collectedItemIndex:int = 0;

		private var buttonOverlay:SimpleLayoutButton;

		public function OpenChestOverlay(type:int, rewards:ISFSArray)
		{
			super();
			
			this.type = type;
			this.rewards = rewards;
			factory = new StarlingFactory();
			dragonBonesData = factory.parseDragonBonesData( JSON.parse(new skeletonClass()) );
			factory.parseTextureAtlasData( JSON.parse(new atlasDataClass()), new atlasImageClass() );
		}
		
		override protected function initialize():void
		{
			super.initialize();
			autoSizeMode = AutoSizeMode.STAGE;
			
			layout = new AnchorLayout();
		}
	
		override protected function addedToStageHandler(event:Event):void
		{
			super.addedToStageHandler(event);
			closable = false;
			if(dragonBonesData == null)
				return;
			
			openAnimation = factory.buildArmatureDisplay(dragonBonesData.armatureNames[type]);
			openAnimation.scale = appModel.scale;
			openAnimation.addEventListener(EventObject.COMPLETE, openAnimation_completeHandler);
			openAnimation.animation.gotoAndPlayByTime("fall", 0, 1);
			addChild(openAnimation);

			buttonOverlay = new SimpleLayoutButton();
			buttonOverlay.addEventListener(Event.TRIGGERED, buttonOverlay_triggeredHandler);
			buttonOverlay.layoutData = new AnchorLayoutData(0,0,0,0);
			addChild(buttonOverlay);
			
			rewardItems = new Vector.<ChestReward>();
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
			if(collectedItemIndex < rewards.size())
			{
				openAnimation.animation.gotoAndPlayByTime(collectedItemIndex < rewards.size()-1?"open":"openLast", 0, 1);
				buttonOverlay.touchable = false;
				showReward();
			}
			else if(collectedItemIndex == rewards.size()+1)
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
			var chestReward:ChestReward = new ChestReward(collectedItemIndex, rewards.getSFSObject(collectedItemIndex));
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
			var numCol:int = rewards.size() > 2 ? 3 : 2;
			var paddingH:int = (appModel.isLTR?chestReward.width*0.4:0)*scal + 140*appModel.scale;
			var paddingV:int = chestReward.height*0.5*scal + 140*appModel.scale;
			var cellH:int = ((stage.stageWidth-chestReward.width*0.4*scal-paddingH*2) / (numCol-1));
			Starling.juggler.tween(chestReward, 0.5, {scale:scal, x:(chestReward.index%numCol)*cellH + paddingH, y:Math.floor(chestReward.index/numCol)*chestReward.height + paddingV, transition:Transitions.EASE_OUT_BACK, onComplete:grabCompleted});
			function grabCompleted():void
			{
			}
		}
		
		override public function dispose():void
		{
			buttonOverlay.removeEventListener(Event.TRIGGERED, buttonOverlay_triggeredHandler);
			openAnimation.removeEventListener(dragonBones.events.EventObject.COMPLETE, openAnimation_completeHandler);
			super.dispose();
		}
	}
}