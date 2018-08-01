package com.gerantech.towercraft.controls.items.challenges
{
import com.gerantech.towercraft.controls.items.AbstractTouchableListItemRenderer;
import com.gerantech.towercraft.controls.texts.RTLLabel;
import com.gerantech.towercraft.controls.texts.ShadowLabel;
import com.gerantech.towercraft.models.AppModel;
import com.gerantech.towercraft.models.Assets;
import com.gerantech.towercraft.themes.BaseMetalWorksMobileTheme;
import com.gerantech.towercraft.utils.StrUtils;
import com.gt.towers.socials.Attendee;
import com.gt.towers.socials.Challenge;
import feathers.controls.ImageLoader;
import feathers.events.FeathersEventType;
import feathers.layout.AnchorLayout;
import feathers.layout.AnchorLayoutData;
import feathers.layout.TiledRowsLayout;
import feathers.skins.ImageSkin;
import flash.text.engine.ElementFormat;
import starling.events.Event;
import starling.events.Touch;

public class ChallengeAttendeeItemRenderer extends AbstractTouchableListItemRenderer
{
public function ChallengeAttendeeItemRenderer(challenge:Challenge){ super(); this.challenge = challenge; }
private static const DEFAULT_TEXT_COLOR:uint = 0xDDFFFF;
private var challenge:Challenge;
private var nameDisplay:ShadowLabel;
private var pointDisplay:RTLLabel;
private var rewardDisplay:ImageLoader;
private var mySkin:ImageSkin;

override protected function initialize():void
{
	super.initialize();
	
	layout = new AnchorLayout();
	height = 80 * appModel.scale;
	
	mySkin = new ImageSkin(appModel.theme.itemRendererUpSkinTexture);
	mySkin.scale9Grid = BaseMetalWorksMobileTheme.ITEM_RENDERER_SCALE9_GRID
	backgroundSkin = mySkin;
	
	nameDisplay = new ShadowLabel("", 1, 0, null, null, false, null, 0.8);
	nameDisplay.layoutData = new AnchorLayoutData(NaN, appModel.isLTR?150:20, NaN, appModel.isLTR?20:150, NaN, -2);
	addChild(nameDisplay);
	
	pointDisplay = new RTLLabel("", 1, "center", null, false, "center", 0.8);
	pointDisplay.width = 120;
	pointDisplay.pixelSnapping = false;
	pointDisplay.layoutData = new AnchorLayoutData(NaN, appModel.isLTR?100:NaN, NaN, appModel.isLTR?NaN:100, NaN, -2);
	addChild(pointDisplay);
	
	rewardDisplay = new ImageLoader();
	rewardDisplay.layoutData = new AnchorLayoutData(-20, appModel.isLTR?-20:NaN, -20, appModel.isLTR?NaN:-20);
	addChild(rewardDisplay);
	
	addEventListener(Event.TRIGGERED, item_triggeredHandler);
}

override protected function commitData():void
{
	super.commitData();
	if( _data == null || _owner == null )
		return;

	width = (stageWidth - TiledRowsLayout(owner.layout).gap * 3) * 0.5;
	var attendee:Attendee = _data as Attendee
	var rankIndex:int = index + 1;
	nameDisplay.text = rankIndex + ".   " + attendee.name;
	pointDisplay.text = "" + attendee.point;
	rewardDisplay.source = Assets.getTexture("books/" + challenge.getReward(rankIndex), "gui");

	/*var fs:int = AppModel.instance.theme.gameFontSize * (_data.id == player.id?1:0.9) * appModel.scale;
	var fc:int = _data.id == player.id?BaseMetalWorksMobileTheme.PRIMARY_TEXT_COLOR:DEFAULT_TEXT_COLOR;
	if( fs != nameDisplay.fontSize )
	{
		nameDisplay.fontSize = fs;
		nameDisplay.elementFormat = new ElementFormat(nameDisplay.fontDescription, fs, fc);
	}*/
	mySkin.defaultTexture = _data.id == player.id ? appModel.theme.itemRendererSelectedSkinTexture : appModel.theme.itemRendererUpSkinTexture;
}
protected function item_triggeredHandler(event:Event):void
{
	owner.dispatchEventWith(FeathersEventType.FOCUS_IN, false, this);
}
}
}