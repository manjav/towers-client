package com.gt.towers.editor
{
	import com.gt.towers.constants.BuildingType;
	
	import flash.display.MovieClip;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;
	
	public class PlaceComponent extends Sprite
	{
		public var type_btn:MovieClip;
		public var level_btn:MovieClip;
		public var body_mc:MovieClip;
		public var tutor_btn:MovieClip;
		public var enabled_btn:MovieClip;
		
		public var type:int = 1;
		public var index:int = 0;
		public var troopType:int = -1;
		public var links:Vector.<int>;
		public var tutorIndex:int = -2;
		public var enabled:Boolean = true;
		
		public function PlaceComponent()
		{
			super();
			
			index_txt.mouseEnabled = false;
			links = new Vector.<int>();
			level_btn.addEventListener(MouseEvent.CLICK, level_btn_clickHandler);
			type_btn.addEventListener(MouseEvent.CLICK, type_btn_clickHandler);
			body_mc.addEventListener(MouseEvent.CLICK, body_mc_clickHandler);
			tutor_btn.addEventListener(MouseEvent.CLICK, tutor_btn_clickHandler);
			enabled_btn.addEventListener(MouseEvent.CLICK, enabled_btn_clickHandler);
			update();
		}
		
		
		private function type_btn_clickHandler(event:Event):void
		{
			if(type >= BuildingType.B40_CRYSTAL)
				type = 1;
			else
				type += 10;
			update();
		}
		
		private function level_btn_clickHandler(event:Event):void
		{
			var improveLevel:int = type%10;
			if(improveLevel >= 4)
				type = type - improveLevel + 1;
			else
				type ++;
			update();
		}
		
		private function body_mc_clickHandler(event:Event):void
		{
			if(troopType >= 1)
				troopType = -1;
			else
				troopType ++;
			update();
		}
		
		private function tutor_btn_clickHandler(event:Event):void
		{
			tutorIndex ++;
			if ( tutorIndex > 5 )
				tutorIndex = -2;
			update();
		}
		
		private function enabled_btn_clickHandler(event:Event):void
		{
			enabled = !enabled;
			update();
		}
		
		public function get classString():String
		{
			return '\t\tfield.places.push( new PlaceData( '+index+',\t'+x+',\t'+y+',\t'+type+',\t'+troopType+',\t"'+links+'"'+',\t'+enabled+',\t'+tutorIndex+'\t) );\r';
		}
		public function get data():Object
		{
			return { index:this.index, type:this.type, troopType:this.troopType, links:this.links, enabled:this.enabled, tutorIndex:this.tutorIndex};
		}
		public function update():void
		{
			//trace(type, type*10 + (troopType+1));
			index_txt.text = index.toString();
			type_btn.txt.text = "T:" + Math.floor(type/10);
			level_btn.txt.text = "L:" + type%10;
			tutor_btn.txt.text = "S:" + tutorIndex;
			enabled_btn.txt.text = enabled ? "E" : "D";
			tutor_btn.alpha = tutorIndex==-2?0.3:1;
			body_mc.gotoAndStop(type*10 + (troopType+2));
		}
		
	}
}