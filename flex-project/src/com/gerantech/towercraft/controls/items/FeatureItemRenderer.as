package com.gerantech.towercraft.controls.items
{
	import com.gerantech.towercraft.controls.RTLLabel;
	import com.gerantech.towercraft.models.Assets;
	import com.gt.towers.buildings.Building;
	
	import feathers.controls.ImageLoader;
	import feathers.controls.LayoutGroup;
	import feathers.layout.HorizontalAlign;
	import feathers.layout.HorizontalLayout;
	import feathers.layout.HorizontalLayoutData;
	import feathers.layout.TiledRowsLayout;
	import feathers.layout.VerticalAlign;
	import feathers.layout.VerticalLayout;

	public class FeatureItemRenderer extends BaseCustomItemRenderer
	{
		private var _firstCommit:Boolean = true;
		private var iconDisplay:ImageLoader;
		private var titleDisplay:RTLLabel  ;
		private var valueDisplay:RTLLabel;
		private var building:Building;
		private var feature:int;
		
		public function FeatureItemRenderer(building:Building)
		{
			this.building = building;
		}
		
		override protected function initialize():void
		{
			super.initialize();
			var hLayout:HorizontalLayout = new HorizontalLayout();
			hLayout.verticalAlign = VerticalAlign.JUSTIFY;
			hLayout.gap = 12 * appModel.scale;
			layout = hLayout;
			
			iconDisplay = new ImageLoader();
			iconDisplay.maintainAspectRatio = false;
			addChild(iconDisplay);
			
			var textLayout:VerticalLayout = new VerticalLayout();
			textLayout.horizontalAlign = HorizontalAlign.JUSTIFY;
			textLayout.paddingTop = -6 * appModel.scale;
			textLayout.gap = -6 * appModel.scale;
			
			var textsContainer:LayoutGroup = new LayoutGroup();
			textsContainer.layoutData = new HorizontalLayoutData (100, 100);
			textsContainer.layout = textLayout;
			addChild(textsContainer);

			titleDisplay = new RTLLabel("", 1, "left", null, false, "left", 0.7);//loc("building_message_"+building.type)
			textsContainer.addChild(titleDisplay);
			
			valueDisplay = new RTLLabel("", 1, "left", "ltr", false, null, 1.1, null, "bold");//loc("building_title_"+building.type)
			//messageDisplay.layoutData = new VerticalLayoutData(100, 100);//
			textsContainer.addChild(valueDisplay);

		}
		
		override protected function commitData():void
		{
			if(_owner==null || _data==null)
				return;
			
			if(_firstCommit)
			{
				_firstCommit = false;
				var layo:TiledRowsLayout = _owner.layout as TiledRowsLayout;
				width = layo.typicalItemWidth;
				height = layo.typicalItemHeight;
				
				iconDisplay.width = iconDisplay.height = height;
			}
			
			feature = _data as int;
			iconDisplay.source = Assets.getTexture("improve-"+12, "gui");
			titleDisplay.text = loc("building_feature_" + feature);;
			
			building.level ++;
			var newValue:Number = building.getFeatureValue(feature);
			building.level --;
			var oldValue:Number = building.getFeatureValue(feature);

			var diff:Number = newValue - oldValue;
			valueDisplay.text = oldValue + (diff==0 ? "" : (diff>0?" + ":" - ") + Math.abs(diff));
			
			
			//width = _owner.width/2;
		//	titleDisplay.text = _data["key"] + ": " + Number(_data["value"]).toFixed(2)
		}
		
	}
}