package com.gerantech.towercraft.controls.screens
{
import com.gerantech.towercraft.Main;
import com.gerantech.towercraft.controls.buttons.IconButton;
import com.gerantech.towercraft.controls.buttons.SimpleButton;
import com.gerantech.towercraft.controls.items.QuestMapItemRenderer;
import com.gerantech.towercraft.controls.overlays.TransitionData;
import com.gerantech.towercraft.controls.overlays.WaitingOverlay;
import com.gerantech.towercraft.controls.popups.QuestDetailsPopup;
import com.gerantech.towercraft.events.GameEvent;
import com.gerantech.towercraft.models.Assets;
import com.gerantech.towercraft.models.tutorials.TutorialData;
import com.gerantech.towercraft.models.tutorials.TutorialTask;
import com.gt.towers.battle.fieldes.FieldData;
import com.gt.towers.constants.BuildingType;

import flash.geom.Rectangle;
import flash.utils.setTimeout;

import feathers.controls.List;
import feathers.controls.ScrollBarDisplayMode;
import feathers.controls.ScrollPolicy;
import feathers.controls.StackScreenNavigatorItem;
import feathers.controls.renderers.IListItemRenderer;
import feathers.data.ListCollection;
import feathers.layout.AnchorLayout;
import feathers.layout.AnchorLayoutData;

import starling.animation.Transitions;
import starling.display.Image;
import starling.display.Quad;
import starling.events.Event;

public class QuestMapScreen extends BaseCustomScreen
{
public static var savedVerticalScrollPosition:Number = 0;

private var list:List;
private static var questsCollection:ListCollection;

public function QuestMapScreen()
{
	super();
	provideQuestsData();
}
private function provideQuestsData():void
{
	if( questsCollection != null )
		return;
	
	var field:FieldData;
	var source:Array = new Array();
	
	var fields:Vector.<FieldData> = game.fieldProvider.shires.values();
	for( var i:int=0; i < fields.length; i++)
		source.push( fields[i] );
	source.sortOn("index", Array.NUMERIC|Array.DESCENDING);
	questsCollection = new ListCollection(source);
}
override protected function initialize():void
{
	super.initialize();
	layout = new AnchorLayout();
	backgroundSkin = new Quad(1,1, 0xFFDF78);
	QuestMapItemRenderer.questIndex = player.get_questIndex();

	list = new List();
	list.layoutData = new AnchorLayoutData(0,0,0,0);
	list.scrollBarDisplayMode = ScrollBarDisplayMode.NONE;
	list.verticalScrollPolicy = player.inTutorial() ? ScrollPolicy.OFF : ScrollPolicy.AUTO;
	list.decelerationRate = 0.99
	list.itemRendererFactory = function():IListItemRenderer { return new QuestMapItemRenderer(); }
	list.addEventListener(Event.SELECT, list_selectHandler);
	list.elasticity = 0.03;
	list.dataProvider = questsCollection;
	addChild(list);
	

	if( savedVerticalScrollPosition != 0 )
		list.scrollToPosition(0, savedVerticalScrollPosition, 0);
	else if( QuestMapItemRenderer.questIndex > 0 )
	{
		var pageIndex:uint = game.fieldProvider.shires.keys().length - game.fieldProvider.getCurrentShire(player.get_questIndex()).index - 1;
		//trace(pageIndex, QuestMapItemRenderer.questIndex, game.fieldProvider.getCurrentShire(QuestMapItemRenderer.questIndex).index, list.dataProvider.length)
		if( pageIndex > 0 )
			setTimeout(list.scrollToDisplayIndex, 1000, pageIndex, 1);
	}
	
	if( player.inTutorial() )
		return;
	
	var backButton:IconButton = new IconButton(Assets.getTexture("tab-1", "gui"));
	backButton.backgroundSkin = new Image(Assets.getTexture("theme/building-button", "gui"));
	Image(backButton.backgroundSkin).scale9Grid = new Rectangle(10, 10, 56, 37);
	backButton.width = backButton.height = 160 * appModel.scale;
	backButton.layoutData = new AnchorLayoutData(NaN, NaN,  10*appModel.scale, NaN, 0);
	backButton.addEventListener(Event.TRIGGERED, backButtonHandler);
	addChild(backButton);
}

override protected function transitionInCompleteHandler(event:Event):void
{
	super.transitionInCompleteHandler(event);
	var lastQuest:FieldData = game.fieldProvider.quests.get( "quest_" + QuestMapItemRenderer.questIndex );
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
		appModel.sounds.addAndPlaySound("outcome-defeat");
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

override protected function backButtonFunction():void
{
	if( !player.inTutorial() )
		super.backButtonFunction();
}
override public function dispose():void
{
	savedVerticalScrollPosition = list.verticalScrollPosition;
	super.dispose();
}
}
}