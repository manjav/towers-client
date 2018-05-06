package com.gerantech.towercraft.managers 
{
import flash.utils.Dictionary;
import starling.extensions.PDParticleSystem;
import starling.textures.Texture;

/**
* ...
* @author Mansour Djawadi
*/
public class ParticleManager
{
	
[Embed(source="../../../../assets/particles/fire/particle.pex", mimeType="application/octet-stream")]
private static const fireConfig:Class;
[Embed(source="../../../../assets/particles/fire/texture.png")]
private static const fireParticle:Class;

[Embed(source="../../../../assets/particles/scrap/particle.pex", mimeType="application/octet-stream")]
private static const scrapConfig:Class;
[Embed(source="../../../../assets/particles/scrap/texture.png")]
private static const scrapParticle:Class;

private static var allTextures:Dictionary = new Dictionary();
private static var allXMLs:Dictionary = new Dictionary();
public function ParticleManager() {}

/**
 * Returns a texture from this class based on a string key.
 * @param name A key that matches a static constant of Bitmap type.
 * @return a starling texture.
 */
private static function getTextureByBitmap(name:String) : Texture
{
	if( allTextures[name] == undefined )
		allTextures[name] = Texture.fromEmbeddedAsset(ParticleManager[name + "Particle"]);
		//allTextures[name] = Texture.fromAtfData(new ParticleManager[name + "Particle"], 1, false);
	return allTextures[name];
}

/**
 * Returns a xml from this class based on a string key.
 * @param name A key that matches a static constant of XML type.
 * @return a particle config.
 */
private static function getParticleData(name:String) : XML
{
	if( allXMLs[name] == undefined )
		allXMLs[name] = XML(new ParticleManager[name + "Config"]())
	return allXMLs[name];
}

public static function getParticle(name:String) : PDParticleSystem
{
	var ret:PDParticleSystem = new PDParticleSystem(getParticleData(name), getTextureByBitmap(name));
	/*ret.emitterX = stage.stageWidth * 0.5;
	ret.emitterY = stage.stageHeight;
	//ret.emissionRate = 555
	ret.start();
	addChild(ret);
	Starling.juggler.add(ret);*/
	return ret;
}
}
}