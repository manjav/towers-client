package com.gerantech.towercraft.controls.items
{
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
		valueDisplay.text = "<span>" + Math.round(oldValue) + (diff == 0?"":(' <font color="#00ff00"> + ' +  diff + '</font>')) + "</span>";
		valueDisplay.isHTML = true;
	}
	else
	{
		valueDisplay.text = Math.round(oldValue);
	}
	
	keyDisplay.text = loc("building_feature_" + feature + (newValue > 0 ? "" : "_1"));
}
}
}