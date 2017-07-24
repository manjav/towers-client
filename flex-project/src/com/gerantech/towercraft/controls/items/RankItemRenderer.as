package com.gerantech.towercraft.controls.items
{
	import com.gerantech.towercraft.controls.texts.RTLLabel;
	import com.gerantech.towercraft.models.AppModel;
	import com.gerantech.towercraft.models.Assets;
	import com.gerantech.towercraft.themes.BaseMetalWorksMobileTheme;
	import com.smartfoxserver.v2.entities.data.SFSObject;
	
	import flash.geom.Rectangle;
	import flash.text.engine.ElementFormat;
	
	import feathers.layout.AnchorLayout;
	import feathers.layout.AnchorLayoutData;
	import feathers.skins.ImageSkin;

	public class RankItemRenderer extends BaseCustomItemRenderer
	{
		private static const DEFAULT_TEXT_COLOR:uint = 0xDDFFFF;
		
		private var nameDisplay:RTLLabel;
		private var nameShadowDisplay:RTLLabel;

		private var pointDisplay:RTLLabel;
		
		override protected function initialize():void
		{
			super.initialize();
			
			layout = new AnchorLayout();
			//height = 140 * appModel.scale;
			var padding:int = 36 * appModel.scale;
			
			skin = new ImageSkin(Assets.getTexture("building-button", "skin"));
			skin.setTextureForState(STATE_NORMAL, Assets.getTexture("building-button", "skin"));
			skin.setTextureForState(STATE_DOWN, Assets.getTexture("building-button", "skin"));
			skin.setTextureForState(STATE_SELECTED, Assets.getTexture("building-button", "skin"));
			skin.setTextureForState(STATE_DISABLED, Assets.getTexture("building-button-disable", "skin"));
			skin.scale9Grid = new Rectangle(10, 10, 56, 37);
			backgroundSkin = skin;
			
			nameShadowDisplay = new RTLLabel("", 0, null, null, false, null, 0.8);
			nameShadowDisplay.layoutData = new AnchorLayoutData(NaN, appModel.isLTR?NaN:padding, NaN, appModel.isLTR?padding:NaN, NaN, 0);
			nameShadowDisplay.pixelSnapping = false;
			addChild(nameShadowDisplay);
			
			nameDisplay = new RTLLabel("", DEFAULT_TEXT_COLOR, null, null, false, null, 0.8);
			nameDisplay.pixelSnapping = false;
			nameDisplay.layoutData = new AnchorLayoutData(NaN, appModel.isLTR?NaN:padding, NaN, appModel.isLTR?padding:NaN, NaN, -padding/12);
			addChild(nameDisplay);
			
			pointDisplay = new RTLLabel("", 1, appModel.isLTR?"right":"left", null, false, null, 1);
			pointDisplay.layoutData = new AnchorLayoutData(NaN, appModel.isLTR?padding:NaN, NaN, appModel.isLTR?NaN:padding, NaN, 0);
			addChild(pointDisplay);
		}
		
		override protected function commitData():void
		{
			super.commitData();
			if(_data ==null || _owner==null)
				return;
			
			var isGap:Boolean = _data.n == undefined;
			height = (isGap?60:140) * appModel.scale;

			alpha = isGap ? 0 : 1;
			
			var rankIndex:int = _data.s ? (_data.s+1) : (index+1);
			nameDisplay.text = rankIndex + ".  " + _data.n ;
			nameShadowDisplay.text = rankIndex + ".  " + _data.n ;
			pointDisplay.text = "" + _data.p;
			//trace(_data.i, player.id);
			var fs:int = AppModel.instance.theme.gameFontSize * (_data.i==player.id?1:0.9) * appModel.scale;
			var fc:int = _data.i==player.id?BaseMetalWorksMobileTheme.PRIMARY_TEXT_COLOR:DEFAULT_TEXT_COLOR;
			if( fs != nameDisplay.fontSize )
			{
				nameDisplay.fontSize = fs;
				nameShadowDisplay.fontSize = fs;
				
				nameDisplay.elementFormat = new ElementFormat(nameDisplay.fontDescription, fs, fc);
				nameShadowDisplay.elementFormat = new ElementFormat(nameShadowDisplay.fontDescription, fs, nameShadowDisplay.color);
			}
			currentState = _data.i==player.id ? STATE_NORMAL : STATE_DISABLED;
		}
} 
}