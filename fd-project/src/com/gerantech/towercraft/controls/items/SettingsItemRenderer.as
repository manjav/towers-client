package com.gerantech.towercraft.controls.items
{
import com.gerantech.towercraft.controls.groups.Spacer;
import com.gerantech.towercraft.controls.buttons.CustomButton;
import com.gerantech.towercraft.controls.texts.RTLLabel;
import com.gerantech.towercraft.models.Assets;
import com.gerantech.towercraft.models.vo.SettingsData;

import feathers.events.FeathersEventType;
import feathers.layout.AnchorLayoutData;
import feathers.layout.HorizontalLayout;
import feathers.layout.HorizontalLayoutData;
import feathers.layout.VerticalAlign;

import starling.events.Event;

public class SettingsItemRenderer extends AbstractTouchableListItemRenderer
{
private var settingData:SettingsData;

private var nameDisplay:RTLLabel;
private var checkDisplay:RTLLabel;
private var buttonDisplay:CustomButton;

public function SettingsItemRenderer(){}
override protected function initialize():void
{
	super.initialize();
	
	height = 180;
	
	var hlayout:HorizontalLayout = new HorizontalLayout();
	//hlayout.paddingLeft = hlayout.paddingRight = 48;
	hlayout.gap = 32;
	hlayout.verticalAlign = VerticalAlign.MIDDLE;
	layout = hlayout;
}

override protected function commitData():void
{
	super.commitData();
	
	if(_data == null)
		return;

	removeChildren();
	settingData = _data as SettingsData;
	settingData.index = index;
	
	if( settingData.type == SettingsData.TYPE_TOGGLE )
	{
		nameDisplay = new RTLLabel(loc("setting_label_"+settingData.key), 1, null, null, false, null, 1.2);
		nameDisplay.layoutData = new HorizontalLayoutData(100);
		addChild(nameDisplay);
	}

	if( settingData.type == SettingsData.TYPE_ICON_BUTTONS )
	{
		if( !appModel.isLTR )
			addChild(new Spacer(false));
		addIconButton(SettingsData.SOCIAL_TELEGRAM);
		addIconButton(SettingsData.SOCIAL_INSTAGRAM);
		//addIconButton(SettingsData.SOCIAL_FACEBOOOK);
		//addIconButton(SettingsData.SOCIAL_YOUTUBE);
		addIconButton(SettingsData.RATING);
	}
	else if( settingData.type == SettingsData.TYPE_LABEL_BUTTONS )
	{
		addLabelButton(SettingsData.BUG_REPORT);
		addLabelButton(SettingsData.QUESTIONS);
	}
	else
	{
		buttonDisplay = new CustomButton();
		buttonDisplay.iconLayout = new AnchorLayoutData(NaN, NaN, NaN, NaN, 0, -3);
		buttonDisplay.width = 140;
		if( settingData.type == SettingsData.TYPE_BUTTON )
			buttonDisplay.label = loc("setting_label_"+settingData.key);
		else
		{
			buttonDisplay.icon = Assets.getTexture("settings-"+settingData.key, "gui");
			buttonDisplay.style = settingData.value ? "normal" : "danger"; 
		}
		
		buttonDisplay.layoutData = new HorizontalLayoutData(settingData.type == SettingsData.TYPE_BUTTON ? 100 : NaN, 100);
		buttonDisplay.addEventListener(Event.TRIGGERED, buttons_triggeredHandler);
		addChild(buttonDisplay);
	}
}

private function addLabelButton(type:int):void
{
	var btn:CustomButton = new CustomButton();
	btn.data = type;
	btn.icon = Assets.getTexture("settings-"+type, "gui");
	btn.label = loc("setting_label_"+type);
	btn.layoutData = new HorizontalLayoutData(100);
	btn.addEventListener(Event.TRIGGERED, buttons_triggeredHandler);
	addChild(btn);
}

private function addIconButton(type:int):void
{
	var btn:CustomButton = new CustomButton();
	btn.data = type;
	btn.icon = Assets.getTexture("settings-"+type, "gui");
	btn.iconLayout = new AnchorLayoutData(NaN, NaN, NaN, NaN, 0, -4);
	btn.width = 160;
	btn.addEventListener(Event.TRIGGERED, buttons_triggeredHandler);
	addChild(btn);
}

private function buttons_triggeredHandler(event:Event):void
{
	if( settingData.type == SettingsData.TYPE_TOGGLE )
		settingData.value = !settingData.value;
	else 
		settingData.value = CustomButton(event.currentTarget).data;
	
	_owner.dispatchEventWith(FeathersEventType.FOCUS_IN, false, settingData);
}
}
}