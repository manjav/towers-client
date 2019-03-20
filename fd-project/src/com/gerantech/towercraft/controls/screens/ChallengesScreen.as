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

public class ChallengesScreen extends BaseCustomScreen
{
private static var challengesCollection:ListCollection;
private var list:List;

public function ChallengesScreen()
{
	super();
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
	layout = new AnchorLayout();
	
	ChallengeIndexItemRenderer.IN_HOME = false;
	ChallengeIndexItemRenderer.ARENA = player.get_arena(0);
	
	var tileBacground:TileBackground = new TileBackground("home/pistole-tile");
	tileBacground.layoutData = new AnchorLayoutData(0, 0, 0, 0);
	addChildAt(tileBacground, 0);
	
	var shadow:ImageLoader = new ImageLoader();
	shadow.source = Assets.getTexture("bg-shadow");
	shadow.maintainAspectRatio = false
	shadow.layoutData = new AnchorLayoutData( -10, -10, -10, -10);
	shadow.color = 0;
	addChild(shadow);
	
	var listLayout:VerticalLayout = new VerticalLayout();
	listLayout.horizontalAlign = HorizontalAlign.JUSTIFY;
	listLayout.verticalAlign = VerticalAlign.MIDDLE;
	listLayout.useVirtualLayout = false;
	listLayout.padding = 50;
	
	var list:List = new List();
	list.layout = listLayout;
	list.itemRendererFactory = function () : IListItemRenderer { return new ChallengeIndexItemRenderer(); };
	list.addEventListener(Event.TRIGGERED, list_triggeredHandler);
	list.dataProvider = challengesCollection;
	list.layoutData = new AnchorLayoutData(100, 100, 100, 100);
	list.scrollBarDisplayMode = ScrollBarDisplayMode.NONE;
	addChild(list);
	
	var closeButton:Button = new Button();
	closeButton.width = 200;
	closeButton.height = 120;
	closeButton.styleName = MainTheme.STYLE_HILIGHT_BUTTON;
	closeButton.defaultIcon = new Image(appModel.theme.buttonBackDownSkinTexture);
	closeButton.addEventListener(Event.TRIGGERED, cloaseButton_triggeredHandler);
	closeButton.layoutData = new AnchorLayoutData( NaN, NaN, 50, 50);
	addChild(closeButton);
	
	var titleDisplay:ShadowLabel = new ShadowLabel(loc(""));
	titleDisplay.layoutData = new AnchorLayoutData(150, NaN, NaN, NaN, 0);
	addChild(titleDisplay);
}

protected function list_triggeredHandler(event:Event) : void 
{
	player.selectedChallengeIndex = event.data as int;
	appModel.navigator.popScreen();
}
protected function cloaseButton_triggeredHandler(event:Event) : void 
{
	appModel.navigator.popScreen();
}
}
}