package com.gerantech.towercraft.controls.items
{
	import com.gerantech.towercraft.models.Assets;
	import com.gerantech.towercraft.models.Fields;
	import com.gt.towers.battle.fieldes.FieldData;
	import com.gt.towers.battle.fieldes.PlaceData;
	
	import starling.display.Image;
	import starling.display.Sprite;

	public class QuestMapItemRenderer extends BaseCustomItemRenderer
	{
		public static var questIndex:int;
		
		private var shire:FieldData;
		private var container:Sprite;
		
		public function QuestMapItemRenderer()
		{
			super();
			height = 800 * appModel.scale;
			container = new Sprite();
			container.scale = appModel.scale * 1.42857;
			addChild(container);
		}
		
		override protected function commitData():void
		{
			super.commitData();
			if( _data == null )
				return;
			shire = _data as FieldData;

			container.removeChildren();
			var images:Vector.<Image> = Fields.getField(shire, "quests");
			for each(var img:Image in images)
				container.addChild(img);
				
			for each(var item:PlaceData in shire.places._list)
			{
				var score:int = player.quests.get(item.index);
				//trace(item.index , player.quests.get(item.index) )
				var color:String = "locked";
				if ( item.index < questIndex )
					color = "passed";
				else if( item.index == questIndex )
					color = "current";
				
				var pin:Image = new Image(Assets.getTexture("map-pin-" + color, "quests"));
				pin.alignPivot();
				pin.x = item.x;
				pin.y = item.y;
				container.addChild(pin);
				
				if ( score > 0 )
				{
					var star_0:Image = new Image(Assets.getTexture("star-center", "quests"));
					star_0.alignPivot("center", "top");
					star_0.x = item.x;
					star_0.y = item.y + 14;
					container.addChild(star_0);
				}
				if ( score > 1 )
				{
					var star_1:Image = new Image(Assets.getTexture("star-side", "quests"));
					star_1.alignPivot("right", "top");
					star_1.scaleX = -1
					star_1.x = item.x + 18;
					star_1.y = item.y + 5;
					container.addChild(star_1);
				}
				if ( score > 2 )
				{
					var star_2:Image = new Image(Assets.getTexture("star-side", "quests"));
					star_2.alignPivot("right", "top");
					star_2.x = item.x - 18;
					star_2.y = item.y + 5;
					container.addChild(star_2);
				}

			}
		}
	}
}