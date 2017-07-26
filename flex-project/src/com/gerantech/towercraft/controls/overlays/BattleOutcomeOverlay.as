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
	
	import starling.core.Starling;
	import starling.display.Quad;
	import starling.events.Event;

	public class BattleOutcomeOverlay extends BaseOverlay
	{
		[Embed(source = "../../../../../assets/animations/battleoutcome/battle-outcome_ske.json", mimeType = "application/octet-stream")]
		public static const skeletonClass: Class;
		[Embed(source = "../../../../../assets/animations/battleoutcome/battle-outcome_tex.json", mimeType = "application/octet-stream")]
		public static const atlasDataClass: Class;
		[Embed(source = "../../../../../assets/animations/battleoutcome/battle-outcome_tex.png")]
		public static const atlasImageClass: Class;

		public static var factory: StarlingFactory;
		public static var dragonBonesData:DragonBonesData;
		
		public var score:int;
		private var rewards:ISFSArray;
		public var tutorialMode:Boolean;
		private var armatureDisplay:StarlingArmatureDisplay ;
		
		public function BattleOutcomeOverlay(score:int, rewards:ISFSArray, tutorialMode:Boolean=false)
		{
			super();
			
			this.score = score;
			this.rewards = rewards;
			this.tutorialMode = tutorialMode;
			if(factory == null)
			{
				factory = new StarlingFactory();
				dragonBonesData = BattleOutcomeOverlay.factory.parseDragonBonesData( JSON.parse(new skeletonClass()) );
				factory.parseTextureAtlasData( JSON.parse(new atlasDataClass()), new atlasImageClass() );
			}
		}
		
		override protected function initialize():void
		{
			super.initialize();
			autoSizeMode = AutoSizeMode.STAGE;

			layout = new AnchorLayout();
			
			var hlayout:HorizontalLayout = new HorizontalLayout();
			hlayout.horizontalAlign = HorizontalAlign.CENTER;
			hlayout.verticalAlign = VerticalAlign.MIDDLE;
			hlayout.paddingBottom = 42 * appModel.scale;
			hlayout.gap = 32 * appModel.scale;
			
			if( rewards.size() > 0 )
			{
				var rewardsList:List = new List();
				rewardsList.backgroundSkin = new Quad(1, 1, 0);
				rewardsList.backgroundSkin.alpha = 0.6;
				rewardsList.height = 320*appModel.scale;
				rewardsList.layout = hlayout;
				rewardsList.layoutData = new AnchorLayoutData(NaN, 0, NaN, 0, NaN, 160*appModel.scale);
				rewardsList.itemRendererFactory = function ():IListItemRenderer { return new BattleOutcomeRewardItemRenderer();	}
				rewardsList.dataProvider = new ListCollection(SFSArray(rewards).toArray());
				addChild(rewardsList);
			}
			
			var buttons:LayoutGroup = new LayoutGroup();
			buttons.layout = hlayout;
			buttons.layoutData = new AnchorLayoutData(NaN, NaN, NaN, NaN, 0, (rewards.size()>0?480:220)*appModel.scale);
			addChild(buttons);
			
			var closeBatton:Button = new Button();
			closeBatton.name = "close";
			closeBatton.label = loc("close_button");
			closeBatton.addEventListener(Event.TRIGGERED, buttons_triggeredHandler);
			buttons.addChild(closeBatton);

			/*if(score == 0)
			{
				var retryButton:Button = new Button();
				retryButton.name = "retry";
				retryButton.label = loc("retry_button");
				retryButton.addEventListener(Event.TRIGGERED, buttons_triggeredHandler);
				buttons.addChild(retryButton);
			}*/
			appModel.sounds.addAndPlaySound("outcome-"+(score>0?"victory":"defeat"));
		}
		
		private function buttons_triggeredHandler(event:Event):void
		{
			if(Button(event.currentTarget).name == "retry")
			{
				dispatchEventWith(FeathersEventType.CLEAR, false);
				setTimeout(close, 100);
			}
			else
				close(false);
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
			this.addChild(armatureDisplay);
			
			if(!appModel.battleFieldView.battleData.map.isQuest && score==0)
				armatureDisplay.animation.gotoAndPlayByTime("draw_0", 0, 1);
			else
				armatureDisplay.animation.gotoAndPlayByTime("star_" + Math.max(0,score), 0, 1);
		}
	}
}