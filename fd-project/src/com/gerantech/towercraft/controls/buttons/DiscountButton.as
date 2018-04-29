package com.gerantech.towercraft.controls.buttons 
{
import com.gerantech.towercraft.controls.groups.Devider;
import com.gerantech.towercraft.controls.texts.RTLLabel;
import com.gerantech.towercraft.models.Assets;
import com.gt.towers.constants.ResourceType;
import feathers.controls.ButtonState;
import feathers.layout.AnchorLayoutData;
import starling.textures.Texture;
/**
* ...
* @author MAnsour Djawadi
*/
public class DiscountButton extends ExchangeButton 
{
	private var _originCount:int;
	private var originLayoutData:AnchorLayoutData;
	private var originDisplay:RTLLabel;

public function DiscountButton() 
{
	super();
	height = maxHeight = 140 * appModel.scale;
	shadowLayoutData = new AnchorLayoutData(NaN, padding, NaN, padding, NaN, padding * 2.5);
	labelLayoutData = new AnchorLayoutData(NaN, padding, NaN, padding, NaN, padding * 3.0);
	originLayoutData =new AnchorLayoutData(NaN, padding*5, NaN, padding*5, NaN, -padding * 3.0);
}

override protected function initialize():void
{
	super.initialize();
	
	originDisplay = new RTLLabel(_originCount.toString(), 0xBB0000, "center");
	originDisplay.layoutData = originLayoutData;
	addChildAt(originDisplay, 0);
	
	var line:Devider = new Devider(0xBB0000, 3);
	line.layoutData = originLayoutData;
	addChildAt(line, 0);
}

override public function set type(value:int):void
{
	if( super.type == value )
		return;
	super.type = value;
	
	var hasIcon:Boolean = value > 0 && value != ResourceType.CURRENCY_REAL;
	if( hasIcon )
		icon = Assets.getTexture("res-" + value, "gui");;
}

override public function set icon(value:Texture):void
{
	super.icon = value;
	originLayoutData.right = (super.icon == null?5:14) * padding;
}

override public function set currentState(value:String):void
{
	if( super.currentState == value )
		return;
	
	super.currentState = value;
	shadowLayoutData.verticalCenter = padding * (value == ButtonState.DOWN?3.0:2.5);
}

public function get originCount():int 
{
	return _originCount;
}
public function set originCount(value:int):void 
{
	if( _originCount == value )
		return;
	_originCount = value;
	if( originDisplay != null )
		originDisplay.text = _originCount.toString();
}
}
}