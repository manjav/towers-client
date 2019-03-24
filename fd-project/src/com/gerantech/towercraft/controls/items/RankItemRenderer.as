package com.gerantech.towercraft.controls.items
{
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
private var arenaDisplay:ImageLoader;
private var rankDisplay:ShadowLabel;
private var nameDisplay:ShadowLabel;
private var pointDisplay:ShadowLabel;
private var _visibility:Boolean;
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

	arenaDisplay = new ImageLoader();
	arenaDisplay.height = arenaDisplay.width = 80;
	arenaDisplay.layoutData = new AnchorLayoutData(NaN, appModel.isLTR?NaN:112, NaN, appModel.isLTR?112:NaN, NaN, 0);
	addChild(arenaDisplay);

	rankDisplay = new ShadowLabel("", 1, 0, "center", null, false, null, 0.7);
	rankDisplay.width = 80;
	rankDisplay.layoutData = new AnchorLayoutData(NaN, appModel.isLTR?NaN:20, NaN, appModel.isLTR?20:NaN, NaN, 0);
	addChild(rankDisplay);
	
	nameDisplay = new ShadowLabel("", 1, 0, null, null, false, null, 0.8);
	nameDisplay.layoutData = new AnchorLayoutData(NaN, appModel.isLTR?NaN:200, NaN, appModel.isLTR?200:NaN, NaN, 0);
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

	rankDisplay.text = StrUtils.getNumber(_data.s ? (_data.s + 1) : (index + 1));
	nameDisplay.text = _data.n ;
	pointDisplay.text = StrUtils.getNumber(_data.p);
	arenaDisplay.source = Assets.getTexture("arena-" + Math.min(8, player.get_arena(_data.p)), "gui");

	mySkin.color = _data.i == player.id ? 0xAAFFFF : 0xFFFFFF;
}

private function set visibility(value:Boolean):void 
{
	if( _visibility == value )
		return;
	_visibility = value;
	mySkin.visible = _visibility;
	iconDisplay.visible = _visibility;
	arenaDisplay.visible = _visibility;
	rankDisplay.visible = _visibility;
	pointDisplay.visible = _visibility;
	nameDisplay.visible = _visibility;
}
} 
}