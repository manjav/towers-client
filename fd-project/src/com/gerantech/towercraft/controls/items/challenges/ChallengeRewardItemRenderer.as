package com.gerantech.towercraft.controls.items.challenges 
{
	import com.gerantech.towercraft.controls.items.AbstractListItemRenderer;
	import com.gerantech.towercraft.controls.texts.ShadowLabel;
	import com.gerantech.towercraft.models.Assets;
	import com.gerantech.towercraft.themes.BaseMetalWorksMobileTheme;
	import feathers.controls.ImageLoader;
	import feathers.layout.AnchorLayout;
	import feathers.layout.AnchorLayoutData;
	import feathers.layout.TiledRowsLayout;
	import starling.display.Image;
/**
* ...
* @author Mansour Djawadi...
*/
public class ChallengeRewardItemRenderer extends AbstractListItemRenderer
{
private var procceed:Boolean;
public function ChallengeRewardItemRenderer() {	super(); }

override protected function commitData() : void
{
	super.commitData();
	if( procceed )
		return;

	width = TiledRowsLayout(owner.layout).typicalItemWidth;
	height = 120;
	procceed = true;
	
	if( _data.index == null )
		return;
	
	layout = new AnchorLayout();
	
	var mySkin:Image = new Image(_data.index > 3 ? appModel.theme.itemRendererUpSkinTexture : appModel.theme.itemRendererSelectedSkinTexture);
	mySkin.scale9Grid = BaseMetalWorksMobileTheme.ITEM_RENDERER_SCALE9_GRID
	backgroundSkin = mySkin;
	
	var rewardDisplay:ImageLoader = new ImageLoader();
	rewardDisplay.source = Assets.getTexture("books/" + _data.book, "gui");
	rewardDisplay.layoutData = new AnchorLayoutData(-16, appModel.isLTR?10:NaN, -16, appModel.isLTR?NaN:10);
	addChild(rewardDisplay);
	
	// title .........................
	var title:String;
	if( _data.index == 4 )
		title = loc("challenge_winners_mid");
	else if( _data.index > 4 )
		title = loc("challenge_winners_last");
	else
	{
		if( appModel.isLTR )
		{
			switch( _data.index ) {
				case 1:		title = _data.index + "st";		break;
				case 2:		title = _data.index + "nd";		break;
				case 3:		title = _data.index + "rd";		break;
			}
		}
		else
		{
			title = loc("challenge_winner_prefix") + " " + loc("num_" + _data.index);
		}
	}
	var nameDisplay:ShadowLabel = new ShadowLabel(title, 1, 0, null, null, false, null, 0.8);
	nameDisplay.layoutData = new AnchorLayoutData(NaN, appModel.isLTR?NaN:16, NaN, appModel.isLTR?16:NaN, NaN, 0);
	addChild(nameDisplay);
}
}
}