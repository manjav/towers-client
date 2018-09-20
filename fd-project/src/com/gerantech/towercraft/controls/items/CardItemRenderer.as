package com.gerantech.towercraft.controls.items
{
import com.gerantech.towercraft.controls.BuildingCard;
import com.gerantech.towercraft.controls.overlays.TutorialArrow;
import com.gerantech.towercraft.events.GameEvent;
import com.gerantech.towercraft.managers.net.sfs.SFSCommands;
import com.gerantech.towercraft.managers.net.sfs.SFSConnection;
import com.gerantech.towercraft.models.Assets;
import com.gerantech.towercraft.models.tutorials.TutorialData;
import com.gt.towers.constants.CardFeatureType;
import com.gt.towers.constants.CardTypes;
import com.gt.towers.constants.PrefsTypes;
import com.smartfoxserver.v2.entities.data.SFSObject;
import feathers.controls.ImageLoader;
import feathers.controls.ScrollContainer;
import feathers.events.FeathersEventType;
import feathers.layout.AnchorLayout;
import feathers.layout.AnchorLayoutData;
import feathers.layout.HorizontalLayout;
import feathers.layout.TiledRowsLayout;
import starling.core.Starling;
import starling.events.Event;

public class CardItemRenderer extends AbstractTouchableListItemRenderer
{
private var _firstCommit:Boolean = true;
private var _width:Number;
private var _height:Number;
private var cardTypes:int = -1;

private var cardDisplay:BuildingCard;
private var showLevel:Boolean;
private var showSlider:Boolean;
private var showElixir:Boolean;
private var scroller:ScrollContainer;
private var cardLayoutData:AnchorLayoutData;
private var newDisplay:ImageLoader;
private var tutorialArrow:TutorialArrow;

public function CardItemRenderer(showLevel:Boolean = true, showSlider:Boolean = true, showElixir:Boolean = false, scroller:ScrollContainer = null)
{
	super();
	this.showLevel = showLevel;
	this.showSlider = showSlider;
	this.showElixir = showElixir;
	this.scroller = scroller;
}

override protected function initialize():void
{
	super.initialize();
	layout = new AnchorLayout();
	alpha = 0;
	
	cardLayoutData = new AnchorLayoutData(0, 0, NaN, 0);
	cardDisplay = new BuildingCard(showLevel, showSlider, false, showElixir);
	cardDisplay.layoutData = cardLayoutData;
	addChild(cardDisplay);
}

override protected function commitData():void
{
	if( _data == null )
		return;
	
	if( _firstCommit )
	{
		if( _owner.layout is HorizontalLayout )
		{
			width = _width = HorizontalLayout(_owner.layout).typicalItemWidth;
			height = _height = HorizontalLayout(_owner.layout).typicalItemHeight;
		}
		else if( _owner.layout is TiledRowsLayout )
		{
			width = _width = TiledRowsLayout(_owner.layout).typicalItemWidth;
			height = _height = TiledRowsLayout(_owner.layout).typicalItemHeight;
		}
		_firstCommit = false;
		_owner.addEventListener(FeathersEventType.CREATION_COMPLETE, _owner_createHandler);
	}

	if( _data is int )
	{
		cardTypes = _data as int;
		var exists:Boolean = player.cards.exists(cardTypes);
		
		// new badge visibility
		if( exists && player.cards.get(cardTypes).level == -1 )
		{
			if( newDisplay == null )
			{
				newDisplay = new ImageLoader();
				newDisplay.source = Assets.getTexture("cards/new-badge", "gui");
				newDisplay.layoutData = new AnchorLayoutData(0, NaN, NaN, 0);
				newDisplay.height = newDisplay.width = width * 0.7;
				addChild(newDisplay);
			}
		}
		else if( newDisplay != null )
		{
			newDisplay.removeFromParent(true);
			newDisplay = null;
		}
		
		var l:int = exists ? player.cards.get(cardTypes).level : 1;
		var c:int = exists ? player.resources.get(cardTypes) : 1;
		cardDisplay.setData( cardTypes, l, c);
		Starling.juggler.tween(this, 0.2, {delay:0.05 * index, alpha:1});
	}
	else
	{
		alpha = 1;
		cardTypes = _data.type;
		cardDisplay.setData(_data.type, _data.level);
	}

	showTutorArrow();
}

private function _owner_createHandler():void
{
	_owner.removeEventListener(FeathersEventType.CREATION_COMPLETE, _owner_createHandler);
	if( scroller == null )
		return;
	ownerBounds = scroller.getBounds(stage);
	scroller.addEventListener(Event.SCROLL, scroller_scrollHandler);
}

private function scroller_scrollHandler(event:Event):void
{
	visible = onScreen(getBounds(stage));//trace(index, visible)
}		

private function showTutorArrow () : void
{
	if( tutorialArrow != null )
		tutorialArrow.removeFromParent(true);
	if( !player.inDeckTutorial() || cardTypes != CardTypes.INITIAL || player.cards.get(cardTypes).level > -1 )
		return;
	
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
	if( super.currentState == _state )
		return;
	super.currentState = _state;
	
	if( !showSlider )
		return;
	
	cardLayoutData.top = cardLayoutData.right = cardLayoutData.bottom = cardLayoutData.left = _state == STATE_DOWN ? 12 : 0;
	if( _state == STATE_SELECTED )
	{
		if( newDisplay != null )
		{
			newDisplay.removeFromParent(true);
			newDisplay = null;
		}
		owner.dispatchEventWith(FeathersEventType.FOCUS_IN, false, this);
	}
	
	//if( player.cards.exists( _data as int ) )
	//	visible = _state != STATE_SELECTED;
}

override public function dispose():void
{
	if( scroller != null )
		scroller.removeEventListener(Event.SCROLL, scroller_scrollHandler);
	super.dispose();
}
}
}