package com.gerantech.towercraft.controls.overlays
{
	import com.gerantech.towercraft.controls.items.BattleOutcomeRewardItemRenderer;
	import com.smartfoxserver.v2.entities.data.ISFSArray;
	import com.smartfoxserver.v2.entities.data.SFSArray;
	
	import flash.utils.setTimeout;
	
	import dragonBones.objects.DragonBonesData;
	import dragonBones.starling.StarlingArmatureDisplay;
	import dragonBones.starling.StarlingFactory;
	
	import feathers.controls.AutoSizeMode;
	import feathers.controls.Button;
	import feathers.controls.LayoutGroup;
	import feathers.controls.List;
	import feathers.controls.renderers.IListItemRenderer;
	import feathers.data.ListCollection;
	import feathers.events.FeathersEventType;
	import feathers.layout.AnchorLayout;
	import feathers.layout.AnchorLayoutData;
	import feathers.layout.HorizontalAlign;
	import feathers.layout.HorizontalLayout;
	import feathers.layout.VerticalAlign;
	
	import starling.events.Event;

	public class BattleOutcomeOverlay extends BaseOverlay
	{
		[Embed(source = "../../../../../assets/animations/battleoutcome/battle-outcome-mc_ske.json", mimeType = "application/octet-stream")]
		public static const skeletonClass: Class;
		[Embed(source = "../../../../../assets/animations/battleoutcome/battle-outcome-mc_tex.json", mimeType = "application/octet-stream")]
		public static const atlasDataClass: Class;
		[Embed(source = "../../../../../assets/animations/battleoutcome/battle-outcome-mc_tex.png")]
		public static const atlasImageClass: Class;
		
		public var score:int;
		public var tutorialMode:Boolean;

		private var factory: StarlingFactory;
		private var dragonBonesData:DragonBonesData;
		private var armatureDisplay:StarlingArmatureDisplay ;
		private var rewards:ISFSArray;
		
		public function BattleOutcomeOverlay(score:int, rewards:ISFSArray, tutorialMode:Boolean=false)
		{
			super();
			
			this.score = score;
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
			
			var hlayout:HorizontalLayout = new HorizontalLayout();
			hlayout.horizontalAlign = HorizontalAlign.CENTER;
			hlayout.verticalAlign = VerticalAlign.MIDDLE;
			hlayout.gap = 20;
			
			var rewardsList:List = new List();
			rewardsList.height = 320*appModel.scale;
			rewardsList.layout = hlayout;
			rewardsList.layoutData = new AnchorLayoutData(NaN, NaN, NaN, NaN, 0, 50);
			rewardsList.itemRendererFactory = function ():IListItemRenderer
			{
				return new BattleOutcomeRewardItemRenderer();	
			}
			rewardsList.dataProvider = new ListCollection(SFSArray(rewards).toArray());
			addChild(rewardsList);
			
			var buttons:LayoutGroup = new LayoutGroup();
			buttons.layout = hlayout;
			buttons.layoutData = new AnchorLayoutData(NaN, NaN, NaN, NaN, 0, 480*appModel.scale);
			addChild(buttons);
			
			var closeBatton:Button = new Button();
			closeBatton.name = "close";
			closeBatton.label = loc("close_button");
			closeBatton.addEventListener(Event.TRIGGERED, buttons_triggeredHandler);
			buttons.addChild(closeBatton);

			if(score == 0)
			{
				var retryButton:Button = new Button();
				retryButton.name = "retry";
				retryButton.label = loc("retry_button");
				retryButton.addEventListener(Event.TRIGGERED, buttons_triggeredHandler);
				buttons.addChild(retryButton);
			}
		}
		
		private function buttons_triggeredHandler(event:Event):void
		{
			if(Button(event.currentTarget).name == "retry")
			{
				dispatchEventWith(FeathersEventType.CLEAR, false);
				setTimeout(close, 100);
			}
			else
				close();
		}		
		
		override protected function addedToStageHandler(event:Event):void
		{
			super.addedToStageHandler(event);
			closable = false;
			if(dragonBonesData == null)
				return;
			
			armatureDisplay = factory.buildArmatureDisplay(dragonBonesData.armatureNames[0]);
			armatureDisplay.x = stage.stageWidth/2;
			armatureDisplay.y = stage.stageHeight / 2;
			armatureDisplay.scale = appModel.scale;
			armatureDisplay.animation.gotoAndPlayByTime("star_" + score, 0, 1);
			
			this.addChild(armatureDisplay);
		}
	}
}