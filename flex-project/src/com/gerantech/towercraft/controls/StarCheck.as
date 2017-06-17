package com.gerantech.towercraft.controls
{
	import com.gerantech.towercraft.models.Assets;
	
	import feathers.controls.ButtonState;
	import feathers.controls.LayoutGroup;
	import feathers.skins.ImageSkin;
	
	public class StarCheck extends LayoutGroup
	{

		private var skin:ImageSkin;

		override protected function initialize():void
		{
			super.initialize();
			
			skin = new ImageSkin(null);
			skin.setTextureForState(ButtonState.UP, Assets.getTexture("star", "gui"));
			skin.setTextureForState(ButtonState.DISABLED, Assets.getTexture("star-off", "gui"));

			backgroundSkin = skin;
		}
		
		override public function set isEnabled(value:Boolean):void
		{
			super.isEnabled = value;
			skin.defaultTexture = skin.getTextureForState(value ? ButtonState.UP : ButtonState.DISABLED );
			
		}
		
		
		
	}
}