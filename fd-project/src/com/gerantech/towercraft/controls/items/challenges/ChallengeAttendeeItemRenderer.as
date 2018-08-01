package com.gerantech.towercraft.controls.items.challenges
{
import com.gerantech.towercraft.controls.items.AbstractTouchableListItemRenderer;
import com.gerantech.towercraft.controls.texts.RTLLabel;
import com.gerantech.towercraft.controls.texts.ShadowLabel;
import com.gerantech.towercraft.models.AppModel;
import com.gerantech.towercraft.models.Assets;
import com.gerantech.towercraft.themes.BaseMetalWorksMobileTheme;
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
public function ChallengeAttendeeItemRenderer(){super();}
private static const DEFAULT_TEXT_COLOR:uint = 0xDDFFFF;
private var nameDisplay:ShadowLabel;
private var pointDisplay:RTLLabel;
private var rewardDisplay:ImageLoader;
private var mySkin:ImageSkin;

override protected function initialize():void
{
	super.initialize();
	
	layout = new AnchorLayout();
	height = 80 * appModel.scale;
	var padding:int = 36 * appModel.scale;
	
	mySkin = new ImageSkin(appModel.theme.itemRendererUpSkinTexture);
	mySkin.scale9Grid = BaseMetalWorksMobileTheme.ITEM_RENDERER_SCALE9_GRID
	backgroundSkin = mySkin;
	
	nameDisplay = new ShadowLabel("", 1, 0, null, null, false, null, 0.8);
	nameDisplay.layoutData = new AnchorLayoutData(NaN, padding*(appModel.isLTR?5:1), NaN,  padding*(appModel.isLTR?1:5), NaN, -padding * 0.1);
	addChild(nameDisplay);
	
	pointDisplay = new RTLLabel("", 1, appModel.isLTR?"right":"left", null, false, null, 0.9);
	pointDisplay.pixelSnapping = false;
	pointDisplay.layoutData = new AnchorLayoutData(NaN, appModel.isLTR?padding * 3.2:NaN, NaN, appModel.isLTR?NaN:padding * 3.2, NaN, 0);
	addChild(pointDisplay);
	
	rewardDisplay = new ImageLoader();
	rewardDisplay.width = 80 * appModel.scale;
	rewardDisplay.layoutData = new AnchorLayoutData(padding * 0.5, appModel.isLTR?padding * 0.5:NaN, padding * 0.5, appModel.isLTR?NaN:padding * 0.5);
	addChild(rewardDisplay);
	
	addEventListener(Event.TRIGGERED, item_triggeredHandler);
}

override protected function commitData():void
{
	super.commitData();
	if( _data == null || _owner == null )
		return;

	var rankIndex:int = index + 1;
	nameDisplay.text = rankIndex + ".  " + _data.name;
	pointDisplay.text = "" + _data.point;
	rewardDisplay.source = Assets.getTexture("arena-"+Math.min(8, player.get_arena(_data.point)), "gui");

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