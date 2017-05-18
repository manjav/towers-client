package com.gerantech.towercraft.models.towers
{
	public class SniperTower extends CommonTower
	{
		public function SniperTower(level:int=1, index:int=0, chosenBase:int=-1)
		{
			super(level, index, chosenBase);
			type = TYPE_SNIPER;
		}
		public override function get capacity():int
		{
			return 15 + level;
		}
	}
}