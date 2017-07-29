package com.gerantech.towercraft.controls.items
{
	import com.gerantech.towercraft.controls.BuildingCard;
	
	import feathers.events.FeathersEventType;
	import feathers.layout.AnchorLayout;
	import feathers.layout.AnchorLayoutData;
	import feathers.layout.HorizontalLayout;
	import feathers.layout.TiledRowsLayout;
	
	import starling.core.Starling;
	import starling.display.Quad;

	public class BuildingItemRenderer extends BaseCustomItemRenderer
	{
		private var _firstCommit:Boolean = true;
		private var _width:Number;
		private var _height:Number;
		
		private var cardDisplay:BuildingCard;
		private var inDeck:Boolean;
		private var cardLayoutData:AnchorLayoutData;
		
		public function BuildingItemRenderer(inDeck:Boolean=true)
		{
			super();
			this.inDeck = inDeck;
		}
		
		override protected function initialize():void
		{
			super.initialize();
			alpha = 0;
			backgroundSkin = new Quad(1,1);
			backgroundSkin.visible = false;

			layout = new AnchorLayout();
			
			cardLayoutData = new AnchorLayoutData(0,0,0,0);
			cardDisplay = new BuildingCard();
			cardDisplay.showLevel = inDeck;
			cardDisplay.showSlider = inDeck;
			cardDisplay.layoutData = cardLayoutData;
			addChild(cardDisplay);
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
				_firstCommit = false;
			}

			cardDisplay.type = _data as int;
			Starling.juggler.tween(this, 0.2, {delay:0.05*index, alpha:1});
			super.commitData();
		}
		override public function set isSelected(value:Boolean):void
		{
			if( super.isSelected == value )
				return;
			if( !super.isSelected && inDeck )
				cardLayoutData.top = cardLayoutData.right = cardLayoutData.bottom = cardLayoutData.left = 0;
			super.isSelected = value
		}

		
		override public function set currentState(_state:String):void
		{
			if(super.currentState == _state)
				return;

			super.currentState = _state;
			
			if ( !this.inDeck )
				return;
			
			cardLayoutData.top = cardLayoutData.right = cardLayoutData.bottom = cardLayoutData.left = _state == STATE_DOWN ? 12*appModel.scale : 0;
			if( _state == STATE_SELECTED )
				owner.dispatchEventWith(FeathersEventType.FOCUS_IN, false, this);
			
			if ( player.buildings.exists( _data as int ) )
				visible = _state != STATE_SELECTED;
		}
		
	}
}