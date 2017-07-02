package com.gerantech.towercraft.controls.buttons
{
	import com.gerantech.towercraft.models.Assets;
	
	import feathers.controls.ButtonState;
	import feathers.controls.ImageLoader;
	import feathers.layout.AnchorLayout;
	import feathers.layout.AnchorLayoutData;
	import feathers.skins.ImageSkin;
	
	import starling.filters.ColorMatrixFilter;

	public class ImproveButton extends SimpleLayoutButton
	{
		public var type:int;

		private var lockDisplay:ImageLoader;
		private var disableFilter:ColorMatrixFilter;

		private var iconDisplay:ImageLoader;
		
		public function ImproveButton(type:int)
		{
			super();
			this.type = type;name = type.toString()
		}
		
		override protected function initialize():void
		{
			super.initialize();
			layout = new AnchorLayout();
			var padding:int = 8 * appModel.scale;
			var size:int = 128 * appModel.scale;
			
			skin = new ImageSkin(Assets.getTexture("improve-button-up", "gui"));
			skin.setTextureForState(ButtonState.UP, Assets.getTexture("improve-button-up", "gui") );
			skin.setTextureForState(ButtonState.DOWN, Assets.getTexture("improve-button-selected", "gui") );
		//	skin.setTextureForState(ButtonState.DISABLED, Assets.getTexture("improve-button-disabled", "gui") );
			skin.disabledTexture = Assets.getTexture("improve-button-disabled", "gui");
			skin.x = skin.y = -size/2;
			skin.width = skin.height = size;
			//skin.touchable = false;
			//addChild(skin);
			backgroundSkin = skin;
			
			disableFilter = new ColorMatrixFilter();
			disableFilter.adjustSaturation(-0.9);
			//disableFilter.resolution = 0.8;
			
			iconDisplay = new ImageLoader();
			iconDisplay.source = Assets.getTexture("improve-"+type, "gui");
			iconDisplay.width = iconDisplay.height = size-padding*2;
			iconDisplay.x = iconDisplay.y = -size/2+padding;
			iconDisplay.filter = enabled ? null : disableFilter;
			iconDisplay.touchable = false;
			addChild(iconDisplay);
			
			lockDisplay = new ImageLoader();
			lockDisplay.width = lockDisplay.height = size*0.6;
			lockDisplay.x = lockDisplay.y = -size*0.7;
			lockDisplay.source = Assets.getTexture("improve-lock", "gui");
			lockDisplay.visible = !enabled;
			lockDisplay.touchable = false;
			addChild(lockDisplay);
		}
		
		public function set enabled(value:Boolean):void
		{
			isEnabled = value;
			if(isEnabled == value)
				return;
			
			if(lockDisplay)
				lockDisplay.visible = !value;
			//trace("disableFilter", value)
			if(iconDisplay)
				iconDisplay.filter = value ? null : disableFilter;
				
		}
		public function get enabled():Boolean
		{
			return isEnabled;
		}
		
	}
}