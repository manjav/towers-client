package com.gerantech.towercraft.controls.segments
{
import com.gerantech.towercraft.Main;
import com.gerantech.towercraft.controls.GameLog;
import com.gerantech.towercraft.controls.buttons.SimpleButton;
import com.gerantech.towercraft.controls.floatings.MapElementFloating;
import com.gerantech.towercraft.controls.overlays.TransitionData;
import com.gerantech.towercraft.controls.overlays.WaitingOverlay;
import com.gerantech.towercraft.controls.popups.SelectNamePopup;

import flash.geom.Point;
import flash.utils.clearInterval;
import flash.utils.setInterval;
import flash.utils.setTimeout;

import dragonBones.objects.DragonBonesData;
import dragonBones.starling.StarlingArmatureDisplay;
import dragonBones.starling.StarlingFactory;

import feathers.controls.StackScreenNavigatorItem;

import starling.animation.Transitions;
import starling.core.Starling;
import starling.events.Event;

public class MainSegment extends Segment
{
	[Embed(source = "../../../../../assets/animations/mainmap/main-map_ske.json", mimeType = "application/octet-stream")]
	public static const skeletonClass: Class;
	[Embed(source = "../../../../../assets/animations/mainmap/main-map_tex.json", mimeType = "application/octet-stream")]
	public static const atlasDataClass: Class;
	[Embed(source = "../../../../../assets/animations/mainmap/main-map_tex.png")]
	public static const atlasImageClass: Class;
	
	private static var factory:StarlingFactory;
	private static var dragonBonesData:DragonBonesData;
	private static var floating:MapElementFloating;
	
	private var intervalId:uint;

	public function MainSegment()
	{
		super();
		if( factory != null )
			return;
		
		factory = new StarlingFactory();
		dragonBonesData = factory.parseDragonBonesData( JSON.parse(new skeletonClass()) );
		factory.parseTextureAtlasData( JSON.parse(new atlasDataClass()), new atlasImageClass() );
	}
	
	override public function init():void
	{
		super.init();

		if(appModel.loadingManager.inBattle)
		{
			setTimeout(gotoLiveBattle, 100);
			return;
		}
		
		showMap();
		showTutorial();
		initializeCompleted = true;
	}
	
	private function showMap():void
	{
		if(dragonBonesData == null)
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
				if(mcName != "background" && mcName != "mine-lights")
				{
					btn.name = mcName;
					btn.addEventListener(Event.TRIGGERED, mapElement_triggeredHandler);
				}
				
				switch(mcName)
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
			intervalId = setInterval(punchButton, 2000,  getChildByName("gold-leaf") as SimpleButton);
		}
		else if(player.nickName == "guest")
		{
			var confirm:SelectNamePopup = new SelectNamePopup();
			confirm.addEventListener(Event.COMPLETE, confirm_eventsHandler);
			appModel.navigator.addChild(confirm);
			function confirm_eventsHandler():void {
				confirm.removeEventListener(Event.COMPLETE, confirm_eventsHandler);
				punchButton(getChildByName("portal-center") as SimpleButton);
				intervalId = setInterval(punchButton, 2000,  getChildByName("portal-center") as SimpleButton);
			}
		}
	}
	
	private function mapElement_triggeredHandler(event:Event ):void
	{
		var mapElement:SimpleButton = event.currentTarget as SimpleButton;
		punchButton(mapElement);
		if(floating != null && floating.element.name == mapElement.name)
			return;
		
		var locked:Boolean = player.inTutorial() && mapElement.name != "gold-leaf" || mapElement.name == "dragon-cross";
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
		floating.height = 140*appModel.scale;
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
			//trace(event.data['name'])
			switch(event.data['name'])
			{
				case "gold-leaf":
					floating = null;
					appModel.navigator.pushScreen( Main.QUESTS_SCREEN );		
					break;
				case "portal-center":
					if( player.inTutorial() )
					{
						appModel.navigator.addLog(loc("map-button-locked", [loc("map-"+event.data['name'])]));
						return;
					}
					floating = null;
					gotoLiveBattle();
					break;
				case "dragon-cross":
					appModel.navigator.addLog(loc("map-button-unavailabled", [loc("map-"+event.data['name'])]));
					break;
				case "portal-tower":
					if( player.inTutorial() )
					{
						appModel.navigator.addLog(loc("map-button-locked", [loc("map-"+event.data['name'])]));
						return;
					}
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
		appModel.navigator.addChild(item.properties.waitingOverlay);		
	}
	
	private function punchButton(mapElement:SimpleButton):void
	{
		mapElement.scale = 0.4;
		Starling.juggler.tween(mapElement, 0.9, {scale:1, transition:Transitions.EASE_OUT_ELASTIC});
	}
	override public function dispose():void
	{
		clearInterval(intervalId);
		super.dispose();
	}
}
}
