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
	if( _owner==null || _data==null )
		return;
	
	super.commitData();
	feature = _data as int;
	titleDisplay.text = loc("building_feature_" + feature);
	
	var baseValue:Number = game.featureCaculator.getBaseline(feature);
	var newValue:Number = game.featureCaculator.get(feature, building.type, building.get_level() + 1);
	var oldValue:Number = game.featureCaculator.get(feature, building.type, building.get_level());

	var diff:Number = newValue - oldValue;
	if( baseValue > 500 )
	{
		oldValue = baseValue/oldValue;
		newValue = baseValue/newValue;
		diff = newValue - oldValue;
	}

	if( oldValue > 500 )
		valueDisplay.text = "<span>" + (oldValue/1000).toFixed(2) + (diff == 0?"":(' <font color="#00ff00"> + ' + Math.abs(diff).toFixed(2)+'</font>')) + "</span>";
	else
		valueDisplay.text = "<span>" + oldValue.toFixed(2) + (diff == 0?"":(' <font color="#00ff00"> + ' + Math.abs(diff).toFixed(2)+'</font>')) + "</span>";
	
	valueDisplay.isHTML = true;
}
}
}