package com.gerantech.towercraft.controls.items
{
	import com.gerantech.towercraft.models.Assets;
	import com.gt.towers.buildings.AbstractBuilding;
	
	import flash.geom.Rectangle;
	
	import feathers.controls.ImageLoader;
	import feathers.controls.Label;
	import feathers.controls.LayoutGroup;
	import feathers.events.FeathersEventType;
	import feathers.layout.AnchorLayout;
	import feathers.layout.AnchorLayoutData;
	import feathers.layout.HorizontalAlign;
	import feathers.layout.TiledRowsLayout;
	import feathers.layout.VerticalLayout;
	import feathers.layout.VerticalLayoutData;
	import feathers.skins.ImageSkin;
	
	import starling.display.Quad;

	public class BuildingItemRenderer extends BaseCustomItemRenderer
	{
		private var container:LayoutGroup;
		private var titleDisplay:Label;
		private var iconDisplay:ImageLoader;
		
		private var _firstCommit:Boolean = true;
		private var _width:Number;
		private var _height:Number;
		
		private var building:AbstractBuilding;
		private var descriptionDisplay:Label;
		
		public function BuildingItemRenderer()
		{
			super();
		}
		
		override protected function initialize():void
		{
			super.initialize();
			backgroundSkin = new Quad(1,1);
			backgroundSkin.visible = false;

			layout = new AnchorLayout();
			
			container = new LayoutGroup();
			addChild(container);
			
			skin = new ImageSkin(Assets.getTexture("building-button", "skin"));
			skin.setTextureForState(STATE_NORMAL, Assets.getTexture("building-button", "skin"));
			skin.setTextureForState(STATE_DOWN, Assets.getTexture("building-button", "skin"));
			skin.setTextureForState(STATE_SELECTED, Assets.getTexture("building-button", "skin"));
			skin.setTextureForState(STATE_DISABLED, Assets.getTexture("building-button-disable", "skin"));
			skin.scale9Grid = new Rectangle(10, 10, 56, 37);
			container.backgroundSkin = skin;

			var vlayout:VerticalLayout = new VerticalLayout();
			vlayout.horizontalAlign = HorizontalAlign.CENTER;
			vlayout.padding = 10;
			container.layout = vlayout;
			
			iconDisplay = new ImageLoader();
			iconDisplay.layoutData = new VerticalLayoutData(100);
			container.addChild(iconDisplay);
			
			var spacer:LayoutGroup = new LayoutGroup();
			spacer.layoutData = new VerticalLayoutData(NaN, 100);
			container.addChild(spacer);
			
			descriptionDisplay = new Label();
			container.addChild(descriptionDisplay);
		}
		
		override protected function commitData():void
		{
			if(_firstCommit)
			{
				width = _width = TiledRowsLayout(_owner.layout).typicalItemWidth;
				height = _height = TiledRowsLayout(_owner.layout).typicalItemHeight;
				container.width = _width;
				container.height = _height;
				container.layoutData = new AnchorLayoutData(NaN, NaN, NaN, NaN, 0, 0);
				_firstCommit = false;
			}
			iconDisplay.source = Assets.getTexture("improve-"+_data, "gui");
			building = player.get_buildingsLevel().get(_data as int);
			
			if(building == null)
			{
				currentState = STATE_DISABLED;
				return;
			}
			//titleDisplay.text = "weapon " + weapon.get_type();
			descriptionDisplay.text = player.get_resources().get(building.type) + "/" + 10;
			super.commitData();
		}
		
		
		/*override public function set currentState(_state:String):void
		{
			if(super.currentState == _state)
				return;

			visible = _state != STATE_SELECTED;
			if(_state != STATE_SELECTED)
				container.scale = _state == STATE_DOWN ? 0.9 : 1;
			else
				owner.dispatchEventWith(FeathersEventType.FOCUS_IN, false, this);
			
			Starling.juggler.removeTweens(container);
			var w:Number = _width;
			var h:Number = _height;
			var t:Number = 0.1;
			if(_state == STATE_DOWN)
			{
				w = _width * 0.9;
				h = _height * 0.9;
			}
			else if(_state == STATE_SELECTED)
			{
				w = _width * 1.4;
				h = _height * 1.6;
				t = 0.3;
			}
			Starling.juggler.tween(container, t, {width:w, height:h, transition:(_state == STATE_SELECTED?Transitions.EASE_OUT_BACK:Transitions.EASE_OUT)});
			super.currentState = _state;
		}*/
		
	}
}