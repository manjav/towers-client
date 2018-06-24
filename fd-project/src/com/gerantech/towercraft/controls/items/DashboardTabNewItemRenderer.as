package com.gerantech.towercraft.controls.items
{
import com.gerantech.towercraft.controls.texts.ShadowLabel;
import com.gerantech.towercraft.themes.BaseMetalWorksMobileTheme;
import feathers.layout.AnchorLayout;
import feathers.layout.AnchorLayoutData;
import feathers.skins.ImageSkin;
import starling.animation.Transitions;
import starling.core.Starling;
import starling.display.Image;

public class DashboardTabNewItemRenderer extends DashboardTabBaseItemRenderer
{
public function DashboardTabNewItemRenderer(width:Number){super(width);}
override protected function titleFactory() : ShadowLabel
{
	if( titleDisplay != null )
	{
		titleDisplay.text = loc("tab-" + dashboardData.index) ;
		return null;
	}

	titleDisplay = new ShadowLabel(loc("tab-" + dashboardData.index), 0xf6cb95, 0, null, null, false, null, 0.8, null, "bold");
	titleDisplay.visible = false;
	titleDisplay.layoutData = new AnchorLayoutData(NaN, NaN, NaN, NaN, 0, padding * 1.3);
	addChild(titleDisplay);
	return titleDisplay;
}

override protected function iconFactory() : Image 
{
	var ret:Image = super.iconFactory();
//	if( ret )
//		ret.scale = appModel.scale * 1.7;
	return ret;
}

override protected function updateSelection(value:Boolean, time:Number = -1):void
{
	if( titleDisplay.visible == value )
		return;
	
	//width = itemWidth * (value ? 2 : 1);
	titleDisplay.visible = value;
	
	// icon animation
	if( iconDisplay != null )
	{
		Starling.juggler.removeTweens(iconDisplay);
		
		if( value )
		{
			titleDisplay.alpha = 0;
			Starling.juggler.tween(titleDisplay, time, {alpha:1});
			Starling.juggler.tween(iconDisplay, time ==-1?0.5:time, {delay:0.2, y:height * 0.25, transition:Transitions.EASE_OUT_BACK});
		}
		else
		{
			iconDisplay.y = height * 0.5;
		}
	}
}
}
}