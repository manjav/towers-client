package com.gerantech.towercraft.controls.screens
{
import com.gerantech.towercraft.controls.items.DashboardTabLagacyItemRenderer;
import com.gerantech.towercraft.models.Assets;
import com.gerantech.towercraft.themes.MainTheme;
import feathers.controls.AutoSizeMode;
import feathers.controls.ImageLoader;
import feathers.controls.List;
import feathers.controls.renderers.IListItemRenderer;
import feathers.data.ListCollection;
import feathers.layout.AnchorLayout;
import feathers.layout.AnchorLayoutData;
import flash.geom.Rectangle;
import starling.animation.Transitions;
import starling.core.Starling;
import starling.display.Image;
import starling.events.Event;
import starling.utils.Color;

public class DashboardLagacyScreen extends DashboardScreen
{
private var tabBorder:ImageLoader;
public function DashboardLagacyScreen(){}
override protected function initialize():void { super.initialize(); }
override protected function addedToStageHandler(event:Event):void
{
	super.addedToStageHandler(event);
	
	tabsList.itemRendererFactory = function ():IListItemRenderer { return new DashboardTabLagacyItemRenderer(tabSize); }
	
	var tiledBG:Image = new Image(Assets.getTexture("home/main-map-tile", "gui"));
	tiledBG.tileGrid = new Rectangle(1, 1, 128, 128);
	backgroundSkin = tiledBG;
	
	var shadow:ImageLoader = new ImageLoader();
	shadow.source = Assets.getTexture("bg-shadow", "gui");
	shadow.maintainAspectRatio = false
	shadow.layoutData = new AnchorLayoutData(0, 0, footerSize, 0);
	shadow.color = Color.BLACK;
	addChildAt(shadow, 0);
	
	var size:int =  24 * appModel.scale;
	var bottomShadow:ImageLoader = new ImageLoader();
	bottomShadow.alpha = 0.7;
	bottomShadow.height = size;
	bottomShadow.source = Assets.getTexture("theme/gradeint-bottom", "gui");
	bottomShadow.scale9Grid = MainTheme.SHADOW_SIDE_SCALE9_GRID;
	bottomShadow.color = Color.BLACK;
	bottomShadow.layoutData = new AnchorLayoutData(NaN, -size, footerSize, -size);
	bottomShadow.touchable = false;
	addChildAt(bottomShadow, getChildIndex(tabsList) - 1);
	
	tabBorder = new ImageLoader();
	tabBorder.touchable = false;
	tabBorder.source = Assets.getTexture("theme/tab-selected-border", "gui");
	tabBorder.width = tabSize * 2;
	tabBorder.height = footerSize;
	tabBorder.layoutData = new AnchorLayoutData(NaN, NaN, 0, NaN);
	tabBorder.scale9Grid = new Rectangle(22, 20, 4, 4);
	addChild(tabBorder);
}

override public function gotoPage(pageIndex:int, animDuration:Number = 0.3, scrollPage:Boolean = true):void
{
	super.gotoPage(pageIndex, animDuration, scrollPage);
	Starling.juggler.tween(tabBorder, animDuration, {x:pageIndex * tabSize, transition:Transitions.EASE_OUT});
}

override public function dispose():void
{
	super.dispose();
}
}
}