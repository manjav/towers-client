package com.gerantech.towercraft.controls.popups
{
import com.gerantech.towercraft.controls.BuildingCard;
import com.gerantech.towercraft.controls.buttons.ExchangeButton;
import com.gerantech.towercraft.controls.items.CardFeatureItemRenderer;
import com.gerantech.towercraft.controls.overlays.TransitionData;
import com.gerantech.towercraft.controls.texts.RTLLabel;
import com.gerantech.towercraft.models.vo.UserData;
import com.gt.towers.buildings.Building;
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
public var buildingType:int;
public function CardDetailsPopup(){}
override protected function initialize():void
{
	// create transition in data
	var popupHeight:int = stageHeight * (BuildingType.get_category(buildingType) == BuildingType.B40_CRYSTAL ? 0.60 : 0.52);
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
	cardDisplay.setData(buildingType);
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
		
	var titleDisplay:RTLLabel = new RTLLabel(loc("building_title_" + buildingType), 1, null, null, false, null, 1.1, null, "bold");
	titleDisplay.layoutData = new AnchorLayoutData(padding, appModel.isLTR?padding:padding * 11, NaN, appModel.isLTR?padding * 11:padding);
	addChild(titleDisplay);
	
	var messageDisplay:RTLLabel = new RTLLabel(loc("building_message_" + buildingType), 1, "justify", null, true, null, 0.7);
	messageDisplay.layoutData = new AnchorLayoutData(padding * 4, appModel.isLTR?padding:padding * 11, NaN, appModel.isLTR?padding * 11:padding);
	addChild(messageDisplay);
	
	var featureList:List = new List();
	featureList.layoutData = new AnchorLayoutData(padding * 15, padding * 2, NaN, padding * 2);
	featureList.horizontalScrollPolicy = featureList.verticalScrollPolicy = ScrollPolicy.OFF;
	featureList.itemRendererFactory = function ():IListItemRenderer { return new CardFeatureItemRenderer(buildingType); }
	featureList.dataProvider = new ListCollection(BuildingFeatureType.getRelatedTo(buildingType)._list);
	addChild(featureList);
	
	var building:Building = player.buildings.get(buildingType);
	if( building == null )
		return;
		
	// remove new badge
	if( building.get_level() == -1 )
		dispatchEventWith(Event.UPDATE, false, buildingType);
	
	var upgradeButton:ExchangeButton = new ExchangeButton();
	upgradeButton.disableSelectDispatching = true;
	upgradeButton.layoutData = new AnchorLayoutData(NaN, NaN, padding, NaN, 0);
	upgradeButton.width = 380 * appModel.scale;
	upgradeButton.height = 110 * appModel.scale;
	upgradeButton.addEventListener(Event.TRIGGERED, upgradeButton_triggeredHandler);
	upgradeButton.addEventListener(Event.SELECT, upgradeButton_selectHandler);
	upgradeButton.count = building.get_upgradeCost();
	upgradeButton.type = ResourceType.CURRENCY_SOFT;
	upgradeButton.isEnabled = player.resources.get(buildingType) >= building.get_upgradeCards();
	upgradeButton.fontColor = player.resources.get(ResourceType.CURRENCY_SOFT) >= building.get_upgradeCost() ? 0xFFFFFF : 0xCC0000;
	addChild(upgradeButton);
	
	if( player.inDeckTutorial() )
	{
		UserData.instance.prefs.setInt(PrefsTypes.TUTOR, PrefsTypes.T_037_CARD_OPENED );
		upgradeButton.showTutorArrow(true);
	}

	/*upgradeButton.alpha = 0;
	Starling.juggler.tween(upgradeButton, 0.1, {alpha:1, delay:0.3});*/
	
	var upgradeLabel:RTLLabel = new RTLLabel(loc("upgrade_title"), 1, "center", null, true, null, 0.7);
	upgradeLabel.layoutData = new AnchorLayoutData(NaN, NaN, padding + upgradeButton.height, NaN, 0);
	upgradeLabel.alpha = 0;
	Starling.juggler.tween(upgradeLabel, 0.1, {alpha:1, delay:0.3});
	addChild(upgradeLabel);
}

override protected function transitionOutStarted():void
{
	removeChildren(2);
	super.transitionOutStarted();
}
private function upgradeButton_selectHandler(event:Event):void
{
	appModel.navigator.addLog(loc("popup_upgrade_building_error", [loc("building_title_" + buildingType)]));
	cardDisplay.punchSlider()
}
private function upgradeButton_triggeredHandler():void
{
	dispatchEventWith(Event.UPDATE, false, buildingType);
}
}
}