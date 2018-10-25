package com.gerantech.towercraft.controls.popups
{
import com.gerantech.towercraft.Main;
import com.gerantech.towercraft.controls.BuildingCard;
import com.gerantech.towercraft.controls.FastList;
import com.gerantech.towercraft.controls.buttons.CustomButton;
import com.gerantech.towercraft.controls.buttons.EmblemButton;
import com.gerantech.towercraft.controls.buttons.Indicator;
import com.gerantech.towercraft.controls.buttons.IndicatorXP;
import com.gerantech.towercraft.controls.headers.BattleHeader;
import com.gerantech.towercraft.controls.items.CardItemRenderer;
import com.gerantech.towercraft.controls.items.ProfileBuildingItemRenderer;
import com.gerantech.towercraft.controls.items.ProfileFeatureItemRenderer;
import com.gerantech.towercraft.controls.overlays.TransitionData;
import com.gerantech.towercraft.controls.screens.IssuesScreen;
import com.gerantech.towercraft.controls.texts.RTLLabel;
import com.gerantech.towercraft.controls.texts.ShadowLabel;
import com.gerantech.towercraft.managers.net.sfs.SFSCommands;
import com.gerantech.towercraft.managers.net.sfs.SFSConnection;
import com.gerantech.towercraft.models.Assets;
import com.gt.towers.constants.CardTypes;
import com.gt.towers.constants.ResourceType;
import com.smartfoxserver.v2.core.SFSEvent;
import com.smartfoxserver.v2.entities.data.ISFSArray;
import com.smartfoxserver.v2.entities.data.ISFSObject;
import com.smartfoxserver.v2.entities.data.SFSArray;
import com.smartfoxserver.v2.entities.data.SFSObject;
import feathers.controls.List;
import feathers.controls.ScrollBarDisplayMode;
import feathers.controls.ScrollContainer;
import feathers.controls.ScrollPolicy;
import feathers.controls.renderers.IListItemRenderer;
import feathers.data.ListCollection;
import feathers.layout.AnchorLayout;
import feathers.layout.AnchorLayoutData;
import feathers.layout.HorizontalAlign;
import feathers.layout.TiledRowsLayout;
import feathers.layout.VerticalAlign;
import feathers.layout.VerticalLayout;
import flash.geom.Rectangle;
import flash.utils.Dictionary;
import starling.core.Starling;
import starling.events.Event;

public class ProfilePopup extends SimplePopup 
{
private var user:Object;
private var adminMode:Boolean;
private var playerData:ISFSObject;
private var resourcesData:ISFSArray;

public function ProfilePopup(user:Object, getFullPlayerData:Boolean=false)
{
	this.user = user;
	this.adminMode = player.admin;
	
	var params:SFSObject = new SFSObject();
	params.putInt("id", user.id);
	if( adminMode )
		params.putBool("am", true);
	if( getFullPlayerData )
		params.putBool("pd", true);
	if( user.ln == null )
		params.putInt("lp", 0);
	
	SFSConnection.instance.addEventListener(SFSEvent.EXTENSION_RESPONSE, sfsConnection_responceHandler);
	SFSConnection.instance.sendExtensionRequest(SFSCommands.PROFILE, params);
}

override protected function initialize():void
{
	super.initialize();
	transitionOut.destinationBound = transitionIn.sourceBound = new Rectangle(stageWidth * 0.05, stageHeight * (adminMode?0.15:0.25), stageWidth * 0.9, stageHeight * (adminMode?0.8:0.5));
	transitionIn.destinationBound = transitionOut.sourceBound = new Rectangle(stageWidth * 0.05, stageHeight * (adminMode?0.05:0.20), stageWidth * 0.9, stageHeight * (adminMode?0.9:0.6));
	rejustLayoutByTransitionData();
}
protected override function transitionInCompleted():void
{
	super.transitionInCompleted();
	if( playerData != null )
		showProfile();
}
protected function sfsConnection_responceHandler(event:SFSEvent):void
{
	if( event.params.cmd != SFSCommands.PROFILE )
		return;
	SFSConnection.instance.removeEventListener(SFSEvent.EXTENSION_RESPONSE, sfsConnection_responceHandler);
	playerData = event.params.params as SFSObject;
	resourcesData = playerData.getSFSArray("resources");
	
	if( playerData.containsKey("ln") )
		user.ln = playerData.getText("ln");
	else if( user.ln == null )
		user.ln = loc("lobby_no");
	
	if( playerData.containsKey("lp") )
		user.lp = playerData.getInt("lp");
	else if( user.lp == null )
		user.lp = 110;

	if( transitionState >= TransitionData.STATE_IN_COMPLETED )
		showProfile();
}

private function showProfile():void
{
	var lobbyIconDisplay:EmblemButton = new EmblemButton(user.lp);
	lobbyIconDisplay.touchable = false;
	lobbyIconDisplay.width = padding * 5.3;
	lobbyIconDisplay.height = padding * 5.6;
	lobbyIconDisplay.layoutData = new AnchorLayoutData(padding, appModel.isLTR?NaN:padding, NaN, appModel.isLTR?padding:NaN);
	addChild(lobbyIconDisplay);
	
	var nameDisplay:ShadowLabel = new ShadowLabel(playerData.containsKey("pd")?playerData.getSFSObject("pd").getText("name"):user.name, 1, 0, null, null, true, "center", 1);
	nameDisplay.layoutData = new AnchorLayoutData(padding, appModel.isLTR?NaN:padding * 7, NaN, appModel.isLTR?padding * 7:NaN);
	addChild(nameDisplay);
	
	var tagDisplay:RTLLabel = new RTLLabel("#" + playerData.getText("tag") + (adminMode?(" => " + user.id) : ""), 0xAABBBB, null, "ltr", true, null, 0.8);
	tagDisplay.layoutData = new AnchorLayoutData(padding * 2.6, appModel.isLTR?NaN:padding * 7, NaN, appModel.isLTR?padding * 7:NaN);
	addChild(tagDisplay);
	
	var lobbyNameDisplay:RTLLabel = new RTLLabel(user.ln, 0xAABBBB, null, "ltr", true, null, 0.8);
	lobbyNameDisplay.layoutData = new AnchorLayoutData(padding * 5, appModel.isLTR?NaN:padding * 7, NaN, appModel.isLTR?padding * 7:NaN);
	addChild(lobbyNameDisplay);
	
	var closeButton:CustomButton = new CustomButton();
	closeButton.label = loc("close_button");
	closeButton.layoutData = new AnchorLayoutData(NaN, NaN, NaN, NaN, 0);
	closeButton.addEventListener(Event.TRIGGERED, close_triggeredHandler);
	addChild(closeButton);

	closeButton.y = height - closeButton.height - padding * 1.6;
	closeButton.alpha = 0;
	closeButton.height = 110;
	Starling.juggler.tween(closeButton, 0.2, {delay:0.8, alpha:1, y:height - closeButton.height - padding});
	
	if( adminMode )
	{
		var banButton:CustomButton = new CustomButton();
		banButton.icon = Assets.getTexture("settings-5", "gui");
		banButton.style = "danger";
		banButton.width = banButton.height = padding * 3;
		banButton.layoutData = new AnchorLayoutData(NaN, appModel.isLTR?padding:NaN, padding, appModel.isLTR?NaN:padding);
		banButton.addEventListener(Event.TRIGGERED, adminButtons_triggeredHandler);
		addChild(banButton);
		
		var issuesButton:CustomButton = new CustomButton();
		issuesButton.icon = Assets.getTexture("home/inbox", "gui");
		issuesButton.width = issuesButton.height = padding * 3
		issuesButton.layoutData = new AnchorLayoutData(NaN, appModel.isLTR?padding * 5:NaN, padding, appModel.isLTR?NaN:padding * 5);
		issuesButton.addEventListener(Event.TRIGGERED, adminButtons_triggeredHandler);
		addChild(issuesButton);
		
		function adminButtons_triggeredHandler(event:Event):void
		{
			if( event.currentTarget == banButton )
			{
				appModel.navigator.addPopup(new AdminBanPopup(user.id));
				return;
			}
			if( appModel.navigator.activeScreen is IssuesScreen )
			{
				IssuesScreen(appModel.navigator.activeScreen).reporter = user.id;
				IssuesScreen(appModel.navigator.activeScreen).requestIssues();
				close();
				return;
			}
			appModel.navigator.getScreen( Main.ISSUES_SCREEN ).properties.reporter = user.id;
			appModel.navigator.pushScreen( Main.ISSUES_SCREEN ) ;
			close();
		}
	}

	
	var featureCollection:ListCollection = new ListCollection();
	var xp:int;
	var point:int;
	for ( var i:int = 0; i < resourcesData.size(); i ++ )
	{
		if( resourcesData.getSFSObject(i).getInt("type") == ResourceType.R1_XP )
			xp = resourcesData.getSFSObject(i).getInt("count");
		else if( resourcesData.getSFSObject(i).getInt("type") == ResourceType.R2_POINT )
			point = resourcesData.getSFSObject(i).getInt("count");
		else if( !ResourceType.isCard(resourcesData.getSFSObject(i).getInt("type")) )
			featureCollection.addItem(resourcesData.getSFSObject(i));
	}

	var indicators:Dictionary = appModel.navigator.toolbar.indicators;
	indicators[ResourceType.R1_XP] = new IndicatorXP("ltr");
	indicators[ResourceType.R1_XP].setData(0, xp, NaN);
	indicators[ResourceType.R1_XP].width = padding * 7;
	indicators[ResourceType.R1_XP].layoutData = new AnchorLayoutData(padding, appModel.isLTR?padding * 2:NaN, NaN, appModel.isLTR?NaN:padding * 2);
	addChild(indicators[ResourceType.R1_XP]);
	
	indicators[ResourceType.R2_POINT] = new Indicator("ltr", ResourceType.R2_POINT, false, false);
	indicators[ResourceType.R2_POINT].width = padding * 7;
	indicators[ResourceType.R2_POINT].setData(0, point, NaN);
	indicators[ResourceType.R2_POINT].layoutData = new AnchorLayoutData(padding * 3.5, appModel.isLTR?padding * 2:NaN, NaN, appModel.isLTR?NaN:padding * 2);
	addChild(indicators[ResourceType.R2_POINT]);
	
	var scroller:ScrollContainer = new ScrollContainer();
	scroller.layout = new AnchorLayout();
	scroller.layoutData = new AnchorLayoutData(padding * 7, padding * 2, padding * 5, padding * 2);
	scroller.scrollBarDisplayMode = ScrollBarDisplayMode.NONE;
	addChild(scroller);
	
	// features
	var featureList:List = new List();
	featureList.horizontalScrollPolicy = ScrollPolicy.OFF;
	featureList.itemRendererFactory = function ():IListItemRenderer { return new ProfileFeatureItemRenderer(); }
	featureList.verticalScrollPolicy = featureList.horizontalScrollPolicy = ScrollPolicy.OFF;
	featureList.dataProvider = featureCollection;
	featureList.layoutData = new AnchorLayoutData(0, 0, NaN, 0);
	scroller.addChild(featureList);
	
	var featureLayout:VerticalLayout = new VerticalLayout();
	featureLayout.horizontalAlign = HorizontalAlign.JUSTIFY;
	featureLayout.verticalAlign = VerticalAlign.MIDDLE;
	featureList.layout = featureLayout;
	
	// buildings
	if( adminMode )
	{
		var listLayout:TiledRowsLayout = new TiledRowsLayout();
		listLayout.padding = 0;
		listLayout.gap = padding * 0.2;
		listLayout.useSquareTiles = false;
		listLayout.requestedColumnCount = 10;
		listLayout.typicalItemWidth = (width -listLayout.padding * (listLayout.requestedColumnCount + 1)) / listLayout.requestedColumnCount;
		listLayout.typicalItemHeight = listLayout.typicalItemWidth * BuildingCard.VERICAL_SCALE;
		
		var buildingslist:FastList = new FastList();
		buildingslist.scrollBarDisplayMode = ScrollBarDisplayMode.NONE;
		buildingslist.layout = listLayout;
		buildingslist.verticalScrollPolicy = buildingslist.horizontalScrollPolicy = ScrollPolicy.OFF;
		buildingslist.layoutData = new AnchorLayoutData(featureCollection.length * 70, 0, NaN, 0);
		buildingslist.itemRendererFactory = function():IListItemRenderer { return new ProfileBuildingItemRenderer(); }
		buildingslist.dataProvider = getBuildingData();
		scroller.addChild(buildingslist);		
	}
	
	// deck
	var top:int = adminMode ? 430 : 20;
    var deckHeader:BattleHeader = new BattleHeader(loc("deck_label"), true);
    deckHeader.width = transitionIn.destinationBound.width * 0.8;
	deckHeader.scaleY = 0.85;
    deckHeader.layoutData = new AnchorLayoutData(featureList.dataProvider.length * 70 + top, NaN, NaN, NaN, 0);
    scroller.addChild(deckHeader);
    
    var deckLayout:TiledRowsLayout = new TiledRowsLayout();
    deckLayout.gap = padding * 0.5;
    deckLayout.useSquareTiles = false;
    deckLayout.useVirtualLayout = false;
    deckLayout.requestedColumnCount = 4;
    deckLayout.typicalItemWidth = (width - deckLayout.gap * (deckLayout.requestedColumnCount - 1) - padding * 4) / deckLayout.requestedColumnCount;
    deckLayout.typicalItemHeight = deckLayout.typicalItemWidth * BuildingCard.VERICAL_SCALE;
	
	var deckList:List = new List();
    deckList.layout = deckLayout;
    deckList.height = deckLayout.typicalItemHeight;
    deckList.verticalScrollPolicy = deckList.horizontalScrollPolicy = ScrollPolicy.OFF;
    deckList.layoutData = new AnchorLayoutData(featureList.dataProvider.length * 70 + top + 150, 0, NaN, 0);
    deckList.itemRendererFactory = function():IListItemRenderer { return new CardItemRenderer(true, false); }
    deckList.dataProvider = getDeckData();
    scroller.addChild(deckList);
    deckList.alpha = 0;
    Starling.juggler.tween(deckList, 0.2, {delay:0.6, alpha:1});
}

private function getBuildingData():ListCollection
{
	var ret:ListCollection = new ListCollection();
	var buildings:Vector.<int> = CardTypes.getAll()._list;
	var buildingArray:Array = new Array();
	while(buildings.length > 0)
	{
		var b:int = buildings.pop();
		buildingArray.push({type:b, level:getLevel(b)});
	}
	buildingArray.sortOn("type");
	return new ListCollection(buildingArray);
}

private function getLevel(type:int):int
{
	var bLen:int = resourcesData.size()
	for (var i:int = 0; i < bLen; i++)
		if( resourcesData.getSFSObject(i).getInt("type") == type ) 
			return resourcesData.getSFSObject(i).getInt("level");
	return 0;
}		
	
private function getDeckData():ListCollection
{
    var decks:ISFSArray = playerData.getSFSArray("decks");
    var ret:ListCollection = new ListCollection();
    for (var i:int = 0; i < decks.size(); i++) 
        ret.addItem({type:decks.getSFSObject(i).getInt("type"), level:decks.getSFSObject(i).getInt("level")});
    return ret;
}

private function close_triggeredHandler(event:Event):void
{
	close();
}
}
}