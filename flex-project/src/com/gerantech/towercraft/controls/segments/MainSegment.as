package com.gerantech.towercraft.controls.segments
{
import com.gerantech.towercraft.Main;
import com.gerantech.towercraft.controls.LobbyBalloon;
import com.gerantech.towercraft.controls.buttons.IconButton;
import com.gerantech.towercraft.controls.buttons.SimpleButton;
import com.gerantech.towercraft.controls.floatings.MapElementFloating;
import com.gerantech.towercraft.controls.overlays.TransitionData;
import com.gerantech.towercraft.controls.overlays.WaitingOverlay;
import com.gerantech.towercraft.controls.popups.NewsPopup;
import com.gerantech.towercraft.controls.popups.SelectNamePopup;
import com.gerantech.towercraft.managers.net.sfs.SFSConnection;
import com.gerantech.towercraft.models.Assets;

import flash.filesystem.File;
import flash.geom.Point;
import flash.utils.clearInterval;
import flash.utils.setInterval;
import flash.utils.setTimeout;

import dragonBones.objects.DragonBonesData;
import dragonBones.starling.StarlingArmatureDisplay;
import dragonBones.starling.StarlingFactory;

import feathers.controls.Button;
import feathers.controls.ImageLoader;
import feathers.controls.StackScreenNavigatorItem;
import feathers.events.FeathersEventType;
import feathers.layout.AnchorLayout;
import feathers.layout.AnchorLayoutData;

import starling.animation.Transitions;
import starling.core.Starling;
import starling.events.Event;

public class MainSegment extends Segment
{
	private static var factory:StarlingFactory;
	private static var dragonBonesData:DragonBonesData;
	private static var floating:MapElementFloating;
	
	private var intervalId:uint;
	private var lobbyBallon:LobbyBalloon;

	public function MainSegment()
	{
		super();
		//appModel.assets.verbose = true;
		if( appModel.assets.getTexture("main-map_tex") == null )
		{
			appModel.assets.enqueue(File.applicationDirectory.resolvePath( "assets/animations/mainmap" ));
			appModel.assets.loadQueue(assets_loadCallback)
		}
	}
	private function assets_loadCallback(ratio:Number):void
	{
		if(ratio >= 1 && initializeStarted && !initializeCompleted)
		{
			factory = new StarlingFactory();
			dragonBonesData = factory.parseDragonBonesData(appModel.assets.getObject("main-map_ske"));
			factory.parseTextureAtlasData(appModel.assets.getObject("main-map_tex"), appModel.assets.getTexture("main-map_tex"));
			init();
		}
	}
	override public function init():void
	{
		super.init();
		if(appModel.assets.isLoading )
			return;
		layout = new AnchorLayout();		

		if( appModel.loadingManager.serverData.getBool("inBattle") )
		{
			setTimeout(gotoLiveBattle, 100);
			return;
		}
		
		showMap();
		showTutorial();
		showButtons();
		
		initializeCompleted = true;
	}
	
	private function showButtons():void
	{
		if( player.inTutorial() )
			return;
		
		var gradient:ImageLoader = new ImageLoader();
		gradient.maintainAspectRatio = false;
		gradient.alpha = 0.5;
		gradient.width = 500 * appModel.scale;
		gradient.height = 120 * appModel.scale;
		gradient.source = Assets.getTexture("theme/grad-ro-right", "gui");
		gradient.layoutData = new AnchorLayoutData(NaN, NaN, 20*appModel.scale, 0);
		addChild(gradient);
		
		var settingButton:IconButton = new IconButton(Assets.getTexture("button-settings", "gui"));
		settingButton.width = settingButton.height = 120 * appModel.scale;
		settingButton.addEventListener(Event.TRIGGERED, function():void{appModel.navigator.pushScreen(Main.SETTINGS_SCREEN);});
		settingButton.layoutData = new AnchorLayoutData(NaN, NaN, 20*appModel.scale, 6*appModel.scale);
		addChild(settingButton);
		
		var newsButton:IconButton = new IconButton(Assets.getTexture("button-news", "gui"));
		newsButton.width = newsButton.height = 110 * appModel.scale;
		newsButton.addEventListener(Event.TRIGGERED, function():void{appModel.navigator.addPopup(new NewsPopup())});
		newsButton.layoutData = new AnchorLayoutData(NaN, NaN, 25*appModel.scale, 126*appModel.scale);
		addChild(newsButton);
		
		var inboxButton:IconButton = new IconButton(Assets.getTexture("button-inbox", "gui"));
		inboxButton.width = inboxButton.height = 120 * appModel.scale;
		inboxButton.addEventListener(Event.TRIGGERED, function():void{appModel.navigator.pushScreen(Main.INBOX_SCREEN)});
		inboxButton.layoutData = new AnchorLayoutData(NaN, NaN, 20*appModel.scale, 246*appModel.scale);
		addChild(inboxButton);
		
		var restoreButton:Button = new Button();
		restoreButton.alpha = 0;
		restoreButton.isLongPressEnabled = true;
		restoreButton.longPressDuration = 3;
		restoreButton.width = restoreButton.height = 120 * appModel.scale;
		restoreButton.addEventListener(FeathersEventType.LONG_PRESS, function():void{appModel.navigator.pushScreen(Main.ADMIN_SCREEN)});
		restoreButton.layoutData = new AnchorLayoutData(NaN, 0, 0);
		addChild(restoreButton);
	}
	
	private function showMap():void
	{
		if( dragonBonesData == null )
			return;
		var mcName:String;
		for (var i:int=0; i<dragonBonesData.armatureNames.length; i++) 
		{
			mcName = dragonBonesData.armatureNames[i];
			if(mcName != "main")
			{
				var mapElement:StarlingArmatureDisplay = factory.buildArmatureDisplay(mcName);
				mapElement.scale = appModel.scale * 1.2;
				mapElement.animation.gotoAndPlayByTime("animtion0", 0, -1);
				
				var btn:SimpleButton = new SimpleButton();
				btn.addChild(mapElement)
				this.addChild(btn);
				if( mcName != "background" && mcName != "mine-lights" )
				{
					btn.name = mcName;
					btn.addEventListener(Event.TRIGGERED, mapElement_triggeredHandler);
				}
				
				switch( mcName )
				{
					case "mine-lights":
						btn.x = 499 * appModel.scale * 1.2;
						btn.y = 449 * appModel.scale * 1.2;
						break;
					case "gold-leaf":
						btn.x = 324.5 * appModel.scale * 1.2;
						btn.y = 768.5 * appModel.scale * 1.2;
						break;
					case "portal-center":
						btn.x = 739.5 * appModel.scale * 1.2;
						btn.y = 1068 * appModel.scale * 1.2;
						break;
					case "dragon-cross":
						btn.x = 726 * appModel.scale * 1.2;
						btn.y = 726 * appModel.scale * 1.2;
						btn.addChild(showLobbyBalloon(10 * appModel.scale, -120 * appModel.scale));
						break;
					case "portal-tower":
						btn.x = 454 * appModel.scale * 1.2;
						btn.y = 1111 * appModel.scale * 1.2;
						break;
				}
			}
		}
	}
	
	// show tutorial steps
	private function showTutorial():void
	{
		trace("player.inTutorial() : ", player.inTutorial());
		trace("player.nickName : ", player.nickName);
		if( player.inTutorial() )
		{
			intervalId = setInterval(punchButton, 2000, getChildByName("gold-leaf") as SimpleButton, 2);
		}
		else
		{
			if( player.nickName == "guest" )
			{
				var confirm:SelectNamePopup = new SelectNamePopup();
				confirm.addEventListener(Event.COMPLETE, confirm_eventsHandler);
				appModel.navigator.addPopup(confirm);
				function confirm_eventsHandler():void {
					confirm.removeEventListener(Event.COMPLETE, confirm_eventsHandler);
					punchButton(getChildByName("portal-center") as SimpleButton);
					intervalId = setInterval(punchButton, 2000, getChildByName("portal-center") as SimpleButton, 2);
				}
			}
			else if( player.quests.keys().length < 20 && player.quests.keys().length < player.resources.get(1201) )
			{
				intervalId = setInterval(punchButton, 3000, getChildByName("gold-leaf") as SimpleButton, 2);
			}
		}
	}
	
	private function showLobbyBalloon(x:int, y:int):LobbyBalloon
	{
		lobbyBallon = new LobbyBalloon(SFSConnection.instance.lobbyManager.numUnreads());
		lobbyBallon.scale = 0;
		lobbyBallon.x = x;
		lobbyBallon.y = y;
		Starling.juggler.tween(lobbyBallon, 0.3, {delay:1, scale:appModel.scale * 2, transition:Transitions.EASE_OUT_BACK});
		SFSConnection.instance.lobbyManager.addEventListener(Event.UPDATE, lobbyManager_updateHandler);
		return lobbyBallon;
	}
	private function lobbyManager_updateHandler(event:Event):void
	{
		lobbyBallon.unreads = SFSConnection.instance.lobbyManager.numUnreads();
	}
	
	
	private function mapElement_triggeredHandler(event:Event ):void
	{
		var mapElement:SimpleButton = event.currentTarget as SimpleButton;
		punchButton(mapElement);
		if(floating != null && floating.element.name == mapElement.name)
			return;
		
		var locked:Boolean = player.inTutorial() && mapElement.name != "gold-leaf" || (mapElement.name == "dragon-cross" && !player.villageEnabled());
		var floatingWidth:int = locked ? 360 : 320;
		
		// create transitions data
		var ti:TransitionData = new TransitionData();
		var to:TransitionData = new TransitionData();
		to.destinationAlpha = ti.sourceAlpha = 0;
		ti.transition = Transitions.EASE_OUT_BACK;
		to.destinationPosition = ti.sourcePosition = new Point(mapElement.x-floatingWidth/2*appModel.scale, mapElement.y-200*appModel.scale);
		ti.destinationAlpha = to.sourceAlpha = 1;
		to.sourcePosition = ti.destinationPosition = new Point(mapElement.x-floatingWidth/2*appModel.scale, mapElement.y-280*appModel.scale);
		
		floating = new MapElementFloating(mapElement, locked);
		floating.width = floatingWidth*appModel.scale;
		floating.height = 128*appModel.scale;
		floating.transitionIn = ti;
		floating.transitionOut = to;
		floating.addEventListener(Event.SELECT, floating_selectHandler);
		floating.addEventListener(Event.CLOSE, floating_closeHandler);
		addChild(floating);
		function floating_closeHandler(event:Event):void
		{
			if(floating == null)return;
			floating.removeEventListener(Event.SELECT, floating_selectHandler);
			floating.removeEventListener(Event.CLOSE, floating_closeHandler);
			setTimeout(function():void{floating = null}, 10);
		}
		function floating_selectHandler(event:Event):void
		{
			if(	player.inTutorial() && event.data['name'] != "gold-leaf")
			{
				appModel.navigator.addLog(loc("map-button-locked", [loc("map-"+event.data['name'])]));
				return;
			}
			floating = null;

			//trace(event.data['name'])
			switch(event.data['name'])
			{
				case "gold-leaf":
					appModel.navigator.pushScreen( Main.QUESTS_SCREEN );		
					break;
				case "portal-center":
					floating = null;
					gotoLiveBattle();
					break;
				case "dragon-cross":
					if( !player.villageEnabled() )
					{
						appModel.navigator.addLog(loc("map-dragon-cross-availabledat", [loc("arena_title_1")]));
						punchButton(getChildByName("portal-tower") as SimpleButton);
						return;
					}
					appModel.navigator.pushScreen( Main.SOCIAL_SCREEN );		
					break;
				case "portal-tower":
					floating = null;
					appModel.navigator.pushScreen( Main.ARENA_SCREEN );		
					break;
			}
		}
	}
	
	private function gotoLiveBattle():void
	{
		var item:StackScreenNavigatorItem = appModel.navigator.getScreen( Main.BATTLE_SCREEN );
		item.properties.requestField = null ;
		item.properties.waitingOverlay = new WaitingOverlay() ;
		appModel.navigator.pushScreen( Main.BATTLE_SCREEN ) ;
		appModel.navigator.addOverlay(item.properties.waitingOverlay);		
	}
	
	private function punchButton(mapElement:SimpleButton, initScale:Number = 1.5):void
	{
		mapElement.scale = initScale;
		Starling.juggler.tween(mapElement, 0.9, {scale:1, transition:Transitions.EASE_OUT_ELASTIC});
	}
	override public function dispose():void
	{
		clearInterval(intervalId);
		SFSConnection.instance.lobbyManager.removeEventListener(Event.UPDATE, lobbyManager_updateHandler);
		super.dispose();
	}
}
}
