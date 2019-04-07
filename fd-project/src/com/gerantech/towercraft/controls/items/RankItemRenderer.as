package com.gerantech.towercraft.controls.items
{
import com.gerantech.towercraft.controls.buttons.LeagueButton;
import com.gerantech.towercraft.controls.texts.ShadowLabel;
import com.gerantech.towercraft.models.Assets;
import com.gerantech.towercraft.themes.MainTheme;
import com.gerantech.towercraft.utils.StrUtils;
import feathers.controls.ImageLoader;
import feathers.layout.AnchorLayout;
import feathers.layout.AnchorLayoutData;
import starling.display.Image;

public class RankItemRenderer extends AbstractTouchableListItemRenderer
{
private var mySkin:Image;
private var iconDisplay:ImageLoader;
private var leagueBGDisplay:ImageLoader;
private var leagueIconDisplay:ImageLoader;
private var rankDisplay:ShadowLabel;
private var nameDisplay:ShadowLabel;
private var pointDisplay:ShadowLabel;
private var _visibility:Boolean;
private var leagueIndex:int;
public function RankItemRenderer(){}
override protected function initialize():void
{
	super.initialize();
	layout = new AnchorLayout();

	mySkin = new Image(Assets.getTexture("theme/item-renderer-ranking-skin", "gui"));
	mySkin.scale9Grid = MainTheme.ITEM_RENDERER_RANK_SCALE9_GRID;
	backgroundSkin = mySkin;
	
	iconDisplay = new ImageLoader();
	iconDisplay.height = iconDisplay.width = 76;
	iconDisplay.layoutData = new AnchorLayoutData(NaN, appModel.isLTR?24:NaN, NaN, appModel.isLTR?NaN:24, NaN, 0);
	iconDisplay.source = Assets.getTexture("res-2", "gui");
	addChild(iconDisplay);

	leagueBGDisplay = new ImageLoader();
	leagueBGDisplay.width = 80;
	leagueBGDisplay.height = 88;
	leagueBGDisplay.layoutData = new AnchorLayoutData(NaN, appModel.isLTR?NaN:112, NaN, appModel.isLTR?112:NaN, NaN, 0);
	addChild(leagueBGDisplay);

	leagueIconDisplay = new ImageLoader();
	leagueIconDisplay.height = leagueIconDisplay.width = 60;
	leagueIconDisplay.layoutData = new AnchorLayoutData(NaN, appModel.isLTR?NaN:122, NaN, appModel.isLTR?122:NaN, NaN, -5);
	addChild(leagueIconDisplay);

	rankDisplay = new ShadowLabel("", 1, 0, "center", null, false, null, 0.7);
	rankDisplay.width = 80;
	rankDisplay.layoutData = new AnchorLayoutData(NaN, appModel.isLTR?NaN:20, NaN, appModel.isLTR?20:NaN, NaN, 0);
	addChild(rankDisplay);
	
	nameDisplay = new ShadowLabel("", 1, 0, null, null, false, null, 0.8);
	nameDisplay.layoutData = new AnchorLayoutData(NaN, appModel.isLTR?NaN:205, NaN, appModel.isLTR?205:NaN, NaN, 0);
	addChild(nameDisplay);
	
	pointDisplay = new ShadowLabel("", 1, 0, "center", null, false, null, 0.7);
	pointDisplay.width = 160;
	pointDisplay.layoutData = new AnchorLayoutData(NaN, appModel.isLTR?100:NaN, NaN, appModel.isLTR?NaN:100, NaN, 0);
	addChild(pointDisplay);
}

override protected function commitData():void
{
	super.commitData();
	if( _data == null || _owner == null )
		return;
	
	visibility = _data.n != undefined// ? 0 : 1;
	height = _visibility ? 110 : 60;
	if( !_visibility )
		return;

	leagueIndex = player.get_arena(_data.p);
	rankDisplay.text = StrUtils.getNumber(_data.s ? (_data.s + 1) : (index + 1));
	nameDisplay.text = _data.n ;
	pointDisplay.text = StrUtils.getNumber(_data.p);
	leagueBGDisplay.source = Assets.getTexture("leagues/circle-" + (leagueIndex % 2) + "-small", "gui");
	leagueIconDisplay.source = Assets.getTexture("leagues/" + Math.floor(leagueIndex * 0.5), "gui");
	mySkin.color = _data.i == player.id ? 0xAAFFFF : 0xFFFFFF;
}

private function set visibility(value:Boolean):void 
{
	if( _visibility == value )
		return;
	_visibility = value;
	mySkin.visible = _visibility;
	iconDisplay.visible = _visibility;
	rankDisplay.visible = _visibility;
	pointDisplay.visible = _visibility;
	nameDisplay.visible = _visibility;
	leagueBGDisplay.visible = _visibility;
	leagueIconDisplay.visible = _visibility;
}
} 
}