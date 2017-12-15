package com.gerantech.towercraft.controls.screens
{
import com.gerantech.towercraft.controls.headers.CloseFooter;
import com.gerantech.towercraft.controls.items.FactionItemRenderer;
import com.gerantech.towercraft.controls.overlays.TransitionData;
import com.gerantech.towercraft.controls.popups.RankingPopup;
import com.gerantech.towercraft.managers.net.sfs.SFSCommands;
import com.gerantech.towercraft.managers.net.sfs.SFSConnection;
import com.gerantech.towercraft.models.AppModel;
import com.gerantech.towercraft.models.Assets;
import com.gt.towers.arenas.Arena;
import com.smartfoxserver.v2.entities.data.SFSObject;

import flash.filesystem.File;
import flash.geom.Rectangle;

import dragonBones.objects.DragonBonesData;
import dragonBones.starling.StarlingFactory;

import feathers.controls.List;
import feathers.controls.ScrollBarDisplayMode;
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
	listLayout.paddingBottom = 220 * appModel.scale;
	listLayout.useVirtualLayout = false;
	
	list = new List();
	list.layout = listLayout;
	list.layoutData = new AnchorLayoutData(0,0,150*appModel.scale,0);
	list.scrollBarDisplayMode = ScrollBarDisplayMode.NONE;
	//list.decelerationRate = 0.99
	list.itemRendererFactory = function():IListItemRenderer { return new FactionItemRenderer (); }
	list.addEventListener(FeathersEventType.CREATION_COMPLETE, list_createCompleteHandler);
	list.addEventListener(FeathersEventType.FOCUS_IN, list_focusInHandler);
	list.elasticity = 0.03;
	list.dataProvider = leaguesCollection;
	addChild(list);

	var closeFooter:CloseFooter = new CloseFooter();
	closeFooter.layoutData = new AnchorLayoutData(NaN, 0,  0, 0);
	closeFooter.addEventListener(Event.CLOSE, backButtonHandler);
	addChild(closeFooter);
}

private function list_createCompleteHandler():void
{
//	trace(leaguesCollection.length,FactionItemRenderer.playerLeague,(leaguesCollection.length-FactionItemRenderer.playerLeague-1), FactionItemRenderer._height * (leaguesCollection.length-FactionItemRenderer.playerLeague-1))
	list.scrollToPosition(NaN, FactionItemRenderer._height * (leaguesCollection.length-FactionItemRenderer.playerLeague-1), 0);
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