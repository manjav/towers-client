package com.gerantech.towercraft.controls.screens
{
import com.gerantech.towercraft.controls.items.DashboardTabNewItemRenderer;
import com.gerantech.towercraft.models.Assets;
import feathers.controls.ImageLoader;
import feathers.controls.renderers.IListItemRenderer;
import feathers.layout.AnchorLayoutData;
import flash.geom.Rectangle;
import starling.animation.Transitions;
import starling.core.Starling;
import starling.display.Image;
import starling.events.Event;

public class DashboardNewScreen extends DashboardScreen
{
private var tabSelection:ImageLoader;
private var tabPadding:Number;
public function DashboardNewScreen(){}
override protected function initialize():void { super.initialize(); }

override protected function addedToStageHandler(event:Event):void
{
	super.addedToStageHandler(event);
	tabPadding = 56;
	tabSize = ( stageWidth - tabPadding * 2 ) / 5;
	
	tabsList.layoutData = new AnchorLayoutData(NaN, tabPadding, 0, tabPadding);
	tabsList.itemRendererFactory = function ():IListItemRenderer { return new DashboardTabNewItemRenderer(tabSize); }
	
	var tiledBG:Image = new Image(Assets.getTexture("home/main-map-tile", "gui"));
	tiledBG.alpha = 0.8;
	tiledBG.tileGrid = new Rectangle(0, 0, 242, 242);
	tiledBG.pixelSnapping = false;
	backgroundSkin = tiledBG;
	
	/*var shadow:ImageLoader = new ImageLoader();
	shadow.source = Assets.getTexture("bg-shadow", "gui");
	shadow.maintainAspectRatio = false
	shadow.layoutData = new AnchorLayoutData(0, 0, footerSize, 0);
	shadow.color = Color.BLACK;
	addChildAt(shadow, 0);
	
	var size:int =  24;*/
	var footerBG:ImageLoader = new ImageLoader();
	//bottomShadow.height = size;
	footerBG.source = Assets.getTexture("home/footer-sliced", "gui");
	footerBG.scale9Grid = new Rectangle(100, 80, 56, 120);
	footerBG.layoutData = new AnchorLayoutData(NaN, 0, 0, 0);
	footerBG.touchable = false;
	addChildAt(footerBG, getChildIndex(tabsList));
	
	tabSelection = new ImageLoader();
	tabSelection.touchable = false;
	tabSelection.source = Assets.getTexture("home/tab", "gui");
	tabSelection.width = tabSize * 1.54;
	tabSelection.maintainAspectRatio = false;
	//tabSelection.height = footerSize;
	tabSelection.layoutData = new AnchorLayoutData(NaN, NaN, 0, NaN);
	addChildAt(tabSelection, getChildIndex(tabsList));
}

override public function gotoPage(pageIndex:int, animDuration:Number = 0.3, scrollPage:Boolean = true):void
{
	super.gotoPage(pageIndex, animDuration, scrollPage);
	Starling.juggler.tween(tabSelection, animDuration, {x:tabPadding + pageIndex * tabSize - tabSize * 0.28, transition:Transitions.EASE_OUT});
}

override public function dispose():void
{
	super.dispose();
}
}
}