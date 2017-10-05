package com.gerantech.towercraft.controls.overlays
{
	import com.gerantech.towercraft.controls.buttons.CustomButton;
	import com.gerantech.towercraft.controls.items.BattleOutcomeRewardItemRenderer;
	import com.gerantech.towercraft.models.Assets;
	import com.gt.towers.constants.ResourceType;
	import com.smartfoxserver.v2.entities.data.ISFSArray;
	import com.smartfoxserver.v2.entities.data.SFSArray;
	
	import flash.utils.setTimeout;
	
	import dragonBones.objects.DragonBonesData;
	import dragonBones.starling.StarlingArmatureDisplay;
	import dragonBones.starling.StarlingFactory;
	
	import feathers.controls.AutoSizeMode;
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
			hlayout.gap = 48 * appModel.scale;
			
			if( rewards.size() > 0 )
			{
				var rewardsList:List = new List();
				rewardsList.backgroundSkin = new Quad(1, 1, 0);
				rewardsList.backgroundSkin.alpha = 0.6;
				rewardsList.height = 400*appModel.scale;
				rewardsList.layout = hlayout;
				rewardsList.layoutData = new AnchorLayoutData(NaN, 0, NaN, 0, NaN, 160*appModel.scale);
				rewardsList.itemRendererFactory = function ():IListItemRenderer { return new BattleOutcomeRewardItemRenderer();	}
				rewardsList.dataProvider = getRewardsCollection();
				addChild(rewardsList);
			}
			
			var buttons:LayoutGroup = new LayoutGroup();
			buttons.layout = hlayout;
			buttons.layoutData = new AnchorLayoutData(NaN, NaN, NaN, NaN, 0, (rewards.size()>0?480:220)*appModel.scale);
			addChild(buttons);
			
			var hasRetry:Boolean = appModel.battleFieldView.battleData.map.isQuest && !player.inTutorial() && !appModel.battleFieldView.battleData.isLeft;
			
			var closeBatton:CustomButton = new CustomButton();
			closeBatton.width = 300 * appModel.scale;
			closeBatton.height = 120 * appModel.scale;
			if( hasRetry )
				closeBatton.style = "danger";
			closeBatton.name = "close";
			closeBatton.label = loc("close_button");
			closeBatton.addEventListener(Event.TRIGGERED, buttons_triggeredHandler);
			Starling.juggler.tween(closeBatton, 0.5, {delay:2, alpha:1});
			closeBatton.alpha = 0;
			buttons.addChild(closeBatton);

			if( hasRetry )
			{
				var retryButton:CustomButton = new CustomButton();
				retryButton.name = "retry";
				retryButton.width = 300 * appModel.scale;
				retryButton.height = 120 * appModel.scale;
				if( !keyExists && score < 3 )
				{
					retryButton.label = "+   " + loc("retry_button");
					retryButton.icon = Assets.getTexture("timer", "gui");
				}
				else
				{
					retryButton.label = loc("retry_button");
				}
				retryButton.addEventListener(Event.TRIGGERED, buttons_triggeredHandler);
				Starling.juggler.tween(retryButton, 0.5, {delay:2.1, alpha:1});
				retryButton.alpha = 0;
				buttons.addChild(retryButton);
			}
				
			appModel.sounds.addAndPlaySound("outcome-"+(score>0?"victory":"defeat"));
		}
		
		private function get keyExists():Boolean
		{
			for (var i:int = 0; i < rewards.size(); i++) 
				if( rewards.getSFSObject(i).getInt("t") == ResourceType.KEY )
					return true;
			return false;
		}
		
		private function getRewardsCollection():ListCollection
		{
			var rw:Array = SFSArray(rewards).toArray();
			var ret:ListCollection = new ListCollection();
			for ( var i:int=0; i<rw.length; i++ )
				if( rw[i].t == ResourceType.POINT || rw[i].t == ResourceType.KEY || rw[i].t == ResourceType.CURRENCY_SOFT )
					ret.addItem( rw[i] );
				
			return ret;
		}
		
		private function buttons_triggeredHandler(event:Event):void
		{
			if(CustomButton(event.currentTarget).name == "retry")
			{
				dispatchEventWith(FeathersEventType.CLEAR, false, !keyExists && score < 3);
				setTimeout(close, 10);
			}
			else
				close(false);
		}		
		
		override protected function addedToStageHandler(event:Event):void
		{
			super.addedToStageHandler(event);
			closeOnStage = false;
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