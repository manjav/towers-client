package com.gerantech.towercraft.controls.items.lobby
{
import com.gerantech.towercraft.controls.items.AbstractTouchableListItemRenderer;
import com.gerantech.towercraft.controls.texts.RTLLabel;
import com.gerantech.towercraft.models.AppModel;
import com.gerantech.towercraft.models.Assets;
import com.gerantech.towercraft.themes.BaseMetalWorksMobileTheme;
import feathers.controls.ImageLoader;
import feathers.events.FeathersEventType;
import feathers.layout.AnchorLayout;
import feathers.layout.AnchorLayoutData;
import feathers.skins.ImageSkin;
import flash.text.engine.ElementFormat;
import starling.events.Event;
import starling.events.Touch;

public class LobbyMemberItemRenderer extends AbstractTouchableListItemRenderer
{
public function LobbyMemberItemRenderer(){ super(); }
private static const DEFAULT_TEXT_COLOR:uint = 0xDDFFFF;
private var nameDisplay:RTLLabel;
private var nameShadowDisplay:RTLLabel;
private var pointDisplay:RTLLabel;
private var pointIconDisplay:ImageLoader;
private var mySkin:ImageSkin;
private var roleDisplay:RTLLabel;
private var activityDisplay:RTLLabel;

override protected function initialize():void
{
	super.initialize();
	
	layout = new AnchorLayout();
	height = 120;
	var padding:int = 36;
	
	mySkin = new ImageSkin(appModel.theme.itemRendererUpSkinTexture);
	mySkin.scale9Grid = BaseMetalWorksMobileTheme.ITEM_RENDERER_SCALE9_GRID
	backgroundSkin = mySkin;
	
	nameShadowDisplay = new RTLLabel("", 0, null, null, false, null, 0.8);
	nameShadowDisplay.layoutData = new AnchorLayoutData(NaN, appModel.isLTR?NaN:padding, NaN, appModel.isLTR?padding:NaN, NaN, -padding*0.6);
	nameShadowDisplay.pixelSnapping = false;
	addChild(nameShadowDisplay);
	
	nameDisplay = new RTLLabel("", DEFAULT_TEXT_COLOR, null, null, false, null, 0.8);
	nameDisplay.pixelSnapping = false;
	nameDisplay.layoutData = new AnchorLayoutData(NaN, appModel.isLTR?NaN:padding, NaN, appModel.isLTR?padding:NaN, NaN, -padding*0.7);
	addChild(nameDisplay);
	
	roleDisplay = new RTLLabel("", 0, null, null, false, null, 0.7);
	roleDisplay.pixelSnapping = false;
	roleDisplay.layoutData = new AnchorLayoutData(NaN, appModel.isLTR?NaN:padding, NaN, appModel.isLTR?padding:NaN, NaN, padding*0.5);
	addChild(roleDisplay);
	
	activityDisplay = new RTLLabel("", 1, "center", null, false, null, 0.9);
	activityDisplay.width = padding * 3
	activityDisplay.pixelSnapping = false;
	activityDisplay.layoutData = new AnchorLayoutData(NaN, appModel.isLTR?padding * 7:NaN, NaN, appModel.isLTR?NaN:padding * 7, NaN, 0);
	addChild(activityDisplay);
	
	pointDisplay = new RTLLabel("", 1, appModel.isLTR?"right":"left", null, false, null, 0.9);
	pointDisplay.pixelSnapping = false;
	pointDisplay.layoutData = new AnchorLayoutData(NaN, appModel.isLTR?padding*3.2:NaN, NaN, appModel.isLTR?NaN:padding*3.2, NaN, 0);
	addChild(pointDisplay);
	
	pointIconDisplay = new ImageLoader();
	pointIconDisplay.width = 80 * appModel.scale;
	pointIconDisplay.layoutData = new AnchorLayoutData(padding/2, appModel.isLTR?padding/2:NaN, padding/2, appModel.isLTR?NaN:padding/2);
	addChild(pointIconDisplay);
	
	addEventListener(Event.TRIGGERED, item_triggeredHandler);
}

override protected function commitData():void
{
	super.commitData();
	if(_data ==null || _owner==null)
		return;
	
	var rankIndex:int = index+1;
	nameDisplay.text = rankIndex + ".  " + _data.name ;
	nameShadowDisplay.text = rankIndex + ".  " + _data.name ;
	roleDisplay.text = loc("lobby_role_"+_data.permission);
	activityDisplay.text = "" + _data.activity;
	pointDisplay.text = "" + _data.point;
	pointIconDisplay.source = Assets.getTexture("arena-"+Math.min(8, player.get_arena(_data.point)), "gui");

	var fs:int = AppModel.instance.theme.gameFontSize * (_data.id==player.id?1:0.9) * appModel.scale;
	var fc:int = _data.id==player.id?BaseMetalWorksMobileTheme.PRIMARY_TEXT_COLOR:DEFAULT_TEXT_COLOR;
	if( fs != nameDisplay.fontSize )
	{
		nameDisplay.fontSize = fs;
		nameShadowDisplay.fontSize = fs;
		
		nameDisplay.elementFormat = new ElementFormat(nameDisplay.fontDescription, fs, fc);
		nameShadowDisplay.elementFormat = new ElementFormat(nameShadowDisplay.fontDescription, fs, nameShadowDisplay.color);
	}
	mySkin.defaultTexture = _data.id==player.id ? appModel.theme.itemRendererSelectedSkinTexture : appModel.theme.itemRendererUpSkinTexture;
}
protected function item_triggeredHandler(event:Event):void
{
	owner.dispatchEventWith(FeathersEventType.FOCUS_IN, false, this);
}
public function getTouch():Touch
{
	return touch;
}
}
}