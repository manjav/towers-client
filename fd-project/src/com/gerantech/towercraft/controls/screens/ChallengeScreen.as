package com.gerantech.towercraft.controls.screens 
{
import com.gerantech.towercraft.controls.buttons.CustomButton;
import com.gerantech.towercraft.controls.buttons.ExchangeButton;
import com.gerantech.towercraft.controls.groups.Devider;
import com.gerantech.towercraft.controls.items.challenges.ChallengeAttendeeItemRenderer;
import com.gerantech.towercraft.controls.items.challenges.ChallengeRewardItemRenderer;
import com.gerantech.towercraft.controls.overlays.OpenBookOverlay;
import com.gerantech.towercraft.controls.popups.ConfirmPopup;
import com.gerantech.towercraft.controls.popups.RequirementConfirmPopup;
import com.gerantech.towercraft.controls.texts.CountdownLabel;
import com.gerantech.towercraft.controls.texts.RTLLabel;
import com.gerantech.towercraft.managers.net.sfs.SFSCommands;
import com.gerantech.towercraft.managers.net.sfs.SFSConnection;
import com.gerantech.towercraft.models.Assets;
import com.gerantech.towercraft.themes.BaseMetalWorksMobileTheme;
import com.gt.towers.constants.MessageTypes;
import com.gt.towers.constants.ResourceType;
import com.gt.towers.socials.Attendee;
import com.gt.towers.socials.Challenge;
import com.gt.towers.utils.maps.IntIntMap;
import com.smartfoxserver.v2.core.SFSEvent;
import com.smartfoxserver.v2.entities.data.ISFSArray;
import com.smartfoxserver.v2.entities.data.ISFSObject;
import com.smartfoxserver.v2.entities.data.SFSArray;
import com.smartfoxserver.v2.entities.data.SFSObject;
import feathers.controls.ImageLoader;
import feathers.controls.List;
import feathers.controls.ScrollBarDisplayMode;
import feathers.controls.renderers.IListItemRenderer;
import feathers.data.ListCollection;
import feathers.layout.AnchorLayout;
import feathers.layout.AnchorLayoutData;
import feathers.layout.HorizontalAlign;
import feathers.layout.TiledRowsLayout;
import feathers.layout.VerticalLayout;
import starling.events.Event;

/**
* ...
* @author Mansour Djawadi ...
*/
public class ChallengeScreen extends BaseFomalScreen
{
public var challenge:Challenge;
private var state:int;
private var countdownDisplay:CountdownLabel;
private var earnOverlay:OpenBookOverlay;

public function ChallengeScreen() {	super(); }
override protected function initialize():void
{
	title = loc("challenge_title_0");
	super.initialize();
	changeState();
}

private function changeState():void 
{
	resetAll();
	state = challenge.getState(timeManager.now);
	showWait();
	showStarted();
	showEnded();
}

private function showWait():void 
{
	if( state != Challenge.STATE_WAIT )
		return;

	var messageDisplay:RTLLabel = new RTLLabel(loc("challenge_message_0"), 1, null, null, true, null, 0.8);
	messageDisplay.layoutData = new AnchorLayoutData(200, 32, NaN, 32);
	addChild(messageDisplay);

	rewardFactory();
	footerFactory();
	countdownFactory();
	buttonFactory();
}

private function showStarted():void 
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

private function sfs_responseGetHandler(e:SFSEvent):void 
{
	if( e.params.cmd != SFSCommands.CHALLENGE_UPDATE )
		return;
	SFSConnection.instance.removeEventListener(SFSEvent.EXTENSION_RESPONSE, sfs_responseGetHandler);
	
	var attendees:ISFSArray = SFSObject(e.params.params).getSFSArray("attendees");
	challenge.attendees = new Array();
	for (var a:int = 0; a < attendees.size(); a++)
	{
		var att:ISFSObject = attendees.getSFSObject(a);
		challenge.attendees.push(new Attendee(att.getInt("id"), att.getText("name"), att.getInt("point"), att.getInt("lastUpdate")));
	}
	player.challenges.set(challenge.type, challenge);
	
	updateList();
}

private function updateList():void 
{
	attendeesFactory();
	footerFactory();	
	countdownFactory();
	buttonFactory();
}

private function showEnded():void 
{
	if( state != Challenge.STATE_END )
		return;
	attendeesFactory();
	footerFactory();
	buttonFactory();
}

// factories -----------------------------------
private function rewardFactory():void 
{
	var rewardsLayout:TiledRowsLayout = new TiledRowsLayout();
	rewardsLayout.useSquareTiles = false;
	rewardsLayout.requestedColumnCount = 2;
	rewardsLayout.padding = rewardsLayout.gap = 24;
	rewardsLayout.typicalItemWidth = stageWidth * 0.5 - rewardsLayout.gap * 3;
	
	var rewardsData:ListCollection = new ListCollection();
	rewardsData.addItem({index:appModel.isLTR?1:2,	book:challenge.rewards.get(appModel.isLTR?1:2)});
	rewardsData.addItem({index:appModel.isLTR?2:1,	book:challenge.rewards.get(appModel.isLTR?2:1)});
	rewardsData.addItem({index:appModel.isLTR?3:4,	book:challenge.rewards.get(appModel.isLTR?3:4)});
	rewardsData.addItem({index:appModel.isLTR?4:3,	book:challenge.rewards.get(appModel.isLTR?4:3)});
	rewardsData.addItem(appModel.isLTR ?			{index:5, book:challenge.rewards.get(5)} : {});
	if( !appModel.isLTR )
		rewardsData.addItem({index:5, book:challenge.rewards.get(5)});
	
	var rewardsList:List = new List();
	rewardsList.touchable = false;
	rewardsList.layout = rewardsLayout;
	rewardsList.layoutData = new AnchorLayoutData(500, 0, NaN, 0);
	rewardsList.dataProvider = rewardsData;
	rewardsList.itemRendererFactory = function () : IListItemRenderer { return new ChallengeRewardItemRenderer(); }
	addChild(rewardsList);
}

private function attendeesFactory() : void 
{
	var attendeesLayout:TiledRowsLayout = new TiledRowsLayout();
	attendeesLayout.useSquareTiles = false;
	attendeesLayout.requestedColumnCount = 2;
	attendeesLayout.horizontalAlign = HorizontalAlign.JUSTIFY;
	attendeesLayout.padding = attendeesLayout.gap = 24;

	challenge.attendees.sortOn( ["point", "updateAt"],[Array.DESCENDING,Array.DESCENDING]);
	//challenge.attendees.sortOn("point", Array.NUMERIC|Array.DESCENDING);
	var attendeesList:List = new List();
	attendeesList.scrollBarDisplayMode = ScrollBarDisplayMode.NONE;
	attendeesList.layout = attendeesLayout;
	attendeesList.layoutData = new AnchorLayoutData(headerSize + 80, 0, 550, 0);
	attendeesList.dataProvider = new ListCollection(challenge.attendees);
	attendeesList.itemRendererFactory = function () : IListItemRenderer { return new ChallengeAttendeeItemRenderer(challenge); }
	addChild(attendeesList);
}

private function footerFactory():void 
{
	var dscriptionBG:Devider = new Devider( state == Challenge.STATE_WAIT ? 0x333333 : (state == Challenge.STATE_STARTED ? 0x235E8E : 0xB60300) );
	dscriptionBG.layout = new AnchorLayout();
	dscriptionBG.height = 400;
	dscriptionBG.layoutData = new AnchorLayoutData(NaN, 0, 150, 0);
	addChild(dscriptionBG);
	
	var shadow:ImageLoader = new ImageLoader();
	shadow.color = 0;
	shadow.alpha = 0.5;
	shadow.height = 30;
	shadow.source = Assets.getTexture("theme/gradeint-bottom", "gui");
	shadow.scale9Grid = BaseMetalWorksMobileTheme.SHADOW_SIDE_SCALE9_GRID;
	shadow.layoutData = new AnchorLayoutData(-shadow.height, 0, NaN, 0);
	dscriptionBG.addChild(shadow);
	
	var joined:Boolean = challenge.indexOfAttendees(player.id) > -1 && state == Challenge.STATE_WAIT;
	var message:String = joined ? loc("challenge_description_joined") : loc("challenge_description_" + state);
	var descriptionDisplay:RTLLabel = new RTLLabel(message, 1, null, null, true, null, 0.8);
	descriptionDisplay.layoutData = new AnchorLayoutData(10, 32, 0, 32);
	dscriptionBG.addChild(descriptionDisplay);
}

private function countdownFactory():void 
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

private function buttonFactory():void 
{
	var	buttonDisplay:CustomButton;
	if( state == Challenge.STATE_WAIT )
	{
		if( challenge.indexOfAttendees(player.id) > -1 )
			return;
		
		buttonDisplay = new ExchangeButton();
		ExchangeButton(buttonDisplay).count = 1;
		buttonDisplay.label = loc("challenge_button_" + state) + "   " + challenge.requirements.values()[0];
		ExchangeButton(buttonDisplay).type = challenge.requirements.keys()[0];
		buttonDisplay.width = 500;
	}
	else
	{
		buttonDisplay = new CustomButton();
		buttonDisplay.label = loc("challenge_button_" + state);
		buttonDisplay.width = 380;
	}
	
	buttonDisplay.layoutData = new AnchorLayoutData(NaN, NaN, 180, NaN, 0);
	buttonDisplay.addEventListener(Event.TRIGGERED, buttonDisplay_triggeredHandler);
	addChild(buttonDisplay);
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
		var registerPopup:ConfirmPopup = new ConfirmPopup(loc("challenge_join_confirm"));
		registerPopup.addEventListener(Event.SELECT, registerPopup_selectHandler);
		appModel.navigator.addPopup(registerPopup);
	}
	else if( state == Challenge.STATE_STARTED )
	{
		DashboardScreen.tabIndex = 2;
		appModel.navigator.popScreen();
	}
	else if( state == Challenge.STATE_END )
	{
		earnOverlay = new OpenBookOverlay(challenge.getRewardByAttendee(player.id));
		appModel.navigator.addOverlay(earnOverlay);
		
		var params:ISFSObject = new SFSObject();
		params.putInt("id", challenge.id);
		SFSConnection.instance.addEventListener(SFSEvent.EXTENSION_RESPONSE, sfs_responseCollectHandler);
		SFSConnection.instance.sendExtensionRequest(SFSCommands.CHALLENGE_COLLECT, params);
	}
}

private function registerPopup_selectHandler(event:Event):void 
{
	event.currentTarget.removeEventListener(Event.SELECT, registerPopup_selectHandler);
	SFSConnection.instance.addEventListener(SFSEvent.EXTENSION_RESPONSE, sfs_responseJoinHandler);
	SFSConnection.instance.sendExtensionRequest(SFSCommands.CHALLENGE_JOIN);
	challenge.attendees.push(new Attendee(player.id, player.nickName, 120, timeManager.now));
	appModel.navigator.popScreen();
}

private function sfs_responseJoinHandler(e:SFSEvent):void 
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

private function sfs_responseCollectHandler(e:SFSEvent):void 
{
	if( e.params.cmd != SFSCommands.CHALLENGE_COLLECT )
		return;
	SFSConnection.instance.removeEventListener(SFSEvent.EXTENSION_RESPONSE, sfs_responseCollectHandler);
	var params:ISFSObject = e.params.params as SFSObject;
	trace( params.getDump() );
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
	earnOverlay.outcomes = outcomes;
	
	player.challenges = null;
	appModel.navigator.popScreen();
}

private function resetAll():void 
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