package com.gerantech.towercraft.controls.switchers
{
public class LabeledSwitcher extends Switcher
{
private var prefix:String;
public function LabeledSwitcher(value:int=0, max:int=2, prefix:String="switch_label")
{
	this.prefix = prefix;
	super(0, value, max, 1);
}
override protected function getLabel(value:int):String
{
	return loc(prefix + "_" + value);
}
}
}