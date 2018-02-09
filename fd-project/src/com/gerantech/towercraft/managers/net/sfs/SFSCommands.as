package com.gerantech.towercraft.managers.net.sfs
{
public class SFSCommands
{
public static const START_BATTLE:String = "startBattle";
public static const CANCEL_BATTLE:String = "cancelBattle" ;
public static const END_BATTLE:String = "endBattle";
public static const LEFT_BATTLE:String = "leftBattle";
public static const REJOIN_BATTLE:String = "rejoinBattle";
public static const RANK:String = "rank";
public static const LEAVE:String = "leave";
public static const RESET_ALL:String = "resetAll";
public static const SEND_STICKER:String = "ss";

public static const PROFILE:String = "profile";

public static const BUILDING_UPGRADE:String = "buildingUpgrade";
public static const EXCHANGE:String = "exchange";
public static const SELECT_NAME:String = "selectName";
public static const VERIFY_PURCHASE:String = "verify";
public static const OAUTH:String = "oauth";
public static const REGISTER_PUSH:String = "registerPush";
public static const RESTORE:String = "restore";
public static const PREFS:String = "prefs";
public static const CHANGE_DECK:String = "changeDeck";

public static const ISSUE_REPORT:String = "issueReport";
public static const ISSUE_GET:String = "issueGet";
public static const ISSUE_TRACK:String = "issueTrack";

public static const FIGHT:String = "f";
public static const BUILDING_IMPROVE:String = "i";
public static const HIT:String = "h";

public static const LOBBY_CREATE:String = "lobbyCreate";
public static const LOBBY_DATA:String = "lobbyData";
public static const LOBBY_INFO:String = "lobbyInfo";
public static const LOBBY_JOIN:String = "lobbyJoin";
public static const LOBBY_LEAVE:String = "lobbyLeave";
public static const LOBBY_MODERATION:String = "lobbyModeration";
public static const LOBBY_EDIT:String = "lobbyEdit";
public static const LOBBY_REPORT:String = "lobbyReport";
public static const LOBBY_PUBLIC:String = "lobbyPublic";
public static const LOBBY_PUBLIC_MESSAGE:String = "m";

public static const BUDDY_ADD:String = "buddyAdd";
public static const BUDDY_REMOVE:String = "buddyRemove";
public static const BUDDY_BATTLE:String = "buddyBattle";

public static const INBOX_GET:String = "inboxGet";
public static const INBOX_OPEN:String = "inboxOpen";
public static const INBOX_CONFIRM:String = "inboxConfirm";
public static const INBOX_BROADCAST:String = "inboxBroadcast";


public static function getDeadline(command:String):int
{
	switch( command )
	{
		case START_BATTLE:
			return 10000;
		case FIGHT:
		case LEFT_BATTLE:
		case REJOIN_BATTLE:
		case LEAVE:
		case BUILDING_IMPROVE:
		case HIT:
		case SEND_STICKER:
		case INBOX_OPEN:
		case INBOX_CONFIRM:
		case INBOX_BROADCAST:
		case ISSUE_GET:
		case ISSUE_REPORT:
		case ISSUE_TRACK:
		case LOBBY_LEAVE:
		case LOBBY_EDIT:
		case REGISTER_PUSH:
		case VERIFY_PURCHASE:
			return -1;
	}
	return 2000;
}

public static function getCanceled(command:String):String
{
	switch( command )
	{
		case CANCEL_BATTLE: return START_BATTLE;
	}
	return null;
}
}
}