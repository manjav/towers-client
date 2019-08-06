package com.gerantech.towercraft.controls.items.challenges
{
import com.gerantech.towercraft.controls.buttons.CustomButton;
import com.gerantech.towercraft.controls.groups.PrizePalette;
import com.gerantech.towercraft.controls.items.AbstractListItemRenderer;
import com.gerantech.towercraft.controls.popups.BookDetailsPopup;
import com.gerantech.towercraft.controls.texts.CountdownLabel;
import com.gerantech.towercraft.controls.texts.RTLLabel;
import com.gerantech.towercraft.controls.texts.ShadowLabel;
import com.gerantech.towercraft.themes.MainTheme;
import com.gt.towers.constants.ResourceType;
import com.gt.towers.exchanges.ExchangeItem;
import com.gt.towers.socials.Challenge;
import feathers.events.FeathersEventType;
import feathers.layout.AnchorLayout;
import feathers.layout.AnchorLayoutData;
import starling.display.Image;
import starling.events.Event;
import starling.textures.Texture;

public class ChallengeListItemRenderer extends AbstractListItemRenderer
{
private var state:int;
public var challenge:Challenge;
private var _firstCommit:Boolean = true;
private var titleDisplay:ShadowLabel;
private var countdownDisplay:CountdownLabel;

public function ChallengeListItemRenderer(){}
override protected function commitData():void
{
	if( _firstCommit )
	{
		layout = new AnchorLayout();
		height = 500;
		_firstCommit = false;
	}
	
	super.commitData();
	
	if( _data == null )
		return;
	
	removeChildren();
	challenge = _data as Challenge;
	state = challenge.getState(timeManager.now);
	
	var skin:Image = new Image(getSkin());
	skin.scale9Grid = MainTheme.ITEM_RENDERER_SCALE9_GRID;
	backgroundSkin = skin;
	
	titleDisplay = new ShadowLabel(loc("challenge_title_" + challenge.type), 1, 0, "center");
	titleDisplay.layoutData = new AnchorLayoutData(20, NaN, NaN, NaN, 0);
	addChild(titleDisplay);
	
	var prizeW:int = width * 0.5 + 20;
	var topPrizePanel:PrizePalette = new PrizePalette(loc("challenge_top_prize"), 0xFFFFFF, challenge.rewards.get(1).minWinStreak);
	topPrizePanel.touchable = true;
	topPrizePanel.addEventListener(Event.TRIGGERED, prizePanel_triggeredHandler);
	topPrizePanel.layoutData = new AnchorLayoutData(140, 20, 160, prizeW);
	addChild(topPrizePanel);
	
	var guaranteedPrizePanel:PrizePalette = new PrizePalette(loc("challenge_guaranteed_prize"), 0xFFFFFF, challenge.rewards.get(challenge.rewards.keys().length).minWinStreak);
	guaranteedPrizePanel.touchable = true;
	guaranteedPrizePanel.addEventListener(Event.TRIGGERED, prizePanel_triggeredHandler);
	guaranteedPrizePanel.layoutData = new AnchorLayoutData(140, prizeW, 160, 20);
	addChild(guaranteedPrizePanel);
	
	if( state < Challenge.STATE_END )
	{
		countdownDisplay = new CountdownLabel();
		countdownDisplay.time = challenge.startAt - timeManager.now + (state == Challenge.STATE_STARTED ? challenge.duration : 0);
		countdownDisplay.localString = state == Challenge.STATE_WAIT ? "challenge_start_at" : "challenge_end_at";
		countdownDisplay.height = 100;
		countdownDisplay.layoutData = new AnchorLayoutData(NaN, 400, 30, 20);
		addChild(countdownDisplay);
		
		timeManager.addEventListener(Event.CHANGE, timeManager_changeHandler);
	}
	else
	{
		var descriptionDisplay:RTLLabel = new RTLLabel(loc("challenge_ended"), 1, "center", null, true, null, 0.8);
		descriptionDisplay.layoutData = new AnchorLayoutData(NaN, 400, 64, 20);
		addChild(descriptionDisplay);
	}
	
	var buttonDisplay:CustomButton = new CustomButton();
	buttonDisplay.style = state == Challenge.STATE_STARTED ? CustomButton.STYLE_NEUTRAL : CustomButton.STYLE_NORMAL;
	buttonDisplay.label = loc(state == Challenge.STATE_WAIT && challenge.indexOfAttendees(player.id) == -1 ? "challenge_start" : "challenge_show");
	buttonDisplay.addEventListener(Event.TRIGGERED, buttonDisplay_triggeredHandler);
	buttonDisplay.width = 360;
	buttonDisplay.height = 120;
	buttonDisplay.layoutData = new AnchorLayoutData(NaN, 20, 20, NaN);
	addChild(buttonDisplay);
}

protected function prizePanel_triggeredHandler(e:Event):void 
{
	var pallete:PrizePalette = e.currentTarget as PrizePalette;
	if( !ResourceType.isBook(pallete.prize) )
		return;
	var item:ExchangeItem = new ExchangeItem(0, 0, 0, null, pallete.prize + ":" + player.get_arena(0));
	appModel.navigator.addPopup(new BookDetailsPopup(item, false));
}

private function getSkin() : Texture 
{
	switch( state )
	{
		case Challenge.STATE_STARTED : return appModel.theme.itemRendererSelectedSkinTexture;
		case Challenge.STATE_END : return appModel.theme.itemRendererDisabledSkinTexture;
	}
	return appModel.theme.itemRendererUpSkinTexture;
}

protected function timeManager_changeHandler(e:Event):void 
{
	var _state:int = challenge.getState(timeManager.now);
	if( state != _state )
	{
		commitData();
		return;
	}
	
	countdownDisplay.time = challenge.startAt - timeManager.now + (state == Challenge.STATE_STARTED ? challenge.duration : 0);
}

protected function buttonDisplay_triggeredHandler(e:Event):void 
{
	_owner.dispatchEventWith(FeathersEventType.FOCUS_IN, false, this);
}
}
}