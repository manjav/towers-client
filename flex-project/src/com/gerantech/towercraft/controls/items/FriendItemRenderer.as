package com.gerantech.towercraft.controls.items
{
import com.gerantech.towercraft.controls.texts.RTLLabel;
import com.gerantech.towercraft.models.AppModel;
import com.gerantech.towercraft.models.Assets;
import com.gerantech.towercraft.themes.BaseMetalWorksMobileTheme;

import flash.text.engine.ElementFormat;

import feathers.controls.ImageLoader;
import feathers.events.FeathersEventType;
import feathers.layout.AnchorLayout;
import feathers.layout.AnchorLayoutData;
import feathers.skins.ImageSkin;

import starling.events.Event;

public class FriendItemRenderer extends BaseCustomItemRenderer
{
	private static const DEFAULT_TEXT_COLOR:uint = 0xDDFFFF;
	
	private var nameDisplay:RTLLabel;
	private var nameShadowDisplay:RTLLabel;
	private var pointDisplay:RTLLabel;
	private var pointIconDisplay:ImageLoader;
	private var inviteDisplay:RTLLabel;

	private var _isInviteButton:Boolean;
	private var mySkin:ImageSkin;

	

	override protected function initialize():void
	{
		super.initialize();
		
		layout = new AnchorLayout();
		var padding:int = 36 * appModel.scale;
		
		mySkin = new ImageSkin(appModel.theme.itemRendererUpSkinTexture);
		mySkin.scale9Grid = BaseMetalWorksMobileTheme.ITEM_RENDERER_SCALE9_GRID
		backgroundSkin = mySkin;
		
		nameShadowDisplay = new RTLLabel("", 0, null, null, false, null, 0.8);
		nameShadowDisplay.layoutData = new AnchorLayoutData(NaN, appModel.isLTR?NaN:padding, NaN, appModel.isLTR?padding:NaN, NaN, 0);
		nameShadowDisplay.pixelSnapping = false;
		addChild(nameShadowDisplay);
		
		nameDisplay = new RTLLabel("", DEFAULT_TEXT_COLOR, null, null, false, null, 0.8);
		nameDisplay.pixelSnapping = false;
		nameDisplay.layoutData = new AnchorLayoutData(NaN, appModel.isLTR?NaN:padding, NaN, appModel.isLTR?padding:NaN, NaN, -padding/12);
		addChild(nameDisplay);
		
		pointDisplay = new RTLLabel("", 1, appModel.isLTR?"right":"left", null, false, null, 1);
		pointDisplay.pixelSnapping = false;
		pointDisplay.layoutData = new AnchorLayoutData(NaN, appModel.isLTR?padding*3.2:NaN, NaN, appModel.isLTR?NaN:padding*3.2, NaN, 0);
		addChild(pointDisplay);
		
		pointIconDisplay = new ImageLoader();
		pointIconDisplay.source = Assets.getTexture("res-1001", "gui");
		pointIconDisplay.layoutData = new AnchorLayoutData(padding/3, appModel.isLTR?padding/2:NaN, padding/2, appModel.isLTR?NaN:padding/2);
		addChild(pointIconDisplay);
		
		inviteDisplay = new RTLLabel(loc("invite_friend"), DEFAULT_TEXT_COLOR, "center");
		inviteDisplay.pixelSnapping = false;
		inviteDisplay.layoutData = new AnchorLayoutData(NaN, padding, NaN, padding, NaN, -padding/12);
		addChild(inviteDisplay);
		
		addEventListener(Event.TRIGGERED, item_triggeredHandler);
	}
	
	override protected function commitData():void
	{
		super.commitData();
		if(_data ==null || _owner==null)
			return;
		
		isInviteButton = _data.name == "" && _data.count == -1;
		height = (isInviteButton?160:120) * appModel.scale;
		
		if( isInviteButton )
			return;
		
		var rankIndex:int = _data.s ? (_data.s+1) : (index+1);
		nameDisplay.text = rankIndex + ".  " + _data.name ;
		nameShadowDisplay.text = rankIndex + ".  " + _data.name ;
		pointDisplay.text = "" + _data.count;
		//trace(_data.i, player.id);
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
	
	private function item_triggeredHandler():void
	{
		owner.dispatchEventWith(FeathersEventType.FOCUS_IN, false, this);
	}
	
	public function get isInviteButton():Boolean
	{
		return _isInviteButton;
	}
	public function set isInviteButton(value:Boolean):void
	{
		_isInviteButton = value;

		nameDisplay.visible = !_isInviteButton;
		nameShadowDisplay.visible = !_isInviteButton;
		pointDisplay.visible = !_isInviteButton;
		pointIconDisplay.visible = !_isInviteButton;
		inviteDisplay.visible = _isInviteButton;
		
		if( _isInviteButton )
			mySkin.defaultTexture = _isInviteButton ? appModel.theme.itemRendererSelectedSkinTexture : appModel.theme.itemRendererUpSkinTexture;
	}
} 
}