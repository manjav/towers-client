package com.gerantech.towercraft.controls.segments
{
import com.gerantech.towercraft.Main;
import com.gerantech.towercraft.controls.GameLog;
import com.gerantech.towercraft.controls.buttons.SimpleButton;
import com.gerantech.towercraft.controls.floatings.MapElementFloating;
import com.gerantech.towercraft.controls.overlays.TransitionData;
import com.gerantech.towercraft.controls.overlays.WaitingOverlay;

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
	
	private var factory:StarlingFactory;
	private var dragonBonesData:DragonBonesData;
	private var floating:MapElementFloating;
	
	private var questButton:SimpleButton;
	private var intervalId:uint;

	public function MainSegment()
	{
		super();
		factory = new StarlingFactory();
		dragonBonesData = factory.parseDragonBonesData( JSON.parse(new skeletonClass()) );
		factory.parseTextureAtlasData( JSON.parse(new atlasDataClass()), new atlasImageClass() );
	}
	
	protected override function coreLoaded() : void
	{
		if(appModel.loadingManager.inBattle)
		{
			gotoLiveBattle();
			return;
		}
		
		showMap();
		showTutorial();
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
						btn.x = 516.4 * appModel.scale * 1.2;
						btn.y = 433.5 * appModel.scale * 1.2;
						break;
					case "gold-leaf":
						btn.x = 324.5 * appModel.scale * 1.2;
						btn.y = 768.5 * appModel.scale * 1.2;
						questButton = btn;
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
		if( player.get_questIndex() <= 4 )
			intervalId = setInterval(punchButton, 2000,  questButton, 1);
	}
	
	private function mapElement_triggeredHandler(event:Event ):void
	{
		var mapElement:SimpleButton = event.currentTarget as SimpleButton;
		punchButton(mapElement);
		if(floating != null && floating.element.name == mapElement.name)
			return;
		
		// create transitions data
		var ti:TransitionData = new TransitionData();
		var to:TransitionData = new TransitionData();
		to.destinationAlpha = ti.sourceAlpha = 0;
		ti.transition = Transitions.EASE_OUT_BACK;
		to.destinationPosition = ti.sourcePosition = new Point(mapElement.x-160*appModel.scale, mapElement.y-200*appModel.scale);
		ti.destinationAlpha = to.sourceAlpha = 1;
		to.sourcePosition = ti.destinationPosition = new Point(mapElement.x-160*appModel.scale, mapElement.y-280*appModel.scale);
		
		floating = new MapElementFloating(mapElement);
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
					appModel.navigator.pushScreen( Main.QUESTS_SCREEN );		
					break;
				case "portal-center":
				/*	if(player.get_questIndex() < 5)
					{
						appModel.navigator.addChild(new GameLog(loc("map-button-locked", [loc("map-"+event.data['name'])])));
						return;
					}*/
					
					gotoLiveBattle();
					break;
				case "dragon-cross":
					appModel.navigator.addChild(new GameLog(loc("map-button-unavailabled", [loc("map-"+event.data['name'])])));
					break;
				case "portal-tower":
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
	
	private function punchButton(mapElement:SimpleButton, time:Number = 0.6):void
	{
		mapElement.scale = 0.4;
		Starling.juggler.tween(mapElement, time, {scale:1, transition:Transitions.EASE_OUT_ELASTIC});
	}
	override public function dispose():void
	{
		clearInterval(intervalId);
		super.dispose();
	}
}
}
