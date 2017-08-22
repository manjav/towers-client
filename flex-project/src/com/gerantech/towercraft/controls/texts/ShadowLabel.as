package com.gerantech.towercraft.controls.texts
{
	import com.gerantech.towercraft.models.AppModel;
	
	import feathers.controls.LayoutGroup;
	import feathers.layout.AnchorLayout;
	import feathers.layout.AnchorLayoutData;
	
	public class ShadowLabel extends LayoutGroup
	{
		public var shadowDistance:Number = 0;
		
		private var mainLabel:RTLLabel;
		private var shadowLabel:RTLLabel;
		private var _text:String;

		public function ShadowLabel(text:String, color:uint=1, shadowColor:uint=0, align:String=null, direction:String=null, wordWrap:Boolean=false, lastAlign:String=null, fontSize:Number=0, fontFamily:String=null, fontWeight:String=null, fontPosture:String=null)
		{		
			super();
			
			shadowDistance = 4 * AppModel.instance.scale;
			mainLabel	= new RTLLabel(text, color,			align, direction, wordWrap, lastAlign, fontSize, fontFamily, fontWeight, fontPosture);
			mainLabel.pixelSnapping = false;

			shadowLabel = new RTLLabel(text, shadowColor,	align, direction, wordWrap, lastAlign, fontSize, fontFamily, fontWeight, fontPosture);
			shadowLabel.pixelSnapping = false;
		}

		override protected function initialize():void
		{
			super.initialize();
			layout = new AnchorLayout();
			
			mainLabel.layoutData = new AnchorLayoutData(-shadowDistance, 0, shadowDistance, 0);
			shadowLabel.layoutData = new AnchorLayoutData(0, 0, 0, 0);
			
			addChild(shadowLabel)
			addChild(mainLabel);
		}
		
		
		public function get text():String
		{
			return _text;
		}
		
		public function set text(value:String):void
		{
			if( _text == value )
				return;
			
			_text = value;
			mainLabel.text = _text;
			shadowLabel.text = _text;
		}

	}
}