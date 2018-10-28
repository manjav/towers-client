package com.gerantech.towercraft.models.vo
{
import com.gerantech.towercraft.managers.TimeManager;
import com.gerantech.towercraft.managers.net.sfs.SFSConnection;
import com.gerantech.towercraft.models.AppModel;
import com.gt.towers.Player;
import com.gt.towers.buildings.Building;
import com.gt.towers.constants.ExchangeType;
import com.gt.towers.exchanges.ExchangeItem;
import com.gt.towers.socials.Challenge;
import flash.events.Event;

public class TabItemData
{
public var index:int;
public var badgeNumber:int;
public var newBadgeNumber:int;
private var player:Player;
public function TabItemData(index:int)
{
	this.index = index;
	player = AppModel.instance.game.player;
	update();
}

protected function exchangeManager_endHandler(e:Event):void 
{
	update();
}

public function update() : void 
{
	if( player.inTutorial() )
		return;
	
	if( index == 0 )
	{
		for each(var e:ExchangeItem in player.game.exchanger.items.values())
		if( (e.category == ExchangeType.C20_SPECIALS && e.numExchanges == 0 ) || (e.category == ExchangeType.C30_BUNDLES && e.expiredAt > TimeManager.instance.now) )
		{
			newBadgeNumber ++;
			badgeNumber ++;
		}
	}

	
	else if( index == 1 )
	{
		var bs:Vector.<Building> = player.buildings.values();
		for each(var b:Building in bs)
		{
			if( b == null )
				continue;
			
			//trace(b.type, b.upgradable() , player.buildings.get(b.type).get_level());
			if( b.upgradable() )
				badgeNumber ++;
			
			if( player.buildings.get(b.type)._level == -1 )
				newBadgeNumber ++;
		}
	}
	
	
	else if( index == 3 )
	{
		badgeNumber = SFSConnection.instance.lobbyManager.numUnreads();
	}
	
	else if( index == 4 && player.get_arena(0) > 2 )
	{
		if( player.challenges != null )
		{
			for each(var c:Challenge in player.challenges.values() )
			{
				if( c.getState(TimeManager.instance.now) == Challenge.STATE_STARTED )
					newBadgeNumber ++;
				badgeNumber ++;
			}
		}
		else
		{
			badgeNumber ++;
		}
	}
}
}
}