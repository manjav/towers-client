package com.gerantech.towercraft.managers
{
	import com.gerantech.towercraft.models.TowerPlace;

	public class PathFinder
	{

		private static var closedList:Vector.<TowerPlace>;
		
		/**
		 * Use 'Breadth First Search' (BFS) for finding path of troops
		 */ 
		public static function find(source:TowerPlace, destination:TowerPlace, all:Vector.<TowerPlace>):Vector.<TowerPlace>
		{
			if(source == destination)
				return null;
			
			for (var p:uint=0; p<all.length; p++)
				all[p].owner = null;
			
			closedList = new Vector.<TowerPlace>();
			if(!sreach(source, destination))
				return null;
			
			// Create return path
			var ret:Vector.<TowerPlace> = new Vector.<TowerPlace>();
			var last:TowerPlace = closedList[closedList.length-1];
			do
			{
				ret.push(last);
				last = last.owner;
			}
			while(last!=null && last != source);
			ret.reverse();
			
			//trace("Path found:", ret.length);
			return ret;
		}
		
		private static function sreach(source:TowerPlace, destination:TowerPlace):Boolean
		{
			// Creating our Open List
			var openList:Vector.<TowerPlace> = new Vector.<TowerPlace>();
			// Adding our starting point to Open List
			openList.push(source);
			
			// Loop while openList contains some data.
			while (openList.length != 0)
			{
			// Remove and get the first element from openList.
				var node:TowerPlace = openList.shift();
				//trace("openList", openList.length, UserData.getInstance().id);
				
				// Check if tower is Destination
				if (node == destination)
				{
					closedList.push(destination);
					return true;
				}
				
				var numLinks:uint = node.links.length;
				// Add each neighbor to the end of our openList
				for (var i:uint=0; i < numLinks; i++) 
				{
					if((node.links[i] != source && node.links[i].tower.troopType == source.tower.troopType) || node.links[i] == destination)
					{
						//trace(node.links[i].name, "added to", node.name )
						if(node.links[i].owner == null)
						{
							node.links[i].owner = node;
							openList.push(node.links[i]);
						}
					}
				}
				
				// Add current tower to closedList
				closedList.push(node);
				//trace("closedList", n.index);
			}
			return false;
		}
	}
}