package com.gerantech.towercraft.controls.items
{
import com.gerantech.towercraft.controls.LTRLable;
import com.gerantech.towercraft.controls.RTLLabel;
import com.gerantech.towercraft.controls.StarCheck;
import com.gerantech.towercraft.models.Assets;
import com.gerantech.towercraft.models.vo.Quest;
import com.gerantech.towercraft.utils.StrUtils;

import flash.geom.Rectangle;

import feathers.layout.HorizontalLayout;
import feathers.layout.HorizontalLayoutData;
import feathers.layout.VerticalAlign;
import feathers.layout.VerticalLayout;
import feathers.skins.ImageSkin;

import starling.display.DisplayObject;


public class QuestItemRenderer extends BaseCustomItemRenderer
{
	private var questIndexLabel:LTRLable;
	private var questNameLabel:RTLLabel;
	private var star_1:StarCheck;
	private var star_2:StarCheck;
	private var star_3:StarCheck;
	private var quest:Quest;
	private var isFirstCommit:Boolean = true;

	override protected function initialize():void
	{
		super.initialize();
		
		skin = new ImageSkin(Assets.getTexture("building-button", "skin"));
		skin.setTextureForState(STATE_NORMAL, Assets.getTexture("building-button", "skin"));
		skin.setTextureForState(STATE_DOWN, Assets.getTexture("building-button", "skin"));
		skin.setTextureForState(STATE_SELECTED, Assets.getTexture("building-button", "skin"));
		skin.setTextureForState(STATE_DISABLED, Assets.getTexture("building-button-disable", "skin"));
		skin.scale9Grid = new Rectangle(10, 10, 56, 37);
		backgroundSkin = skin;
		
		var hlayout:HorizontalLayout = new HorizontalLayout();
		hlayout.paddingLeft = hlayout.paddingRight = 48 * appModel.scale;
		hlayout.gap = 16 * appModel.scale;
		hlayout.verticalAlign = VerticalAlign.MIDDLE;
		layout = hlayout;
		
		var elements:Vector.<DisplayObject> = new Vector.<DisplayObject>();
		
		questIndexLabel = new LTRLable("");
		elements.push( questIndexLabel );
		
		questNameLabel = new RTLLabel("");
		questNameLabel.layoutData = new HorizontalLayoutData(100);
		elements.push( questNameLabel );
		
		star_1 = new StarCheck();
		//star_1.width = star_1.height = height * 0.5;
		elements.push( star_1 );
		
		star_2 = new StarCheck();
		//star_2.width = star_2.height = height * 0.5
		elements.push( star_2 );
		
		star_3 = new StarCheck();
		//star_3.width = star_3.height = height * 0.5
		elements.push( star_3 );
		
		if(!appModel.isLTR)
			elements.reverse();
		
		for each(var e:DisplayObject in elements)
			addChild(e);
	}
	
	override protected function commitData():void
	{
		super.commitData();
		if(_data == null) return;
		if(isFirstCommit)
		{
			height = VerticalLayout(_owner.layout).typicalItemHeight;
			star_1.width = star_1.height = star_2.width = star_2.height = star_3.width = star_3.height = height * 0.5;
			isFirstCommit = false;	
		}
		
		quest = _data as Quest;
		if(quest.locked)
			currentState = STATE_DISABLED;
		
		questIndexLabel.text = quest.index.toString();
		questNameLabel.text = loc("quest_label") + " " + StrUtils.getNumber(quest.index+1);
		star_1.isEnabled = quest.score >= 1;
		star_2.isEnabled = quest.score >= 2;
		star_3.isEnabled = quest.score >= 3;
	}
	
	
}
}