package com.gerantech.towercraft.managers
{
import com.gerantech.towercraft.managers.net.sfs.SFSCommands;
import com.gerantech.towercraft.managers.net.sfs.SFSConnection;
import com.gerantech.towercraft.models.AppModel;
import com.gt.towers.Player;
import com.smartfoxserver.v2.core.SFSEvent;
import com.smartfoxserver.v2.entities.data.ISFSArray;
import com.smartfoxserver.v2.entities.data.SFSObject;

public class UserPrefs
{
private var player:Player;

public function UserPrefs(){}
public function requestData():void
{
	player = AppModel.instance.game.player;
	SFSConnection.instance.addEventListener(SFSEvent.EXTENSION_RESPONSE, sfs_getAllPrefsHandler);
	SFSConnection.instance.sendExtensionRequest(SFSCommands.PREFS);	
}

protected function sfs_getAllPrefsHandler(event:SFSEvent):void
{
	if( event.params.cmd != SFSCommands.PREFS )
		return;
	SFSConnection.instance.removeEventListener(SFSEvent.EXTENSION_RESPONSE, sfs_getAllPrefsHandler);
	
	var map:ISFSArray = SFSObject(event.params.params).getSFSArray("map");
	for ( var i:int=0; i<map.size(); i++ )
		player.prefs.set(int(map.getSFSObject(i).getText("k")), map.getSFSObject(i).getText("v"));
}

public function setBool(key:int, value:Boolean):void
{
	setString(key, value.toString());
}
public function setInt(key:int, value:int):void
{
	setString(key, value.toString());
}
public function setFloat(key:int, value:Number):void
{
	setString(key, value.toString());
}
public function setString(key:int, value:String):void
{
	AppModel.instance.game.player.prefs.set(key, value);
	var params:SFSObject = new SFSObject();
	params.putInt("k", key);
	params.putText("v", value);
	SFSConnection.instance.sendExtensionRequest(SFSCommands.PREFS, params);
}		
}
}