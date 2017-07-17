package com.gerantech.towercraft.controls.items
{
	import com.gerantech.towercraft.controls.BuildingCard;
	import com.gerantech.towercraft.models.Assets;
	import com.gt.towers.buildings.Building;
	
	import flash.geom.Rectangle;
	
	import feathers.controls.LayoutGroup;
	import feathers.events.FeathersEventType;
	import feathers.layout.AnchorLayout;
	import feathers.layout.AnchorLayoutData;
	import feathers.layout.HorizontalLayout;
	import feathers.layout.TiledRowsLayout;
	import feathers.skins.ImageSkin;
	
	import starling.animation.Transitions;
	import starling.core.Starling;
	import starling.display.Quad;

	public class BuildingItemRenderer extends BaseCustomItemRenderer
	{
		private var building:Building;
		
		private var _firstCommit:Boolean = true;
		private var _width:Number;
		private var _height:Number;
		
		private var container:LayoutGroup;
		private var cardDisplay:BuildingCard;
		private var inDeck:Boolean;
		
		public function BuildingItemRenderer(inDeck:Boolean=true)
		{
			super();
			this.inDeck = inDeck;
		}
		
		override protected function initialize():void
		{
			super.initialize();
			backgroundSkin = new Quad(1,1);
			backgroundSkin.visible = false;

			layout = new AnchorLayout();
			
			container = new LayoutGroup();
			addChild(container);

			container.layout = new AnchorLayout();
			
			cardDisplay = new BuildingCard();
			cardDisplay.showSlider = inDeck;
			cardDisplay.layoutData = new AnchorLayoutData(0,0,0,0);
			container.addChild(cardDisplay);
		}
		
		override protected function commitData():void
		{
			if(_firstCommit)
			{
				if(_owner.layout is HorizontalLayout)
				{
					width = _width = HorizontalLayout(_owner.layout).typicalItemWidth;
					height = _height = HorizontalLayout(_owner.layout).typicalItemHeight;
				}
				else if(_owner.layout is TiledRowsLayout)
				{
					width = _width = TiledRowsLayout(_owner.layout).typicalItemWidth;
					height = _height = TiledRowsLayout(_owner.layout).typicalItemHeight;
				}
				container.width = _width;
				container.height = _height;
				//container.layoutData = new AnchorLayoutData(NaN, NaN, NaN, NaN, 0, 0);
				_firstCommit = false;
			}
			/*building = player.buildings.get(_data as int);
			
			if(building == null)
				currentState = STATE_DISABLED;
			
			cardDisplay.upgradable = currentState != STATE_DISABLED;
			if(currentState != STATE_DISABLED)*/
				cardDisplay.type = _data as int;
			super.commitData();
		}
		
		
		override public function set currentState(_state:String):void
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
		}
		
	}
}