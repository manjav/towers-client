package com.gerantech.towercraft.models.vo
{
	import com.gerantech.towercraft.utils.Utils;

	public class Descriptor
	{
		public var id:String;
		public var copyright:String;
		public var description:String;
		public var versionLabel:String;
		public var versionNumber:String;
		public var versionCode:int;
		public var market:String;
		
		public function Descriptor(xml:XML)
		{
			id = getNodesByName(xml, "id");
			copyright = getNodesByName(xml, "copyright");
			description = getNodesByName(xml, "description");
			versionLabel = getNodesByName(xml, "versionLabel");
			versionNumber = getNodesByName(xml, "versionNumber");
			versionCode = Utils.getVersionCode(versionNumber)
			
			/*var descriptJson:Object = JSON.parse(description);
			for(var n:String in descriptJson)
				this[n] = descriptJson[n];*/
		}
		
		private function getNodesByName(xml:XML, nodeName:String) : String 
		{
			var list:XMLList = xml.children();
			
			for each(var node:XML in  list)
			{
				
				var name:String = node.localName().toString();
				if (name == nodeName)
					return node.valueOf();
			}
			return null;
		}
	}
}
