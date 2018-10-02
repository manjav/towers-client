package com.gerantech.towercraft.controls
{
import com.gerantech.towercraft.controls.buttons.CustomButton;
import com.gerantech.towercraft.controls.buttons.SimpleLayoutButton;
import com.gerantech.towercraft.controls.headers.AttendeeHeader;
import com.gerantech.towercraft.controls.headers.BattleFooter;
import com.gerantech.towercraft.controls.items.StickerItemRenderer;
import com.gerantech.towercraft.controls.overlays.EndOverlay;
import com.gerantech.towercraft.controls.sliders.battle.BattleCountdown;
import com.gerantech.towercraft.controls.sliders.battle.BattleScoreBoard;
import com.gerantech.towercraft.controls.sliders.battle.BattleTimerSlider;
import com.gerantech.towercraft.controls.sliders.battle.IBattleBoard;
import com.gerantech.towercraft.controls.sliders.battle.IBattleSlider;
import com.gerantech.towercraft.controls.sliders.battle.TerritorySlider;
import com.gerantech.towercraft.controls.texts.RTLLabel;
import com.gerantech.towercraft.controls.toasts.BattleExtraTimeToast;
import com.gerantech.towercraft.controls.toasts.BattleKeyChangeToast;
import com.gerantech.towercraft.controls.tooltips.StickerBubble;
import com.gerantech.towercraft.managers.net.sfs.SFSConnection;
import com.gerantech.towercraft.models.Assets;
import com.gerantech.towercraft.models.vo.BattleData;
import com.gerantech.towercraft.themes.MainTheme;
import com.gerantech.towercraft.utils.StrUtils;
import com.gt.towers.battle.BattleField;
import com.gt.towers.constants.StickerType;
import com.marpies.ane.gameanalytics.GameAnalytics;
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
import flash.utils.setTimeout;
import starling.animation.Transitions;
import starling.core.Starling;
import starling.display.Image;
import starling.display.Quad;
import starling.events.Event;
import starling.utils.Color;

 public class BattleHUD extends TowersLayout
{
private var padding:int;
private var scoreIndex:int = 0;
private var debugMode:Boolean = false;

private var battleData:BattleData;
private var timerSlider:IBattleSlider;
private var stickerList:List;
private var stickerCloserOveraly:SimpleLayoutButton;
private var bubbleAllise:StickerBubble;
private var bubbleAxis:StickerBubble;
private var timeLog:RTLLabel;
private var surrenderButton:CustomButton;
private var scoreBoard:IBattleBoard;
private var deck:BattleFooter;

public function BattleHUD() { super(); }
override protected function initialize():void
{
	super.initialize();
	layout = new AnchorLayout();
	this.battleData = appModel.battleFieldView.battleData;
	
	if( player.inTutorial() )
		return;

	var gradient:ImageLoader = new ImageLoader();
	gradient.scale9Grid = MainTheme.SHADOW_SIDE_SCALE9_GRID;
    gradient.color = Color.BLACK;
	gradient.alpha = 0.5;
	gradient.width = 440;
	gradient.height = 140;
	gradient.source = Assets.getTexture("theme/gradeint-left", "gui");
	addChild(gradient);
	
	var hasQuit:Boolean = battleData.battleField.map.isOperation || SFSConnection.instance.mySelf.isSpectator;
	padding = 16;
	var leftPadding:int = (hasQuit ? 150 : 0);
	if( hasQuit )
	{
		var closeButton:CustomButton = new CustomButton();
		closeButton.style = "danger";
		closeButton.label = "X";
		closeButton.height = closeButton.width = 120;
		closeButton.layoutData = new AnchorLayoutData(padding, NaN, NaN, padding);
		closeButton.addEventListener(Event.TRIGGERED, closeButton_triggeredHandler);
		addChild(closeButton);			
	}
	
	var _name:String = battleData.battleField.map.isOperation ? loc("operation_label") + " " + StrUtils.getNumber(battleData.battleField.map.index + 1) : battleData.axis.getUtfString("name");
	var _point:int = player.admin ? battleData.axis.getInt("point") : 0;
	var opponentHeader:AttendeeHeader = new AttendeeHeader(_name, _point);
	opponentHeader.layoutData = new AnchorLayoutData(0, NaN, NaN, leftPadding );
	addChild(opponentHeader);
	
	if( SFSConnection.instance.mySelf.isSpectator )
	{
		_name = battleData.allis.getUtfString("name");
		_point = battleData.allis.getInt("point");
		var meHeader:AttendeeHeader = new AttendeeHeader(_name, player.admin ? _point : 0);
		meHeader.layoutData = new AnchorLayoutData(NaN, NaN, 0, 0 );
		addChild(meHeader);
	}
	
	if( debugMode )
	{
		timeLog = new RTLLabel("", 0);
		timeLog.layoutData = new AnchorLayoutData(padding * 10, padding * 6);
		addChild(timeLog);
	}

	if( battleData.battleField.map.isOperation )
	{
		timerSlider = new BattleTimerSlider();
		timerSlider.layoutData = new AnchorLayoutData(padding * 4, padding * 6);
	}
	else
	{
		timerSlider = new BattleCountdown();
		timerSlider.layoutData = new AnchorLayoutData(padding * 5, padding * 3);
	}
	addChild(timerSlider);
	
	addEventListener(FeathersEventType.CREATION_COMPLETE, createCompleteHandler);
	
	if( battleData.battleField.map.isOperation )
		return;
		
	deck = new BattleFooter();
	deck.layoutData = new AnchorLayoutData(NaN, 0, 0, 0);
	addChild(deck);

	/*if( !SFSConnection.instance.mySelf.isSpectator )
	{
		stickerButton = new CustomButton();
		stickerButton.icon = Assets.getTexture("tooltip-bg-bot-right", "gui");
		stickerButton.iconLayout = new AnchorLayoutData(NaN, NaN, NaN, NaN, 0, -4);
		stickerButton.width = 140;
		stickerButton.layoutData = new AnchorLayoutData(NaN, padding * 2, padding);
		stickerButton.addEventListener(Event.TRIGGERED, stickerButton_triggeredHandler);
		addChild(stickerButton);
	}*/
	
	if( !SFSConnection.instance.mySelf.isSpectator )
	{
        deck.addEventListener(FeathersEventType.BEGIN_INTERACTION, stickerButton_triggeredHandler);
		
		if ( player.get_arena(player.get_point()) > 4 )
		{
			surrenderButton = new CustomButton();
			surrenderButton.style = CustomButton.STYLE_DANGER;
			surrenderButton.icon = Assets.getTexture("surrender", "gui");
			surrenderButton.iconLayout = new AnchorLayoutData(NaN, NaN, NaN, NaN, 0, -4);
			surrenderButton.width = 140;
			surrenderButton.layoutData = new AnchorLayoutData(NaN, NaN, padding, padding);
			surrenderButton.addEventListener(Event.TRIGGERED, closeButton_triggeredHandler);
			addChild(surrenderButton);
		}
	}
	
	bubbleAllise = new StickerBubble();
	bubbleAllise.layoutData = new AnchorLayoutData(NaN, padding, padding);
	
	bubbleAxis = new StickerBubble(true);
	bubbleAxis.layoutData = new AnchorLayoutData(140 + padding, NaN, NaN, padding);
	
	scoreBoard = new BattleScoreBoard();
	scoreBoard.layoutData = new AnchorLayoutData(NaN, 0);
	scoreBoard.y = (BattleField.HEIGHT - scoreBoard.height) * 0.5;
	addChild(scoreBoard);
	updateScores(battleData.allis.getInt("score"), battleData.axis.getInt("score"));
}

protected function createCompleteHandler(event:Event):void
{
	removeEventListener(FeathersEventType.CREATION_COMPLETE, createCompleteHandler);
	timeManager.addEventListener(Event.CHANGE, timeManager_changeHandler);
	if( !battleData.battleField.map.isOperation )
		return;
	
	setTimePosition();
	if( battleData.battleField.extraTime > 0 )
		appModel.navigator.addAnimation(stage.stageWidth * 0.5, stage.stageHeight * 0.5, 240, Assets.getTexture("extra-time", "gui"), battleData.battleField.extraTime, BattleTimerSlider(timerSlider).iconDisplay.getBounds(this), 0.5, punchTimer, "+ ");
	function punchTimer():void {
		var diff:int = 48;
		timerSlider.y -= diff;
		Starling.juggler.tween(timerSlider, 0.4, {y:y + diff, transition:Transitions.EASE_OUT_ELASTIC});
	}
}

protected function timeManager_changeHandler(event:Event):void
{
	//trace(timeManager.now-battleData.startAt , battleData.battleField.map.times._list)
	if( scoreIndex < battleData.battleField.map.times.size() && timeManager.now - battleData.battleField.startAt > battleData.battleField.getTime(scoreIndex) )
	{
		scoreIndex ++;
		if( scoreIndex < battleData.battleField.map.times.size() )
		{
			setTimePosition();
		}
		else
		{
			timeManager.removeEventListener(Event.CHANGE, timeManager_changeHandler);
			timerSlider.enableStars(0);
		}
	}
	
	if ( !battleData.battleField.map.isOperation )
	{
		if( surrenderButton != null )
			surrenderButton.visible = battleData.battleField.startAt + battleData.battleField.map.times.get(0) < timeManager.now;
		var time:int = battleData.battleField.startAt + battleData.battleField.map.times.get(2) - timeManager.now;
		if( time < 0 )
			time = battleData.battleField.startAt + battleData.battleField.map.times.get(3) - timeManager.now;
		timerSlider.value = time;
		return;
	}
	
	time = timeManager.now - battleData.battleField.startAt - timerSlider.minimum;
	if( debugMode )
		timeLog.text = time.toString();
	//trace(time, timerSlider.minimum, timerSlider.maximum)
	if( time % 2 == 0 )
		Starling.juggler.tween(timerSlider, 1, {value:timerSlider.maximum - time, transition:Transitions.EASE_OUT_ELASTIC});
}

private function setTimePosition():void
{
	timerSlider.enableStars(2 - scoreIndex);
	timerSlider.minimum = scoreIndex > 0 ? battleData.battleField.getTime(scoreIndex - 1) : 0;
	timerSlider.value = timerSlider.maximum = battleData.battleField.getTime(scoreIndex);
	showTimeNotice(2 - scoreIndex);
	trace("[" + battleData.battleField.map.times._list + "]", "min:", timerSlider.minimum, "max:", timerSlider.maximum, "score:", 2 - scoreIndex);
}		

private function showTimeNotice(score:int):void
{
	if( score > 1 )
		return;
	
	if( battleData.battleField.map.isOperation )
	{
		appModel.navigator.addPopup(new BattleKeyChangeToast(score));
	}
	else if( score == -1 )
	{
		var shadow:Image = new Image(Assets.getTexture("bg-shadow", "gui"));
		shadow.touchable = false;
		shadow.width = stage.stageWidth;
		shadow.height = stage.stageHeight;
		shadow.alpha = 0.5;
		shadow.color = 0xAA0000;;
		addChildAt(shadow, 0);
		setTimeout(animateShadow, 1000, shadow, 0);
		appModel.navigator.addPopup(new BattleExtraTimeToast());
	}
}
public function animateShadow(shadow:Image, alphaSeed:Number):void
{
	Starling.juggler.tween(shadow, Math.random() + 0.1, {alpha:Math.random() * alphaSeed + 0.1, onComplete:animateShadow, onCompleteArgs:[shadow, alphaSeed==0?0.6:0]});
}

public function updateRoomVars():void
{
	if( battleData == null || battleData.battleField.map.isOperation || !battleData.room.containsVariable("towers") )
		return;
	
	/*var towers:Array = [0, 0, 0];
	for ( var i:int = 0; i < battleData.battleField.places.size(); i++ )
		towers[ battleData.battleField.places.get(i).building.troopType + 1 ] ++;
		updateScores(towers[1], towers[2]);
*/
}
public function updateScores(allise:int, axis:int) : void
{
	if( scoreBoard != null )
		scoreBoard.update(allise, axis);
}

protected function closeButton_triggeredHandler(event:Event):void
{
	dispatchEventWith(Event.CLOSE);
}

protected function stickerButton_triggeredHandler(event:Event):void
{
	deck.stickerButton.visible = false;
	if( stickerList == null )
	{
		var stickersLayout:TiledRowsLayout = new TiledRowsLayout();
		stickersLayout.padding = stickersLayout.gap = padding * 0.2;
		stickersLayout.tileHorizontalAlign = HorizontalAlign.JUSTIFY;
		stickersLayout.tileVerticalAlign = VerticalAlign.JUSTIFY;
		stickersLayout.useSquareTiles = false;
		stickersLayout.distributeWidths = true;
		stickersLayout.distributeHeights = true;
		stickersLayout.requestedColumnCount = 4;
		
		stickerList = new List();
		stickerList.layout = stickersLayout;
		stickerList.layoutData = new AnchorLayoutData(NaN, padding, NaN, 0);
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
	Starling.juggler.tween(stickerList.layoutData, 0.2, {bottom: -padding * 20, transition:Transitions.EASE_IN, onComplete:stickerList.removeFromParent});
}

protected function stickerCloserOveraly_triggeredHandler(event:Event):void
{
	hideStickerList();
	deck.stickerButton.visible = true;
}

protected function stickerList_changeHandler(event:Event):void
{
	hideStickerList();
	var sticker:int = stickerList.selectedItem as int
	appModel.battleFieldView.responseSender.sendSticker(sticker);
	showBubble(sticker);
	stickerList.selectedIndex = -1;
	GameAnalytics.addDesignEvent("sticker:st" + sticker);
}

public function showBubble(type:int, itsMe:Boolean=true):void
{
	var bubble:StickerBubble = itsMe ? bubbleAllise : bubbleAxis;
	if( bubble == null )
		return;
	
	Starling.juggler.removeTweens(bubble);
	bubble.type = type;
	bubble.scale = 0.5;
	addChild(bubble);
	Starling.juggler.tween(bubble, 0.2, {scale:1.0, transition:Transitions.EASE_OUT_BACK});
	Starling.juggler.tween(bubble, 0.2, {scale:0.5, transition:Transitions.EASE_IN_BACK, delay:4, onComplete:hideBubble, onCompleteArgs:[bubble]});
	appModel.sounds.addAndPlaySound("whoosh");
}

private function hideBubble(bubble:StickerBubble):void
{
	bubble.removeFromParent();
	if( SFSConnection.instance.lastJoinedRoom != null && !SFSConnection.instance.mySelf.isSpectator )
		deck.stickerButton.visible = true;
}

public function end(overlay:EndOverlay) : void 
{
	// remove all element except sticker elements
	var numCh:int = numChildren - 1;
	while ( numCh >= 0 )
	{
		if( getChildAt(numCh) != bubbleAllise && getChildAt(numCh) != bubbleAxis && getChildAt(numCh) != deck.stickerButton && getChildAt(numCh) != scoreBoard )
			getChildAt(numCh).removeFromParent(true);
		numCh --;
	}

	addChildAt(overlay, 0);
	if( scoreBoard != null )
		addChildAt(scoreBoard, 0);
}

public function stopTimers() : void
{
	timeManager.removeEventListener(Event.CHANGE, timeManager_changeHandler);
	Starling.juggler.removeTweens(timerSlider);
}

override public function dispose():void
{
	stopTimers();
	super.dispose();
}
}
}