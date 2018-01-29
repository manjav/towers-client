package com.gerantech.towercraft.controls
{
import com.gerantech.towercraft.controls.buttons.CustomButton;
import com.gerantech.towercraft.controls.buttons.SimpleLayoutButton;
import com.gerantech.towercraft.controls.headers.AttendeeHeader;
import com.gerantech.towercraft.controls.headers.BattleFooter;
import com.gerantech.towercraft.controls.indicators.BattleKeyIndicator;
import com.gerantech.towercraft.controls.items.StickerItemRenderer;
import com.gerantech.towercraft.controls.sliders.BattleTimerSlider;
import com.gerantech.towercraft.controls.texts.RTLLabel;
import com.gerantech.towercraft.controls.toasts.BattleExtraTimeToast;
import com.gerantech.towercraft.controls.toasts.BattleKeyChangeToast;
import com.gerantech.towercraft.controls.tooltips.StickerBubble;
import com.gerantech.towercraft.managers.net.sfs.SFSConnection;
import com.gerantech.towercraft.models.Assets;
import com.gerantech.towercraft.models.vo.BattleData;
import com.gerantech.towercraft.utils.StrUtils;
import com.gerantech.towercraft.views.PlaceView;
import com.gt.towers.buildings.Place;
import com.gt.towers.constants.StickerType;

import flash.geom.Rectangle;
import flash.utils.setTimeout;

import feathers.controls.ImageLoader;
import feathers.controls.List;
import feathers.controls.ScrollPolicy;
import feathers.controls.renderers.IListItemRenderer;
import feathers.data.ListCollection;
import feathers.events.FeathersEventType;
import feathers.layout.AnchorLayout;
import feathers.layout.AnchorLayoutData;
import feathers.layout.HorizontalAlign;
import feathers.layout.TiledRowsLayout;
import feathers.layout.VerticalAlign;

import starling.animation.Transitions;
import starling.core.Starling;
import starling.display.Quad;
import starling.events.Event;
import starling.utils.Color;

public class BattleHUD extends TowersLayout
{
private var battleData:BattleData;
private var timerSlider:BattleTimerSlider;
private var stickerList:List;

private var padding:int;

private var stickerCloserOveraly:SimpleLayoutButton;
private var bubbleAllise:StickerBubble;
private var bubbleAxis:StickerBubble;

private var scoreIndex:int = 0;
private var timeLog:RTLLabel;
private var debugMode:Boolean = false;

private var deck:BattleFooter;
private var keyIndicatorAllies:BattleKeyIndicator;
private var keyIndicatorAxis:BattleKeyIndicator;

public function BattleHUD()
{
	super();
}

override protected function initialize():void
{
	super.initialize();
	layout = new AnchorLayout();
	this.battleData = appModel.battleFieldView.battleData;

	var gradient:ImageLoader = new ImageLoader();
	gradient.scale9Grid = new Rectangle(1, 1, 7, 7);
	gradient.color = Color.BLACK
	gradient.alpha = 0.5;
	gradient.width = 440 * appModel.scale;
	gradient.height = 140 * appModel.scale;
	gradient.source = Assets.getTexture("theme/gradeint-left", "gui");
	addChild(gradient);
	
	var hasQuit:Boolean = battleData.map.isQuest && player.get_questIndex() > 3 || SFSConnection.instance.mySelf.isSpectator;
	padding = 16 * appModel.scale;
	var leftPadding:int = (hasQuit ? 150 : 0) * appModel.scale;
	if( hasQuit )
	{
		var closeButton:CustomButton = new CustomButton();
		closeButton.style = "danger";
		closeButton.label = "X";
		closeButton.height = closeButton.width = 120 * appModel.scale;
		closeButton.layoutData = new AnchorLayoutData(padding, NaN, NaN, padding);
		closeButton.addEventListener(Event.TRIGGERED, closeButton_triggeredHandler);
		addChild(closeButton);
	}
	
	var _name:String = battleData.map.isQuest ? loc("quest_label") + " " + StrUtils.getNumber(battleData.map.index+1) : battleData.opponent.getVariable("name").getStringValue();
	var _point:int = battleData.map.isQuest ? 0 : battleData.opponent.getVariable("point").getIntValue();
	var opponentHeader:AttendeeHeader = new AttendeeHeader(_name, _point);
	opponentHeader.layoutData = new AnchorLayoutData(0, NaN, NaN, leftPadding );
	addChild(opponentHeader);
	
	if( SFSConnection.instance.mySelf.isSpectator )
	{
		_name = battleData.me.getVariable("name").getStringValue();
		_point = battleData.me.getVariable("point").getIntValue();
		var meHeader:AttendeeHeader = new AttendeeHeader(_name, _point);
		meHeader.layoutData = new AnchorLayoutData(NaN, NaN, 0, 0 );
		addChild(meHeader);
	}
	
	if( debugMode )
	{
		timeLog = new RTLLabel("", 0);
		timeLog.layoutData = new AnchorLayoutData(padding * 10, padding * 6);
		addChild(timeLog);
	}
	
	if( battleData.map.isQuest )
	{
		timerSlider = new BattleTimerSlider();
		timerSlider.layoutData = new AnchorLayoutData(padding*4, padding*6);
		addChild(timerSlider);
	}
	else
	{
		
	}
	addEventListener(FeathersEventType.CREATION_COMPLETE, createCompleteHandler);
	
	//if( player.get_questIndex() >= 2 && !player.hardMode )
	//{
		deck = new BattleFooter();
		deck.layoutData = new AnchorLayoutData(NaN, 0, 0, 0);
		addChild(deck);
	//}
	
	if( !battleData.map.isQuest )
	{
		deck.addEventListener(FeathersEventType.BEGIN_INTERACTION, stickerButton_triggeredHandler);
		
		bubbleAllise = new StickerBubble();
		bubbleAllise.layoutData = new AnchorLayoutData( NaN, NaN, padding * 13, padding);
		
		bubbleAxis = new StickerBubble(true);
		bubbleAxis.layoutData = new AnchorLayoutData( 140 * appModel.scale + padding, NaN, NaN, padding);
		
		keyIndicatorAllies = new BattleKeyIndicator(true);
		keyIndicatorAllies.layoutData = new AnchorLayoutData( NaN, -padding * 0.5, NaN, NaN, NaN, padding * 10 - deck.height * 0.5);
		addChild(keyIndicatorAllies);
		
		keyIndicatorAxis = new BattleKeyIndicator(false);
		keyIndicatorAxis.layoutData = new AnchorLayoutData( NaN, -padding * 0.5, NaN, NaN, NaN, -padding * 10 - deck.height * 0.5);
		addChild(keyIndicatorAxis);
	}
}

private function createCompleteHandler(event:Event):void
{
	removeEventListener(FeathersEventType.CREATION_COMPLETE, createCompleteHandler);
	timeManager.addEventListener(Event.CHANGE, timeManager_changeHandler);
	
	if ( battleData.map.isQuest )
	{
		setTimePosition();
		
		if( battleData.battleField.extraTime > 0 )
			appModel.navigator.addAnimation(stage.stageWidth*0.5, stage.stageHeight*0.5, 240, Assets.getTexture("extra-time", "gui"), battleData.battleField.extraTime, BattleTimerSlider(timerSlider).iconDisplay.getBounds(this), 0.5, punchTimer, "+ ");
		function punchTimer():void {
			var diff:int = 48 * appModel.scale;
			timerSlider.y -= diff;
			Starling.juggler.tween(timerSlider, 0.4, {y:y + diff, transition:Transitions.EASE_OUT_ELASTIC});
		}
	}
}

private function timeManager_changeHandler(event:Event):void
{

	//trace(timeManager.now-battleData.startAt , battleData.map.times._list)
	if ( scoreIndex < battleData.map.times.size() && timeManager.now-battleData.startAt > battleData.battleField.getTime(scoreIndex) )
	{
		scoreIndex ++;
		if( scoreIndex < battleData.map.times.size() )
		{
			setTimePosition();
		}
		else
		{
			timeManager.removeEventListener(Event.CHANGE, timeManager_changeHandler);
			timerSlider.enableStars(0);
		}
	}
	var time:int = timeManager.now - battleData.startAt - timerSlider.minimum;
	if( debugMode )
		timeLog.text = time.toString();
	//trace(time, timerSlider.minimum, timerSlider.maximum)
	if( time % 2 == 0 )
		Starling.juggler.tween(timerSlider, 1, {value:timerSlider.maximum - time, transition:Transitions.EASE_OUT_ELASTIC});;
}


private function setTimePosition():void
{
	timerSlider.enableStars(2 - scoreIndex);
	timerSlider.minimum = scoreIndex > 0 ? battleData.battleField.getTime(scoreIndex - 1) : 0 ;
	timerSlider.value = timerSlider.maximum = battleData.battleField.getTime(scoreIndex);
	showTimeNotice(2 - scoreIndex);
	trace("["+battleData.map.times._list+"]", "min:", timerSlider.minimum, "max:", timerSlider.maximum, "score:", 2-scoreIndex)
}		

private function showTimeNotice(score:int):void
{
	if ( score > 1 )
		return;

	if( battleData.map.isQuest )
		appModel.navigator.addPopup(new BattleKeyChangeToast(score));
	else if ( score == -1 )
		appModel.navigator.addPopup(new BattleExtraTimeToast());
}


public function updateRoomVars(changedVars:Object):void
{
	if( battleData == null || !battleData.room.containsVariable("towers") || battleData.map.isQuest )
		return;
	var towers:Array = [0,0]
	for ( var i:int = 0; i < battleData.battleField.places.size(); i++ )
	{
		var p:Place = battleData.battleField.places.get(i);
		if ( p.mode == 1 && p.building.troopType > -1 )
			towers[ p.building.troopType ] ++;
	}
	keyIndicatorAllies.value = towers[player.troopType];
	keyIndicatorAxis.value = towers[player.troopType == 0 ? 1 : 0];
}

private function closeButton_triggeredHandler(event:Event):void
{
	dispatchEventWith(Event.CLOSE);
}

private function stickerButton_triggeredHandler(event:Event):void
{
	deck.stickerButton.visible = false;
	if( stickerList == null )
	{
		var stickersLayout:TiledRowsLayout = new TiledRowsLayout();
		stickersLayout.padding = stickersLayout.gap = padding;
		stickersLayout.tileHorizontalAlign = HorizontalAlign.JUSTIFY;
		stickersLayout.tileVerticalAlign = VerticalAlign.JUSTIFY;
		stickersLayout.useSquareTiles = false;
		stickersLayout.distributeWidths = true;
		stickersLayout.distributeHeights = true;
		stickersLayout.requestedColumnCount = 4;
		
		stickerList = new List();
		stickerList.layout = stickersLayout;
		stickerList.layoutData = new AnchorLayoutData(NaN, 0, NaN, 0);
		stickerList.height = padding * 20;
		stickerList.itemRendererFactory = function ():IListItemRenderer { return new StickerItemRenderer(); }
		stickerList.verticalScrollPolicy = stickerList.horizontalScrollPolicy = ScrollPolicy.OFF;
		stickerList.dataProvider = new ListCollection(StickerType.getAll(game)._list);
		
		stickerCloserOveraly = new SimpleLayoutButton();
		stickerCloserOveraly.backgroundSkin = new Quad(1, 1, 0);
		stickerCloserOveraly.backgroundSkin.alpha = 0.1;
		stickerCloserOveraly.layoutData = new AnchorLayoutData(0, 0, 0, 0);
		stickerCloserOveraly.addEventListener(Event.TRIGGERED, stickerCloserOveraly_triggeredHandler);
	}
	addChild(stickerCloserOveraly);

	AnchorLayoutData(stickerList.layoutData).bottom = -padding * 20;
	Starling.juggler.tween(stickerList.layoutData, 0.2, {bottom:0, transition:Transitions.EASE_OUT});
	stickerList.addEventListener(Event.CHANGE, stickerList_changeHandler);
	addChild(stickerList);
}
private function hideStickerList():void
{
	stickerList.removeEventListener(Event.CHANGE, stickerList_changeHandler);
	removeChild(stickerCloserOveraly);
	AnchorLayoutData(stickerList.layoutData).bottom = 0;
	Starling.juggler.tween(stickerList.layoutData, 0.2, {bottom:-padding*20, transition:Transitions.EASE_IN, onComplete:stickerList.removeFromParent});
}

private function stickerCloserOveraly_triggeredHandler(event:Event):void
{
	hideStickerList();
	deck.stickerButton.visible = true;
}

private function stickerList_changeHandler(event:Event):void
{
	hideStickerList();
	var sticker:int = stickerList.selectedItem as int;
	appModel.battleFieldView.responseSender.sendSticker(sticker);
	showBubble(sticker);
	stickerList.selectedIndex = -1;
}

public function showBubble(type:int, itsMe:Boolean=true):void
{
	var bubble:StickerBubble = itsMe ? bubbleAllise : bubbleAxis;

	Starling.juggler.removeTweens(bubble);
	bubble.type = type;
	bubble.scale = 0.5;
	addChild(bubble);
	Starling.juggler.tween(bubble, 0.2, {scale:1, transition:Transitions.EASE_OUT_BACK});
	Starling.juggler.tween(bubble, 0.2, {scale:0.5, transition:Transitions.EASE_IN_BACK, delay:4, onComplete:hideBubble, onCompleteArgs:[bubble]});
	appModel.sounds.addAndPlaySound("whoosh");
}

private function hideBubble(bubble:StickerBubble):void
{
	bubble.removeFromParent();
	if( !SFSConnection.instance.mySelf.isSpectator )
		deck.stickerButton.visible = true;
}

override public function dispose():void
{
	timeManager.removeEventListener(Event.CHANGE, timeManager_changeHandler);
	super.dispose();
}
}
}