package com.gerantech.towercraft.controls.items.lobby
{
import com.gerantech.towercraft.controls.items.AbstractTouchableListItemRenderer;
import com.gerantech.towercraft.controls.texts.RTLLabel;
import com.gerantech.towercraft.controls.texts.ShadowLabel;
import com.gerantech.towercraft.models.Assets;
import com.gerantech.towercraft.themes.MainTheme;
import com.gerantech.towercraft.utils.StrUtils;
import feathers.controls.ImageLoader;
import feathers.layout.AnchorLayout;
import feathers.layout.AnchorLayoutData;
import flash.geom.Rectangle;
import starling.display.Image;

public class LobbyItemRenderer extends AbstractTouchableListItemRenderer
{
static private const MEMBER_SCALE9_GRID:Rectangle = new Rectangle(11, 11, 1, 1);
private var emblemDisplay:ImageLoader;
private var membersDisplay:RTLLabel;
private var activenessDisplay:ShadowLabel;
private var rankDisplay:ShadowLabel;
private var nameDisplay:ShadowLabel;

public function LobbyItemRenderer(){}
override protected function initialize():void
{
	super.initialize();
	height = 110;
	layout = new AnchorLayout();

	var mySkin:Image = new Image(Assets.getTexture("theme/item-renderer-ranking-skin", "gui"));
	mySkin.scale9Grid = MainTheme.ITEM_RENDERER_RANK_SCALE9_GRID;
	backgroundSkin = mySkin;

	var membersRect:ImageLoader = new ImageLoader();
	membersRect.width = 120;
	membersRect.scale9Grid = MEMBER_SCALE9_GRID;
	membersRect.source = Assets.getTexture("theme/inner-rect-small", "gui");
	membersRect.layoutData = new AnchorLayoutData(46, appModel.isLTR?280:NaN, 14, appModel.isLTR?NaN:280);
	addChild(membersRect);
	
	emblemDisplay = new ImageLoader();
	emblemDisplay.layoutData = new AnchorLayoutData(15, appModel.isLTR?NaN:109, 14, appModel.isLTR?109:NaN);
	addChild(emblemDisplay);
	
	// labels .........
	rankDisplay = new ShadowLabel("", 1, 0, "center", null, false, null, 0.7);
	rankDisplay.width = 80;
	rankDisplay.layoutData = new AnchorLayoutData(NaN, appModel.isLTR?NaN:20, NaN, appModel.isLTR?20:NaN, NaN, 0);
	addChild(rankDisplay);
	
	nameDisplay = new ShadowLabel("", 1, 0, null, null, false, null, 0.8);
	nameDisplay.layoutData = new AnchorLayoutData(NaN, appModel.isLTR?NaN:205, NaN, appModel.isLTR?205:NaN, NaN, 0);
	addChild(nameDisplay);
	
	var populationDisplay:RTLLabel = new RTLLabel(loc("lobby_population"), 0, "center", null, false, null, 0.55);
	populationDisplay.width = 120;
	populationDisplay.layoutData = new AnchorLayoutData(7, appModel.isLTR?280:NaN, NaN, appModel.isLTR?NaN:280);
	addChild(populationDisplay);
	
	membersDisplay = new RTLLabel("", 0, "center", null, false, null, 0.7);
	membersDisplay.width = 120;
	membersDisplay.layoutData = new AnchorLayoutData(NaN, appModel.isLTR?280:NaN, 7, appModel.isLTR?NaN:280);
	addChild(membersDisplay);
	
	activenessDisplay = new ShadowLabel("", 1, 0, "center", null, false, null, 0.8);
	activenessDisplay.width = 160;
	activenessDisplay.layoutData = new AnchorLayoutData(NaN, appModel.isLTR?60:NaN, NaN, appModel.isLTR?NaN:60, NaN, 0);
	addChild(activenessDisplay);
}

override protected function commitData():void
{
	super.commitData();
	if( _data == null || _owner == null )
		return;
	
	emblemDisplay.source = Assets.getTexture("emblems/emblem-" + StrUtils.getZeroNum(_data.pic + ""), "gui");
	rankDisplay.text = StrUtils.getNumber(index + 1);
	nameDisplay.text = _data.name;
    activenessDisplay.text = StrUtils.getNumber(_data.act);
	membersDisplay.text = StrUtils.getNumber(_data.num + "/" + _data.max);
}
}
}