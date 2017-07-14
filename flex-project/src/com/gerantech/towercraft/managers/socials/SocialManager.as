package com.gerantech.towercraft.managers.socials
{
	import com.marpies.ane.gameservices.GameServices;
	import com.marpies.ane.gameservices.events.GSAuthEvent;
	import com.marpies.ane.gameservices.events.GSIdentityEvent;
	
	import flash.events.EventDispatcher;

	[Event(name="init", type="com.gerantech.towercraft.managers.socials.SocialEvent")]
	[Event(name="failure", type="com.gerantech.towercraft.managers.socials.SocialEvent")]
	[Event(name="authenticate", type="com.gerantech.towercraft.managers.socials.SocialEvent")]
	
	public class SocialManager extends EventDispatcher
	{
		public static const TYPE_GOOGLEPLAY : int = 0;
		public static const TYPE_GAMECENTER : int = 1;
		public static const TYPE_FACEBOOK : int = 2;
		
		public var type:int;
		public var user:SocialUser;
		
		public function init(type:int):void
		{
			this.type = type;
			if( type == TYPE_GOOGLEPLAY )
			{
				GameServices.addEventListener( GSAuthEvent.SUCCESS, gameServices_successHandler );
				GameServices.addEventListener( GSAuthEvent.ERROR, gameServices_errorHandler );
				//GameServices.addEventListener( GSIdentityEvent.SUCCESS, onGameServicesIdentitySuccess ); only for iOS
				//GameServices.addEventListener( GSIdentityEvent.ERROR, onGameServicesIdentityError );
				GameServices.init( false );		
			}
		}
		
		public function signin():void
		{
			if( type == TYPE_GOOGLEPLAY )
			{
				//GameServices.addEventListener( GSAuthEvent.DIALOG_WILL_APPEAR, onGameServicesAuthDialogWillAppear );
				GameServices.authenticate();
			}
		}
		
		public function signout():void
		{
			if( type == TYPE_GOOGLEPLAY )
				GameServices.signOut();
		}
		
		private function gameServices_successHandler(event:GSAuthEvent):void
		{
			//log( "User authenticated: "+ event.player );
			user = new SocialUser();
			user.id = event.player.id;
			user.name = event.player.displayName;
			user.imageURL = event.player.iconImageUri;
			dispatchEvent(new SocialEvent(SocialEvent.AUTHENTICATE));
		}
		private function gameServices_errorHandler(event:GSAuthEvent):void
		{
			//log( "Auth error occurred: "+ event.errorMessage );
			dispatchEvent(new SocialEvent(SocialEvent.FAILURE, event.errorMessage));
		}
		
		private function onGameServicesIdentitySuccess( event:GSIdentityEvent ):void {
			// pass the information to a third party server
			/*log( "publicKeyUrl " + event.publicKeyUrl );
			log( "signature " + event.signature );
			log( "salt " + event.salt );
			log( "timestamp " + event.timestamp );*/
		}
		private function onGameServicesIdentityError( event:GSIdentityEvent ):void {
			//log( "Identity error: " + event.errorMessage );
		}
		
		public function get initialized():Boolean
		{
			if( type == TYPE_GOOGLEPLAY )
				return GameServices.isInitialized;
			return false;
		}
		public function get authenticated():Boolean
		{
			if( type == TYPE_GOOGLEPLAY )
				return GameServices.isAuthenticated;
			return false;
		}

	}
}