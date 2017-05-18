package com.gerantech.towercraft.models.towers
{
	public class BomberTower extends Tower
	{
		public function BomberTower(level:int=1, index:int = 0)
		{
			super(level, index);
			type = TYPE_BOMBER;
		}
	}
}