package com.gerantech.towercraft.controls.items.lobby
{
import com.gerantech.towercraft.controls.items.AbstractTouchableListItemRenderer;
import com.gerantech.towercraft.controls.texts.RTLLabel;
import com.gerantech.towercraft.controls.texts.ShadowLabel;
import com.gerantech.towercraft.models.Assets;
import com.gerantech.towercraft.themes.MainTheme;
import com.gerantech.towercraft.utils.StrUtils;
import feathers.controls.ImageLoader;
import feathers.events.FeathersEventType;
import feathers.layout.AnchorLayout;
import feathers.layout.AnchorLayoutData;
import flash.geom.Rectangle;
import starling.display.Image;
import starling.events.Event;
import starling.events.Touch;

public class LobbyMemberItemRenderer extends AbstractTouchableListItemRenderer
{
public function LobbyMemberItemRenderer(){ super(); }
private var mySkin:Image;
private var rankDisplay:ShadowLabel;
private var nameDisplay:ShadowLabel;
private var roleDisplay:RTLLabel;
private var pointsDisplay:RTLLabel;
private var battlesDisplay:ShadowLabel;
private var leagueBGDisplay:ImageLoader;
private var leagueIconDisplay:ImageLoader;
private var leagueIndex:int;

override protected function initialize():void
{
	super.initialize();
	height = 110;
	layout = new AnchorLayout();

	// images .........
	mySkin = new Image(Assets.getTexture("theme/item-renderer-ranking-skin", "gui"));
	mySkin.scale9Grid = MainTheme.ITEM_RENDERER_RANK_SCALE9_GRID;
	backgroundSkin = mySkin;

	var pointsRect:ImageLoader = new ImageLoader();
	pointsRect.width = 180;
	pointsRect.source = appModel.theme.roundSmallInnerSkin;
	pointsRect.scale9Grid = MainTheme.ROUND_SMALL_SCALE9_GRID;
	pointsRect.layoutData = new AnchorLayoutData(11, appModel.isLTR?280:NaN, 13, appModel.isLTR?NaN:280);
	addChild(pointsRect);

	leagueBGDisplay = new ImageLoader();
	leagueBGDisplay.width = 80;
	leagueBGDisplay.height = 88;
	leagueBGDisplay.layoutData = new AnchorLayoutData(NaN, appModel.isLTR?NaN:112, NaN, appModel.isLTR?112:NaN, NaN, 0);
	addChild(leagueBGDisplay);

	leagueIconDisplay = new ImageLoader();
	leagueIconDisplay.height = leagueIconDisplay.width = 60;
	leagueIconDisplay.layoutData = new AnchorLayoutData(NaN, appModel.isLTR?NaN:122, NaN, appModel.isLTR?122:NaN, NaN, -5);
	addChild(leagueIconDisplay);
	
	var pointIconDisplay:ImageLoader = new ImageLoader();
	pointIconDisplay.height = pointIconDisplay.width = 76;
	pointIconDisplay.layoutData = new AnchorLayoutData(NaN, appModel.isLTR?24:NaN, NaN, appModel.isLTR?NaN:24, NaN, 0);
	pointIconDisplay.source = Assets.getTexture("res-2", "gui");
	addChild(pointIconDisplay);
	
	// labels .........
	rankDisplay = new ShadowLabel("", 1, 0, "center", null, false, null, 0.7);
	rankDisplay.width = 80;
	rankDisplay.layoutData = new AnchorLayoutData(NaN, appModel.isLTR?NaN:20, NaN, appModel.isLTR?20:NaN, NaN, 0);
	addChild(rankDisplay);
	
	nameDisplay = new ShadowLabel("", 1, 0, null, null, false, null, 0.8);
	nameDisplay.layoutData = new AnchorLayoutData(10, appModel.isLTR?NaN:208, NaN, appModel.isLTR?205:NaN);
	addChild(nameDisplay);
	
	roleDisplay = new RTLLabel("", 0, null, null, false, null, 0.6);
	roleDisplay.layoutData = new AnchorLayoutData(NaN, appModel.isLTR?NaN:205, 10, appModel.isLTR?205:NaN);
	addChild(roleDisplay);
	
	pointsDisplay = new RTLLabel("", 0, "center", null, false, null, 0.7);
	pointsDisplay.width = 180;
	pointsDisplay.layoutData = new AnchorLayoutData(NaN, appModel.isLTR?280:NaN, NaN, appModel.isLTR?NaN:280, NaN, 0);
	addChild(pointsDisplay);
	
	battlesDisplay = new ShadowLabel("", 1, 0, "center", null, false, null, 0.8);
	battlesDisplay.width = 160;
	battlesDisplay.layoutData = new AnchorLayoutData(NaN, appModel.isLTR?100:NaN, NaN, appModel.isLTR?NaN:100, NaN, 0);
	addChild(battlesDisplay);
	
	addEventListener(Event.TRIGGERED, item_triggeredHandler);
}

override protected function commitData():void
{
	super.commitData();
	if( _data == null || _owner == null )
		return;
	
	leagueIndex = player.get_arena(_data.point);
	rankDisplay.text = StrUtils.getNumber(index + 1);
	nameDisplay.text = _data.name ;
	roleDisplay.text = loc("lobby_role_" + _data.permission);
	pointsDisplay.text = StrUtils.getNumber(_data.point);
	battlesDisplay.text = StrUtils.getNumber(_data.activity);
	leagueBGDisplay.source = Assets.getTexture("leagues/circle-" + (leagueIndex % 2) + "-small", "gui");
	leagueIconDisplay.source = Assets.getTexture("leagues/" + Math.floor(leagueIndex * 0.5), "gui");
	mySkin.color = _data.id == player.id ? 0xAAFFFF : 0xFFFFFF;
}
protected function item_triggeredHandler(event:Event):void
{
	owner.dispatchEventWith(FeathersEventType.FOCUS_IN, false, this);
}
public function getTouch():Touch
{
	return touch;
}
}
}