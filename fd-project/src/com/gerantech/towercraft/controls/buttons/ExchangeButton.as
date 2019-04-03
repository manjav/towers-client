package com.gerantech.towercraft.controls.buttons
{
import com.gerantech.towercraft.models.Assets;
import com.gerantech.towercraft.utils.StrUtils;
import com.gt.towers.constants.ResourceType;
import starling.textures.Texture;

public class ExchangeButton extends CustomButton
{
private var _type:int = -2;
private var _count:int = -2;
public var currency:String = "";		
public function ExchangeButton(){super();}
public function set count(value:int):void
{
	if( _count == value )
		return;
	_count = value;
	
	if( _count == -1 )
		label = loc("open_label");
	else if( _count == 0 )
		label = loc("free_label");
	else
		label = StrUtils.getCurrencyFormat(_count) + " " + currency;
}
public function get count():int
{
	return _count;
}

public function set type(value:int):void
{
	if( _type == value )
		return;
	_type = value;
	
	var hasIcon:Boolean = _count > 0 && _type > 0 && _type != ResourceType.R5_CURRENCY_REAL;
	if( hasIcon )
		icon = Assets.getTexture("res-" + _type, "gui");
	else
		icon = null;
}
public function get type():int
{
	return _type;
}


static public function getIcon(count:int, type:int) : Texture
{
	var hasIcon:Boolean = count > 0 && type > 0 && type != ResourceType.R5_CURRENCY_REAL;
	if( hasIcon )
		return Assets.getTexture("res-" + type, "gui");
	return null;
}

static public function getLabel(count:int, type:int) : String
{
	if( count == -1 )
		return StrUtils.loc("open_label");
	if( count == 0 )
		return StrUtils.loc("free_label");
	return StrUtils.getCurrencyFormat(count)//+ " " + currency;
}
}
}