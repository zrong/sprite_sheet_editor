////////////////////////////////////////////////////////////////////////////////
//  zengrong.net
//  创建者:	zrong(zrongzrong@gmail.com)
//  创建时间：2011-8-9
////////////////////////////////////////////////////////////////////////////////

package utils
{
import com.adobe.serialization.json.JSON;

import flash.filesystem.File;
import flash.geom.Rectangle;

/**
 * 生成Metadata
 * @author zrong
 */
public class MetadataBuilder
{
	/**
	 * 返回JSON格式的Metadata
	 * @param $isSimple 是否简单数据
	 */	
	public static function getJSONMeta($isSimple:Boolean=false):String
	{
		var __jsonObj:Object = {};
		var __framesArr:Array = [];
		for(var i:int=0;i<Global.instance.adjustedSheet.metadata.totalFrame;i++)
			__framesArr[i] = getRectJson(Global.instance.adjustedSheet.metadata.frameSizeRect[i]);
		__jsonObj.frames = __framesArr;
		//如果不是SWF状态，且选择了包含Name，就将文件的文件名存入MetaData中，下同
		if(Global.instance.adjustedSheet.metadata.hasName)
		{
			__jsonObj.names = {};
			var __nameKey:String = null;
			for (var j:int = 0; j < Global.instance.adjustedSheet.metadata.names.length; j++) 
			{
				__nameKey = Global.instance.adjustedSheet.metadata.names[j];
				__jsonObj.names[__nameKey] = Global.instance.adjustedSheet.metadata.namesIndex[__nameKey];
			}
		}
		//加入附加信息
		if(!$isSimple)
		{
			var __addObj:Object = getJSONAddMeta();
			for(var __addKey:String in __addObj)
				__jsonObj[__addKey] = __addObj[__addKey];
		}
		return JSON.encode(__jsonObj);
	}
	
	/**
	 * 返回XML格式的Metadata
	 * @param $isSimple 是否简单数据
	 */	
	public static function getXMLMeta($isSimple:Boolean=false):String
	{
		var __xml:XML = <metadata />;
		var __frames:XML = <frames />;
		for(var i:int=0;i<Global.instance.adjustedSheet.metadata.totalFrame;i++)  
		{
			__frames.appendChild( getRectXML(Global.instance.adjustedSheet.metadata.frameSizeRect[i]) );
		}
		__xml.appendChild(__frames);
		if(Global.instance.adjustedSheet.metadata.hasName)
		{
			var __namesXML:XML = <names />;
			var __nameKey:String = null;
			for (var j:int = 0; j < Global.instance.adjustedSheet.metadata.names.length; j++) 
			{
				__nameKey = Global.instance.adjustedSheet.metadata.names[j];
				__namesXML[__nameKey] = Global.instance.adjustedSheet.metadata.namesIndex[__nameKey];
			}
			
			for(var __key:String in __namesObj)
			{
				__namesXML[__key] = __namesObj[__key];
			}
			__xml.appendChild(__namesXML);
		}
		if(!$isSimple)
		{
			var __addXMLList:XMLList = getXMLAddMeta().children();
			for(var i:int = 0;i<__addXMLList.length();i++)
			{
				__xml.appendChild(__addXMLList[i]);
			}
		}
		return '<?xml version="1.0" encoding="UTF-8"?>' + File.lineEnding + __xml.toXMLString();
	}
	
	/**
	 * 返回TXT格式的Metadata
	 * @param $isSimple 是否简单数据
	 */	
	public static function getTXTMeta($isSimple:Boolean=false):void
	{
		var __str:String = 'frames' + File.lineEnding;
		for(var i:int=0;i<Global.instance.adjustedSheet.metadata.totalFrame;i++)
		{
			__str += getRectTxt(Global.instance.adjustedSheet.metadata.frameSizeRect[i]);
		}
		var __nameStr:String = '';
		//如果不是SWF状态，且选择了包含Name，就将文件的文件名存入MetaData中
		if(Global.instance.adjustedSheet.metadata.hasName)
		{
			__nameStr += 'names' + File.lineEnding;
			var __nameKey:String = null;
			for (var j:int = 0; j < Global.instance.adjustedSheet.metadata.names.length; j++) 
			{
				__nameKey = Global.instance.adjustedSheet.metadata.names[j];
				__nameStr += __nameKey + '=' + Global.instance.adjustedSheet.metadata.namesIndex[__nameKey] + File.lineEnding;
			}
		}
		__str += __nameStr;
		//如果需要附加信息，要在帧信息前面加上frames字样
		if(!$isSimple)
			__str += getTXTAddMeta();
	}
	
	public static function getJSONAddMeta():Object
	{
		var __framesArr:Array = [];
		var __jsonObj:Object = {};
		//写入sheet的类型
		__jsonObj.sheetType = Global.instance.adjustedSheet.metadata.type;
		__jsonObj.isEqualSize = Global.instance.adjustedSheet.metadata.isEqualSize;
		__jsonObj.hasLabel = Global.instance.adjustedSheet.metadata.hasLabel;
		__jsonObj.maskType = Global.instance.adjustedSheet.metadata.maskType;
		__jsonObj.hasName = Global.instance.adjustedSheet.metadata.hasName;
		__jsonObj.totalFrame = Global.instance.adjustedSheet.metadata.totalFrame;
		if(Global.instance.adjustedSheet.metadata.hasLabel)
		{
			__jsonObj.labels = Global.instance.adjustedSheet.metadata.labelsFrame;
			__jsonObj.labels.count = Global.instance.adjustedSheet.metadata.labels.length;
		}
		return __jsonObj;
	}
	
	public static function getXMLAddMeta():XML
	{
		var __key:String = '';
		var __xml:XML = <metadata />;
		__xml.sheetType = Global.instance.adjustedSheet.metadata.type;
		__xml.isEqualSize = Global.instance.adjustedSheet.metadata.isEqualSize;
		__xml.hasLabel = Global.instance.adjustedSheet.metadata.hasLabel;
		__xml.maskType = Global.instance.adjustedSheet.metadata.maskType;
		__xml.hasName = Global.instance.adjustedSheet.metadata.hasName;
		__xml.totalFrame = Global.instance.adjustedSheet.metadata.totalFrame;
		if(Global.instance.adjustedSheet.metadata.hasLabel)
		{
			var __labelXML:XML = <labels />;
			__labelXML.@count = Global.instance.adjustedSheet.metadata.labels.length;
			for(__key in Global.instance.adjustedSheet.metadata.labelsFrame)
			{
				__labelXML[__key] = Global.instance.adjustedSheet.metadata.labelsFrame[__key].toString();
			}
			__xml.appendChild(__labelXML);
		}
		return __xml;
	}
	
	public static function getTXTAddMeta():String
	{
		var i:int=0;
		var __str:String = '';
		__str += getTextKeyValue('sheepType', Global.instance.adjustedSheet.metadata.type);
		__str += getTextKeyValue('isEqualSize',Global.instance.adjustedSheet.metadata.isEqualSize);
		__str += getTextKeyValue('hasLabel',Global.instance.adjustedSheet.metadata.hasLabel);
		__str += getTextKeyValue('maskType',Global.instance.adjustedSheet.metadata.maskType);
		__str += getTextKeyValue('hasName',Global.instance.adjustedSheet.metadata.hasName);
		__str += getTextKeyValue('totalFrame',Global.instance.adjustedSheet.metadata.totalFrame);
		trace('hasLabel:', Global.instance.adjustedSheet.metadata.hasLabel);
		if(Global.instance.adjustedSheet.metadata.hasLabel)
		{
			__str += 'labels'+File.lineEnding;
			__str += getTextKeyValue('count', Global.instance.adjustedSheet.metadata.labels.length);
			var __labelName:String = '';
			for(i=0; i<Global.instance.adjustedSheet.metadata.labels.length; i++)
			{
				__labelName = Global.instance.adjustedSheet.metadata.labels[i];
				__str += __labelName + '=' + Global.instance.adjustedSheet.metadata.labelsFrame[__labelName].toString();
			}
		}
		return __str;
	}
	
	/**
	 * 返回Frame的Rect的Json格式
	 */	
	public static function getRectJson($rect:Rectangle):Object
	{
		return {x:$rect.x, y:$rect.y, w:$rect.width, h:$rect.height};
		//trace($rect);
	}
	
	/**
	 * 返回Frame的Rect的XML格式
	 */	
	public static function getRectXML($rect:Rectangle):XML
	{
		var __xml:XML = <frame />;
		__xml.x = $rect.x;
		__xml.y = $rect.y;
		__xml.w = $rect.width;
		__xml.h = $rect.height;
		return __xml;
	}
	
	/**
	 * 返回Frame的Rect的纯文本格式
	 */	
	public static function getRectTxt($rect:Rectangle):String
	{
		return $rect.x+','+$rect.y+','+$rect.width+','+$rect.height+File.lineEnding;
	}
	
	public static function getTextKeyValue($key:String, $value:*):String
	{
		return $key + '=' + $value.toString()+ File.lineEnding;
	}
}
}