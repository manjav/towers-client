package com.gerantech.towercraft.managers.socials
{
import com.gerantech.extensions.NativeAbilities;
import com.gerantech.towercraft.controls.popups.ConfirmPopup;
import com.gerantech.towercraft.events.LoadingEvent;
import com.gerantech.towercraft.managers.net.sfs.SFSCommands;
import com.gerantech.towercraft.managers.net.sfs.SFSConnection;
import com.gerantech.towercraft.models.AppModel;
import com.gerantech.towercraft.models.vo.UserData;
import com.gt.towers.constants.PrefsTypes;
import com.marpies.ane.gameservices.GameServices;
import com.marpies.ane.gameservices.events.GSAuthEvent;
import com.marpies.ane.gameservices.events.GSIdentityEvent;
import com.smartfoxserver.v2.core.SFSEvent;
import com.smartfoxserver.v2.entities.data.SFSObject;
import flash.events.EventDispatcher;
import flash.utils.clearTimeout;
import flash.utils.setTimeout;
import mx.resources.ResourceManager;

[Event(name="init",			type="com.gerantech.towercraft.managers.socials.SocialEvent")]
[Event(name="signin",		type="com.gerantech.towercraft.managers.socials.SocialEvent")]
[Event(name="failure",		type="com.gerantech.towercraft.managers.socials.SocialEvent")]
[Event(name="authenticate",	type="com.gerantech.towercraft.managers.socials.SocialEvent")]

public class SocialManager extends EventDispatcher
{
private static var _instance:SocialManager;

public var type:int;
public var user:SocialUser;
public var signinTimeout:int = 14;

private var timeoutID:int;

public function SocialManager(){};
public function init(type:int, showLogs:Boolean = false):void
{
	this.type = type;
	/*if( UserData.instance.authenticationAttemps > 1 && !force )
	{
		dispatchFailurEvent("out of authentication attemps");
		return;
	}*/
	
	timeoutID = setTimeout( timeoutCallback, signinTimeout * 1000);
	if( type == PrefsTypes.AUTH_41_GOOGLE )
	{
		GameServices.addEventListener( GSAuthEvent.SUCCESS, gameServices_successHandler );
		GameServices.addEventListener( GSAuthEvent.ERROR, gameServices_errorHandler );
		//GameServices.addEventListener( GSIdentityEvent.SUCCESS, onGameServicesIdentitySuccess ); only for iOS
		//GameServices.addEventListener( GSIdentityEvent.ERROR, onGameServicesIdentityError );
		GameServices.init( showLogs );	
		toast("init");
	}
}

private function timeoutCallback():void
{
	dispatchFailurEvent("Sign in timeout.");
	//UserData.instance.authenticationAttemps ++;
	//UserData.instance.save();
}

public function signin():void
{
	toast("signin " + initialized );
	if( !initialized )
	{
		toast("please init before sign in.");
		return;
	}
	
	if( type == PrefsTypes.AUTH_41_GOOGLE )
	{
		if( authenticated )
		{
			toast("already authenticated.");
			UserData.instance.prefs.setBool(PrefsTypes.AUTH_41_GOOGLE, true)
			return;
		}
		//GameServices.addEventListener( GSAuthEvent.DIALOG_WILL_APPEAR, onGameServicesAuthDialogWillAppear );
		GameServices.authenticate();
	}
}

public function signout():void
{
	if( type == PrefsTypes.AUTH_41_GOOGLE )
	{
		toast("sign out");
		GameServices.signOut();
		UserData.instance.prefs.setBool(PrefsTypes.AUTH_41_GOOGLE, false)
	}
}

protected function gameServices_successHandler(event:GSAuthEvent):void
{
	
//	if( timeoutID == -1 )
//		return;
	toast("success:" + event.errorMessage + " player:" + event.player);
	clearTimeout(timeoutID);
	
	//log( "User authenticated: "+ event.player );
	user = new SocialUser();
	user.id = event.player.id;
	user.name = event.player.displayName;
	user.imageURL = event.player.iconImageUri;
	if( AppModel.instance.game.player.prefs.getAsBool(PrefsTypes.AUTH_41_GOOGLE) )
		toast(event.player.alias + " data exists in db.");
	else
		sendSocialData();
}
protected function gameServices_errorHandler(event:GSAuthEvent):void
{
	if( timeoutID == -1 )
		return;
	clearTimeout(timeoutID);
	
	toast("errorMessage:"+ event.errorMessage + " player:" + event.player);
	dispatchFailurEvent(event.errorMessage);
}


private function sendSocialData():void
{
	toast("sendSocialData");
	//state = STATE_SEND_SOCIAL_DATA;			
	var sfs:SFSObject = SFSObject.newInstance();
	sfs.putInt("accountType", type);
	sfs.putText("accountId", user.id);
	sfs.putText("accountName", user.name);
	sfs.putText("accountImageURL", user.imageURL);
	
	SFSConnection.instance.addEventListener(SFSEvent.EXTENSION_RESPONSE, sfsConnection_extensionResponseHandler);
	SFSConnection.instance.sendExtensionRequest(SFSCommands.OAUTH, sfs);
}
protected function sfsConnection_extensionResponseHandler(event:SFSEvent):void
{
	if( event.params.cmd != SFSCommands.OAUTH )
		return;
	SFSConnection.instance.removeEventListener(SFSEvent.EXTENSION_RESPONSE, sfsConnection_extensionResponseHandler);
	UserData.instance.prefs.setBool(PrefsTypes.AUTH_41_GOOGLE, true);
	
	var sfs:SFSObject = event.params.params;
	dispatchEvent(new SocialEvent(SocialEvent.SINGIN));
	if( sfs.getInt("playerId") == AppModel.instance.game.player.id )
	{
		toast("player exists.");
		dispatchEvent(new SocialEvent(SocialEvent.AUTHENTICATE));
		return;
	}
	
	var confirm:ConfirmPopup = new ConfirmPopup(ResourceManager.getInstance().getString("loc", "popup_reload_authenticated_label", [sfs.getText("playerName")]));
	confirm.closeOnOverlay = false;
	confirm.data = sfs;
	confirm.addEventListener("select", confirm_eventsHandler);
	confirm.addEventListener("cancel", confirm_eventsHandler);
	AppModel.instance.navigator.addChild(confirm);
}		
private function confirm_eventsHandler(event:*):void
{
	var confirm:ConfirmPopup = event.currentTarget as ConfirmPopup;
	confirm.removeEventListener("select", confirm_eventsHandler);
	confirm.removeEventListener("cancel", confirm_eventsHandler);
	if( event.type == "select" )
	{
		var sfs:SFSObject = confirm.data as SFSObject;
		UserData.instance.id = sfs.getInt("playerId");
		UserData.instance.password = sfs.getText("playerPassword");
		UserData.instance.save();
		AppModel.instance.loadingManager.dispatchEvent(new LoadingEvent(LoadingEvent.FORCE_RELOAD));
		return;
	}
	dispatchEvent(new SocialEvent(SocialEvent.AUTHENTICATE));
}


private function dispatchFailurEvent(errorMessag:String):void
{
	timeoutID = -1;
	dispatchEvent(new SocialEvent(SocialEvent.FAILURE, errorMessag));			
}

private function onGameServicesIdentitySuccess( event:GSIdentityEvent ):void {
	toast("IdentitySuccess:" + event.publicKeyUrl);
	// pass the information to a third party server
	/*log( "publicKeyUrl " + event.publicKeyUrl );
	log( "signature " + event.signature );
	log( "salt " + event.salt );
	log( "timestamp " + event.timestamp );*/
}
private function onGameServicesIdentityError( event:GSIdentityEvent ):void {
	toast( "Identity error: " + event.errorMessage );
}

public function get initialized():Boolean
{
	if( type == PrefsTypes.AUTH_41_GOOGLE )
		return GameServices.isInitialized;
	return false;
}
public function get authenticated():Boolean
{
	if( type == PrefsTypes.AUTH_41_GOOGLE )
		return GameServices.isAuthenticated;
	return false;
}
public static function get instance():SocialManager
{
	if(!_instance)
		_instance = new SocialManager();
	return _instance;
}
private function toast(text:String):void
{
	//NativeAbilities.instance.showToast(text, 2);
}
}
}