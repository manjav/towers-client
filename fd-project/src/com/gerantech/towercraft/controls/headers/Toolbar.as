package com.gerantech.towercraft.controls.headers
{
import com.gerantech.towercraft.Main;
import com.gerantech.towercraft.controls.TowersLayout;
import com.gerantech.towercraft.controls.buttons.Indicator;
import com.gerantech.towercraft.events.LoadingEvent;
import com.gerantech.towercraft.managers.net.LoadingManager;
import com.gerantech.towercraft.models.Assets;
import com.gerantech.towercraft.models.vo.RewardData;
import com.gerantech.towercraft.themes.MainTheme;
import com.gt.towers.constants.ResourceType;
import com.gt.towers.events.CoreEvent;
import feathers.layout.AnchorLayout;
import feathers.layout.AnchorLayoutData;
import flash.utils.Dictionary;
import starling.display.Image;
import starling.events.Event;

public class Toolbar extends TowersLayout
{
public var indicators:Dictionary = new Dictionary();

public function Toolbar(){}
override protected function initialize():void
{
	super.initialize();

	var gradient:Image = new Image(Assets.getTexture("theme/gradeint-top"));
	gradient.scale9Grid = MainTheme.SHADOW_SIDE_SCALE9_GRID;
	gradient.color = 0x1122;
	backgroundSkin = gradient;
	backgroundSkin.touchable = false;
	
	var padding:Number = 36;
	height = padding * 4;
	layout = new AnchorLayout();
	
	indicators[ResourceType.R4_CURRENCY_HARD] = new Indicator("rtl", ResourceType.R4_CURRENCY_HARD);
	indicators[ResourceType.R4_CURRENCY_HARD].addEventListener(Event.SELECT, indicators_selectHandler);
	indicators[ResourceType.R4_CURRENCY_HARD].layoutData = new AnchorLayoutData(NaN, padding, NaN, NaN);
	addChild(indicators[ResourceType.R4_CURRENCY_HARD]);
	
	indicators[ResourceType.R3_CURRENCY_SOFT] = new Indicator("rtl", ResourceType.R3_CURRENCY_SOFT);
	indicators[ResourceType.R3_CURRENCY_SOFT].addEventListener(Event.SELECT, indicators_selectHandler);
	indicators[ResourceType.R3_CURRENCY_SOFT].layoutData = new AnchorLayoutData(NaN, padding * 3 + indicators[ResourceType.R4_CURRENCY_HARD].width, NaN, NaN);
	addChild(indicators[ResourceType.R3_CURRENCY_SOFT]);

	if( appModel.loadingManager.state >= LoadingManager.STATE_LOADED )
		loadingManager_loadedHandler(null);
	else
		appModel.loadingManager.addEventListener(LoadingEvent.LOADED, loadingManager_loadedHandler);
}
protected function loadingManager_loadedHandler(event:LoadingEvent):void
{
	player.resources.addEventListener(CoreEvent.CHANGE, playerResources_changeHandler);
	
	if( stage != null )
		checkIndictorAchievements();
	addEventListener(Event.ADDED_TO_STAGE, addedToStageHandler);
	
	updateIndicators();
}

protected function addedToStageHandler(e:Event):void 
{
	checkIndictorAchievements();
}

public function checkIndictorAchievements():void 
{
	if( appModel.battleFieldView == null || appModel.battleFieldView.battleData == null || appModel.battleFieldView.battleData.outcomes == null )
		return;
	
	var achieved:Array = new Array();
	for ( var i:int = 0; i < appModel.battleFieldView.battleData.outcomes.length; i++ )
	{
		var rd:RewardData = appModel.battleFieldView.battleData.outcomes[i];
		if( indicators.hasOwnProperty(rd.key) && Indicator(indicators[rd.key]).stage != null )
		{
			appModel.navigator.addResourceAnimation(rd.x, rd.y, rd.key, rd.value, 0.1);
			achieved.push(i); 
		}
	}
	
	for each( var a:int in achieved )
		appModel.battleFieldView.battleData.outcomes.removeAt(a);
}

protected function playerResources_changeHandler(event:CoreEvent):void
{
	trace("CoreEvent.CHANGE:", ResourceType.getName(event.key), event.from, event.to);
	updateIndicators();
}
	
protected function indicators_selectHandler(event:Event):void
{
	dispatchEventWith(Event.SELECT, false, event.currentTarget);
}

public function updateIndicators():void
{
	if( appModel.loadingManager.state < LoadingManager.STATE_LOADED )
		return;
	
	for (var k:Object in indicators)
	{
		if( k == ResourceType.R4_CURRENCY_HARD || k == ResourceType.R3_CURRENCY_SOFT )
			indicators[k].y = 18;
		indicators[k].setData(0, player.getResource(k as int), NaN);
		
		if( k == ResourceType.R1_XP )
		{
			if ( appModel.navigator.activeScreenID == Main.QUESTS_SCREEN )
			{
				indicators[k].y = 18;
				addChild(indicators[k]);				
			}
			else
			{
				Indicator(indicators[k]).removeFromParent();
			}
		}
	}
}


override public function dispose():void
{
	appModel.loadingManager.removeEventListener(LoadingEvent.LOADED, loadingManager_loadedHandler);
	player.resources.removeEventListener(CoreEvent.CHANGE, playerResources_changeHandler);
	super.dispose();
}
}
}