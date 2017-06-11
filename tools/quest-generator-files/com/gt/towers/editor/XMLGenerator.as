package com.gt.towers.editor
{
	import flash.display.MovieClip;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.KeyboardEvent;
	import flash.events.MouseEvent;
	import flash.filesystem.File;
	import flash.net.FileFilter;
	import flash.net.FileReference;
	import flash.ui.Keyboard;
	import flash.utils.setTimeout;
	
	import fl.controls.CheckBox;
	
	public class XMLGenerator extends MovieClip
	{
		
		private var timelines:XMLList;
		private var places:Vector.<PlaceComponent>;
		private var selectedPalce:PlaceComponent;
		private var linksContainer:Sprite;
		private var questClassStr:String;
		
		public var intro_check:CheckBox;
		public var final_check:CheckBox;
		
		public function XMLGenerator()
		{
			linksContainer = new Sprite();
			
			var dom:File = File.applicationDirectory.resolvePath("quest-generator/DOMDocument.xml");
			dom.addEventListener(Event.COMPLETE, dom_completeHandler);
			setTimeout(dom.load, 100);
		}
		private function dom_completeHandler(event:Event):void
		{
			var xml:XML = new XML(event.currentTarget.data);
			timelines = xml.children()[3].children();
			resetPlaces();
		}
		private function addButtonsListener():void
		{
			load_btn.removeEventListener(MouseEvent.CLICK, load_btn_clickHandler);
			save_btn.removeEventListener(MouseEvent.CLICK, save_btn_clickHandler);
			next_btn.removeEventListener(MouseEvent.CLICK, scene_btn_clickHandler);
			prev_btn.removeEventListener(MouseEvent.CLICK, scene_btn_clickHandler);
			scene_txt.removeEventListener(KeyboardEvent.KEY_UP, scene_txt_keyUpHandler);

			load_btn.label_txt.text = "Load";
			load_btn.addEventListener(MouseEvent.CLICK, load_btn_clickHandler);
			save_btn.label_txt.text = "Save";
			save_btn.addEventListener(MouseEvent.CLICK, save_btn_clickHandler);
			
			next_btn.addEventListener(MouseEvent.CLICK, scene_btn_clickHandler);
			prev_btn.addEventListener(MouseEvent.CLICK, scene_btn_clickHandler);
			scene_txt.addEventListener(KeyboardEvent.KEY_UP, scene_txt_keyUpHandler);
			scene_txt.text = getSceneIndex().toString();
		}
		
		private function scene_btn_clickHandler(event:MouseEvent):void
		{
			var sceneIndex:int = getSceneIndex();
			if(event.currentTarget == next_btn)
			{
				if(sceneIndex < scenes.length-1)
					nextScene();
			}
			else
			{
				if(sceneIndex > 0)
					prevScene();
			}
			resetPlaces();
		}
		private function scene_txt_keyUpHandler(event:KeyboardEvent):void
		{
			if(event.keyCode == Keyboard.ENTER)
			{
				var sceneIndex:int = Math.max(0, Math.min(int(scene_txt.text), scenes.length-1));
				gotoAndStop(1, scenes[sceneIndex].name);
				resetPlaces();
			}
		}
		private function load_btn_clickHandler(event:Event):void
		{
			var sceneJson:FileReference = new FileReference();
			sceneJson.addEventListener(Event.SELECT, sceneJson_selectHandler);
			sceneJson.browse([new FileFilter("Json Files", "*.json")]);
			function sceneJson_selectHandler(event:Event):void
			{
				sceneJson.removeEventListener(Event.SELECT, sceneJson_selectHandler);
				sceneJson.addEventListener(Event.COMPLETE, sceneJson_completeHandler);
				sceneJson.load();
			}
		}
		private function resetPlaces():void
		{
			linksContainer.removeChildren();
			addChildAt(linksContainer, 1);
			addButtonsListener();
			
			if(places != null)
				for (var i:int=0; i<places.length; i++)
					places[i].removeEventListener(MouseEvent.MOUSE_DOWN, place_mouseDownHandler);
			
			places = new Vector.<PlaceComponent>();
			var place:PlaceComponent;
			var placeIndex:int = 0;
			for (i = 0; i<numChildren; i++)
			{
				place = getChildAt(i) as PlaceComponent;
				if(place != null)
				{
					place.index = placeIndex;
					places.push(place);
					place.addEventListener(MouseEvent.MOUSE_DOWN, place_mouseDownHandler);
					place.update();
					placeIndex ++;
				}
			}
		}
		private function sceneJson_completeHandler(event:Event):void
		{
			var json:Object = JSON.parse(event.currentTarget.data);
			if(json.name != currentScene.name || places.length!=json.places.length)
			{
				trace("Incompatiple data.");
				return;
			}
			
			resetPlaces();
			
			intro_check.selected = json.hasIntro;
			final_check.selected = json.hasFinal;
			for (var p:int=0; p < places.length; p++)
			{
				places[p].type = json.places[p].type;
				places[p].level = json.places[p].level;
				places[p].troopType = json.places[p].troopType;
				places[p].enabled = json.places[p].enabled;
				places[p].tutorIndex = json.places[p].tutorIndex;
				places[p].update();
				
				var jsonlink:int = -1;
				var a:PlaceComponent = places[p];
				var b:PlaceComponent;
				
				for (var l:int=0; l < json.places[p].links.length; l++)
				{
					jsonlink = json.places[p].links[l];
					if(a.links.indexOf(jsonlink) == -1 )
					{
						b = places[jsonlink];
						var linkMc:LinkComponent = new LinkComponent(a.index, b.index);
						linkMc.graphics.lineStyle(10, 0x999999);
						linkMc.graphics.moveTo(a.x, a.y);
						linkMc.graphics.lineTo(b.x, b.y);
						linkMc.addEventListener(MouseEvent.CLICK, linkMc_clickHandler);
						linksContainer.addChild(linkMc);
						a.links.push(b.index);
						b.links.push(a.index);
					}
				}
			}
		}

		// mouse handlers
		private function place_mouseDownHandler(event:MouseEvent):void
		{
			selectedPalce = event.currentTarget as PlaceComponent;
			stage.addEventListener(MouseEvent.MOUSE_MOVE, stage_mouseMoveHandler);
			stage.addEventListener(MouseEvent.MOUSE_UP, stage_mouseUpHandler);
		}
		private function stage_mouseMoveHandler(event:MouseEvent):void
		{
			event.updateAfterEvent();
			selectedPalce.graphics.clear();
			selectedPalce.graphics.lineStyle(10);
			selectedPalce.graphics.moveTo(0,0);
			
			selectedPalce.graphics.lineTo(selectedPalce.mouseX + (selectedPalce.mouseX>0?-10:10), selectedPalce.mouseY + (selectedPalce.mouseY>0?-10:10));
		}
		private function stage_mouseUpHandler(event:MouseEvent):void
		{
			selectedPalce.graphics.clear();
			var placeTarget:PlaceComponent = event.target.parent as PlaceComponent;//trace(event.target)
			if(placeTarget != null && placeTarget != selectedPalce)
			{
				if(selectedPalce.links.indexOf(placeTarget.index) == -1 )
				{
					var linkMc:LinkComponent = new LinkComponent(selectedPalce.index, placeTarget.index);
					linkMc.graphics.lineStyle(10, 0x999999);
					linkMc.graphics.moveTo(selectedPalce.x, selectedPalce.y);
					linkMc.graphics.lineTo(placeTarget.x, placeTarget.y);
					linkMc.addEventListener(MouseEvent.CLICK, linkMc_clickHandler);
					linksContainer.addChild(linkMc);
					
					selectedPalce.links.push(placeTarget.index);
					placeTarget.links.push(selectedPalce.index);
				}
			}
			
			stage.removeEventListener(MouseEvent.MOUSE_MOVE, stage_mouseMoveHandler);
			stage.removeEventListener(MouseEvent.MOUSE_UP, stage_mouseUpHandler);
			selectedPalce = null;
		}
		private function linkMc_clickHandler(event:MouseEvent):void
		{
			var linkMc:LinkComponent = event.currentTarget as LinkComponent;
			linkMc.parent.removeChild(linkMc);
			
			places[linkMc.places.x].links.splice(places[linkMc.places.x].links.indexOf(linkMc.places.y), 1);
			places[linkMc.places.y].links.splice(places[linkMc.places.y].links.indexOf(linkMc.places.x), 1);
		}
		
		private function save_btn_clickHandler(event:MouseEvent):void
		{
			questClassStr = '\r\r\r\t\tquest = new Quest("' + currentScene.name + '", ' + intro_check.selected + ', ' + final_check.selected + ' );\r\t\t// create places\r';

			var tutorSteps:String = "";
			var sceneIndex:int = getSceneIndex();
			var sceneData:Object = new Object();
			sceneData.name = currentScene.name;
			sceneData.hasIntro = intro_check.selected;
			sceneData.hasFinal = final_check.selected;
			var items:Array = new Array();
			for (var i:int=0; i<places.length; i++)
			{
				items.push( places[i].data );
				questClassStr += places[i].classString;
			}
			
			sceneData.places = items;
			sceneData.images = getImagesData(sceneIndex);
			
			questClassStr += '\t\tquests.set( "' + currentScene.name + '" , quest );\r';
			trace(questClassStr)
			
			var sceneJson:FileReference = new FileReference();
			sceneJson.save( JSON.stringify(sceneData) , currentScene.name+".json");
		}
		private function getSceneIndex():int
		{
			for(var s:int=0; s<scenes.length; s++)
				if(scenes[s].name == currentScene.name)
					return s;
			return 0;
		}
		
		private function getImagesData(t:int):Array
		{
			var items:Array = new Array();
			var bitmaps:XMLList = timelines[t].descendants("*");
			questClassStr += '\t\t// create images\r';
			for (var i:int=0; i<bitmaps.length(); i++)
			{
				if(bitmaps[i].name() == "http://ns.adobe.com/xfl/2008/::DOMBitmapInstance")
				{
					//trace(t, i, bitmaps[i].name())
					var bitmap:XML = bitmaps[i];
					var item:Object = new Object();
					
					var attName:String = bitmap.attribute("libraryItemName");
					attName = attName.split(".")[0];
					var ns:Array = attName.split("/");
					item.name = ns[ns.length-1];
					questClassStr+= '\t\tquest.images.push( new ImageData( "' + ns[ns.length-1] + '"\t';
					if(bitmap.children().length() > 0)
					{
						var bitmapChildren:XMLList = bitmap.descendants("*");
						for (var j:int=0; j<bitmapChildren.length(); j++)
						{
							if( bitmapChildren[j].name() == "http://ns.adobe.com/xfl/2008/::Matrix" )
							{
								addToItem(item, "tx", bitmapChildren[j], "tx");
								addToItem(item, "ty", bitmapChildren[j], "ty");
								addToItem(item, "a", bitmapChildren[j], "a");
								addToItem(item, "b", bitmapChildren[j], "b");
								addToItem(item, "c", bitmapChildren[j], "c");
								addToItem(item, "d", bitmapChildren[j], "d");
							}
							if( bitmapChildren[j].name() == "http://ns.adobe.com/xfl/2008/::Point" )
							{
								addToItem(item, "px", bitmapChildren[j], "x");
								addToItem(item, "py", bitmapChildren[j], "y");
							}
						}
					}
					items.push(item);
					questClassStr += ') );\r';
				}
			}
			
			function addToItem(item:Object, property:String, matrix:XML, attribute:String):void
			{
				var att:String = matrix.attribute(attribute);
				if(att != "" )
					item[property] = Number(att);
				else
					item[property] = property=="a"||property=="d" ? 1 : 0;
				
				questClassStr += ',\t' + item[property];
			}
			
			return items;
		}
	}
}