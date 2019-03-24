package com.gerantech.towercraft.controls.items
{
import com.gerantech.towercraft.controls.texts.LTRLable;
import com.gerantech.towercraft.utils.StrUtils;
import com.gt.towers.battle.units.Card;
import com.gt.towers.constants.CardFeatureType;
import com.gt.towers.scripts.ScriptEngine;

public class CardFeatureItemRenderer extends FeatureItemRenderer
{
private var CardTypes:int;
private var feature:int;

public function CardFeatureItemRenderer(CardTypes:int)
{
	this.CardTypes = CardTypes;
}

override protected function commitData():void
{
	if( _owner == null || _data == null )
		return;
	
	super.commitData();
	feature = _data as int;
	
	var building:Card = player.cards.get(CardTypes);
	var buildingLevel:int = building == null ? 1 : building.level;
	
	//var baseValue:Number = game.calculator.getBaseline(feature) * game.calculator.getUIFactor(feature);
	var newValue:Number = ScriptEngine.get(feature, CardTypes, buildingLevel + 1) * CardFeatureType.getUIFactor(feature);
	var oldValue:Number = ScriptEngine.get(feature, CardTypes, buildingLevel + 0) * CardFeatureType.getUIFactor(feature);
	var diff:Number = Math.round(Math.abs(newValue - oldValue));
	if( building != null )
	{
		valueDisplay.text = "<span>" + StrUtils.getNumber(Math.round(oldValue)) + (diff == 0?"":(' <font leading="22" color="#00ff00"> + ' + StrUtils.getNumber(diff) + ' </font>')) + "</span>";
		LTRLable(valueDisplay).isHTML = true;
	}
	else
	{
		valueDisplay.text = StrUtils.getNumber(Math.round(oldValue));
	}
	
	keyDisplay.text = loc("building_feature_" + feature + (newValue > 0 ? "" : "_1"));
}
}
}