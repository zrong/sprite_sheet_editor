package utils
{
import flash.filesystem.File;
import flash.filesystem.FileMode;
import flash.filesystem.FileStream;
import flash.geom.Rectangle;

import gnu.as3.gettext.FxGettext;
import gnu.as3.gettext.ISO_3166;
import gnu.as3.gettext.ISO_639_1;
import gnu.as3.gettext.Locale;

import mx.managers.PopUpManager;

import org.zengrong.air.utils.getDesc;
import org.zengrong.display.spritesheet.SpriteSheetMetadataType;
import org.zengrong.net.SpriteSheetLoader;
import org.zengrong.utils.MathUtil;
import org.zengrong.utils.SOUtil;

import type.ExtendedNameType;
import type.StateType;

import view.panel.ProcessPanel;
import view.widget.Alert;

import vo.MetadataFileVO;

public class Funs
{
	public static function getLang():String
	{
		var __so:SOUtil = SOUtil.getSOUtil("sse");
		//获取已经保存的显示语言
		var __lang:String = __so.get("lang");
		//没有设置显示语言，则根据当前系统判断
		if(!__lang)
		{
			var __enus:String = mklocale(ISO_639_1.EN, ISO_3166.US);
			var __zhcn:String = mklocale(ISO_639_1.ZH, ISO_3166.CN);
			var __zhtw:String = mklocale(ISO_639_1.ZH, ISO_3166.TW);
			//若为简中或者繁中系统
			if( Locale.LANG == __zhcn ||
				Locale.LANG == __zhtw )
			{
				__lang = __zhcn;
			}
			//不是简中系统均使用英文
			else
			{
				__lang = __enus;
			}
			__so.save(__lang, "lang");
		}
		return __lang;
	}
	
	public static function mklocale(iso639:String, iso3166:String):String
	{
		return ISO_639_1.codes[iso639]+"_"+ISO_3166.codes[iso3166];
	}
	
	public static function alert($text:String, $title:String=null):void
	{
		var __alert:Alert = PopUpManager.createPopUp(Global.root, Alert, true) as Alert;
		__alert.title = $title?FxGettext.gettext($title):FxGettext.gettext("Warning");
		__alert.text = $text;
		var __xy:Array = getAlertXY(__alert);
		__alert.move(__xy[0], __xy[1]);
	}
	
	public static function confirm($text:String, $okHandler:Function, $cancelHandler:Function=null, $title:String=null):void
	{
		var __alert:Alert = PopUpManager.createPopUp(Global.root, Alert, true) as Alert;
		__alert.currentState = 'confirm';
		__alert.title = $title?FxGettext.gettext($title):FxGettext.gettext("Please Confirm");
		__alert.text = $text;
		__alert.okHandler = $okHandler;
		__alert.cancelHandler = $cancelHandler;
		var __xy:Array = getAlertXY(__alert);
		__alert.move(__xy[0], __xy[1]);
	}
	
	private static function getAlertXY($alert:Alert):Array
	{
		return [(Global.root.width-$alert.width)*.5, (Global.root.height-$alert.height)*.5];
	}
	
	public static function getCreatedWith():String
	{
		return "Created with " + getDesc("name") + " v" + getDesc("versionNumber");
	}
	
	public static function getXMLHeader($lineEnding:String):String
	{
			return '<?xml version="1.0" encoding="UTF-8"?>' +$lineEnding+ 
				"<!-- " + getCreatedWith() + " -->" + $lineEnding +
				"<!-- http://zengrong.net/sprite_sheet_editor -->" + $lineEnding;
	}
	
	/**
	 * 根据传递的图像文件查找该图像文件对应的外部metadata文件。
	 * 如果找不到文件，那么返回null
	 */
	public static function getMetadataFile($imgFile:File):MetadataFileVO
	{
		for(var i:int=0;i<SpriteSheetLoader.SUPPORTED_TYPES.length;i++)
		{
			var __type:String = SpriteSheetLoader.SUPPORTED_TYPES[i];
			var __metaUrl:String = SpriteSheetLoader.getMetadataUrl($imgFile.url, __type);
			var __file:File = new File(__metaUrl);
			if(__file.exists) 
			{
				var __metaFile:MetadataFileVO = new MetadataFileVO(__file, __type);
				//如果文件存在，需要判断这个文件的具体类型
				//不能相信 __type 的值，因SSE_XML和STARLING的文件扩展名都是xml
				if( __type == SpriteSheetMetadataType.SSE_XML ||
					__type == SpriteSheetMetadataType.STARLING)
				{
					var __stream:FileStream = new FileStream();
					__stream.open(__file, FileMode.READ);
					var __xml:XML = new XML(__stream.readUTFBytes(__stream.bytesAvailable));
					//若找到了对应的Tag，直接返回，不必继续循环
					if(__xml.localName() == "TextureAtlas")
						__metaFile.type = SpriteSheetMetadataType.STARLING;
					else if(__xml.localName() == "metadata")
						__metaFile.type = SpriteSheetMetadataType.SSE_XML;
				}
				return __metaFile;
			}
		}
		return null;
	}
	
	/**
	 * 根据当前传递的文件类型取得当前的界面状态
	 * @return
	 */
	public static function getStateByFile($file:File):String
	{
		if(ExtendedNameType.SWF_FILTER.extension.indexOf($file.type) > -1)
		{
			return StateType.SWF;
		}
		else if(ExtendedNameType.ALL_PIC_FILTER.extension.indexOf($file.type) > -1)
		{
			if(getMetadataFile($file)) return StateType.SS;
			return StateType.PIC;
		}
		return '';
	}
}
}