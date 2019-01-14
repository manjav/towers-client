package com.gerantech.towercraft.views 
{
import flash.utils.Dictionary;
/**
* ...
* @author Mansour Djawadi
*/
public class ArtRules 
{
static public const BULLET:String = "bullet";
static public const FIRE:String = "fire";
static public const EXPLOSION:String = "explode";
static public const DIE:String = "die";
static public const SUMMON_SFX:String = "summonSFX";
static public const ATTACK_SFX:String = "attackSFX";
static public const EXPLOSION_SFX:String = "explodeSFX";

private var rules:Dictionary;
public function ArtRules(data:Object)
{
	rules = new Dictionary();
	for ( var i:int = 0; i < data.units.length; i++ )
		rules[data.units[i].id] = data.units[i];
}

public function get(type:int, attribute:String) : String
{
	if( rules[type] == null )
		return "";
	return rules[type][attribute];
}
public function getArray(type:int, attribute:String) : Array
{
	if( rules[type] == null )
		return null;
	return rules[type][attribute];
}
}
}