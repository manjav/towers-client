package com.gerantech.towercraft.controls.items
{
	import com.gerantech.towercraft.controls.texts.LTRLable;
	import com.gerantech.towercraft.controls.texts.RTLLabel;
	import com.gerantech.towercraft.models.Assets;
	import com.gt.towers.buildings.Building;
	
	import feathers.controls.ImageLoader;
	import feathers.controls.LayoutGroup;
	import feathers.layout.AnchorLayout;
	import feathers.layout.AnchorLayoutData;
	import feathers.layout.HorizontalAlign;
	import feathers.layout.HorizontalLayout;
	import feathers.layout.HorizontalLayoutData;
	import feathers.layout.TiledRowsLayout;
	import feathers.layout.VerticalAlign;
	import feathers.layout.VerticalLayout;
	
	import starling.core.Starling;

	public class FeatureItemRenderer extends BaseCustomItemRenderer
	{
		private var _firstCommit:Boolean = true;
		//private var iconDisplay:ImageLoader;
		private var titleDisplay:RTLLabel  ;
		private var valueDisplay:LTRLable;
		private var building:Building;
		private var feature:int;
		
		public function FeatureItemRenderer(building:Building)
		{
			this.building = building;
		}
		
		override protected function initialize():void
		{
			super.initialize();
			/*var hLayout:HorizontalLayout = new HorizontalLayout();
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
			addChild(textsContainer);*/
			
			layout = new AnchorLayout();

			titleDisplay = new RTLLabel("", 1, null, null,	false, null, 0.8);
			titleDisplay.layoutData = new AnchorLayoutData(NaN, appModel.isLTR?NaN:0, NaN, appModel.isLTR?0:NaN, NaN, 0);
			addChild(titleDisplay);
			
			valueDisplay = new LTRLable("", 1, "left", false, 0.9);
			valueDisplay.layoutData = new AnchorLayoutData(NaN, appModel.isLTR?0:NaN, NaN, appModel.isLTR?NaN:0, NaN, 0);
			addChild(valueDisplay);

		}
		
		override protected function commitData():void
		{
			if(_owner==null || _data==null)
				return;
			
			if(_firstCommit)
			{
				_firstCommit = false;
				/*var layo:TiledRowsLayout = _owner.layout as TiledRowsLayout;
				width = layo.typicalItemWidth;
				height = layo.typicalItemHeight;*/
				height = 68 * appModel.scale;
				//iconDisplay.width = iconDisplay.height = height;
			}
			
			feature = _data as int;
			//iconDisplay.source = Assets.getTexture("improve-"+12, "gui");
			titleDisplay.text = loc("building_feature_" + feature);
			
			var baseValue:Number = building.getFeatureBaseValue(feature);
			building.level ++;
			var newValue:Number = building.getFeatureValue(feature);
			building.level --;
			var oldValue:Number = building.getFeatureValue(feature);

			var diff:Number = newValue - oldValue;
			if( baseValue > 500 )
			{
				oldValue = baseValue/oldValue;
				newValue = baseValue/newValue;
				diff = newValue - oldValue;
			}
			
			if( oldValue > 500 )
				valueDisplay.text = "<span>" + (oldValue/1000).toFixed(2) + (diff == 0?"":(' <font color="#00ff00"> + ' + Math.abs(diff).toFixed(2)+'</font>')) + "</span>";
			else
				valueDisplay.text = "<span>" + oldValue.toFixed(2) + (diff == 0?"":(' <font color="#00ff00"> + ' + Math.abs(diff).toFixed(2)+'</font>')) + "</span>";
			
			valueDisplay.isHTML = true;
			
			alpha = 0;
			Starling.juggler.tween(this, 0.2, {delay:index/30, alpha:1});
			//width = _owner.width/2;
		//	titleDisplay.text = _data["key"] + ": " + Number(_data["value"]).toFixed(2)
		}
		
	}
}