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
import com.gt.towers.others.Arena;
import com.smartfoxserver.v2.entities.data.SFSObject;
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
import flash.geom.Rectangle;
import starling.animation.Transitions;
import starling.core.Starling;
import starling.display.Image;
import starling.events.Event;

public class FactionsScreen extends BaseCustomScreen
{
public static var factory:StarlingFactory;
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
public static function createFactory():void
{
	factory = new StarlingFactory();
	dragonBonesData = factory.parseDragonBonesData(AppModel.instance.assets.getObject("factions_ske"));
	factory.parseTextureAtlasData(AppModel.instance.assets.getObject("factions_tex"), AppModel.instance.assets.getTexture("factions_tex"));
}
override protected function initialize():void
{
	super.initialize();
	layout = new AnchorLayout();
	
	var tiledBG:Image = new Image(Assets.getTexture("home/main-map-tile", "gui"));
	tiledBG.tileGrid = new Rectangle(1, 1, 240, 240);
	backgroundSkin = tiledBG;
	
	var shadow:Image = new Image(Assets.getTexture("bg-shadow", "gui"));
	shadow.color = 0;
	shadow.width = stage.stageWidth;
	shadow.height = stage.stageHeight//-footerSize;
	addChildAt(shadow, 0);
	
	FactionItemRenderer._height = 1480;
	FactionItemRenderer.playerLeague = player.get_arena(0);

	var listLayout:VerticalLayout = new VerticalLayout();
	listLayout.horizontalAlign = HorizontalAlign.JUSTIFY;
	listLayout.paddingBottom = 220;
	listLayout.useVirtualLayout = false;
	
	list = new List();
	list.layout = listLayout;
	list.layoutData = new AnchorLayoutData(0,0,150,0);
	list.scrollBarDisplayMode = ScrollBarDisplayMode.NONE;
	//list.decelerationRate = 0.99
	list.itemRendererFactory = function():IListItemRenderer { return new FactionItemRenderer (); }
	list.addEventListener(FeathersEventType.CREATION_COMPLETE, list_createCompleteHandler);
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
	list.scrollToPosition(NaN, FactionItemRenderer._height * (leaguesCollection.length - FactionItemRenderer.playerLeague-1) - FactionItemRenderer._height * 0.2, 0);
}

public static function showRanking(arenaIndex:int):void
{
	var extraInfo:SFSObject = new SFSObject();
	extraInfo.putInt("arena", arenaIndex );
	SFSConnection.instance.sendExtensionRequest( SFSCommands.RANK, extraInfo );
	
	var padding:int = 36;
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