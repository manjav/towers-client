package com.gerantech.towercraft.utils
{	
	import flash.display.Loader;
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.IOErrorEvent;
	import flash.events.ProgressEvent;
	import flash.filesystem.File;
	import flash.net.URLLoader;
	import flash.net.URLRequest;
	import flash.net.URLStream;
	import flash.system.ApplicationDomain;
	import flash.system.LoaderContext;
	import flash.utils.ByteArray;
	import flash.utils.setTimeout;
	
	//import gt.utils.GTStreamer;
	
	[Event(name="cancel", type="flash.events.Event")]
	[Event(name="complete", type="flash.events.Event")]
	[Event(name="complete", type="flash.events.Event")]
	[Event(name="ioError", type="flash.events.IOErrorEvent")]
	[Event(name="progress", type="flash.events.ProgressEvent")]
	
	public class LoadAndSaver extends EventDispatcher
	{
		public var fileUTFData:String;
		public var fileLoader:Loader;
		public var loading:Boolean;
		
		private var localPath:String;
		private var webPath:String;
		private var md5:String;
		private var extention:String;
		private var isLoader:Boolean;
		private var sizeCheck:uint;
		
		private var urlStream:URLStream;
		private var urlLoader:URLLoader;
		private var gtStreamer:GTStreamer;
		public var byteArray:ByteArray;
		
		public function LoadAndSaver(localPath:String, webPath:String, md5:String=null, isLoader:Boolean=false, sizeCheck:uint=0):void
		{
			//trace(localPath, webPath)
			this.localPath = localPath;
			this.webPath = webPath;
			this.isLoader = isLoader;
			this.md5 = md5;
			this.sizeCheck = sizeCheck;
			extention = localPath.substr(localPath.lastIndexOf('.')+1)
			loading = true;
			
			var file:File = new File(localPath);
			if(file.exists)
			{
				gtStreamer = new GTStreamer(file, loacalFileLoadHandler, null, null, !UTFMode&&!isSound&&!isBytes);
			} 
			else
			{
				var urlRequest:URLRequest = new URLRequest(this.webPath);
				if(UTFMode)
				{
					urlLoader = new URLLoader();
					urlLoader.addEventListener(Event.COMPLETE, webFileLoadHandler);
					urlLoader.addEventListener(IOErrorEvent.IO_ERROR, webFileErrorHandler);
					urlLoader.addEventListener(ProgressEvent.PROGRESS, webFileProgressHandler);
					urlLoader.load(urlRequest);
				} 
				else 
				{
					urlStream = new URLStream();
					urlStream.addEventListener(Event.COMPLETE, webFileLoadHandler);
					urlStream.addEventListener(IOErrorEvent.IO_ERROR, webFileErrorHandler);
					urlStream.addEventListener(ProgressEvent.PROGRESS, webFileProgressHandler);
					urlStream.load(urlRequest);
				}
				////////if(user.language!=null && verbose)user.dispatchEvent(new UserEvent(UserEvent.PROGRESS, -1, progMessage+' '+user.language.download.@start, closeLoader));
			}
		}
		

		private function loacalFileLoadHandler(streamer:GTStreamer):void
		{
			UTFMode ? fileUTFData = streamer.utfBytes : fileLoader = streamer.loader;
			byteArray = UTFMode ? null : streamer.bytes;
			finalizeLoad();
		}
		
		private function webFileErrorHandler(event:IOErrorEvent=null):void
		{
			if(hasEventListener(IOErrorEvent.IO_ERROR))
				dispatchEvent(event.clone());
			else
				trace(event.text);
			setTimeout(closeLoader, 1000);
		}
		private function webFileProgressHandler(event:ProgressEvent):void
		{
			//var bt:Number = Boolean(event.bytesTotal==0 && e.bytesLoaded!=0) ? 1500000 : e.bytesTotal;
			if(hasEventListener(event.type))
				dispatchEvent(event.clone());
			///////if(user!=null && user.language!=null && verbose)user.dispatchEvent(new UserEvent(UserEvent.PROGRESS, bt, progMessage+' '+user.language.download.@progress+uint(bt*100)+' %', closeLoader));
		}
		private function webFileLoadHandler(event:Event):void
		{
			gtStreamer = new GTStreamer(localPath, finalizeLoad, null, null, false, false);
			////if(user.language!=null && verbose)user.dispatchEvent(new UserEvent(UserEvent.PROGRESS, -2, progMessage+' '+user.language.download.@complete));
			if(UTFMode)
			{
				fileUTFData = event.target.data;
				urlLoader.close();
				if(isXML && fileUTFData.substr(0, 1)!='<')
				{
					webFileErrorHandler();
					return;
				}
				checkAndSave(fileUTFData);
			} 
			else 
			{
				byteArray = new ByteArray();
				urlStream.readBytes(byteArray);
				urlStream.close();
				
				if(Boolean(extention=='jbqr'||extention=='jpg') && byteArray.readUTFBytes(3)!='ÿØÿ')
				{
					webFileErrorHandler(new IOErrorEvent(IOErrorEvent.IO_ERROR, false, false, "Not jpeg file."));
					return;
				}
				if((extention=="dat"||extention=="mp3")&&byteArray.length<2000)
				{
					webFileErrorHandler(new IOErrorEvent(IOErrorEvent.IO_ERROR, false, false, "Not mp3 file."));
					return;
				}
				byteArray.position=0;
				checkAndSave(byteArray);
				//byteArray.clear();
			}
		}
		
		private function checkAndSave(data:*):void
		{
			/*if(md5!=null)
			{
				var _md5:String = UTFMode?MD5.hash(data):MD5.hashBytes(data);
				//trace(localPath, md5 ,_md5)
				if(md5!=_md5)
				{
					webFileErrorHandler(new IOErrorEvent(IOErrorEvent.IO_ERROR, false, false, "md5 check failed."));
					return;
				}
			}*/
			if(sizeCheck>0 && sizeCheck!=data.length)
			{
				webFileErrorHandler(new IOErrorEvent(IOErrorEvent.IO_ERROR, false, false, "size check failed."));
				return;
			}
			gtStreamer.save(data);
			//MD5.hash(fileUTFData);
		}
		
		private function finalizeLoad(s:GTStreamer=null):void
		{
			if(byteArray)
				byteArray.position = 0;
			
			closeLoader(false);
			if(isLoader)
				loadLoaderBytes();
			else if(hasEventListener(Event.COMPLETE))
				dispatchEvent(new Event(Event.COMPLETE));
		}
		
		private function loadLoaderBytes():void
		{
			fileLoader = new Loader();
			//var loaderContext:LoaderContext = new LoaderContext();
			var loaderContext:LoaderContext = new LoaderContext(false, ApplicationDomain.currentDomain);
			loaderContext.allowCodeImport = true;
			loaderContext.allowLoadBytesCodeExecution = true;
			fileLoader.contentLoaderInfo.addEventListener(Event.COMPLETE, fileLoader_completeHandler);
			fileLoader.contentLoaderInfo.addEventListener(IOErrorEvent.IO_ERROR, fileLoader_ioErrorHandler);
			fileLoader.loadBytes(byteArray, loaderContext);

		}
		
		protected function fileLoader_ioErrorHandler(event:IOErrorEvent):void
		{
			fileLoader.contentLoaderInfo.removeEventListener(IOErrorEvent.IO_ERROR, fileLoader_ioErrorHandler);
			fileLoader.contentLoaderInfo.removeEventListener(Event.COMPLETE, fileLoader_completeHandler);
		}
		
		protected function fileLoader_completeHandler(event:Event):void
		{
			fileLoader.contentLoaderInfo.removeEventListener(IOErrorEvent.IO_ERROR, fileLoader_ioErrorHandler);
			fileLoader.contentLoaderInfo.removeEventListener(Event.COMPLETE, fileLoader_completeHandler);
			if(hasEventListener(Event.COMPLETE))
				dispatchEvent(new Event(Event.COMPLETE));
		}
		
		public function closeLoader(hasError:Boolean=true):void
		{
			loading = false;
			/*if(UTFMode)
			{
			if(urlLoader!=null)urlLoader.close();
			}
			else 
			{
			if(urlStream!=null)urlStream.close();
			}*/
			
			/////if(hasError && user!=null && user.language!=null && verbose)user.dispatchEvent(new UserEvent(UserEvent.PROGRESS, -2, progMessage+' '+user.language.download.@cancel));
			try 
			{
				if(urlLoader!=null)
				{
					urlLoader.removeEventListener(Event.COMPLETE, webFileLoadHandler);
					urlLoader.removeEventListener(IOErrorEvent.IO_ERROR, webFileErrorHandler);
					urlLoader.removeEventListener(ProgressEvent.PROGRESS, webFileProgressHandler);
					urlLoader.close();
					urlLoader = null;
				}
				if(urlStream!=null)
				{
					urlStream.removeEventListener(Event.COMPLETE, webFileLoadHandler);
					urlStream.removeEventListener(IOErrorEvent.IO_ERROR, webFileErrorHandler);
					urlStream.removeEventListener(ProgressEvent.PROGRESS, webFileProgressHandler);
					if(urlStream.connected)
						urlStream.close();
					urlStream = null;
				}
				if(gtStreamer!=null)
				{
					gtStreamer.close();
					gtStreamer = null;
				}
			}
			catch(e:Error) 
			{
				trace("LoadAndSaver An error occurred " + e.toString());
			}
		}
		
		private function get UTFMode():Boolean
		{
			return (extention=='txt'||extention=="xbqr"||extention=='xml'||extention=='md5');
		}
		
		
		public function get isBytes():Boolean
		{
			return (extention=='bt'||extention=="zbqr");
		}
		
		private function get isSound():Boolean
		{
			return (extention=='dat'||extention=="mp3");
		}
		
		private function get isXML():Boolean
		{
			return (extention=="xbqr"||extention=='xml');
		}
		
		private function getCharCodes(str:String):Number
		{
			return(str.charCodeAt()-str.charCodeAt(1)+str.charCodeAt(2))
		}
	}
}