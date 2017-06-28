package com.gerantech.towercraft.controls.segments
{
import com.gerantech.towercraft.Main;
import com.gerantech.towercraft.controls.GameLog;
import com.gerantech.towercraft.controls.buttons.SimpleButton;
import com.gerantech.towercraft.controls.buttons.SimpleLayoutButton;
import com.gerantech.towercraft.controls.floatings.BuildingImprovementFloating;
import com.gerantech.towercraft.controls.floatings.MapElementFloating;
import com.gerantech.towercraft.controls.overlays.TransitionData;
import com.gerantech.towercraft.events.LoadingEvent;
import com.gerantech.towercraft.managers.net.LoadingManager;
import com.gerantech.towercraft.managers.net.sfs.SFSCommands;
import com.gerantech.towercraft.managers.net.sfs.SFSConnection;
import com.gerantech.towercraft.models.tutorials.TutorialData;
import com.gerantech.towercraft.models.tutorials.TutorialTask;
import com.gt.towers.battle.fieldes.PlaceData;
import com.gt.towers.utils.lists.PlaceDataList;
import com.smartfoxserver.v2.entities.data.SFSObject;

import flash.geom.Point;
import flash.net.navigateToURL;
import flash.utils.setTimeout;

import dragonBones.objects.DragonBonesData;
import dragonBones.starling.StarlingArmatureDisplay;
import dragonBones.starling.StarlingFactory;

import feathers.events.FeathersEventType;
import feathers.layout.AnchorLayout;

import starling.animation.Transitions;
import starling.core.Starling;
import starling.display.Button;
import starling.display.DisplayObject;
import starling.display.Quad;
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
	private var questButton:SimpleLayoutButton;
	private var floating:MapElementFloating;
	
	public function MainSegment()
	{
		super();
		factory = new StarlingFactory();
		dragonBonesData = factory.parseDragonBonesData( JSON.parse(new skeletonClass()) );
		factory.parseTextureAtlasData( JSON.parse(new atlasDataClass()), new atlasImageClass() );
		addEventListener(Event.ADDED_TO_STAGE, addedToStageHandler);
	}
	protected function addedToStageHandler(event:Event):void
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
		
		addEventListener(FeathersEventType.TRANSITION_IN_COMPLETE, transitionInCompleteHandler);
	}
	
	private function mapElement_triggeredHandler(event:Event ):void
	{
		var mapElement:SimpleButton = event.currentTarget as SimpleButton;
		mapElement.scale = 0.4;
		Starling.juggler.tween(mapElement, 0.6, {scale:1, transition:Transitions.EASE_OUT_ELASTIC});
	
		if(floating != null && floating.element.name == mapElement.name)
			return;; 
		
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
					var sfsObj:SFSObject = new SFSObject();
					sfsObj.putBool("q", false);
					sfsObj.putInt("i", 0);
					SFSConnection.instance.sendExtensionRequest(SFSCommands.START_BATTLE, sfsObj);
					appModel.navigator.pushScreen( Main.BATTLE_SCREEN );
					break;
				case "dragon-cross":
				case "portal-tower":
					appModel.navigator.addChild(new GameLog(loc("map-button-unavailabled", ["123"])));
					break;
			}
		}
	}

	private function transitionInCompleteHandler():void
	{
		removeEventListener(FeathersEventType.TRANSITION_IN_COMPLETE, transitionInCompleteHandler);
		showTutorial();
	}		
	
	// show tutorial steps
	private function showTutorial():void
	{
		if(appModel.loadingManager.state < LoadingManager.STATE_LOADED )
		{
			appModel.loadingManager.addEventListener(LoadingEvent.LOADED, loadingManager_loadedHandler);
			return;
		}
		//trace("main screen", player.get_questIndex());
		if( player.get_questIndex() > 1 )
			return;	
		
		var tutorialData:TutorialData = new TutorialData("");
		tutorialData.tasks.push(new TutorialTask(TutorialTask.TYPE_MESSAGE, "tutor_quest_" + player.get_questIndex() + "_start",  null, 200));
		var pl:PlaceDataList = new PlaceDataList();
		pl.push(new PlaceData(0,(questButton.x+questButton.width/2)/appModel.scale, (questButton.y+questButton.height/2)/appModel.scale, 0, 0, ""));
		tutorialData.tasks.push(new TutorialTask(TutorialTask.TYPE_TOUCH, null, pl, 200));
		tutorials.show(this, tutorialData);
	}
	private function loadingManager_loadedHandler():void
	{
		appModel.loadingManager.removeEventListener(LoadingEvent.LOADED, loadingManager_loadedHandler);
		showTutorial();
	}

}
}
