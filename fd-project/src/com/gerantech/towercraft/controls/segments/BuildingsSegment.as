package com.gerantech.towercraft.controls.segments
{
import com.gerantech.towercraft.controls.BuildingCard;
import com.gerantech.towercraft.controls.items.CardItemRenderer;
import com.gerantech.towercraft.controls.overlays.BuildingUpgradeOverlay;
import com.gerantech.towercraft.controls.popups.CardDetailsPopup;
import com.gerantech.towercraft.controls.popups.RequirementConfirmPopup;
import com.gerantech.towercraft.controls.screens.DashboardScreen;
import com.gerantech.towercraft.events.GameEvent;
import com.gerantech.towercraft.managers.net.sfs.SFSCommands;
import com.gerantech.towercraft.managers.net.sfs.SFSConnection;
import com.gerantech.towercraft.models.tutorials.TutorialData;
import com.gerantech.towercraft.models.tutorials.TutorialTask;
import com.gerantech.towercraft.models.vo.UserData;
import com.gt.towers.buildings.Building;
import com.gt.towers.constants.BuildingType;
import com.gt.towers.constants.PrefsTypes;
import com.gt.towers.exchanges.Exchanger;
import com.smartfoxserver.v2.entities.data.SFSObject;
import feathers.controls.List;
import feathers.controls.ScrollBarDisplayMode;
import feathers.controls.renderers.IListItemRenderer;
import feathers.data.ListCollection;
import feathers.events.FeathersEventType;
import feathers.layout.AnchorLayout;
import feathers.layout.AnchorLayoutData;
import feathers.layout.TiledRowsLayout;
import starling.events.Event;

public class BuildingsSegment extends Segment
{

public static var SELECTED_CARD:int = -1;
private var buildingsListCollection:ListCollection;
private var buildingslist:List;
private var listLayout:TiledRowsLayout;
private var detailsPopup:CardDetailsPopup;

public function BuildingsSegment(){}
override public function init():void
{
	super.init();
	
	layout = new AnchorLayout();
	listLayout = new TiledRowsLayout();
	listLayout.padding = listLayout.gap = 6;
	listLayout.paddingTop = listLayout.padding * 16;
	listLayout.paddingBottom = listLayout.padding * 2;
	listLayout.verticalGap = listLayout.padding * 1;
	listLayout.useSquareTiles = false;
	listLayout.requestedColumnCount = 4;
	listLayout.typicalItemWidth = (width - listLayout.gap * (listLayout.requestedColumnCount + 2)) / listLayout.requestedColumnCount;
	listLayout.typicalItemHeight = listLayout.typicalItemWidth * BuildingCard.VERICAL_SCALE;
	
	buildingslist = new List();
	buildingslist.scrollBarDisplayMode = ScrollBarDisplayMode.NONE;
	buildingslist.layout = listLayout;
	buildingslist.layoutData = new AnchorLayoutData(0, 0, 0, 0);
	buildingslist.itemRendererFactory = function():IListItemRenderer { return new CardItemRenderer(); }
	buildingslist.dataProvider = buildingsListCollection;
	buildingslist.addEventListener(FeathersEventType.FOCUS_IN, list_focusInHandler);
	addChild(buildingslist);
	initializeCompleted = true;
	showAutoSelected();
}

override public function focus():void
{
	updateData();
}

override public function updateData():void
{
	if( buildingsListCollection == null )
	{
		buildingsListCollection = new ListCollection();
		var buildings:Vector.<int> = BuildingType.getAll().keys();
		var buildingArray:Array = new Array();
		while(buildings.length > 0)
			buildingArray.push(buildings.pop());
		buildingArray.sort();
		buildingsListCollection.data = buildingArray;
		return;
	}
	buildingsListCollection.updateAll();
}

private function showAutoSelected():void 
{
	if( SELECTED_CARD == -1 ) 
		return;
	openCard(SELECTED_CARD);
	SELECTED_CARD = -1;
}
private function list_focusInHandler(event:Event):void
{
	var item:CardItemRenderer = event.data as CardItemRenderer;
	openCard(item.data as int);
}

private function openCard(buildingType:int):void 
{
	var unlockedAt:int = game.unlockedBuildingAt( buildingType );
	if( !player.buildings.exists( buildingType ) && unlockedAt > player.get_arena(0) )
	{
		appModel.navigator.addLog(loc("arena_unlocked_at", [loc("arena_text") + " " + loc("num_" + (unlockedAt + 1))]));
		return;
	}
	
	/*if( player.inDeckTutorial() )
	{
		seudUpgradeRequest(player.buildings.get(buildingType), 0);
		UserData.instance.prefs.setInt(PrefsTypes.TUTOR, PrefsTypes.T_038_CARD_UPGRADED );
		tutorials.dispatchEventWith("upgrade");
		appModel.navigator.runBattle();
		return;
	}*/

	detailsPopup = new CardDetailsPopup();
	detailsPopup.buildingType = buildingType;
	detailsPopup.addEventListener(Event.CLOSE, details_closeHandler);
	appModel.navigator.addPopup(detailsPopup);
	detailsPopup.addEventListener(Event.UPDATE, details_updateHandler);
	function details_closeHandler():void
	{
		buildingslist.selectedIndex = -1;
		if( player.inDeckTutorial() )
			buildingsListCollection.updateAll();
	}
}

private function details_updateHandler(event:Event):void
{
	var building:Building = player.buildings.get(event.data as int);
	var confirmedHards:int = 0;
	if( !player.has(building.get_upgradeRequirements()) )
	{
		var confirm:RequirementConfirmPopup = new RequirementConfirmPopup(loc("popup_cardtogem_message"), building.get_upgradeRequirements());
		confirm.data = building;
		confirm.addEventListener(FeathersEventType.ERROR, upgradeConfirm_errorHandler);
		confirm.addEventListener(Event.SELECT, upgradeConfirm_selectHandler);
		appModel.navigator.addPopup(confirm);
		return;
	}
	
	seudUpgradeRequest(building, 0);
}
private function upgradeConfirm_errorHandler(event:Event):void
{
	appModel.navigator.toolbar.dispatchEventWith(Event.SELECT, true, {resourceType:1002});
	appModel.navigator.addLog(loc("log_not_enough", [loc("resource_title_1003")]));
	detailsPopup.close();
}
private function upgradeConfirm_selectHandler(event:Event):void
{
	var confirm:RequirementConfirmPopup = event.currentTarget as RequirementConfirmPopup;
	seudUpgradeRequest( confirm.data as Building, Exchanger.toHard(player.deductions(confirm.requirements)) );
}

private function seudUpgradeRequest(building:Building, confirmedHards:int):void
{
	if( detailsPopup != null && building.get_level() > -1 )
	{
		detailsPopup.close();
		detailsPopup = null;
	}
	
	if( !building.upgrade(confirmedHards) )
		return;
	
	var sfs:SFSObject = new SFSObject();
	sfs.putInt("type", building.type);
	sfs.putInt("confirmedHards", confirmedHards);
	SFSConnection.instance.sendExtensionRequest(SFSCommands.BUILDING_UPGRADE, sfs);
	
	updateData();
	
	if( building.get_level() < 2 )
		return;
	
	var upgradeOverlay:BuildingUpgradeOverlay = new BuildingUpgradeOverlay();
	upgradeOverlay.building = building;
	appModel.navigator.addOverlay(upgradeOverlay);
	UserData.instance.prefs.setInt(PrefsTypes.TUTOR, PrefsTypes.T_038_CARD_UPGRADED );
}
}
}