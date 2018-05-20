package com.gerantech.towercraft.controls.items.exchange
{
import com.gerantech.towercraft.controls.items.AbstractTouchableListItemRenderer;
import com.gerantech.towercraft.themes.BaseMetalWorksMobileTheme;
import com.gt.towers.exchanges.ExchangeItem;
import feathers.layout.AnchorLayout;
import feathers.layout.TiledRowsLayout;
import feathers.skins.ImageSkin;
import flash.geom.Rectangle;
import starling.events.Event;

public class ExchangeBaseItemRenderer extends AbstractTouchableListItemRenderer
{
protected var firstCommit:Boolean = true;
protected var exchange:ExchangeItem;
protected var padding:int;

public function ExchangeBaseItemRenderer(){super();}
override protected function initialize():void
{
	super.initialize();
	
	layout = new AnchorLayout();
	padding = 12 * appModel.scale;
	
	skin = new ImageSkin(appModel.theme.itemRendererDisabledSkinTexture);
	skin.setTextureForState(STATE_NORMAL, appModel.theme.itemRendererDisabledSkinTexture);
	skin.setTextureForState(STATE_DOWN, appModel.theme.itemRendererSelectedSkinTexture);
	skin.setTextureForState(STATE_SELECTED, appModel.theme.itemRendererSelectedSkinTexture);
	skin.scale9Grid = BaseMetalWorksMobileTheme.ITEM_RENDERER_SCALE9_GRID;
	skin.alpha = 0.5;
	backgroundSkin = skin;
}
override protected function commitData():void
{
	if( firstCommit )
	{
		width = TiledRowsLayout(_owner.layout).typicalItemWidth;
		height = TiledRowsLayout(_owner.layout).typicalItemHeight;
		exchangeManager.addEventListener(Event.COMPLETE, exchangeManager_completeHandler);
		firstCommit = false;
	}
	exchange = exchanger.items.get(_data as int);

	super.commitData();
}

protected function exchangeManager_completeHandler(event:Event):void 
{
	var item:ExchangeItem = event.data as ExchangeItem;
	if( item.type != exchange.type )
		return;
	removeChildren();
	commitData();
	showAchieveAnimation(item);
}

protected function showAchieveAnimation(item:ExchangeItem):void 
{
	var outs:Vector.<int> = item.outcomes.keys();
	var rect:Rectangle = getBounds(stage);
	for ( var i:int = 0; i < outs.length; i++ )
		appModel.navigator.addResourceAnimation(rect.x + rect.width * 0.5, rect.y + rect.height * 0.5, outs[i], item.outcomes.get(outs[i]), i * 0.3 + 0.1);
}

override public function dispose() : void
{
	if( exchangeManager != null )
		exchangeManager.removeEventListener(Event.COMPLETE, exchangeManager_completeHandler);
	super.dispose();
}
}
}