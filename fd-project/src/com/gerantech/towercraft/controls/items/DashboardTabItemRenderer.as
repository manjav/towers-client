package com.gerantech.towercraft.controls.items
{
import com.gerantech.towercraft.controls.buttons.IndicatorButton;
import com.gerantech.towercraft.controls.overlays.TutorialArrow;
import com.gerantech.towercraft.controls.screens.DashboardScreen;
import com.gerantech.towercraft.controls.texts.RTLLabel;
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

public class DashboardTabItemRenderer extends AbstractTouchableListItemRenderer
{
private var itemWidth:Number;
private var _firstCommit:Boolean = true;
private var titleDisplay:RTLLabel;
private var iconDisplay:Image;
private var badgeNumber:IndicatorButton;

private var padding:int;
private var dashboardData:TabItemData;
private var tutorialArrow:TutorialArrow;

public function DashboardTabItemRenderer(width:Number)
{
	super();
	layout = new AnchorLayout();
	padding = 36 * appModel.scale;
	
	skin = new ImageSkin(appModel.theme.tabUpSkinTexture);
	skin.setTextureForState(STATE_NORMAL, appModel.theme.tabUpSkinTexture);
	skin.setTextureForState(STATE_SELECTED, appModel.theme.tabDownSkinTexture);
	skin.setTextureForState(STATE_DOWN, appModel.theme.tabDownSkinTexture);
	skin.scale9Grid = BaseMetalWorksMobileTheme.TAB_SCALE9_GRID;
	backgroundSkin = skin;
	
	titleDisplay = new RTLLabel("", 1, null, null, false, null, 1.2, null, "bold");
	titleDisplay.visible = false;
	titleDisplay.layoutData = new AnchorLayoutData(NaN, NaN, NaN, NaN, (width-padding*3)/2, 0);
	addChild(titleDisplay);
	
	badgeNumber = new IndicatorButton("0", 0.8);
	badgeNumber.width = badgeNumber.height = padding * 1.8;
	badgeNumber.layoutData = new AnchorLayoutData(padding/2, padding/2);
	
	itemWidth = width;
}

override protected function commitData():void
{
	if(_firstCommit)
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
	if( iconDisplay == null )
	{
		iconDisplay = new Image(Assets.getTexture("tab-"+dashboardData.index, "gui"));
		iconDisplay.alignPivot();
		iconDisplay.x = itemWidth * 0.5;
		iconDisplay.y = height * 0.5;
		iconDisplay.scale = appModel.scale * 2;
		iconDisplay.pixelSnapping = false;
		//iconDisplay.width = iconDisplay.height = width - padding * 3;
		//iconDisplay.layoutData = iconLayoutData;
		addChild(iconDisplay); 
	}
	iconDisplay.alpha = player.dashboadTabEnabled(index) ? 1 : 0.5;
	//iconDisplay.source = Assets.getTexture("tab-"+dashboardData.index, "gui");
	titleDisplay.text = loc("tab-"+dashboardData.index) ;
	updateBadge();
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
		updateBadge();
	}
	
	if( tutorialArrow != null )
		tutorialArrow.removeFromParent(true);
}

private function updateBadge():void
{
	if( dashboardData.badgeNumber <= 0 )
	{
		badgeNumber.removeFromParent();
		return;
	}

	badgeNumber.label = String(dashboardData.newBadgeNumber > 0 ? dashboardData.newBadgeNumber : dashboardData.badgeNumber);
	badgeNumber.style = dashboardData.newBadgeNumber > 0 ? "danger" : "normal";
	addChild(badgeNumber);
}

private function updateSelection(value:Boolean, time:Number = -1):void
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
			Starling.juggler.tween(iconDisplay, time==-1?0.5:time, {delay:0.2, scale:appModel.scale*2.6, transition:Transitions.EASE_OUT_BACK});
		else
			iconDisplay.scale = appModel.scale * 1.8;
	}
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