package com.gerantech.towercraft.controls.screens
{
import com.gerantech.towercraft.controls.items.PlayersItemRenderer;
import com.gerantech.towercraft.controls.popups.BroadcastMessagePopup;
import com.gerantech.towercraft.controls.popups.ProfilePopup;
import com.gerantech.towercraft.controls.texts.CustomTextInput;
import com.gerantech.towercraft.managers.net.sfs.SFSConnection;
import com.smartfoxserver.v2.core.SFSEvent;
import com.smartfoxserver.v2.entities.data.SFSArray;
import com.smartfoxserver.v2.entities.data.SFSObject;
import flash.text.ReturnKeyLabel;
import flash.text.SoftKeyboardType;
import feathers.controls.renderers.IListItemRenderer;
import feathers.data.ListCollection;
import feathers.events.FeathersEventType;
import feathers.layout.AnchorLayoutData;
import starling.events.Event;

public class PlayersScreen extends ListScreen
{
private var players:ListCollection = new ListCollection();
private var textInput:CustomTextInput;

public function PlayersScreen(){}
override protected function initialize():void
{
	title = "Players";
	super.initialize();
	
	textInput = new CustomTextInput(SoftKeyboardType.DEFAULT, ReturnKeyLabel.SEARCH);
	textInput.promptProperties
	textInput.promptProperties.fontSize = textInput.textEditorProperties.fontSize = 0.8*appModel.theme.gameFontSize*appModel.scale;
	textInput.maxChars = 16 ;
	textInput.prompt = "نام  |  آیدی(!)  |  تگ(#)";
	textInput.addEventListener(FeathersEventType.ENTER, searchButton_triggeredHandler);
	textInput.layoutData = new AnchorLayoutData( 0, 0, NaN, 0);
	textInput.height = listLayout.padding * 0.9;
	addChild(textInput);
	
	listLayout.gap = 0;	
	list.itemRendererFactory = function():IListItemRenderer { return new PlayersItemRenderer(); }
	list.addEventListener(FeathersEventType.FOCUS_IN, list_focusHandler);
	list.dataProvider = players;
}

private function searchButton_triggeredHandler():void
{
	if( textInput.text.length < 3 )
	{
		appModel.navigator.addLog("Wrong Pattern!");
		return;
	}
	var params:SFSObject = new SFSObject();
	if( textInput.text.substr(0, 1) == "#" )
		params.putText("tag", textInput.text.substr(1));
	else if( textInput.text.substr(0, 1)=="!" )
		params.putInt("id", int(textInput.text.substr(1)));
	else
		params.putUtfString("name", textInput.text);
	SFSConnection.instance.addEventListener(SFSEvent.EXTENSION_RESPONSE, sfs_issuesResponseHandler);
	SFSConnection.instance.sendExtensionRequest("playersGet", params);
}
protected function sfs_issuesResponseHandler(event:SFSEvent):void
{
	if( event.params.cmd != "playersGet" )
		return;
	SFSConnection.instance.removeEventListener(SFSEvent.EXTENSION_RESPONSE, sfs_issuesResponseHandler);
	players.data = SFSArray(SFSObject(event.params.params).getSFSArray("players")).toArray();
}

protected function list_focusHandler(event:Event):void
{
    appModel.navigator.addPopup(new ProfilePopup(event.data.data));
}
}
}