package com.gerantech.towercraft.controls.groups 
{
import com.gerantech.towercraft.Main;
import com.gerantech.towercraft.controls.TowersLayout;
import com.gerantech.towercraft.controls.buttons.IconButton;
import com.gerantech.towercraft.controls.buttons.NotifierButton;
import com.gerantech.towercraft.managers.InboxService;
import com.gerantech.towercraft.models.Assets;
import com.gerantech.towercraft.themes.BaseMetalWorksMobileTheme;
import feathers.controls.ImageLoader;
import feathers.layout.HorizontalLayout;
import feathers.layout.VerticalAlign;
import flash.geom.Rectangle;
import starling.events.Event;
import starling.utils.Color;

/**
* ...
* @author Mansour Djawadi
*/
public class HomeFooter extends TowersLayout 
{
private var inboxButton:NotifierButton;
public function HomeFooter() {super();}
override protected function initialize():void 
{
	super.initialize();
	
    width = 500 * appModel.scale;
    height = 140 * appModel.scale;
	
	var hLayout:HorizontalLayout = new HorizontalLayout();
	hLayout.verticalAlign = VerticalAlign.MIDDLE;
	layout = hLayout;
	
	var gradient:ImageLoader = new ImageLoader();
	gradient.scale9Grid = BaseMetalWorksMobileTheme.SHADOW_SIDE_SCALE9_GRID;
    gradient.color = Color.BLACK;
    gradient.alpha = 0.6;
    gradient.source = Assets.getTexture("theme/gradeint-left", "gui");
	backgroundSkin = gradient;
	
	addButton("home/settings");
	addButton("home/inbox");
	addButton("home/spectate");
	
	InboxService.instance.request();
	InboxService.instance.addEventListener(Event.UPDATE, inboxService_updateHandler);
}

private function addButton(texture:String) : void 
{
	var button:IconButton;
	if( texture == "home/inbox" )
	{
		button = inboxButton = new NotifierButton(Assets.getTexture("home/inbox", "gui"));
		inboxButton.badgeLabel = InboxService.instance.numUnreads.toString();
	}
	else
	{
		button = new IconButton(Assets.getTexture(texture, "gui"));
	}
	button.name = texture;
	button.width = button.height = 140 * appModel.scale;
	button.addEventListener(Event.TRIGGERED, buttons_triggeredHandler);
	addChild(button);
}

private function buttons_triggeredHandler(event:Event):void 
{
	switch ( IconButton(event.currentTarget).name )
	{
		case "home/settings" :	appModel.navigator.pushScreen(Main.SETTINGS_SCREEN);	break;
		case "home/inbox" :		appModel.navigator.pushScreen(Main.INBOX_SCREEN);		break;
		case "home/spectate" :	var item:StackScreenNavigatorItem = appModel.navigator.getScreen( Main.SPECTATE_SCREEN );item.properties.cmd = "battles";appModel.navigator.pushScreen( Main.SPECTATE_SCREEN ); break;
	}
}

private function inboxService_updateHandler():void
{
	inboxButton.badgeLabel = InboxService.instance.numUnreads.toString();
}
}
}