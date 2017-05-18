package com.gerantech.towercraft.models.towers
{
	public class CannonTower extends Tower
	{
		public function CannonTower(level:int=1, index:int = 0)
		{
			super(level, index);
			type = TYPE_CANNON;
		}
	}
}