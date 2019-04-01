package com.gerantech.towercraft.controls.screens
{
import com.gerantech.towercraft.controls.TileBackground;
import com.gerantech.towercraft.controls.items.challenges.ChallengeIndexItemRenderer;
import com.gerantech.towercraft.controls.texts.ShadowLabel;
import com.gerantech.towercraft.models.Assets;
import com.gerantech.towercraft.themes.MainTheme;
import feathers.controls.Button;
import feathers.controls.ImageLoader;
import feathers.controls.List;
import feathers.controls.ScrollBarDisplayMode;
import feathers.controls.renderers.IListItemRenderer;
import feathers.data.ListCollection;
import feathers.layout.AnchorLayout;
import feathers.layout.AnchorLayoutData;
import feathers.layout.HorizontalAlign;
import feathers.layout.VerticalAlign;
import feathers.layout.VerticalLayout;
import starling.display.Image;
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
	ChallengeIndexItemRenderer.ARENA = player.get_arena(0);
	
	listLayout.verticalAlign = VerticalAlign.MIDDLE;
	listLayout.padding = 150;
	listLayout.paddingTop = 200;
	
	list.dataProvider = challengesCollection;
	list.layoutData = new AnchorLayoutData(0, 0, headerSize, 0);
	list.itemRendererFactory = function () : IListItemRenderer { return new ChallengeIndexItemRenderer(); };
	list.addEventListener(Event.TRIGGERED, list_triggeredHandler);
}

protected function list_triggeredHandler(event:Event) : void 
{
	player.selectedChallengeIndex = event.data as int;
	appModel.navigator.popScreen();
}
}
}