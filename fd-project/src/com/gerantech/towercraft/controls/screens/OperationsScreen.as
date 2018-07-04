package com.gerantech.towercraft.controls.screens
{
import com.gerantech.towercraft.controls.buttons.SimpleButton;
import com.gerantech.towercraft.controls.headers.CloseFooter;
import com.gerantech.towercraft.controls.items.OperationMapItemRenderer;
import com.gerantech.towercraft.controls.overlays.TransitionData;
import com.gerantech.towercraft.controls.popups.QuestDetailsPopup;
import com.gerantech.towercraft.events.GameEvent;
import com.gerantech.towercraft.models.tutorials.TutorialData;
import com.gerantech.towercraft.models.tutorials.TutorialTask;
import com.gt.towers.battle.fieldes.FieldData;
import feathers.controls.List;
import feathers.controls.ScrollBarDisplayMode;
import feathers.controls.ScrollPolicy;
import feathers.controls.renderers.IListItemRenderer;
import feathers.data.ListCollection;
import feathers.layout.AnchorLayout;
import feathers.layout.AnchorLayoutData;
import feathers.layout.HorizontalAlign;
import feathers.layout.VerticalLayout;
import flash.geom.Rectangle;
import flash.utils.setTimeout;
import starling.animation.Transitions;
import starling.display.Quad;
import starling.events.Event;

public class OperationsScreen extends BaseCustomScreen
{
public static var savedVerticalScrollPosition:Number = 0;
private var list:List;
private static var questsCollection:ListCollection;
public function OperationsScreen()
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
	OperationMapItemRenderer.OPERATION_INDEX = player.getLastOperation();
	trace(player.getLastOperation())

	var listLayout:VerticalLayout = new VerticalLayout();
	listLayout.paddingBottom = 150 * appModel.scale;
	listLayout.horizontalAlign = HorizontalAlign.JUSTIFY;
	
	list = new List();
	list.layout = listLayout;
	list.layoutData = new AnchorLayoutData(0, 0, 0, 0);
	list.scrollBarDisplayMode = ScrollBarDisplayMode.NONE;
	list.verticalScrollPolicy = player.inTutorial() ? ScrollPolicy.OFF : ScrollPolicy.AUTO;
	list.decelerationRate = 0.99
	list.itemRendererFactory = function():IListItemRenderer { return new OperationMapItemRenderer(); }
	list.addEventListener(Event.SELECT, list_selectHandler);
	list.elasticity = 0.03;
	list.dataProvider = questsCollection;
	addChild(list);
	

	if( savedVerticalScrollPosition != 0 )
		list.scrollToPosition(0, savedVerticalScrollPosition, 0);
	else if( OperationMapItemRenderer.OPERATION_INDEX > 0 )
	{
//		var pageIndex:uint = game.fieldProvider.shires.keys().length - game.fieldProvider.getCurrentShire(player.getLastOperation()).index - 1;
		var pageIndex:uint = game.fieldProvider.shires.keys().length - Math.floor(player.getLastOperation() / 10) - 1;
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
	var lastOperation:FieldData = game.fieldProvider.operations.get( "quest_" + OperationMapItemRenderer.OPERATION_INDEX );
	//trace("inTutorial:", player.inTutorial(), lastQuest.name, "hasStart:", lastQuest.hasStart, "hasIntro:", lastQuest.hasIntro, "hasFinal:", lastQuest.hasFinal, lastQuest.times);
	if( lastOperation.index == 3 && player.nickName == "guest" )
	{
		backButtonHandler();
		return;	
	}
	
	if( lastOperation.index > 0 )
		list.scrollToPosition(0, savedVerticalScrollPosition, 0);
	
	//if( player.inTutorial() )
	//	UserData.instance.prefs.setInt(PrefsTypes.TUTOR, player.emptyDeck() ? PrefsTypes.T_121_QUESTMAP_FIRST_VIEW : PrefsTypes.T_161_QUESTMAP_SECOND_VIEW);

	//quest intro
	var tutorialData:TutorialData = new TutorialData("quest_" + lastOperation.index + "_intro");
	for (var i:int ; i < lastOperation.introNum.size() ; i++) 
	{
		var tuteMessage:String = "tutor_quest_" + lastOperation.index + "_intro_"
/*		if( lastQuest.index == 2 )
			tuteMessage += (player.emptyDeck()?"first_":"second_");*/
		tuteMessage += lastOperation.introNum.get(i);
		trace("tuteMessage:", tuteMessage);
		tutorialData.addTask(new TutorialTask(TutorialTask.TYPE_MESSAGE, tuteMessage, null, 500, 1500, lastOperation.introNum.get(i)));	
	}
	
	tutorials.addEventListener(GameEvent.TUTORIAL_TASK_SHOWN, tutorials_showHandler);
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
	to.destinationBound = ti.sourceBound = new Rectangle(bounds.x - popupWidth * 0.45, bounds.y + 50 * appModel.scale, popupWidth * 0.9, popupHeight);
	ti.destinationAlpha = to.sourceAlpha = 1;
	to.sourceBound = ti.destinationBound = new Rectangle(bounds.x - popupWidth * 0.50, bounds.y - 50 * appModel.scale, popupWidth * 1.0, popupHeight);
	
	var detailsPopup:QuestDetailsPopup = new QuestDetailsPopup(index);
	detailsPopup.transitionIn = ti;
	detailsPopup.transitionOut = to;
	detailsPopup.addEventListener(Event.SELECT, floating_selectHandler);
	addChild(detailsPopup);
	function floating_selectHandler(event:Event):void
	{
		detailsPopup.removeEventListener(Event.SELECT, floating_selectHandler);
		appModel.navigator.runBattle(false, game.fieldProvider.operations.get("quest_" + index));
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
}