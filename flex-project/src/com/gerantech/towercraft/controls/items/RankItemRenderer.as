package com.gilass.tanks.controls.items
{
	import com.gerantech.towercraft.controls.items.BaseCustomItemRenderer;
	
	import feathers.controls.Label;
	import feathers.controls.text.TextBlockTextRenderer;
	import feathers.core.ITextRenderer;
	import feathers.layout.HorizontalLayout;
	import feathers.layout.HorizontalLayoutData;

	public class RankItemRenderer extends BaseCustomItemRenderer
	{
		private var rankData:RankData;
		
		private var nameText:Label;
		private var pointText:Label;
		
		override protected function initialize():void
		{
			super.initialize();
			var hlayout:HorizontalLayout = new HorizontalLayout();
		//	hlayout.verticalAlign = VerticalAlign.JUSTIFY;
			hlayout.padding = 10;
			layout = hlayout;
			
			nameText = new Label();
			nameText.textRendererFactory = function():ITextRenderer
			{
				var txt:TextBlockTextRenderer = new TextBlockTextRenderer();
				txt.bidiLevel = 1;
				txt.textAlign = "right";
				return txt;
			}
			nameText.layoutData = new HorizontalLayoutData(100);
			
			pointText = new Label();

			addChild(pointText);
			addChild(nameText);
		}
		
		
		override protected function commitData():void
		{
			super.commitData();
			if(_data ==null || _owner==null)
				return;
			
			rankData = _data as RankData;
			nameText.text = rankData.rank + ". " + rankData.name ;
			pointText.text = rankData.xp.toString();
			
		}
		
	} 
}