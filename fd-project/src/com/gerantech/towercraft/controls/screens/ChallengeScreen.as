package com.gerantech.towercraft.controls.screens 
{
import com.gerantech.towercraft.controls.buttons.CustomButton;
import com.gerantech.towercraft.controls.buttons.ExchangeButton;
import com.gerantech.towercraft.controls.items.challenges.ChallengeAttendeeItemRenderer;
import com.gerantech.towercraft.controls.items.challenges.ChallengePrizeItemRenderer;
import com.gerantech.towercraft.controls.overlays.OpenBookOverlay;
import com.gerantech.towercraft.controls.popups.BookDetailsPopup;
import com.gerantech.towercraft.controls.popups.ProfilePopup;
import com.gerantech.towercraft.controls.texts.CountdownLabel;
import com.gerantech.towercraft.controls.texts.RTLLabel;
import com.gerantech.towercraft.controls.texts.ShadowLabel;
import com.gerantech.towercraft.managers.net.sfs.SFSCommands;
import com.gerantech.towercraft.managers.net.sfs.SFSConnection;
import com.gerantech.towercraft.models.Assets;
import com.gerantech.towercraft.themes.MainTheme;
import com.gt.towers.others.Arena;
import com.gt.towers.constants.MessageTypes;
import com.gt.towers.constants.ResourceType;
import com.gt.towers.exchanges.ExchangeItem;
import com.gt.towers.others.Arena;
import com.gt.towers.socials.Attendee;
import com.gt.towers.socials.Challenge;
import com.gt.towers.utils.maps.IntIntMap;
import com.smartfoxserver.v2.core.SFSEvent;
import com.smartfoxserver.v2.entities.data.ISFSArray;
import com.smartfoxserver.v2.entities.data.ISFSObject;
import com.smartfoxserver.v2.entities.data.SFSObject;
import feathers.controls.ImageLoader;
import feathers.controls.List;
import feathers.controls.ScrollBarDisplayMode;
import feathers.controls.renderers.IListItemRenderer;
import feathers.data.ListCollection;
import feathers.events.FeathersEventType;
import feathers.layout.AnchorLayoutData;
import feathers.layout.HorizontalAlign;
import feathers.layout.TiledRowsLayout;
import feathers.layout.VerticalLayout;
import flash.geom.Rectangle;
import flash.utils.setTimeout;
import starling.display.Quad;
import starling.events.Event;

/**
* ...
* @author Mansour Djawadi ...
*/
public class ChallengeScreen extends BaseFomalScreen
{
public var challenge:Challenge;
protected var state:int;
private var countdownDisplay:CountdownLabel;
private var earnOverlay:OpenBookOverlay;

public function ChallengeScreen() {	super(); }
override protected function initialize():void
{
	title = loc("challenge_title_" + challenge.type);
	super.initialize();
	changeState();
}

protected function changeState():void 
{
	resetAll();
	state = challenge.getState(timeManager.now);
	
	backgroundSkin = new Quad(1, 1, state == Challenge.STATE_WAIT ? MainTheme.STYLE_BLUE : (state == Challenge.STATE_STARTED ? MainTheme.STYLE_GREEN : MainTheme.STYLE_GRAY));
	backgroundSkin.alpha = 0.8;
	
	showWait();
	showStarted();
	showEnded();
}

protected function showWait():void 
{
	if( state != Challenge.STATE_WAIT )
		return;

	var messageDisplay:RTLLabel = new RTLLabel(loc("challenge_message_" + challenge.type), 1, null, null, true, null, 0.8);
	messageDisplay.layoutData = new AnchorLayoutData(200, 32, NaN, 32);
	addChild(messageDisplay);

	rewardFactory();
	footerFactory();
	countdownFactory();
	buttonFactory();
}

protected function showStarted():void 
{
	if( state != Challenge.STATE_STARTED )
		return;
	
	if ( challenge.id > -1 )
	{
		var sfs:SFSObject = new SFSObject();
		sfs.putInt("id", challenge.id);
		SFSConnection.instance.addEventListener(SFSEvent.EXTENSION_RESPONSE, sfs_responseGetHandler);
		SFSConnection.instance.sendExtensionRequest(SFSCommands.CHALLENGE_UPDATE, sfs);
	}
	else
	{
		updateList();
	}
}

protected function sfs_responseGetHandler(e:SFSEvent):void 
{
	if( e.params.cmd != SFSCommands.CHALLENGE_UPDATE )
		return;
	SFSConnection.instance.removeEventListener(SFSEvent.EXTENSION_RESPONSE, sfs_responseGetHandler);
	
	var attendees:ISFSArray = SFSObject(e.params.params).getSFSArray("attendees");
	challenge.attendees = new Array();
	for (var a:int = 0; a < attendees.size(); a++)
	{
		var att:ISFSObject = attendees.getSFSObject(a);
		challenge.attendees.push(new Attendee(att.getInt("id"), att.getText("name"), att.getInt("point"), att.getInt("updateAt")));
	}
	player.challenges.set(challenge.type, challenge);
	updateList();
}

protected function updateList():void 
{
	attendeesFactory();
	footerFactory();	
	countdownFactory();
	buttonFactory();
}

protected function showEnded():void 
{
	if( state != Challenge.STATE_END )
		return;
	attendeesFactory();
	footerFactory();
	buttonFactory();
}

// factories -----------------------------------
protected function rewardFactory():void 
{
	var rewardsLayout:TiledRowsLayout = new TiledRowsLayout();
	rewardsLayout.useSquareTiles = false;
	rewardsLayout.requestedColumnCount = 2;
	rewardsLayout.padding = rewardsLayout.gap = 24;
	rewardsLayout.typicalItemWidth = stageWidth * 0.5 - rewardsLayout.gap * 3;
	
	var rewardsData:ListCollection = new ListCollection();
	rewardsData.addItem(getPrize(appModel.isLTR?1:2));
	rewardsData.addItem(getPrize(appModel.isLTR?2:1));
	rewardsData.addItem(getPrize(appModel.isLTR?3:4));
	rewardsData.addItem(getPrize(appModel.isLTR?4:3));
	rewardsData.addItem(getPrize(appModel.isLTR?5:6));
	rewardsData.addItem(getPrize(appModel.isLTR?6:5));
	rewardsData.addItem(getPrize(appModel.isLTR?7:8));
	rewardsData.addItem(getPrize(appModel.isLTR?8:7));

	var rewardsList:List = new List();
	rewardsList.layout = rewardsLayout;
	rewardsList.layoutData = new AnchorLayoutData(500, 0, NaN, 0);
	rewardsList.dataProvider = rewardsData;
	rewardsList.itemRendererFactory = function () : IListItemRenderer { return new ChallengePrizeItemRenderer(); }
	rewardsList.addEventListener(FeathersEventType.FOCUS_IN, rewardsList_focusInHandler);
	addChild(rewardsList);
	
	function getPrize(key:int) : Arena 
	{
		if( challenge.rewards.exists(key) )
			return challenge.rewards.get(key);
		return new Arena(0, 0, 0, 0, null);
	}
}

protected function attendeesFactory() : void 
{
	var pointTab:ShadowLabel = new ShadowLabel(loc(Challenge.getTargetLabel(challenge.type)), 1, 0, null, null, false, null, 0.8);
	pointTab.layoutData = new AnchorLayoutData(headerSize + 10, appModel.isLTR?280:NaN, NaN, appModel.isLTR?NaN:280);
	addChild(pointTab);

	var prizeTab:ShadowLabel = new ShadowLabel(loc("challenge_prize"), 1, 0, null, null, false, null, 0.8);
	prizeTab.layoutData = new AnchorLayoutData(headerSize + 10, appModel.isLTR?50:NaN, NaN, appModel.isLTR?NaN:50);
	addChild(prizeTab);

	var attendeesLayout:VerticalLayout = new VerticalLayout();
	attendeesLayout.horizontalAlign = HorizontalAlign.JUSTIFY;
	attendeesLayout.padding = attendeesLayout.gap = 10

	challenge.sort();
	var attendeesList:List = new List();
	attendeesList.scrollBarDisplayMode = ScrollBarDisplayMode.NONE;
	attendeesList.layout = attendeesLayout;
	attendeesList.layoutData = new AnchorLayoutData(headerSize + 80, 0, 550, 0);
	attendeesList.dataProvider = new ListCollection(challenge.attendees);
	attendeesList.itemRendererFactory = function () : IListItemRenderer { return new ChallengeAttendeeItemRenderer(challenge); }
	attendeesList.addEventListener(FeathersEventType.FOCUS_IN, attendeesList_focusInHandler);
	setTimeout(scrollMe, 700, attendeesList);
	addChild(attendeesList);
	
	var shadowTop:ImageLoader = new ImageLoader();
	shadowTop.touchable = false;
	shadowTop.color = 0;
	shadowTop.alpha = 0.5;
	shadowTop.height = 30;
	shadowTop.source = Assets.getTexture("theme/gradeint-top", "gui");
	shadowTop.scale9Grid = MainTheme.SHADOW_SIDE_SCALE9_GRID;
	shadowTop.layoutData = new AnchorLayoutData(headerSize + 79, 0, NaN, 0);
	addChild(shadowTop);
	
	var shadowBottom:ImageLoader = new ImageLoader();
	shadowBottom.touchable = false;
	shadowBottom.color = 0;
	shadowBottom.alpha = 0.5;
	shadowBottom.height = 30;
	shadowBottom.source = Assets.getTexture("theme/gradeint-bottom", "gui");
	shadowBottom.scale9Grid = MainTheme.SHADOW_SIDE_SCALE9_GRID;
	shadowBottom.layoutData = new AnchorLayoutData(NaN, 0, 550, 0);
	addChild(shadowBottom);
}
protected function scrollMe(attendeesList:List) : void 
{
	var indexOfMe:int = findMe(attendeesList);
	if( indexOfMe > -1 )
		attendeesList.scrollToDisplayIndex(indexOfMe, 0.5);
}
protected function findMe(attendeesList:List):int
{
	for (var i:int=0; i<attendeesList.dataProvider.length; i++)
		if( attendeesList.dataProvider.getItemAt(i).id == player.id )
			return i;
	return -1;
}

protected function footerFactory():void 
{
	var joined:Boolean = challenge.indexOfAttendees(player.id) > -1 && state == Challenge.STATE_WAIT;
	var message:String = joined ? loc("challenge_description_joined") : loc("challenge_description_" + state);
	var descriptionDisplay:RTLLabel = new RTLLabel(message, 1, null, null, true, null, 0.8);
	descriptionDisplay.layoutData = new AnchorLayoutData(NaN, 16, 440, 16);
	addChild(descriptionDisplay);
}

protected function countdownFactory():void 
{
	if( countdownDisplay == null )
		countdownDisplay = new CountdownLabel();
	countdownDisplay.time = challenge.startAt - timeManager.now + (state == Challenge.STATE_STARTED ? challenge.duration : 0);
	countdownDisplay.localString = state == Challenge.STATE_WAIT ? "challenge_start_at" : "challenge_end_at";
	countdownDisplay.height = 100;
	countdownDisplay.layoutData = new AnchorLayoutData(NaN, 150, 320, 120);
	addChild(countdownDisplay);

	timeManager.addEventListener(Event.CHANGE, timeManager_changeHandler);
}

protected function buttonFactory():void 
{
	var	buttonDisplay:CustomButton;
	if( state == Challenge.STATE_WAIT )
	{
		if( challenge.indexOfAttendees(player.id) > -1 )
			return;
		
		buttonDisplay = new ExchangeButton();
		ExchangeButton(buttonDisplay).count = challenge.joinRequirements.values()[0];
		if( ExchangeButton(buttonDisplay).count > 0 )
			buttonDisplay.label = loc("challenge_button_" + state) + "   " + ExchangeButton(buttonDisplay).count;
		ExchangeButton(buttonDisplay).type = challenge.joinRequirements.keys()[0];
		buttonDisplay.width = 500;
	}
	else
	{
		buttonDisplay = new ExchangeButton();
		buttonDisplay.style = CustomButton.STYLE_NEUTRAL;
		ExchangeButton(buttonDisplay).count = challenge.runRequirements.values()[0];
		if( ExchangeButton(buttonDisplay).count > 0 )
			buttonDisplay.label = ExchangeButton(buttonDisplay).count + "     " + loc("challenge_button_" + state);
		else
			buttonDisplay.label = loc("challenge_button_" + state);
		ExchangeButton(buttonDisplay).type = challenge.runRequirements.keys()[0];
		buttonDisplay.width = 380;
	}
	
	buttonDisplay.layoutData = new AnchorLayoutData(NaN, NaN, 180, NaN, 0);
	buttonDisplay.addEventListener(Event.TRIGGERED, buttonDisplay_triggeredHandler);
	addChild(buttonDisplay);
}

protected function attendeesList_focusInHandler(e:Event) : void 
{
	var att:Attendee = e.data as Attendee;
	appModel.navigator.addPopup(new ProfilePopup({id:att.id, name:att.name}));
}

protected function rewardsList_focusInHandler(e:Event) : void 
{
	if( !ResourceType.isBook(e.data as int) )
		return;
	var item:ExchangeItem = new ExchangeItem(0, 0, 0, null, e.data + ":" + player.get_arena(0));
	appModel.navigator.addPopup(new BookDetailsPopup(item, false));
}

protected function timeManager_changeHandler(e:Event):void 
{
	var _state:int = challenge.getState(timeManager.now);
	if( state != _state )
	{
		if( _state == Challenge.STATE_STARTED && challenge.indexOfAttendees(player.id) <= -1 )
			appModel.navigator.popScreen();
		else
			changeState();
		return;
	}
	countdownDisplay.time = challenge.startAt - timeManager.now + (state == Challenge.STATE_STARTED ? challenge.duration : 0);
}

protected function buttonDisplay_triggeredHandler(e:Event):void 
{
	if( state == Challenge.STATE_WAIT )
	{
		if( challenge.indexOfAttendees(player.id) > -1 )
		{
			appModel.navigator.addLog(loc("challenge_error_already"));
			return;
		}
		
		var response:int = exchanger.exchange(Challenge.getExchangeItem(challenge.type, challenge.joinRequirements, player.get_arena(0)), 0, 0);
		if( response != MessageTypes.RESPONSE_SUCCEED )
		{
			DashboardScreen.TAB_INDEX = 0;
			appModel.navigator.addLog(loc("log_not_enough", [loc("resource_title_" + challenge.joinRequirements.keys()[0])]));
			appModel.navigator.popScreen();
			return;
		}
		SFSConnection.instance.addEventListener(SFSEvent.EXTENSION_RESPONSE, sfs_responseJoinHandler);
		var params:ISFSObject = new SFSObject();
		params.putInt("type", challenge.type);
		SFSConnection.instance.sendExtensionRequest(SFSCommands.CHALLENGE_JOIN, params);
		challenge.attendees.push(new Attendee(player.id, player.nickName, 120, timeManager.now));
		appModel.navigator.popScreen();
	}
	else if( state == Challenge.STATE_STARTED )
	{
		response = challenge.run(game, timeManager.now, player.get_arena(0));
		if( response != MessageTypes.RESPONSE_SUCCEED )
		{
			DashboardScreen.TAB_INDEX = 0;
			appModel.navigator.addLog(loc("log_not_enough", [loc("resource_title_" + challenge.joinRequirements.keys()[0])]));
			appModel.navigator.popScreen();
			return;
		}
		appModel.navigator.runBattle(false, null, null, false, challenge.type);
	}
	else if( state == Challenge.STATE_END )
	{
		var reward:int = challenge.getRewardByAttendee(player.id).keys()[0];
		if( ResourceType.isBook(reward) )
		{
			earnOverlay = new OpenBookOverlay(challenge.getRewardByAttendee(player.id).keys()[0]);
			appModel.navigator.addOverlay(earnOverlay);
		}
		else
		{
			var rect:Rectangle = CustomButton(e.currentTarget).getBounds(stage);
			appModel.navigator.addMapAnimation(rect.x + rect.width * 0.5, rect.y, challenge.getRewardByAttendee(player.id));
		}
		
		params = new SFSObject();
		params.putInt("id", challenge.id);
		SFSConnection.instance.addEventListener(SFSEvent.EXTENSION_RESPONSE, sfs_responseCollectHandler);
		SFSConnection.instance.sendExtensionRequest(SFSCommands.CHALLENGE_COLLECT, params);
	}
}

protected function sfs_responseJoinHandler(e:SFSEvent):void 
{
	if( e.params.cmd != SFSCommands.CHALLENGE_JOIN )
		return;
	SFSConnection.instance.removeEventListener(SFSEvent.EXTENSION_RESPONSE, sfs_responseJoinHandler);
	var params:ISFSObject = e.params.params as SFSObject;
	if( params.getInt("response") != MessageTypes.RESPONSE_SUCCEED )
	{
		appModel.navigator.addLog(loc("challenge_error_join_" + params.getInt("response")));
		return;
	}
}

protected function sfs_responseCollectHandler(e:SFSEvent):void 
{
	if( e.params.cmd != SFSCommands.CHALLENGE_COLLECT )
		return;
	SFSConnection.instance.removeEventListener(SFSEvent.EXTENSION_RESPONSE, sfs_responseCollectHandler);
	var params:ISFSObject = e.params.params as SFSObject;
	if( params.getInt("response") != MessageTypes.RESPONSE_SUCCEED )
	{
		appModel.navigator.addLog(loc("challenge_error_collect_" + params.getInt("response")));
		return;
	}
	
	var outcomes:IntIntMap = new IntIntMap();
	//trace(data.getSFSArray("rewards").getDump());
	var reward:ISFSObject;
	for( var i:int=0; i<params.getSFSArray("rewards").size(); i++ )
	{
		reward = params.getSFSArray("rewards").getSFSObject(i);
		if( ResourceType.isBuilding(reward.getInt("t")) || ResourceType.isBook(reward.getInt("t")) || reward.getInt("t") == ResourceType.CURRENCY_HARD || reward.getInt("t") == ResourceType.CURRENCY_SOFT || reward.getInt("t") == ResourceType.XP )
			outcomes.set(reward.getInt("t"), reward.getInt("c"));
	}
	
	player.addResources( outcomes );
	if( earnOverlay != null )
		earnOverlay.outcomes = outcomes;
	
	player.challenges = null;
	appModel.navigator.popScreen();
}

protected function resetAll():void 
{
	timeManager.removeEventListener(Event.CHANGE, timeManager_changeHandler);
	removeChildren(2);
}

override public function dispose():void 
{
	resetAll();
	super.dispose();
}
}
}