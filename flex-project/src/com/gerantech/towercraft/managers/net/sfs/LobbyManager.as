package com.gerantech.towercraft.managers.net.sfs
{
import com.gerantech.towercraft.models.AppModel;
import com.gerantech.towercraft.models.vo.UserData;
import com.gt.towers.Player;
import com.gt.towers.constants.MessageTypes;
import com.smartfoxserver.v2.core.SFSEvent;
import com.smartfoxserver.v2.entities.Room;
import com.smartfoxserver.v2.entities.data.ISFSArray;
import com.smartfoxserver.v2.entities.data.ISFSObject;
import com.smartfoxserver.v2.entities.data.SFSObject;

import feathers.data.ListCollection;

import starling.events.Event;
import starling.events.EventDispatcher;

public class LobbyManager extends EventDispatcher
{
public var isReady:Boolean;
public var lobby:Room;
public var messages:ListCollection;
public var members:ISFSArray;
public var point:int;
public var emblem:int;
public var activeness:int;

private var player:Player;

public function LobbyManager()
{
	initialize();
}

public function initialize():void
{
	var _lobby:Room = SFSConnection.instance.getLobby();
	if( _lobby == null )
	{
		dispose();
		return;
	}
	if( lobby != null && lobby.id == _lobby.id )
		return;
	
	dispose();
	lobby = _lobby;
	requestData();

	player = AppModel.instance.game.player;
}

public function requestData(broadcast:Boolean = false, skipMessages:Boolean = false):void
{
	var params:SFSObject = new SFSObject();
	params.putInt("id", lobby.id);
	if( broadcast )
		params.putBool("broadcast", true);
	if( skipMessages )
		params.putBool("nomsg", true);
	SFSConnection.instance.addEventListener(SFSEvent.EXTENSION_RESPONSE, sfs_getLobbyInfoHandler);
	SFSConnection.instance.sendExtensionRequest(SFSCommands.LOBBY_INFO, params, lobby);	
}

protected function sfs_getLobbyInfoHandler(event:SFSEvent):void
{
	if( event.params.cmd != SFSCommands.LOBBY_INFO )
		return;

	var data:ISFSObject = event.params.params as SFSObject;
	point = data.getInt("sum");
	emblem = data.getInt("pic");
	activeness = data.getInt("act");
	members = data.getSFSArray("all");
	if( data.containsKey("messages") )
	{
		messages = new ListCollection();
		for( var i:int=0; i<data.getSFSArray("messages").size(); i++ )
		{
			var msg:ISFSObject = data.getSFSArray("messages").getSFSObject(i);
			if( msg.getShort("m") == MessageTypes.M30_FRIENDLY_BATTLE && msg.getShort("st") > 2 )
				continue;
			messages.addItem(data.getSFSArray("messages").getSFSObject(i));
		}
		SFSConnection.instance.addEventListener(SFSEvent.EXTENSION_RESPONSE, sfs_publicMessageHandler);
	}
	isReady = true;
	dispatchEventWith(Event.READY);
}

protected function sfs_publicMessageHandler(event:SFSEvent):void
{
	if( event.params.cmd != SFSCommands.LOBBY_PUBLIC_MESSAGE )
		return;
	var msg:ISFSObject = event.params.params as SFSObject;
	if( msg.getShort("m") == MessageTypes.M0_TEXT )
	{
		var last:SFSObject = messages.length > 0 ? SFSObject(messages.getItemAt(messages.length-1)) : null;
		if( last != null && last.getShort("m") == MessageTypes.M0_TEXT && last.getInt("i") == msg.getInt("i") )
		{
			last.putInt("u", msg.getInt("u"));
			last.putUtfString("t", msg.getUtfString("t"));
			messages.updateItemAt(messages.length-1);
		}
		else
		{
			messages.addItem(msg);
		}
	}
	else if( msg.getShort("m") == MessageTypes.M30_FRIENDLY_BATTLE )
	{
		var lastBattleIndex:int = containBattle(msg.getInt("bid"));
		if( lastBattleIndex > -1 )
		{
			if( msg.getShort("st") > 2 )
			{
				messages.removeItemAt(lastBattleIndex);
			}
			else
			{
				var battleMsg:ISFSObject = messages.getItemAt(lastBattleIndex) as SFSObject;
				battleMsg.putShort("st", msg.getShort("st"));
				battleMsg.putInt("u", msg.getInt("u"));
				if( msg.containsKey("o") )
					battleMsg.putText("o", msg.getText("o"));
				messages.updateItemAt(lastBattleIndex);
				if( msg.getShort("st") == 1 && (msg.getText("s") == player.nickName || msg.getText("o") == player.nickName) )
					dispatchEventWith(Event.TRIGGERED);// go to friendly battle
			}
		}
		else
		{
			messages.addItem(msg);
			dispatchEventWith(Event.OPEN, false, msg.getText("s"));
		}
	}
	else if( MessageTypes.isComment(msg.getShort("m")) )
	{
		messages.addItem(msg);
	}
	//traceList()
	dispatchEventWith(Event.UPDATE);
}

public function numUnreads():int
{
	var ret:int = 0;
	if( messages == null )
		return ret;
	for( var i:int=messages.length-1; i>=0; i-- )
	{
		if( UserData.instance.lastLobbeyMessageTime < messages.getItemAt(i).getInt("u") )
			ret ++;
	}
	return ret;
}

private function containBattle(battleId:int):int
{
	for (var i:int = 0; i < messages.length; i++) 
		if( messages.getItemAt(i).getShort("m") == MessageTypes.M30_FRIENDLY_BATTLE && messages.getItemAt(i).getInt("bid") == battleId )
			return i;
	return -1;
}
public function getMyRequestBattleIndex():int
{
	for (var i:int = 0; i < messages.length; i++) 
		if( messages.getItemAt(i).getShort("m") == MessageTypes.M30_FRIENDLY_BATTLE && messages.getItemAt(i).getInt("i") == player.id && messages.getItemAt(i).getShort("st") == 0 )
			return i;
	return -1;
}
public function getMyRequestBattleId():int
{
	for (var i:int = 0; i < messages.length; i++) 
		if( messages.getItemAt(i).getShort("m") == MessageTypes.M30_FRIENDLY_BATTLE && messages.getItemAt(i).getInt("i") == player.id && messages.getItemAt(i).getShort("st") == 0 )
			return messages.getItemAt(i).getInt("bid");
	return -1;
}
private function traceList():void
{
	for (var i:int = 0; i < messages.length; i++) 
	{
		var msg:SFSObject =  messages.getItemAt(i) as SFSObject;//trace(i, msg.getText("t"))
		trace(i, msg.getShort("m"), msg.getShort("st"), msg.getInt("i"), msg.containsKey("bid")?msg.getInt("bid"):"");
	}
}

private function dispose():void
{
	SFSConnection.instance.removeEventListener(SFSEvent.EXTENSION_RESPONSE, sfs_publicMessageHandler);
	SFSConnection.instance.removeEventListener(SFSEvent.EXTENSION_RESPONSE, sfs_getLobbyInfoHandler);
	if( messages )
		messages.removeAll();
}
}
}