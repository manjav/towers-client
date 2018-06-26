package com.gerantech.towercraft.controls.segments
{
import com.gerantech.towercraft.controls.BuildingCard;
import com.gerantech.towercraft.controls.items.BuildingItemRenderer;
import com.gerantech.towercraft.controls.overlays.BuildingUpgradeOverlay;
import com.gerantech.towercraft.controls.overlays.TransitionData;
import com.gerantech.towercraft.controls.popups.BuildingDetailsPopup;
import com.gerantech.towercraft.controls.popups.RequirementConfirmPopup;
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
import flash.geom.Rectangle;
import starling.animation.Transitions;
import starling.events.Event;

public class BuildingsSegment extends Segment
{
private var buildingsListCollection:ListCollection;
private var buildingslist:List;
private var listLayout:TiledRowsLayout;
private var detailsPopup:BuildingDetailsPopup;

public function BuildingsSegment(){}
override public function init():void
{
	super.init();
	
	layout = new AnchorLayout();
	listLayout = new TiledRowsLayout();
	listLayout.padding = listLayout.gap = 16 * appModel.scale;
	listLayout.paddingTop = listLayout.padding * 6;
	listLayout.paddingBottom = listLayout.padding * 1.2;
	listLayout.verticalGap = listLayout.padding * 1;
	listLayout.useSquareTiles = false;
	listLayout.requestedColumnCount = 4;
	listLayout.typicalItemWidth = (width - listLayout.gap * (listLayout.requestedColumnCount + 2)) / listLayout.requestedColumnCount;
	listLayout.typicalItemHeight = listLayout.typicalItemWidth * BuildingCard.VERICAL_SCALE;
	
	updateData();
	buildingslist = new List();
	buildingslist.scrollBarDisplayMode = ScrollBarDisplayMode.NONE;
	buildingslist.layout = listLayout;
	buildingslist.layoutData = new AnchorLayoutData(0, 0, 0, 0);
	buildingslist.itemRendererFactory = function():IListItemRenderer { return new BuildingItemRenderer(); }
	buildingslist.dataProvider = buildingsListCollection;
	buildingslist.addEventListener(FeathersEventType.FOCUS_IN, list_focusInHandler);
	addChild(buildingslist);
	initializeCompleted = true;
	showTutorial();
	
	appModel.navigator.addEventListener("bookOpened", navigator_bookOpenedHandler);
}
protected function navigator_bookOpenedHandler(event:Event):void
{
	updateData();
}
override public function focus():void
{
	if( initializeCompleted )
		showTutorial();
}	
private function showTutorial():void
{
	if( !player.inDeckTutorial() )
		return;
	
	UserData.instance.prefs.setInt(PrefsTypes.TUTOR, PrefsTypes.T_152_DECK_FIRST_VIEW );
	var tutorialData:TutorialData = new TutorialData("deck_start");
	tutorialData.addTask(new TutorialTask(TutorialTask.TYPE_MESSAGE, "tutor_deck_0", null, 500, 1500, 0));
	tutorials.show(tutorialData);
}		
override public function updateData():void
{
	if(buildingsListCollection == null)
		buildingsListCollection = new ListCollection();
	var buildings:Vector.<int> = BuildingType.getAll().keys();
	var buildingArray:Array = new Array();
	while(buildings.length > 0)
		buildingArray.push(buildings.pop());
	buildingArray.sort();
	buildingsListCollection.data = buildingArray;
}

private function list_focusInHandler(event:Event):void
{
	var item:BuildingItemRenderer = event.data as BuildingItemRenderer;
	var buildingType:int = item.data as int;
	if( player.inTutorial() && buildingType != BuildingType.B11_BARRACKS )
		return;// disalble all items in tutorial
	
	var unlockedAt:int = game.unlockedBuildingAt( buildingType );
	if( !player.buildings.exists( buildingType ) && unlockedAt > player.get_arena(0) )
	{
		appModel.navigator.addLog(loc("arena_unlocked_at", [loc("arena_text") + " " + loc("num_" + (unlockedAt + 1))]));
		return;
	}
	
	if( player.inDeckTutorial() )
	{
		seudUpgradeRequest(player.buildings.get(buildingType), 0);
		UserData.instance.prefs.setInt(PrefsTypes.TUTOR, PrefsTypes.T_160_MAIN_SECOND_VIEW );
		tutorials.dispatchEventWith("upgrade");
		return;
	}
	
	// create transition in data
	var ti:TransitionData = new TransitionData();
	ti.transition = Transitions.EASE_OUT_BACK;
	ti.sourceAlpha = 1;
	ti.sourceBound = item.getBounds(this);
	ti.destinationConstrain = this.getBounds(stage);
	ti.destinationBound = new Rectangle(stage.stageWidth * 0.05,
		stage.stageHeight * (Math.floor(buildingType / 10) == 4?0.17:0.22),
		stage.stageWidth * 0.9,
		stage.stageHeight * (Math.floor(buildingType / 10) == 4?0.66:0.56));

	// create transition out data
	var to:TransitionData = new TransitionData();
	to.sourceAlpha = 1;
	to.destinationAlpha = 0.8;
	to.sourceBound = ti.destinationBound.clone();
	to.destinationBound = ti.sourceBound.clone();

	detailsPopup = new BuildingDetailsPopup();
	detailsPopup.buildingType = item.data as int;
	detailsPopup.transitionIn = ti;
	detailsPopup.transitionOut = to;
	detailsPopup.addEventListener(Event.CLOSE, details_closeHandler);
	appModel.navigator.addPopup(detailsPopup);
	detailsPopup.addEventListener(Event.UPDATE, details_updateHandler);
	function details_closeHandler():void
	{
		buildingslist.selectedIndex = -1;
	}
}

private function details_updateHandler(event:Event):void
{
	var building:Building = event.data as Building;
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
	if( detailsPopup != null )
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
	
	var upgradeOverlay:BuildingUpgradeOverlay = new BuildingUpgradeOverlay();
	upgradeOverlay.building = building;
	appModel.navigator.addOverlay(upgradeOverlay);
	
	updateData();
}
}
}