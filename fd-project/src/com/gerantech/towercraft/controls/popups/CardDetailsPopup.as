package com.gerantech.towercraft.controls.popups
{
import com.gerantech.towercraft.controls.BuildingCard;
import com.gerantech.towercraft.controls.buttons.ExchangeButton;
import com.gerantech.towercraft.controls.buttons.ExchangeDButton;
import com.gerantech.towercraft.controls.groups.ColorGroup;
import com.gerantech.towercraft.controls.items.CardFeatureItemRenderer;
import com.gerantech.towercraft.controls.overlays.TransitionData;
import com.gerantech.towercraft.controls.texts.RTLLabel;
import com.gerantech.towercraft.models.vo.UserData;
import com.gt.towers.buildings.Building;
import com.gt.towers.buildings.Card;
import com.gt.towers.constants.BuildingFeatureType;
import com.gt.towers.constants.BuildingType;
import com.gt.towers.constants.PrefsTypes;
import com.gt.towers.constants.ResourceType;
import feathers.controls.List;
import feathers.controls.ScrollPolicy;
import feathers.controls.renderers.IListItemRenderer;
import feathers.data.ListCollection;
import feathers.layout.AnchorLayoutData;
import feathers.layout.HorizontalAlign;
import feathers.layout.VerticalLayout;
import flash.geom.Rectangle;
import starling.animation.Transitions;
import starling.core.Starling;
import starling.events.Event;

public class CardDetailsPopup extends SimplePopup
{
private var cardDisplay:BuildingCard;
public var cardType:int;
public function CardDetailsPopup(){}
override protected function initialize():void
{
	// create transition in data
	var popupHeight:int = stageHeight * (BuildingType.get_category(cardType) == BuildingType.B40_CRYSTAL ? 0.60 : 0.52);
	var popupY:int = (stageHeight - popupHeight) * 0.5;
	transitionIn = new TransitionData();
	transitionIn.transition = Transitions.EASE_OUT;
	transitionIn.sourceBound =		new Rectangle(stageWidth * 0.05,	popupY * 1.1,	stageWidth * 0.9, popupHeight * 0.9);
	transitionIn.destinationBound = new Rectangle(stageWidth * 0.05,	popupY,			stageWidth * 0.9, popupHeight * 1.0);

	// create transition out data
	transitionOut = new TransitionData();
	transitionOut.sourceAlpha = 1;
	transitionOut.destinationAlpha = 0.5;
	transitionOut.sourceBound = transitionIn.destinationBound.clone();
	transitionOut.destinationBound = transitionIn.sourceBound.clone();
	
	super.initialize();
	
	cardDisplay = new BuildingCard(true, true, false, false);
	cardDisplay.width = padding * 9;
	cardDisplay.layoutData = new AnchorLayoutData(padding, appModel.isLTR?NaN:padding, NaN, appModel.isLTR?padding:NaN);
	addChild(cardDisplay);
	cardDisplay.setData(cardType);
}

override protected function transitionInCompleted():void
{
	super.transitionInCompleted();
	
	var textLayout:VerticalLayout = new VerticalLayout();
	textLayout.horizontalAlign = HorizontalAlign.JUSTIFY;
	textLayout.gap = padding;
		
	var titleDisplay:RTLLabel = new RTLLabel(loc("building_title_" + cardType), 1, null, null, false, null, 1.1, null, "bold");
	titleDisplay.layoutData = new AnchorLayoutData(padding, appModel.isLTR?padding:padding * 11, NaN, appModel.isLTR?padding * 11:padding);
	addChild(titleDisplay);
	
	var messageDisplay:RTLLabel = new RTLLabel(loc("building_message_" + cardType), 1, "justify", null, true, null, 0.7);
	messageDisplay.layoutData = new AnchorLayoutData(padding * 4, appModel.isLTR?padding:padding * 11, NaN, appModel.isLTR?padding * 11:padding);
	addChild(messageDisplay);
	
	var featureList:List = new List();
	featureList.layoutData = new AnchorLayoutData(padding * 15, padding * 2, NaN, padding * 2);
	featureList.horizontalScrollPolicy = featureList.verticalScrollPolicy = ScrollPolicy.OFF;
	featureList.itemRendererFactory = function ():IListItemRenderer { return new CardFeatureItemRenderer(cardType); }
	featureList.dataProvider = new ListCollection(BuildingFeatureType.getRelatedTo(cardType)._list);
	addChild(featureList);

	var card:Building = player.buildings.get(cardType);
	if( card == null )
		return;
		
	// remove new badge
	if( card.get_level() == -1 )
		dispatchEventWith(Event.UPDATE, false, cardType);

	var upgradeButton:ExchangeDButton = new ExchangeDButton();
	upgradeButton.disableSelectDispatching = true;
	upgradeButton.layoutData = new AnchorLayoutData(NaN, NaN, padding, NaN, 0);
	upgradeButton.alpha = 0;
	upgradeButton.width = 320;
	upgradeButton.height = 130;
	upgradeButton.addEventListener(Event.TRIGGERED, upgradeButton_triggeredHandler);
	upgradeButton.addEventListener(Event.SELECT, upgradeButton_selectHandler);
	upgradeButton.count = Card.get_upgradeCost(card.get_level());
	upgradeButton.type = ResourceType.R3_CURRENCY_SOFT;
	upgradeButton.label = loc("upgrade_label") + "\n" + Card.get_upgradeCost(card.get_level());
	upgradeButton.isEnabled = player.resources.get(cardType) >= Card.get_upgradeCards(card.get_level());
	upgradeButton.fontColor = player.resources.get(ResourceType.R3_CURRENCY_SOFT) >= upgradeButton.count ? 0xFFFFFF : 0xCC0000;
	addChild(upgradeButton);
	Starling.juggler.tween(upgradeButton, 0.3, {delay:0.1, alpha:1, onComplete:upgradeButton_tweenCompleted});
	function upgradeButton_tweenCompleted () : void
	{
		if( player.inDeckTutorial() )
		{
			UserData.instance.prefs.setInt(PrefsTypes.TUTOR, PrefsTypes.T_037_CARD_OPENED);
			upgradeButton.showTutorHint();
		}
	}
}

override protected function transitionOutStarted():void
{
	removeChildren(2);
	super.transitionOutStarted();
}
private function usingButton_triggeredHandler():void
{
	dispatchEventWith(Event.SELECT, false, cardType);
	close();
}
private function upgradeButton_selectHandler(event:Event):void
{
	appModel.navigator.addLog(loc("popup_upgrade_building_error", [loc("building_title_" + cardType)]));
	cardDisplay.punchSlider()
}
private function upgradeButton_triggeredHandler():void
{
	dispatchEventWith(Event.UPDATE, false, cardType);
	close();
}
}
}