package com.gerantech.towercraft.controls.items
{
	import com.gerantech.towercraft.models.Assets;
	import com.smartfoxserver.v2.entities.data.SFSObject;
	
	import flash.geom.Rectangle;
	
	import feathers.controls.Label;
	import feathers.controls.text.TextBlockTextRenderer;
	import feathers.core.ITextRenderer;
	import feathers.layout.HorizontalLayout;
	import feathers.layout.HorizontalLayoutData;
	import feathers.skins.ImageSkin;

	public class RankItemRenderer extends BaseCustomItemRenderer
	{
		private var rankData:SFSObject;
		
		private var nameText:Label;
		private var pointText:Label;
		
		override protected function initialize():void
		{
			super.initialize();
			var hlayout:HorizontalLayout = new HorizontalLayout();
		//	hlayout.verticalAlign = VerticalAlign.JUSTIFY;
			hlayout.padding = 10;
			layout = hlayout;
			height = 160 * appModel.scale;
			
			skin = new ImageSkin(Assets.getTexture("building-button", "skin"));
			skin.setTextureForState(STATE_NORMAL, Assets.getTexture("building-button", "skin"));
			skin.setTextureForState(STATE_DOWN, Assets.getTexture("building-button", "skin"));
			skin.setTextureForState(STATE_SELECTED, Assets.getTexture("building-button", "skin"));
			skin.setTextureForState(STATE_DISABLED, Assets.getTexture("building-button-disable", "skin"));
			skin.scale9Grid = new Rectangle(10, 10, 56, 37);
			backgroundSkin = skin;
			
			nameText = new Label();
			nameText.textRendererFactory = function():ITextRenderer
			{
				var txt:TextBlockTextRenderer = new TextBlockTextRenderer();
				txt.bidiLevel = 1;
				txt.textAlign = "right";
				return txt;
			}
			nameText.layoutData = new HorizontalLayoutData(100);
			
			pointText = new Label();

			addChild(pointText);
			addChild(nameText);
		}
		
		
		override protected function commitData():void
		{
			super.commitData();
			if(_data ==null || _owner==null)
				return;
			
			//rankData = _data as Object;
			nameText.text = (index+1) + ". " + _data["n"] ;
			pointText.text = "" + _data["p"];
			
		}
		
	} 
}