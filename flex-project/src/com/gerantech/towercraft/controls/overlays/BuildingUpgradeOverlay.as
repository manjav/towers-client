package com.gerantech.towercraft.controls.overlays
{
	import com.gerantech.towercraft.controls.BuildingCard;
	import com.gerantech.towercraft.controls.buttons.SimpleLayoutButton;
	import com.gerantech.towercraft.controls.items.BuildingFeatureItemRenderer;
	import com.gerantech.towercraft.controls.texts.RTLLabel;
	import com.gt.towers.buildings.Building;
	import com.gt.towers.constants.BuildingFeatureType;
	
	import flash.utils.setTimeout;
	
	import dragonBones.starling.StarlingArmatureDisplay;
	
	import feathers.controls.List;
	import feathers.controls.ScrollPolicy;
	import feathers.controls.renderers.IListItemRenderer;
	import feathers.data.ListCollection;
	import feathers.layout.AnchorLayout;
	import feathers.layout.AnchorLayoutData;
	
	import starling.animation.Transitions;
	import starling.core.Starling;
	import starling.events.Event;

	public class BuildingUpgradeOverlay extends BaseOverlay
	{
		public var building:Building;
		private var initializeStarted:Boolean;
		
		public function BuildingUpgradeOverlay()
		{
			super();
			//BattleOutcomeOverlay.createFactionsFactory(initialize);
		}
		
		override protected function initialize():void
		{
			if( stage != null )
				addChild(defaultOverlayFactory());
			//if( stage == null || appModel.assets.isLoading || initializeStarted )
				//return;
			super.initialize();
			initializeStarted = true;
		
			layout = new AnchorLayout();
			closeOnStage = false;

			width = stage.stageWidth;
			height = stage.stageHeight;
			overlay.alpha = 1;
		/*	
			if(BattleOutcomeOverlay.dragonBonesData == null)
				return;
			
			var armatureDisplay:StarlingArmatureDisplay = BattleOutcomeOverlay.animFactory.buildArmatureDisplay("levelup");
			armatureDisplay.x = stage.stageWidth/2;
			armatureDisplay.y = stage.stageHeight / 2;
			armatureDisplay.scale = appModel.scale;
			armatureDisplay.animation.gotoAndPlayByFrame("appearin", 1, 1);
			addChild(armatureDisplay);*/
			
			
			var card:BuildingCard = new BuildingCard();
			card.showSlider = false;
			card.pivotY = card.height/2
			card.layoutData = new AnchorLayoutData(NaN, NaN, NaN, NaN, 0, NaN);
			card.width = 240 * appModel.scale;
			card.height = card.width*1.4;
			card.y = (stage.stageHeight-card.height)/2;
			addChild(card);
			card.type = building.type;
			card.level = building.get_level()-1;
			card.scale = 1.6;
			
			appModel.sounds.setVolume("main-theme", 0.3);
			setTimeout(levelUp, 500);
			setTimeout(showFeatures, 1800);
			function levelUp():void {
				var titleDisplay:RTLLabel = new RTLLabel(loc("building_title_"+building.type), 1, "center", null, false, null, 1.5);
				titleDisplay.layoutData = new AnchorLayoutData(NaN, NaN, NaN, NaN, 0);
				titleDisplay.y = (stage.stageHeight-card.height)/3;
				addChild(titleDisplay);
			
				card.scale = 2.4;
				card.level = building.get_level(); 
				Starling.juggler.tween(card, 0.3, {scale:1.6, transition:Transitions.EASE_OUT});
				Starling.juggler.tween(card, 0.5, {delay:0.7, y:card.y-150*appModel.scale, transition:Transitions.EASE_IN_OUT});
				
				appModel.sounds.addAndPlaySound("upgrade");
			}
			function showFeatures():void {
				var featureList:List = new List();
				featureList.width = stage.stageWidth/2;
				featureList.layoutData = new AnchorLayoutData(NaN, NaN, NaN, NaN, 0, featureList.width*0.7);
				featureList.horizontalScrollPolicy = featureList.verticalScrollPolicy = ScrollPolicy.OFF;
				featureList.itemRendererFactory = function ():IListItemRenderer { return new BuildingFeatureItemRenderer(building, -1); }
				featureList.dataProvider = new ListCollection(BuildingFeatureType.getChangables(game, building.type, building.get_level())._list);
				addChild(featureList);
				
				var buttonOverlay:SimpleLayoutButton = new SimpleLayoutButton();
				buttonOverlay.addEventListener(Event.TRIGGERED, buttonOverlay_triggeredHandler);
				buttonOverlay.layoutData = new AnchorLayoutData(0,0,0,0);
				addChild(buttonOverlay);
			}
		}
		
		private function buttonOverlay_triggeredHandler(event:Event):void
		{
			close();
		}
		
		override public function dispose():void
		{
			appModel.sounds.setVolume("main-theme", 1);
			super.dispose();
		}
	}
}