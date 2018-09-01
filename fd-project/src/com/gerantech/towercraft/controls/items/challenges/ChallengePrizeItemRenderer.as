package com.gerantech.towercraft.controls.items.challenges 
{
import com.gerantech.towercraft.controls.items.AbstractTouchableListItemRenderer;
import com.gerantech.towercraft.controls.texts.ShadowLabel;
import com.gerantech.towercraft.models.Assets;
import com.gerantech.towercraft.themes.MainTheme;
import com.gt.towers.arenas.Arena;
import com.gt.towers.constants.ResourceType;
import feathers.controls.ImageLoader;
import feathers.events.FeathersEventType;
import feathers.layout.AnchorLayout;
import feathers.layout.AnchorLayoutData;
import feathers.layout.TiledRowsLayout;
import starling.events.Event;
import starling.display.Image;
/**
* ...
* @author Mansour Djawadi...
*/
public class ChallengePrizeItemRenderer extends AbstractTouchableListItemRenderer
{
private var procceed:Boolean;
private var prize:Arena;
public function ChallengePrizeItemRenderer() {	super(); }

override protected function commitData() : void
{
	super.commitData();
	if( procceed )
		return;

	width = TiledRowsLayout(owner.layout).typicalItemWidth;
	height = 120;
	procceed = true;
	
	if( _data == null )
		return;
	
	prize = _data as Arena;
	if( prize.index < 1 )
		return;
		
	layout = new AnchorLayout();
	
	var mySkin:Image = new Image(prize.index > 3 ? appModel.theme.itemRendererUpSkinTexture : appModel.theme.itemRendererSelectedSkinTexture);
	mySkin.scale9Grid = MainTheme.ITEM_RENDERER_SCALE9_GRID;
	backgroundSkin = mySkin;
	
	var prizeSrc:String;
	if( prize.minWinStreak == -1 )
		prizeSrc = "settings-22";
	else
		prizeSrc = (ResourceType.isBook(prize.minWinStreak)?"books/":"cards/") + prize.minWinStreak;
	var prizeIconDisplay:ImageLoader = new ImageLoader();
	prizeIconDisplay.source = Assets.getTexture(prizeSrc, "gui");
	prizeIconDisplay.layoutData = new AnchorLayoutData( -20, appModel.isLTR?0:NaN, -16, appModel.isLTR?NaN: -10);
	addChild(prizeIconDisplay);
	
	// title .........................
	var title:String;
	if( prize.max - prize.min > 0 )
	{
		title = loc("challenge_winner_title", [prize.min, prize.max]);
	}
	else
	{
		if( appModel.isLTR )
		{
			switch( _data.index ) {
				case 1:		title = prize.index + "st";		break;
				case 2:		title = prize.index + "nd";		break;
				case 3:		title = prize.index + "rd";		break;
			}
		}
		else
		{
			title = loc("challenge_winner_prefix") + " " + loc("num_" + prize.index);
		}
	}
	var nameDisplay:ShadowLabel = new ShadowLabel(title, 1, 0, null, null, false, null, 0.8);
	nameDisplay.layoutData = new AnchorLayoutData(NaN, appModel.isLTR?NaN:16, NaN, appModel.isLTR?16:NaN, NaN, -3);
	addChild(nameDisplay);
	
	addEventListener(Event.TRIGGERED, item_triggeredHandler);
}
protected function item_triggeredHandler(event:Event):void
{
	owner.dispatchEventWith(FeathersEventType.FOCUS_IN, false, prize.minWinStreak);
}
}
}