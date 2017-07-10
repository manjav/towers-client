package com.gerantech.towercraft.controls.items
{
	import com.gerantech.towercraft.controls.texts.RTLLabel;
	import com.gerantech.towercraft.models.AppModel;
	import com.gerantech.towercraft.models.Assets;
	import com.smartfoxserver.v2.entities.data.SFSObject;
	
	import flash.geom.Rectangle;
	import flash.text.engine.ElementFormat;
	import flash.text.engine.FontDescription;
	import flash.text.engine.FontLookup;
	
	import feathers.controls.Label;
	import feathers.controls.text.TextBlockTextRenderer;
	import feathers.core.ITextRenderer;
	import feathers.layout.HorizontalLayout;
	import feathers.layout.HorizontalLayoutData;
	import feathers.layout.VerticalAlign;
	import feathers.skins.ImageSkin;

	public class RankItemRenderer extends BaseCustomItemRenderer
	{
		private var rankData:SFSObject;
		
		private var nameText:RTLLabel;
		private var pointText:RTLLabel;
		
		override protected function initialize():void
		{
			super.initialize();
			var hlayout:HorizontalLayout = new HorizontalLayout();
			hlayout.verticalAlign = VerticalAlign.MIDDLE;
			hlayout.paddingRight = hlayout.paddingLeft = 32*appModel.scale;
			layout = hlayout;
			height = 160 * appModel.scale;
			
			skin = new ImageSkin(Assets.getTexture("building-button", "skin"));
			skin.setTextureForState(STATE_NORMAL, Assets.getTexture("building-button", "skin"));
			skin.setTextureForState(STATE_DOWN, Assets.getTexture("building-button", "skin"));
			skin.setTextureForState(STATE_SELECTED, Assets.getTexture("building-button", "skin"));
			skin.setTextureForState(STATE_DISABLED, Assets.getTexture("building-button-disable", "skin"));
			skin.scale9Grid = new Rectangle(10, 10, 56, 37);
			backgroundSkin = skin;
			
			nameText = new RTLLabel("");
			nameText.height = height * 0.9;
			nameText.layoutData = new HorizontalLayoutData(100);
			
			pointText = new RTLLabel("");
			pointText.height = height * 0.9;

			addChild(!appModel.isLTR ? pointText : nameText);
			addChild(appModel.isLTR ? pointText : nameText);
		}
		
		
		override protected function commitData():void
		{
			super.commitData();
			if(_data ==null || _owner==null)
				return;
			
			nameText.text = (index+1) + ". " + _data.n ;
			pointText.text = "" + _data.p;
			//trace(_data.i, player.id);
			var fs:Number = AppModel.instance.theme.regularFontSize * (_data.i==player.id?1:1.2);
			if( fs != nameText.fontSize )
			{
				nameText.fontSize = fs;
				nameText.elementFormat = new ElementFormat(nameText.fontDescription, fs, nameText.color);
			}
		}
} 
}