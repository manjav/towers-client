package com.gerantech.towercraft.controls.items
{
import com.gerantech.towercraft.controls.BuildingCard;
import com.gerantech.towercraft.controls.overlays.TutorialArrow;
import com.gerantech.towercraft.managers.net.sfs.SFSCommands;
import com.gerantech.towercraft.managers.net.sfs.SFSConnection;
import com.gerantech.towercraft.models.Assets;
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

public class BuildingItemRenderer extends AbstractTouchableListItemRenderer
{
private var _firstCommit:Boolean = true;
private var _width:Number;
private var _height:Number;

private var cardDisplay:BuildingCard;
private var showLevel:Boolean;
private var showSlider:Boolean;
private var showElixir:Boolean;
private var scroller:ScrollContainer;
private var cardLayoutData:AnchorLayoutData;

private var newDisplay:ImageLoader;
private var tutorialArrow:TutorialArrow;

public function BuildingItemRenderer(showLevel:Boolean=true, showSlider:Boolean=true, showElixir:Boolean=false, scroller:ScrollContainer=null)
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
	
	cardLayoutData = new AnchorLayoutData(0,0,NaN,0);
	cardDisplay = new BuildingCard();
	cardDisplay.showLevel = showLevel;
	cardDisplay.showElixir = showElixir;
	cardDisplay.showSlider = showSlider;
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
		else if(_owner.layout is TiledRowsLayout)
		{
			width = _width = TiledRowsLayout(_owner.layout).typicalItemWidth;
			height = _height = TiledRowsLayout(_owner.layout).typicalItemHeight;
		}
		_firstCommit = false;
		_owner.addEventListener(FeathersEventType.CREATION_COMPLETE, _owner_createHandler);
	}

	if( _data is int )
	{
		var t:int = _data as int;
		cardDisplay.type = t >= 900 ? 999 : t;
		Starling.juggler.tween(this, 0.2, {delay:0.05*index, alpha:1});
		
		if( player.buildings.exists(t) && player.buildings.get(t).get_level() == -1 )
		{
			newDisplay = new ImageLoader();
			newDisplay.source = Assets.getTexture("cards/new-badge", "gui");
			newDisplay.layoutData = new AnchorLayoutData(0, NaN, NaN, 0);
			newDisplay.height = newDisplay.width = width * 0.7;
			addChild(newDisplay);
		}
	}
	else
	{
		alpha = 1;
		cardDisplay.type = _data.type;
		cardDisplay.level = _data.level;
	}
	
	super.commitData();
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

override public function set currentState(_state:String):void
{
	if(super.currentState == _state)
		return;
	super.currentState = _state;

	if( _state == STATE_SELECTED )
	{
		if( newDisplay )
		{
			newDisplay.removeFromParent(true);
			newDisplay = null;
			player.buildings.get( cardDisplay.type ).upgrade();
			
			var sfs:SFSObject = new SFSObject();
			sfs.putInt("type", cardDisplay.type);
			sfs.putInt("confirmedHards", 0);
			SFSConnection.instance.sendExtensionRequest(SFSCommands.BUILDING_UPGRADE, sfs);
		}
		owner.dispatchEventWith(FeathersEventType.FOCUS_IN, false, this);
	}
}

override public function dispose():void
{
	if( scroller != null )
		scroller.removeEventListener(Event.SCROLL, scroller_scrollHandler);
	super.dispose();
}
}
}