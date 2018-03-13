package com.gerantech.towercraft.models.vo
{
	import com.gt.towers.battle.fieldes.FieldData;
	
	public class Quest extends FieldData
	{
		public var score:int;
		public var locked:Boolean;
		
		public function Quest(baseField:FieldData, score:int)
		{
			this.score = score;
			locked = score == -1;
			super(baseField.index, baseField.name, baseField.hasIntro, baseField.hasFinal, baseField.times);
		}
	}
}