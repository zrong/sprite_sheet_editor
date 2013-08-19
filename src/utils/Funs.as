package utils
{
import flash.geom.Rectangle;

import mx.managers.PopUpManager;

import gnu.as3.gettext.FxGettext;
import gnu.as3.gettext.ISO_3166;
import gnu.as3.gettext.ISO_639_1;
import gnu.as3.gettext.Locale;

import org.zengrong.air.utils.getDesc;
import org.zengrong.utils.MathUtil;
import org.zengrong.utils.SOUtil;

import view.comps.Alert;

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
	
	/**
	 * 根据提供的Rectangle数组计算最终Sheet的宽高以及每帧在Sheet中的位置
	 * @param $frameRect 当前帧的独立大小
	 */
	public static function calculateSize($frameRects:Vector.<Rectangle>, 
								   $newSizeRects:Vector.<Rectangle>,
								   $whRect:Rectangle, 
								   $limitW:Boolean, 
								   $wh:int,
								   $powOf2:Boolean=false,
								   $square:Boolean=false):void
	{
		if($frameRects.length==0) return;
		var __frameRect:Rectangle = $frameRects[0];
		$newSizeRects[0] = new Rectangle(0,0,__frameRect.width, __frameRect.height);
		var __rectInSheet:Rectangle = new Rectangle(0,0,__frameRect.width,__frameRect.height);
		trace('getSheetWH:', __rectInSheet, __frameRect, $whRect);
		//设置sheet的初始宽高
		if($limitW)
		{
			//若限制宽度小于帧的宽度，就扩大限制宽度
			$whRect.width = $wh;
			if($whRect.width<__frameRect.width) $whRect.width = __frameRect.width;
			//计算2的幂
			if($powOf2) $whRect.width = MathUtil.nextPowerOf2($whRect.width);
			$whRect.height = __frameRect.height;
		}
		else
		{
			$whRect.height = $wh;
			if($whRect.height<__frameRect.height) $whRect.height = __frameRect.height;
			if($powOf2) $whRect.height = MathUtil.nextPowerOf2($whRect.height);
			$whRect.width = __frameRect.width;
		}
		for (var i:int = 1; i < $frameRects.length; i++) 
		{
			__frameRect = $frameRects[i];
			updateRectInSheet(__rectInSheet, $whRect, __frameRect, $limitW);
			trace('getSheetWH:', __rectInSheet, __frameRect, $whRect);
			$newSizeRects[i] = __rectInSheet.clone();
		}
		if($square)
		{
			//计算正方形的尺寸
			if($whRect.width!=$whRect.height)
			{
				//使用当前计算出的面积开方得到正方形的基准尺寸
				var __newWH:int = Math.sqrt($whRect.width*$whRect.height);
				//使用基准尺寸重新排列一次
				calculateSize($frameRects,$newSizeRects,$whRect,$limitW,__newWH, $powOf2);
				//trace('正方形计算1:', $whRect);
				//如果基准尺寸无法实现正方形尺寸，就使用结果WH中比较大的那个尺寸作为正方形边长
				if($whRect.width!=$whRect.height)
				{
					var __max:int = Math.max($whRect.width, $whRect.height);
					$whRect.width = __max;
					$whRect.height = __max;
				}
				//trace('正方形计算2:', $whRect);
			}
		}
		if($powOf2)
		{
			$whRect.width = MathUtil.nextPowerOf2($whRect.width);
			$whRect.height = MathUtil.nextPowerOf2($whRect.height);
		}
	}
	
	/**
	 * 更新在Sheet中帧的Rect的位置，根据Rect位置计算出大Sheet的WH
	 * 会直接修改$rectInSheet和$whRect参数的值。
	 * @param $rectInSheet	当前处理的帧在整个Sheet中的位置和大小，会修改此参数的值
	 * @param $whRect		保存Sheet的W和H，会修改此参数的值
	 * @param $frameRect	要处理的帧大小的Rect
	 * @param $limitW		为true代表限制宽度，否则是显示高度
	 */
	public static function updateRectInSheet($rectInSheet:Rectangle, 
											 $whRect:Rectangle,
											 $frameRect:Rectangle,
											 $limitW:Boolean):void
	{

		//限制宽度的计算
		if($limitW)
		{
			$rectInSheet.height = $frameRect.height;
			//若限制宽度小于帧的宽度，就扩大限制宽度，并进入新行
			if($whRect.width < $frameRect.width)
			{
				$whRect.width = $frameRect.width;
				newRow($rectInSheet, $frameRect, $whRect);
			}
				//如果这一行的宽度已经不够放下当前的位图，就进入新行
			else if($rectInSheet.right + $frameRect.width > $whRect.width)
			{
				newRow($rectInSheet, $frameRect, $whRect);
			}
			else
			{
				$rectInSheet.x += $rectInSheet.width;
				//如果当前帧比较高，就增加Sheet的高度
				if($whRect.height<$rectInSheet.bottom)
					$whRect.height = $rectInSheet.bottom;
			}
			//更新帧的宽
			$rectInSheet.width = $frameRect.width;
		}
		//限制高度的计算
		else
		{
			//更新帧的宽
			$rectInSheet.width = $frameRect.width;
			//若限制高度小于帧的高度，就扩大限制高度，并进入新列
			if($whRect.height < $frameRect.height)
			{
				$whRect.height = $frameRect.height;
				newColumn($rectInSheet, $frameRect, $whRect);
			}
			//如果这一列的高度已经放不下当前的位图，就进入新列
			else if($rectInSheet.bottom + $frameRect.height > $whRect.height)
			{
				newColumn($rectInSheet, $frameRect, $whRect);
			}
			else
			{
				//如果当前帧比Sheet还要宽，就增大Sheet的宽度
				$rectInSheet.y += $rectInSheet.height;
				if($whRect.width<$rectInSheet.right)
					$whRect.width = $rectInSheet.right;
			}
			
			$rectInSheet.height = $frameRect.height;
		}
	}
	
	private static function newRow($rectInSheet:Rectangle, $frameRect:Rectangle, $whRect:Rectangle):void
	{
		//让x回到行首
		$rectInSheet.x = 0;
		//更新新行的y值
		$rectInSheet.y = $whRect.height;
		//更新Sheet的高度
		$whRect.height += $frameRect.height;
	}
	
	private static function newColumn($rectInSheet:Rectangle, $frameRect:Rectangle, $whRect:Rectangle):void
	{
		$rectInSheet.y = 0;
		$rectInSheet.x = $whRect.width;
		$whRect.width += $frameRect.width;
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
}
}