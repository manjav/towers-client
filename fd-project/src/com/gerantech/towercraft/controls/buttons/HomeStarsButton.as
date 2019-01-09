package com.gerantech.towercraft.controls.buttons 
{
import com.gerantech.towercraft.controls.sliders.BuildingSlider;
import com.gerantech.towercraft.controls.texts.ShadowLabel;
import com.gerantech.towercraft.models.vo.RewardData;
import com.gt.towers.constants.ExchangeType;
import com.gt.towers.constants.ResourceType;
import com.gt.towers.events.CoreEvent;
import com.gt.towers.exchanges.ExchangeItem;
import feathers.controls.ImageLoader;
import feathers.events.FeathersEventType;
import feathers.layout.AnchorLayoutData;
import flash.events.Event;
import flash.utils.Dictionary;
import flash.utils.clearTimeout;
import flash.utils.setTimeout;

/**
* ...
* @author Mansour Djawadi
*/
public class HomeStarsButton extends HomeHeaderButton 
{
public function HomeStarsButton(){ super(); }

override public function update() : void
{
	reset();
	
	exchange = exchanger.items.get(ExchangeType.C104_STARS);
	if( exchange == null )
		return;
	state = exchange.getState(timeManager.now);

	backgroundFactory();
	iconFactory("gift");
	titleFactory(loc(state == ExchangeItem.CHEST_STATE_BUSY ? "nextin_label" : (state == ExchangeItem.CHEST_STATE_WAIT ? "toopen_label" : "open_label")));
	countdownFactory();
	sliderFactory();

	if( state == ExchangeItem.CHEST_STATE_BUSY )
	{
		timeManager.addEventListener(Event.CHANGE, timeManager_changeHandler);
		timeManager_changeHandler(null);
	}
	exchangeManager.addEventListener(FeathersEventType.END_INTERACTION, exchangeManager_endInteractionHandler);
}

override protected function titleFactory(text:String) : ShadowLabel
{
	titleDisplay = new ShadowLabel(text, 1, 0, "center", null, false, null, state == ExchangeItem.CHEST_STATE_READY ? 0.9 : 0.7);
	titleDisplay.touchable = false;
	titleDisplay.shadowDistance = appModel.theme.gameFontSize * 0.05;
	titleDisplay.layoutData = new AnchorLayoutData(NaN, NaN, NaN, NaN, -54, state == ExchangeItem.CHEST_STATE_READY ? -10 : -44);
	addChild(titleDisplay);
	return titleDisplay;
}

protected function sliderFactory() : Indicator 
{
	if ( state != ExchangeItem.CHEST_STATE_WAIT )
	{
		appModel.navigator.addEventListener("achieveResource", navigator_achieveResourceHandler);
		return null;
	}
		
	var ind_17:Indicator = new Indicator("ltr", ResourceType.STARS, true, false);
	ind_17.setData(0, -1, 10);
	ind_17.height = 50;
	ind_17.layoutData = new AnchorLayoutData(NaN, 180, 50, 80);
	ind_17.formatLabelFactory = function(minimum:Number, value:Number, maximum:Number) : String
	{
		return value + " / " + maximum;
	}
	ind_17.addEventListener(FeathersEventType.CREATION_COMPLETE, function() : void
	{
		var icon:ImageLoader = ind_17.iconDisplay;
		icon.width = icon.height = 100;
		AnchorLayoutData(icon.layoutData).verticalCenter = -12;
		AnchorLayoutData(icon.layoutData).left = -60;
	});
	addChild(ind_17);
	return ind_17;
}

// remove key achieve item when indicator is not exists
protected function navigator_achieveResourceHandler(event:Event) : void 
{
	if( appModel.battleFieldView == null || appModel.battleFieldView.battleData == null || appModel.battleFieldView.battleData.outcomes == null )
		return;
	for( var i:int = 0; i < appModel.battleFieldView.battleData.outcomes.length; i++ )
	{
		var rd:RewardData = appModel.battleFieldView.battleData.outcomes[i];
		if( rd.key == ResourceType.STARS )
		{
			appModel.battleFieldView.battleData.outcomes.removeAt(i);
			return;
		}
	}
}

override public function dispose() : void
{
	appModel.navigator.removeEventListener("achieveResource", navigator_achieveResourceHandler);
	super.dispose();
}
}
}