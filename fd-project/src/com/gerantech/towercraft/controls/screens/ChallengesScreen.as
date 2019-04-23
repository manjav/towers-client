package com.gerantech.towercraft.controls.screens
{
import com.gerantech.towercraft.controls.items.challenges.ChallengeIndexItemRenderer;
import com.gerantech.towercraft.models.vo.UserData;
import com.gt.towers.constants.PrefsTypes;
import feathers.controls.renderers.IListItemRenderer;
import feathers.data.ListCollection;
import feathers.layout.VerticalAlign;
import starling.core.Starling;
import starling.events.Event;

public class ChallengesScreen extends ListScreen
{
private static var challengesCollection:ListCollection;
public function ChallengesScreen()
{
	super();
	title = loc("challenges_page");
	if( challengesCollection == null )
	{
		challengesCollection = new ListCollection();
		var keys:Vector.<int> = player.challenges.keys();
		var index:int = 0;
		while( index < keys.length )
		{
			challengesCollection.addItem(player.challenges.get(keys[index]));
			index ++;
		}
	}
}

override protected function initialize():void
{
	super.initialize();
	
	ChallengeIndexItemRenderer.IN_HOME = false;
	ChallengeIndexItemRenderer.SHOW_INFO = true;
	ChallengeIndexItemRenderer.ARENA = player.get_arena(0);
	
	listLayout.verticalAlign = VerticalAlign.MIDDLE;
	listLayout.typicalItemHeight = 410;
	listLayout.paddingTop = 200;
	listLayout.padding = 150;
	
	list.dataProvider = challengesCollection;
	list.itemRendererFactory = function () : IListItemRenderer { return new ChallengeIndexItemRenderer(); };
	list.addEventListener(Event.TRIGGERED, list_triggeredHandler);
	
	closeButton.alpha = 0;
	Starling.juggler.tween(closeButton, 0.3, {delay:0.4, alpha:1});
}

protected function list_triggeredHandler(event:Event) : void 
{
	UserData.instance.challengeIndex = event.data as int;
	UserData.instance.save();
	appModel.navigator.popScreen();
}
}
}