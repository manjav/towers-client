package com.gerantech.towercraft.controls.items
{
import com.gt.towers.buildings.Building;

public class BuildingFeatureItemRenderer extends FeatureItemRenderer
{
private var building:Building;
private var feature:int;

public function BuildingFeatureItemRenderer(building:Building)
{
	this.building = building;
}

override protected function commitData():void
{
	if( _owner == null || _data == null )
		return;
	
	super.commitData();
	feature = _data as int;
	titleDisplay.text = loc("building_feature_" + feature);
	
	var baseValue:Number = game.calculator.getBaseline(feature) * game.calculator.getUIFactor(feature);
	var newValue:Number = game.calculator.get(feature, building.type, building.get_level() + 1, building.improveLevel) * game.calculator.getUIFactor(feature);
	var oldValue:Number = game.calculator.get(feature, building.type, building.get_level() + 0, building.improveLevel) * game.calculator.getUIFactor(feature);

	var diff:Number = Math.round(Math.abs(newValue - oldValue));
	valueDisplay.text = "<span>" + Math.round(oldValue) + (diff == 0?"":(' <font color="#00ff00"> + ' +  diff + '</font>')) + "</span>";
	valueDisplay.isHTML = true;
}
}
}