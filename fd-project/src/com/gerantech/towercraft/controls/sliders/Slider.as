package com.gerantech.towercraft.controls.sliders
{
	import feathers.controls.ProgressBar;
	import feathers.layout.Direction;
	import feathers.layout.HorizontalAlign;
	
	public class Slider extends ProgressBar
	{
		
		public var horizontalAlign:String = "left";
		
		public function Slider()
		{
			super();
		}
		
		override protected function layoutChildren():void
		{
			if(this.currentBackground !== null)
			{
				this.currentBackground.width = this.actualWidth;
				this.currentBackground.height = this.actualHeight;
			}
			
			if(this._minimum === this._maximum)
			{
				var percentage:Number = 1;
			}
			else
			{
				percentage = (this._value - this._minimum) / (this._maximum - this._minimum);
				if(percentage < 0)
				{
					percentage = 0;
				}
				else if(percentage > 1)
				{
					percentage = 1;
				}
			}
			if(this._direction === Direction.VERTICAL)
			{
				this.currentFill.width = this.actualWidth - this._paddingLeft - this._paddingRight;
				this.currentFill.height = this._originalFillHeight + percentage * (this.actualHeight - this._paddingTop - this._paddingBottom - this._originalFillHeight);
				this.currentFill.x = this._paddingLeft;
				this.currentFill.y = this.actualHeight - this._paddingBottom - this.currentFill.height;
			}
			else //horizontal
			{
				this.currentFill.width = this._originalFillWidth + percentage * (this.actualWidth - this._paddingLeft - this._paddingRight - this._originalFillWidth);
				this.currentFill.height = this.actualHeight - this._paddingTop - this._paddingBottom;
				
				this.currentFill.x =  this._paddingLeft + ( horizontalAlign == HorizontalAlign.RIGHT ? actualWidth-currentFill.width : 0 );
				this.currentFill.y = this._paddingTop;
			}
		}
	}
}