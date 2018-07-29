package com.gerantech.towercraft.controls.items
{
import com.gerantech.towercraft.controls.buttons.CustomButton;
import com.gerantech.towercraft.controls.groups.Devider;
import com.gerantech.towercraft.controls.groups.LabelGroup;
import com.gerantech.towercraft.controls.groups.PrizePalette;
import com.gerantech.towercraft.controls.texts.CountdownLabel;
import com.gerantech.towercraft.controls.texts.RTLLabel;
import com.gerantech.towercraft.controls.texts.ShadowLabel;
import com.gerantech.towercraft.models.Assets;
import com.gerantech.towercraft.themes.BaseMetalWorksMobileTheme;
import com.gt.towers.socials.Challenge;
import feathers.controls.ImageLoader;
import feathers.controls.List;
import feathers.events.FeathersEventType;
import feathers.layout.AnchorLayout;
import feathers.layout.AnchorLayoutData;
import starling.events.Event;

public class EventsListItemRenderer extends AbstractListItemRenderer
{
public var challenge:Challenge;
private var padding:Number;
private var _firstCommit:Boolean = true;
private var titleDisplay:ShadowLabel;
private var countdownDisplay:CountdownLabel;

public function EventsListItemRenderer(){}
override protected function commitData():void
{
	if( _firstCommit )
	{
		layout = new AnchorLayout();
		padding = 20 * appModel.scale;
		height = padding * 25;
		_firstCommit = false;
	}
	
	super.commitData();
	
	if( _data == null )
		return;
	
	challenge = _data as Challenge;
	var skin:ImageLoader = new ImageLoader();
	skin.source = appModel.theme.itemRendererSelectedSkinTexture;
	skin.scale9Grid = BaseMetalWorksMobileTheme.ITEM_RENDERER_SCALE9_GRID;
	backgroundSkin = skin;
	
	titleDisplay = new ShadowLabel(loc("challenge_title_0"), 1, 0, "center");
	titleDisplay.layoutData = new AnchorLayoutData(padding, NaN, NaN, NaN, 0);
	addChild(titleDisplay);
	
	var prizeW:int = width * 0.5 + padding;
	var topPrizePanel:PrizePalette = new PrizePalette(loc("challenge_top_prize"), 0xFFFFFF, 56);
	topPrizePanel.layoutData = new AnchorLayoutData(padding * 7, padding, padding * 8, prizeW);
	addChild(topPrizePanel);
	
	var guaranteedPrizePanel:PrizePalette = new PrizePalette(loc("challenge_guaranteed_prize"), 0xFFFFFF, 52);
	guaranteedPrizePanel.layoutData = new AnchorLayoutData(padding * 7, prizeW, padding * 8, padding);
	addChild(guaranteedPrizePanel);
	
	countdownDisplay = new CountdownLabel();
	countdownDisplay.time = challenge.startAt - timeManager.now;
	countdownDisplay.localString = "challenge_time_remaining";
	countdownDisplay.height = padding * 5;
	countdownDisplay.layoutData = new AnchorLayoutData(NaN, padding * 20, padding * 1.5, padding, 0);
	addChild(countdownDisplay);
	
	var buttonDisplay:CustomButton = new CustomButton();
	buttonDisplay.label = loc("challenge_start");
	buttonDisplay.addEventListener(Event.TRIGGERED, buttonDisplay_triggeredHandler);
	buttonDisplay.width = padding * 18;
	buttonDisplay.height = padding * 6;
	buttonDisplay.layoutData = new AnchorLayoutData(NaN, padding, padding, NaN);
	addChild(buttonDisplay);
	
	timeManager.addEventListener(Event.CHANGE, timeManager_changeHandler);
}

protected function timeManager_changeHandler(e:Event):void 
{
	countdownDisplay.time = challenge.startAt - timeManager.now;
}

protected function buttonDisplay_triggeredHandler(e:Event):void 
{
	_owner.dispatchEventWith(FeathersEventType.FOCUS_IN, false, this);
}
}
}