package com.gerantech.towercraft.models.tutorials
{
	public class TutorialData
	{
		public var name:String;
		public var tasks:Vector.<TutorialTask>;
		
		public function TutorialData(name:String)
		{
			this.name = name;
			tasks = new Vector.<TutorialTask>;
		}
	}
}