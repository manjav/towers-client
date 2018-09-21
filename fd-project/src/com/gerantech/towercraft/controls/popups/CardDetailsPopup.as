package com.gerantech.towercraft.controls.popups
{
import com.gerantech.towercraft.controls.BuildingCard;
import com.gerantech.towercraft.controls.buttons.CustomButton;
import com.gerantech.towercraft.controls.buttons.ExchangeButton;
import com.gerantech.towercraft.controls.groups.ColorGroup;
import com.gerantech.towercraft.controls.items.CardFeatureItemRenderer;
import com.gerantech.towercraft.controls.overlays.TransitionData;
import com.gerantech.towercraft.controls.texts.RTLLabel;
import com.gerantech.towercraft.models.vo.UserData;
import com.gt.towers.battle.units.Card;
import com.gt.towers.constants.CardFeatureType;
import com.gt.towers.constants.CardTypes;
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
	var popupHeight:int = stageHeight * 0.7;// (cardType.get_category(cardType) == CardTypes.B40_CRYSTAL ? 0.60 : 0.52);
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
	cardDisplay.setData(cardType);
	cardDisplay.width = padding * 9;
	cardDisplay.layoutData = new AnchorLayoutData(padding, appModel.isLTR?NaN:padding, NaN, appModel.isLTR?padding:NaN);
	addChild(cardDisplay);
}

override protected function transitionInCompleted():void
{
	super.transitionInCompleted();
	
	var textLayout:VerticalLayout = new VerticalLayout();
	textLayout.horizontalAlign = HorizontalAlign.JUSTIFY;
	textLayout.gap = padding;
	
	var titleDisplay:RTLLabel = new RTLLabel(loc("card_title_" + cardType), 1, null, null, false, null, 1.1, null, "bold");
	titleDisplay.layoutData = new AnchorLayoutData(padding, appModel.isLTR?padding:padding * 12, NaN, appModel.isLTR?padding * 12:padding);
	addChild(titleDisplay);
	
	var rarityColors:Array = [0xFFFFFF, 0xffcc00, 0x00eeff];
	var rarity:int = game.calculator.getInt(CardFeatureType.F00_RARITY, cardType, 1);
	var rarityPalette:ColorGroup = new ColorGroup(loc("card_rarity_" +rarity), rarityColors[rarity]);
	rarityPalette.width = (transitionIn.destinationBound.width - padding * 13) * 0.48;
	rarityPalette.layoutData = new AnchorLayoutData(padding * 3.7, appModel.isLTR?NaN:padding * 12, NaN, appModel.isLTR?padding * 12:NaN);
	addChild(rarityPalette);
/*	
	var categoryPalette:ColorGroup = new ColorGroup(loc("card_category_" + building.category));
	categoryPalette.width = (transitionIn.destinationBound.width - padding * 13) * 0.48;
	categoryPalette.layoutData = new AnchorLayoutData(padding * 3.7, appModel.isLTR?padding:NaN, NaN, appModel.isLTR?NaN:padding);
	addChild(categoryPalette);*/
	
	var messageDisplay:RTLLabel = new RTLLabel(loc("card_message_" + cardType), 1, "justify", null, true, null, 0.7);
	messageDisplay.layoutData = new AnchorLayoutData(padding * 7, appModel.isLTR?padding:padding * 12, NaN, appModel.isLTR?padding * 12:padding);
	addChild(messageDisplay);
	
	var featureList:List = new List();
	featureList.layoutData = new AnchorLayoutData(padding * 16, padding * 2, NaN, padding * 2);
	featureList.horizontalScrollPolicy = featureList.verticalScrollPolicy = ScrollPolicy.OFF;
	featureList.itemRendererFactory = function ():IListItemRenderer { return new CardFeatureItemRenderer(cardType); }
	featureList.dataProvider = new ListCollection(CardFeatureType.getRelatedTo(cardType)._list);
	addChild(featureList);

	var card:Card = player.cards.get(cardType);
	if( card == null )
		return;
		
	// remove new badge
	if( card.level == -1 )
		dispatchEventWith(Event.UPDATE, false, cardType);
	
	var upgradeButton:ExchangeButton = new ExchangeButton();
	upgradeButton.disableSelectDispatching = true;
	upgradeButton.layoutData = new AnchorLayoutData(NaN, NaN, padding, NaN, -padding * 5);
	upgradeButton.width = 320;
	upgradeButton.height = 110;
	upgradeButton.addEventListener(Event.TRIGGERED, upgradeButton_triggeredHandler);
	upgradeButton.addEventListener(Event.SELECT, upgradeButton_selectHandler);
	upgradeButton.count = Card.get_upgradeCost(card.level);
	upgradeButton.type = ResourceType.CURRENCY_SOFT;
	upgradeButton.isEnabled = player.resources.get(cardType) >= Card.get_upgradeCards(card.level);
	upgradeButton.fontColor = player.resources.get(ResourceType.CURRENCY_SOFT) >= upgradeButton.count ? 0xFFFFFF : 0xCC0000;
	addChild(upgradeButton);
	
	if( player.inDeckTutorial() )
	{
		UserData.instance.prefs.setInt(PrefsTypes.TUTOR, PrefsTypes.T_037_CARD_OPENED );
		upgradeButton.showTutorArrow(true);
	}

	/*upgradeButton.alpha = 0;
	Starling.juggler.tween(upgradeButton, 0.1, {alpha:1, delay:0.3});*/
	
	var upgradeLabel:RTLLabel = new RTLLabel(loc("upgrade_title"), 1, "center", null, true, null, 0.7);
	upgradeLabel.layoutData = new AnchorLayoutData(NaN, NaN, padding + upgradeButton.height, NaN, -padding * 5);
	upgradeLabel.alpha = 0;
	Starling.juggler.tween(upgradeLabel, 0.1, {alpha:1, delay:0.3});
	addChild(upgradeLabel);
	
    var usingButton:CustomButton = new CustomButton();
    usingButton.style = "neutral";
    usingButton.label = loc("usage_label");
    usingButton.isEnabled = player.cards.exists(cardType) && !player.getSelectedDeck().exists(cardType);
	usingButton.width = 320;
    usingButton.height = 110;
    usingButton.addEventListener(Event.TRIGGERED, usingButton_triggeredHandler);
    usingButton.layoutData = new AnchorLayoutData(NaN, NaN, padding, NaN, padding*5);
    addChild(usingButton);
    
 /*   showTutorArrow();
}

private function showTutorArrow () : void
{
    if( buildingType != CardTypes.INITIAL || player.getTutorStep() != PrefsTypes.TUTE_114_SELECT_BUILDING )
        return;
    
    if( tutorialArrow != null )
        tutorialArrow.removeFromParent(true);
    
    tutorialArrow = new TutorialArrow(true);
    tutorialArrow.layoutData = new AnchorLayoutData(NaN, NaN, -padding * 2.4, NaN, -padding * 5);
    addChild(tutorialArrow);*/
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
}
}
}