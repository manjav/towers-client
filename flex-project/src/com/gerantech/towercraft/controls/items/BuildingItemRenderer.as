package com.gerantech.towercraft.controls.items
{
	import com.gerantech.towercraft.controls.BuildingCard;
	import com.gerantech.towercraft.controls.overlays.TutorialArrow;
	import com.gerantech.towercraft.events.GameEvent;
	import com.gerantech.towercraft.managers.net.sfs.SFSCommands;
	import com.gerantech.towercraft.managers.net.sfs.SFSConnection;
	import com.gerantech.towercraft.models.Assets;
	import com.gerantech.towercraft.models.tutorials.TutorialData;
	import com.gt.towers.constants.BuildingType;
	import com.gt.towers.constants.PrefsTypes;
	import com.smartfoxserver.v2.entities.data.SFSObject;
	
	import feathers.controls.ImageLoader;
	import feathers.events.FeathersEventType;
	import feathers.layout.AnchorLayout;
	import feathers.layout.AnchorLayoutData;
	import feathers.layout.HorizontalLayout;
	import feathers.layout.TiledRowsLayout;
	
	import starling.core.Starling;
	import starling.display.Quad;
	import starling.events.Event;

	public class BuildingItemRenderer extends AbstractTouchableListItemRenderer
	{
		private var _firstCommit:Boolean = true;
		private var _width:Number;
		private var _height:Number;
		
		private var cardDisplay:BuildingCard;
		private var inDeck:Boolean;
		private var cardLayoutData:AnchorLayoutData;

		private var newDisplay:ImageLoader;
		private var tutorialArrow:TutorialArrow;
		
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
			
			if( player.buildings.exists(cardDisplay.type) && player.buildings.get(cardDisplay.type).get_level() == -1 )
			{
				newDisplay = new ImageLoader();
				newDisplay.source = Assets.getTexture("cards/new-badge", "gui");
				newDisplay.layoutData = new AnchorLayoutData(-10*appModel.scale, NaN, NaN, -10*appModel.scale);
				newDisplay.height = newDisplay.width = width * 0.6;
				addChild(newDisplay);
			}
			
			super.commitData();
			if( _data == BuildingType.B11_BARRACKS )
				tutorials.addEventListener(GameEvent.TUTORIAL_TASKS_FINISH, tutorialManager_finishHandler);
		}
		
		private function tutorialManager_finishHandler(event:Event):void
		{
			if( player.getTutorStep() != PrefsTypes.T_152_DECK_FIRST_VIEW )
				return;
			tutorials.removeEventListener(GameEvent.TUTORIAL_TASKS_FINISH, tutorialManager_finishHandler);
			var tuteData:TutorialData = event.data as TutorialData;
			if( tuteData.name == "deck_start" )
				showFocus();
		}
		private function showFocus () : void
		{
			if( tutorialArrow != null )
				tutorialArrow.removeFromParent(true);
			
			tutorialArrow = new TutorialArrow(true);
			tutorialArrow.layoutData = new AnchorLayoutData(NaN, NaN, NaN, NaN, 0, height * 0.3);
			addChild(tutorialArrow);
		}
		
		override public function set isSelected(value:Boolean):void
		{
			super.isSelected = value
			if( value && tutorialArrow != null )
				tutorialArrow.removeFromParent(true);
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
			{
				if( newDisplay )
				{
					newDisplay.removeFromParent(true);
					player.buildings.get( cardDisplay.type ).upgrade();
					
					var sfs:SFSObject = new SFSObject();
					sfs.putInt("type", cardDisplay.type);
					sfs.putInt("confirmedHards", 0);
					SFSConnection.instance.sendExtensionRequest(SFSCommands.BUILDING_UPGRADE, sfs);

				}
				owner.dispatchEventWith(FeathersEventType.FOCUS_IN, false, this);
			}
			
			if ( player.buildings.exists( _data as int ) )
				visible = _state != STATE_SELECTED;
		}
		
	}
}