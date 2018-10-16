package com.gerantech.towercraft.controls.overlays
{
import com.gerantech.towercraft.controls.BuildingCard;
import com.gerantech.towercraft.controls.buttons.SimpleLayoutButton;
import com.gerantech.towercraft.controls.items.CardFeatureItemRenderer;
import com.gerantech.towercraft.controls.texts.RTLLabel;
import com.gerantech.towercraft.views.effects.MortalParticleSystem;
import com.gt.towers.battle.units.Card;
import com.gt.towers.constants.CardFeatureType;
import dragonBones.starling.StarlingArmatureDisplay;
import feathers.controls.List;
import feathers.controls.ScrollPolicy;
import feathers.controls.renderers.IListItemRenderer;
import feathers.data.ListCollection;
import feathers.layout.AnchorLayout;
import feathers.layout.AnchorLayoutData;
import flash.utils.setTimeout;
import starling.animation.Transitions;
import starling.core.Starling;
import starling.events.Event;

public class BuildingUpgradeOverlay extends BaseOverlay
{
public var card:Card;
private var initializeStarted:Boolean;
private var shineArmature:StarlingArmatureDisplay;

public function BuildingUpgradeOverlay()
{
	super();
}

override protected function initialize():void
{
	if( stage != null )
		addChild(defaultOverlayFactory());

	super.initialize();
	appModel.navigator.activeScreen.visible = false;
	initializeStarted = true;

	layout = new AnchorLayout();
	closeOnStage = false;

	width = stage.stageWidth;
	height = stage.stageHeight;
	overlay.alpha = 1;
	
	var cardView:BuildingCard = new BuildingCard(true, false, false, false);
	cardView.pivotX= cardView.width * 0.5;
	cardView.pivotY = cardView.height * 0.5;
	cardView.layoutData = new AnchorLayoutData(NaN, NaN, NaN, NaN, 0, NaN);
	cardView.width = 240;
	cardView.height = cardView.width * BuildingCard.VERICAL_SCALE;
	cardView.y = (stage.stageHeight - cardView.height) * 0.5;
	addChild(cardView);
	cardView.setData(card.type, card.level - 1);
	//card.scale = 1.6;
	
	appModel.sounds.setVolume("main-theme", 0.3);
	setTimeout(levelUp, 500);
	setTimeout(showFeatures, 1800);
	function levelUp():void {
		var titleDisplay:RTLLabel = new RTLLabel(loc("building_title_" + cardView.type), 1, "center", null, false, null, 1.5);
		titleDisplay.layoutData = new AnchorLayoutData(NaN, NaN, NaN, NaN, 0);
		titleDisplay.y = (stage.stageHeight - cardView.height) / 3;
		addChild(titleDisplay);
		
		cardView.scale = 2.4;
		cardView.setData(card.type, card.level);
		Starling.juggler.tween(cardView, 0.3, {scale:1.6, transition:Transitions.EASE_OUT});
		Starling.juggler.tween(cardView, 0.5, {delay:0.7, y:cardView.y - 150, transition:Transitions.EASE_IN_OUT});
		
		// shine animation
		shineArmature = OpenBookOverlay.factory.buildArmatureDisplay("shine");
		shineArmature.touchable = false;
		shineArmature.scale = 0.1;
		shineArmature.x = 120;
		shineArmature.y = 170;
		shineArmature.animation.gotoAndPlayByTime("rotate", 0, 10);
		cardView.addChildAt(shineArmature, 0);
		Starling.juggler.tween(shineArmature, 0.3, {scale:2.5, transition:Transitions.EASE_OUT_BACK});
		
		// explode particles
		var explode:MortalParticleSystem = new MortalParticleSystem("explode", 2);
		explode.x = 120;
		explode.y = 170;
		cardView.addChildAt(explode, 0);
		
		// scraps particles
		var scraps:MortalParticleSystem = new MortalParticleSystem("scrap", 5);
		scraps.x = stage.stageWidth * 0.5;
		scraps.y = -stage.stageHeight * 0.1;
		addChildAt(scraps, 1);
		
		appModel.sounds.addAndPlaySound("upgrade");
	}
	function showFeatures():void {
		var featureList:List = new List();
		featureList.width = stage.stageWidth * 0.5;
		featureList.layoutData = new AnchorLayoutData(NaN, NaN, NaN, NaN, 0, featureList.width * 0.7);
		featureList.horizontalScrollPolicy = featureList.verticalScrollPolicy = ScrollPolicy.OFF;
		featureList.itemRendererFactory = function ():IListItemRenderer { return new CardFeatureItemRenderer(card.type); }
		featureList.dataProvider = new ListCollection(CardFeatureType.getRelatedTo(card.type)._list);
		addChild(featureList);
		
		var buttonOverlay:SimpleLayoutButton = new SimpleLayoutButton();
		buttonOverlay.addEventListener(Event.TRIGGERED, buttonOverlay_triggeredHandler);
		buttonOverlay.layoutData = new AnchorLayoutData(0, 0, 0, 0);
		addChild(buttonOverlay);
	}
}


private function buttonOverlay_triggeredHandler(event:Event):void
{
	close();
}

override public function dispose():void
{
	appModel.navigator.activeScreen.visible = true;
	shineArmature.removeFromParent();
	appModel.sounds.setVolume("main-theme", 1);
	super.dispose();
}
}
}