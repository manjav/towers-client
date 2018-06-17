package com.gerantech.towercraft.controls.items
{
import com.gerantech.towercraft.themes.BaseMetalWorksMobileTheme;
import feathers.skins.ImageSkin;
import starling.animation.Transitions;
import starling.core.Starling;

public class DashboardTabLagacyItemRenderer extends DashboardTabBaseItemRenderer
{
public function DashboardTabLagacyItemRenderer(width:Number)
{
	super(width);
	
	skin = new ImageSkin(appModel.theme.tabUpSkinTexture);
	skin.setTextureForState(STATE_NORMAL, appModel.theme.tabUpSkinTexture);
	skin.setTextureForState(STATE_SELECTED, appModel.theme.tabDownSkinTexture);
	skin.setTextureForState(STATE_DOWN, appModel.theme.tabDownSkinTexture);
	skin.scale9Grid = BaseMetalWorksMobileTheme.TAB_SCALE9_GRID;
	backgroundSkin = skin;
}

override protected function commitData():void
{
	super.commitData();
}

override protected function updateSelection(value:Boolean, time:Number = -1):void
{
	if( titleDisplay.visible == value )
		return;
	
	width = itemWidth * (value ? 2 : 1);
	titleDisplay.visible = value;
	
	// icon animation
	if( iconDisplay != null )
	{
		Starling.juggler.removeTweens(iconDisplay);
		iconDisplay.x = itemWidth * (value?0.42:0.5);
		if( value )
			Starling.juggler.tween(iconDisplay, time ==-1?0.5:time, {delay:0.2, scale:appModel.scale * 2.6, transition:Transitions.EASE_OUT_BACK});
		else
			iconDisplay.scale = appModel.scale * 1.8;
	}
}
}
}