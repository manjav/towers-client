package com.gerantech.towercraft.controls.screens
{
import com.gerantech.towercraft.Main;
import com.gerantech.towercraft.controls.buttons.IconButton;
import com.gerantech.towercraft.controls.buttons.SimpleButton;
import com.gerantech.towercraft.controls.items.FactionItemRenderer;
import com.gerantech.towercraft.controls.overlays.TransitionData;
import com.gerantech.towercraft.controls.overlays.WaitingOverlay;
import com.gerantech.towercraft.controls.popups.QuestDetailsPopup;
import com.gerantech.towercraft.controls.popups.RankingPopup;
import com.gerantech.towercraft.managers.net.sfs.SFSCommands;
import com.gerantech.towercraft.managers.net.sfs.SFSConnection;
import com.gerantech.towercraft.models.AppModel;
import com.gerantech.towercraft.models.Assets;
import com.gt.towers.arenas.Arena;
import com.gt.towers.battle.fieldes.FieldData;
import com.smartfoxserver.v2.entities.data.SFSObject;

import flash.filesystem.File;
import flash.geom.Rectangle;

import dragonBones.objects.DragonBonesData;
import dragonBones.starling.StarlingFactory;

import feathers.controls.List;
import feathers.controls.ScrollBarDisplayMode;
import feathers.controls.ScrollPolicy;
import feathers.controls.StackScreenNavigatorItem;
import feathers.controls.renderers.IListItemRenderer;
import feathers.data.ListCollection;
import feathers.events.FeathersEventType;
import feathers.layout.AnchorLayout;
import feathers.layout.AnchorLayoutData;
import feathers.layout.HorizontalAlign;
import feathers.layout.VerticalLayout;

import starling.animation.Transitions;
import starling.core.Starling;
import starling.display.Image;
import starling.events.Event;

public class FactionsScreen extends BaseCustomScreen
{
public static var animFactory:StarlingFactory;
public static var dragonBonesData:DragonBonesData;
private static var factoryCreateCallback:Function;
private static var leaguesCollection:ListCollection;

private var list:List;

public function FactionsScreen()
{
	super();
	if( leaguesCollection == null )
	{
		leaguesCollection = new ListCollection();
		var leagues:Vector.<Arena> = game.arenas.values();
		var numLeagues:int = leagues.length - 1;
		while( numLeagues >= 0 )
		{
			leaguesCollection.addItem(leagues[numLeagues]);
			numLeagues --;
		}
	}
	//createFactionsFactory(initialize);
}
public static function createFactionsFactory(callback:Function):void
{
	if( AppModel.instance.assets.getTexture("factions_tex") == null )
	{
		AppModel.instance.assets.enqueue(File.applicationDirectory.resolvePath( "assets/animations/factions" ));
		AppModel.instance.assets.loadQueue(assets_loadCallback)
		factoryCreateCallback = callback;
		return;
	}
	callback();
}
private static function assets_loadCallback(ratio:Number):void
{
	if( ratio >= 1 )
	{
		if( animFactory != null )
		{
			if( factoryCreateCallback != null )
				factoryCreateCallback = null;
			factoryCreateCallback();
			return;
		}
		
		animFactory = new StarlingFactory();
		dragonBonesData = animFactory.parseDragonBonesData(AppModel.instance.assets.getObject("factions_ske"));
		animFactory.parseTextureAtlasData(AppModel.instance.assets.getObject("factions_tex"), AppModel.instance.assets.getTexture("factions_tex"));
		if( factoryCreateCallback != null )
			factoryCreateCallback();
		factoryCreateCallback = null;
	}
}

override protected function initialize():void
{
	super.initialize();
	layout = new AnchorLayout();
	
	var tiledBG:Image = new Image(Assets.getTexture("main-map-tile", "gui"));
	tiledBG.tileGrid = new Rectangle(appModel.scale, appModel.scale, 256 * appModel.scale, 256 * appModel.scale);
	backgroundSkin = tiledBG;
	
	var shadow:Image = new Image(Assets.getTexture("bg-shadow", "gui"));
	shadow.width = stage.stageWidth;
	shadow.height = stage.stageHeight//-footerSize;
	addChildAt(shadow, 0);
	
	FactionItemRenderer._height = 1480 * appModel.scale;
	FactionItemRenderer.playerLeague = player.get_arena(0);

	var listLayout:VerticalLayout = new VerticalLayout();
	listLayout.horizontalAlign = HorizontalAlign.JUSTIFY;
	listLayout.paddingBottom = 320 * appModel.scale;
	listLayout.useVirtualLayout = false;
	
	list = new List();
	list.layout = listLayout;
	list.layoutData = new AnchorLayoutData(0,0,0,0);
	list.scrollBarDisplayMode = ScrollBarDisplayMode.NONE;
	//list.decelerationRate = 0.99
	list.itemRendererFactory = function():IListItemRenderer { return new FactionItemRenderer (); }
	list.addEventListener(FeathersEventType.CREATION_COMPLETE, list_createCompleteHandler);
	list.addEventListener(FeathersEventType.FOCUS_IN, list_focusInHandler);
	list.addEventListener(Event.SELECT, list_selectHandler);
	list.elasticity = 0.03;
	list.dataProvider = leaguesCollection;
	addChild(list);

	/*if( savedVerticalScrollPosition != 0 )
		list.scrollToPosition(0, savedVerticalScrollPosition, 0);
	else if( player.get_questIndex() > 0 )
	{
		var pageIndex:uint = game.fieldProvider.shires.keys().length - game.fieldProvider.getCurrentShire(player.get_questIndex()).index - 1;
		if( pageIndex > 0 )
			setTimeout(list.scrollToDisplayIndex, 1000, pageIndex, 1);
	}
	
	if( player.inTutorial() )
		return;
	*/
	var backButton:IconButton = new IconButton(Assets.getTexture("tab-1", "gui"));
	backButton.backgroundSkin = new Image(Assets.getTexture("theme/building-button", "gui"));
	Image(backButton.backgroundSkin).scale9Grid = new Rectangle(10, 10, 56, 37);
	backButton.width = backButton.height = 160 * appModel.scale;
	backButton.layoutData = new AnchorLayoutData(NaN, NaN,  10*appModel.scale, NaN, 0);
	backButton.addEventListener(Event.TRIGGERED, backButtonHandler);
	addChild(backButton);
}

private function list_createCompleteHandler():void
{
//	trace(leaguesCollection.length,FactionItemRenderer.playerLeague,(leaguesCollection.length-FactionItemRenderer.playerLeague-1), FactionItemRenderer._height * (leaguesCollection.length-FactionItemRenderer.playerLeague-1))
	list.scrollToPosition(NaN, FactionItemRenderer._height * (leaguesCollection.length-FactionItemRenderer.playerLeague-1), 0);
}

override protected function transitionInCompleteHandler(event:Event):void
{
	super.transitionInCompleteHandler(event);
	/*var lastQuest:FieldData = game.fieldProvider.quests.get( "quest_" + player.get_questIndex() );
	//trace("inTutorial:", player.inTutorial(), lastQuest.name, "hasStart:", lastQuest.hasStart, "hasIntro:", lastQuest.hasIntro, "hasFinal:", lastQuest.hasFinal, lastQuest.times);
	if( lastQuest.index == 3 && player.nickName == "guest" )
	{
		backButtonHandler();
		return;	
	}
	
	if( lastQuest.index > 0 )
		list.scrollToPosition(0, savedVerticalScrollPosition, 0);
	
	//quest intro
	var tutorialData:TutorialData = new TutorialData("quest_" + lastQuest.index + "_intro");
	for (var i:int ; i < lastQuest.introNum.size() ; i++) 
	{
		var tuteMessage:String = "tutor_quest_" + lastQuest.index + "_intro_"
		if( lastQuest.index == 2 )
			tuteMessage += (player.buildings.exists(BuildingType.B11_BARRACKS)?"second_":"first_");
		tuteMessage += lastQuest.introNum.get(i);
		trace("tuteMessage:", tuteMessage);
		tutorialData.addTask(new TutorialTask(TutorialTask.TYPE_MESSAGE, tuteMessage, null, 1000, 1000, lastQuest.introNum.get(i)));	
	}
	
	tutorials.addEventListener(GameEvent.SHOW_TUTORIAL, tutorials_showHandler);
	tutorials.show(tutorialData);
	if( tutorialData.numTasks > 0 )
		appModel.sounds.addAndPlaySound("outcome-defeat");*/
}

private function tutorials_showHandler(event:Event):void
{
	if( event.data.data == 2 )
		list.scrollToPosition(0, list.maxVerticalScrollPosition, 2);
}

private function list_selectHandler(event:Event):void
{
	var btn:SimpleButton = event.data as SimpleButton;
	var index:int = int(btn.name)

	var popupWidth:int = 400 * appModel.scale;
	var popupHeight:int = 300 * appModel.scale;
	var bounds:Rectangle = btn.getBounds(this);
	bounds.x += bounds.width * 0.5;
	bounds.y -= popupHeight;
	
	// create transitions data
	var ti:TransitionData = new TransitionData();
	var to:TransitionData = new TransitionData();
	to.destinationAlpha = ti.sourceAlpha = 0;
	var constrain:Rectangle = list.getBounds(this);
	constrain.y += 80 * appModel.scale;
	to.destinationConstrain = ti.destinationConstrain = constrain;
	ti.transition = Transitions.EASE_OUT_BACK;
	to.destinationBound = ti.sourceBound = new Rectangle(bounds.x-popupWidth*0.45, bounds.y+50*appModel.scale, popupWidth*0.9, popupHeight);
	ti.destinationAlpha = to.sourceAlpha = 1;
	to.sourceBound = ti.destinationBound = new Rectangle(bounds.x-popupWidth*0.50, bounds.y-50*appModel.scale, popupWidth*1.0, popupHeight);
	
	var detailsPopup:QuestDetailsPopup = new QuestDetailsPopup(index);
	detailsPopup.transitionIn = ti;
	detailsPopup.transitionOut = to;
	detailsPopup.addEventListener(Event.SELECT, floating_selectHandler);
	addChild(detailsPopup);
	function floating_selectHandler(event:Event):void
	{
		detailsPopup.removeEventListener(Event.SELECT, floating_selectHandler);
		var quest:FieldData = game.fieldProvider.quests.get("quest_" + index);
		var item:StackScreenNavigatorItem = appModel.navigator.getScreen( Main.BATTLE_SCREEN );
		item.properties.requestField = quest;
		item.properties.waitingOverlay = new WaitingOverlay() ;
		appModel.navigator.addOverlay(item.properties.waitingOverlay);
		appModel.navigator.pushScreen( Main.BATTLE_SCREEN ) ;
	}
}

private function list_focusInHandler(event:Event):void
{
	showRanking(Arena(event.data).index);
}		

public static function showRanking(arenaIndex:int):void
{
	var extraInfo:SFSObject = new SFSObject();
	extraInfo.putInt("arena", arenaIndex );
	SFSConnection.instance.sendExtensionRequest( SFSCommands.RANK, extraInfo );
	
	var padding:int = 36*AppModel.instance.scale;
	var transitionIn:TransitionData = new TransitionData();
	transitionIn.sourceAlpha = 0;
	var transitionOut:TransitionData = new TransitionData();
	transitionOut.destinationAlpha = 0;
	transitionOut.transition = Transitions.EASE_IN;
	transitionOut.destinationBound = transitionIn.sourceBound = new Rectangle(padding*2,	padding,	Starling.current.stage.stageWidth-padding*4,	Starling.current.stage.stageHeight-padding*2);
	transitionIn.destinationBound = transitionOut.sourceBound = new Rectangle(padding*2,	padding*2,	Starling.current.stage.stageWidth-padding*4,	Starling.current.stage.stageHeight-padding*4);
	
	//appModel.navigator.pushScreen( Main.RANK_SCREEN );
	var rankingPopup:RankingPopup = new RankingPopup();
	rankingPopup.arenaIndex = arenaIndex;
	rankingPopup.transitionIn = transitionIn;
	rankingPopup.transitionOut = transitionOut;
	AppModel.instance.navigator.addPopup(rankingPopup);			
}
override protected function backButtonFunction():void
{
	if( !player.inTutorial() )
		super.backButtonFunction();
}
}
}