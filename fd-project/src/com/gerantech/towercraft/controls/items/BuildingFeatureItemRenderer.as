package com.gerantech.towercraft.controls.items
{
import com.gt.towers.buildings.Building;

public class BuildingFeatureItemRenderer extends FeatureItemRenderer
{
private var buildingType:int;
private var feature:int;

public function BuildingFeatureItemRenderer(buildingType:int)
{
	this.buildingType = buildingType;
}

override protected function commitData():void
{
	if( _owner == null || _data == null )
		return;
	
	super.commitData();
	feature = _data as int;
	titleDisplay.text = loc("building_feature_" + feature);
	
	var building:Building = player.buildings.get(buildingType);
	var buildingLevel:int = building == null ? 1 : building.get_level();
	var buildingImprove:int = building == null ? 1 : building.improveLevel;
	
	//var baseValue:Number = game.calculator.getBaseline(feature) * game.calculator.getUIFactor(feature);
	var newValue:Number = game.calculator.get(feature, buildingType, buildingLevel + 1, buildingImprove) * game.calculator.getUIFactor(feature);
	var oldValue:Number = game.calculator.get(feature, buildingType, buildingLevel + 0, buildingImprove) * game.calculator.getUIFactor(feature);

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
}
}
}