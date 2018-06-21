package com.gerantech.towercraft.controls.items
{
import com.gerantech.towercraft.controls.buttons.IndicatorButton;
import com.gerantech.towercraft.controls.overlays.TutorialArrow;
import com.gerantech.towercraft.controls.screens.DashboardScreen;
import com.gerantech.towercraft.controls.texts.RTLLabel;
import com.gerantech.towercraft.controls.texts.ShadowLabel;
import com.gerantech.towercraft.events.GameEvent;
import com.gerantech.towercraft.models.Assets;
import com.gerantech.towercraft.models.vo.TabItemData;
import com.gerantech.towercraft.themes.BaseMetalWorksMobileTheme;
import com.gt.towers.constants.PrefsTypes;

import flash.utils.setTimeout;

import feathers.layout.AnchorLayout;
import feathers.layout.AnchorLayoutData;
import feathers.skins.ImageSkin;

import starling.animation.Transitions;
import starling.core.Starling;
import starling.display.Image;
import starling.events.Event;

public class DashboardTabBaseItemRenderer extends AbstractTouchableListItemRenderer
{
protected var itemWidth:Number;
protected var _firstCommit:Boolean = true;
protected var titleDisplay:ShadowLabel;
protected var iconDisplay:Image;
protected var badgeNumber:IndicatorButton;

protected var padding:int;
protected var dashboardData:TabItemData;
private var tutorialArrow:TutorialArrow;

public function DashboardTabBaseItemRenderer(width:Number)
{
	super();
	layout = new AnchorLayout();
	padding = 36 * appModel.scale;
	itemWidth = width;
}

override protected function commitData():void
{
	if( _firstCommit )
	{
		width = itemWidth;
		height = _owner.height;
		_firstCommit = false;
		
		// show focus in tutorial 
		if ( player.inTutorial() || player.tutorialMode == 1 )
		{
			var tutorStep:int = player.getTutorStep();
			if( index == 0 && player.inShopTutorial() )
			{
				setTimeout(showTutorArrow, 600);		
			}
			else if( index == 1 )
			{
				tutorials.addEventListener("upgrade", tutorialManager_upgradeHandler);
			}
			else if( index == 2 )
			{
				if( player.inDeckTutorial() )
					setTimeout(showTutorArrow, 600);
				else 
					tutorials.addEventListener(GameEvent.TUTORIAL_TASKS_FINISH, tutorialManager_finishHandler);
			}
		}
		appModel.navigator.addEventListener("dashboardTabChanged", navigator_dashboardTabChanged);
	}
	super.commitData();
	dashboardData = _data as TabItemData;
	
	titleFactory();
	iconFactory();
	badgeFactory();
}

protected function iconFactory() : Image 
{
	if( iconDisplay != null )
		return null;

	iconDisplay = new Image(Assets.getTexture("home/tab-" + dashboardData.index, "gui"));
	iconDisplay.alignPivot();
	iconDisplay.x = width * 0.5;
	iconDisplay.y = height * 0.5;
	iconDisplay.pixelSnapping = false;
	iconDisplay.alpha = player.dashboadTabEnabled(index) ? 1 : 0.5;
	addChild(iconDisplay); 
	return iconDisplay;
}

protected function titleFactory() : ShadowLabel
{
	if( titleDisplay != null )
	{
		titleDisplay.text = loc("tab-" + dashboardData.index) ;
		return null;
	}

	titleDisplay = new ShadowLabel(loc("tab-" + dashboardData.index), 1, 0, null, null, false, null, 1.2, null, "bold");
	titleDisplay.visible = false;
	titleDisplay.layoutData = new AnchorLayoutData(NaN, NaN, NaN, NaN, (width - padding * 3) * 0.5, 0);
	addChild(titleDisplay);
	return titleDisplay;
}

protected function badgeFactory() : IndicatorButton
{
	if( dashboardData.badgeNumber <= 0 )
	{
		if( badgeNumber != null )
			badgeNumber.removeFromParent();
		return null;
	}

	if( badgeNumber == null )
	{
		badgeNumber = new IndicatorButton("0", 0.8);
		badgeNumber.width = badgeNumber.height = padding * 1.8;
		badgeNumber.layoutData = new AnchorLayoutData(padding * 0.5, padding * 0.5);
		addChild(badgeNumber);
	}
	badgeNumber.label = String(dashboardData.newBadgeNumber > 0 ? dashboardData.newBadgeNumber : dashboardData.badgeNumber);
	badgeNumber.style = dashboardData.newBadgeNumber > 0 ? "danger" : "normal";
	return null;
}

private function navigator_dashboardTabChanged(event:Event):void
{
	updateSelection(index == DashboardScreen.tabIndex, event.data as Number ); 
}

override protected function setSelection(value:Boolean):void
{
	super.setSelection(value);
	if( value && _owner != null )
		_owner.dispatchEventWith(Event.SELECT, false, data);
	
	if( !player.dashboadTabEnabled(index) && value )
		return;
	
	if( dashboardData != null && value )
	{
		dashboardData.newBadgeNumber = dashboardData.badgeNumber = 0;
		badgeFactory();
	}
	
	if( tutorialArrow != null )
		tutorialArrow.removeFromParent(true);
}

protected function updateSelection(value:Boolean, time:Number = -1):void
{
}

private function tutorialManager_upgradeHandler(event:Event):void
{
	if( index != 1 || stage == null )
		return;
	tutorials.removeEventListener("upgrade", tutorialManager_upgradeHandler);
	showTutorArrow();
}
private function tutorialManager_finishHandler(event:Event):void
{
	if( !player.inDeckTutorial() || event.data.name != "shop_end" || stage == null )
		return;
	tutorials.removeEventListener(GameEvent.TUTORIAL_TASKS_FINISH, tutorialManager_finishHandler);
	showTutorArrow();
}
private function showTutorArrow () : void
{
	if( tutorialArrow != null )
		tutorialArrow.removeFromParent(true);
	
	tutorialArrow = new TutorialArrow(false);
	tutorialArrow.layoutData = new AnchorLayoutData(-tutorialArrow.height, NaN, NaN, NaN, 0);
	addChild(tutorialArrow);
}
}
}