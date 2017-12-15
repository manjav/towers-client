package com.gerantech.towercraft.controls.screens
{
import com.gerantech.towercraft.Main;
import com.gerantech.towercraft.controls.buttons.SimpleButton;
import com.gerantech.towercraft.controls.headers.CloseFooter;
import com.gerantech.towercraft.controls.items.QuestMapItemRenderer;
import com.gerantech.towercraft.controls.overlays.BattleStartOverlay;
import com.gerantech.towercraft.controls.overlays.TransitionData;
import com.gerantech.towercraft.controls.popups.QuestDetailsPopup;
import com.gerantech.towercraft.events.GameEvent;
import com.gerantech.towercraft.models.tutorials.TutorialData;
import com.gerantech.towercraft.models.tutorials.TutorialTask;
import com.gt.towers.battle.fieldes.FieldData;

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
import feathers.layout.HorizontalAlign;
import feathers.layout.VerticalLayout;

import starling.animation.Transitions;
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

	var listLayout:VerticalLayout = new VerticalLayout();
	listLayout.paddingBottom = 150*appModel.scale;
	listLayout.horizontalAlign = HorizontalAlign.JUSTIFY;
	
	list = new List();
	list.layout = listLayout;
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
	
	var closeFooter:CloseFooter = new CloseFooter();
	closeFooter.layoutData = new AnchorLayoutData(NaN, 0,  0, 0);
	closeFooter.addEventListener(Event.CLOSE, backButtonHandler);
	addChild(closeFooter);
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
			tuteMessage += (player.isHardMode()?"first_":"second_");
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
		item.properties.waitingOverlay = new BattleStartOverlay(index, true) ;
		appModel.navigator.addOverlay(item.properties.waitingOverlay);
		setTimeout(appModel.navigator.pushScreen, 1000, Main.BATTLE_SCREEN ) ;
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