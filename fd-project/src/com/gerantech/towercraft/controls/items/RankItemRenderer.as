package com.gerantech.towercraft.controls.items
{
import com.gerantech.towercraft.controls.texts.RTLLabel;
import com.gerantech.towercraft.models.AppModel;
import com.gerantech.towercraft.models.Assets;
import com.gerantech.towercraft.themes.BaseMetalWorksMobileTheme;
import flash.geom.Rectangle;
import flash.text.engine.ElementFormat;
import feathers.layout.AnchorLayout;
import feathers.layout.AnchorLayoutData;
import feathers.skins.ImageSkin;

public class RankItemRenderer extends AbstractTouchableListItemRenderer
{
private static const DEFAULT_TEXT_COLOR:uint = 0xDDFFFF;
private var nameDisplay:RTLLabel;
private var nameShadowDisplay:RTLLabel;
private var pointDisplay:RTLLabel;
private var mySkin:ImageSkin;

public function RankItemRenderer(){}
override protected function initialize():void
{
	super.initialize();
	
	layout = new AnchorLayout();
	var padding:int = 36 * appModel.scale;
	
	mySkin = new ImageSkin(appModel.theme.itemRendererUpSkinTexture);
	mySkin.scale9Grid = BaseMetalWorksMobileTheme.ITEM_RENDERER_SCALE9_GRID
	backgroundSkin = mySkin;
	
	nameShadowDisplay = new RTLLabel("", 0, null, null, false, null, 0.8);
	nameShadowDisplay.layoutData = new AnchorLayoutData(NaN, appModel.isLTR?NaN:padding, NaN, appModel.isLTR?padding:NaN, NaN, 0);
	nameShadowDisplay.pixelSnapping = false;
	addChild(nameShadowDisplay);
	
	nameDisplay = new RTLLabel("", DEFAULT_TEXT_COLOR, null, null, false, null, 0.8);
	nameDisplay.pixelSnapping = false;
	nameDisplay.layoutData = new AnchorLayoutData(NaN, appModel.isLTR?NaN:padding, NaN, appModel.isLTR?padding:NaN, NaN, -padding/12);
	addChild(nameDisplay);
	
	pointDisplay = new RTLLabel("", 1, appModel.isLTR?"right":"left", null, false, null, 1);
	pointDisplay.pixelSnapping = false;
	pointDisplay.layoutData = new AnchorLayoutData(NaN, appModel.isLTR?padding:NaN, NaN, appModel.isLTR?NaN:padding, NaN, 0);
	addChild(pointDisplay);
}

override protected function commitData():void
{
	super.commitData();
	if( _data == null || _owner == null )
		return;
	
	var isGap:Boolean = _data.n == undefined;
	height = (isGap?60:90) * appModel.scale;

	alpha = isGap ? 0 : 1;
	
	var rankIndex:int = _data.s ? (_data.s+1) : (index+1);
	nameDisplay.text = rankIndex + ".  " + _data.n ;
	nameShadowDisplay.text = rankIndex + ".  " + _data.n ;
	pointDisplay.text = "" + _data.p;
	//trace(_data.i, player.id);
	var fs:int = AppModel.instance.theme.gameFontSize * (_data.i==player.id?1:0.9) * appModel.scale;
	var fc:int = _data.i==player.id?BaseMetalWorksMobileTheme.PRIMARY_TEXT_COLOR:DEFAULT_TEXT_COLOR;
	if( fs != nameDisplay.fontSize )
	{
		nameDisplay.fontSize = fs;
		nameShadowDisplay.fontSize = fs;
		
		nameDisplay.elementFormat = new ElementFormat(nameDisplay.fontDescription, fs, fc);
		nameShadowDisplay.elementFormat = new ElementFormat(nameShadowDisplay.fontDescription, fs, nameShadowDisplay.color);
	}
	mySkin.defaultTexture = _data.i==player.id ? appModel.theme.itemRendererSelectedSkinTexture : appModel.theme.itemRendererUpSkinTexture;
}
} 
}