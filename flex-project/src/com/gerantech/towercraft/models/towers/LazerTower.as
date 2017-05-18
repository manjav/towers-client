package com.gerantech.towercraft.models.towers
{
	public class LazerTower extends Tower
	{
		public function LazerTower(level:int=1, index:int = 0)
		{
			super(level, index);
			type = TYPE_LAZER;
		}
	}
}