package utils
{
import view.comps.Alert;

import flash.desktop.NativeApplication;
import flash.display.BitmapData;
import flash.geom.Point;
import flash.geom.Rectangle;

import mx.managers.PopUpManager;

import org.zengrong.display.spritesheet.SpriteSheet;
import org.zengrong.display.spritesheet.SpriteSheetMetadata;

public class Funs
{
	/**
	 * 修改当前的State
	 * @param $state 要修改的状态的名称
	 * @see type.StateType
	 */	
	public static function changeState($state:String):void
	{
		Global.instance.currentState = $state;
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
	
	public static function resetSheet($bmd:BitmapData=null, $meta:SpriteSheetMetadata=null):void
	{
		if(Global.instance.sheet)
			Global.instance.sheet.destroy();
		Global.instance.sheet = new SpriteSheet($bmd, $meta);
	}
	
	public static function alert($text:String, $title:String='警告'):void
	{
		var __alert:Alert = PopUpManager.createPopUp(Global.instance.root, Alert, true) as Alert;
		__alert.title = $title;
		__alert.text = $text;
		var __xy:Array = getAlertXY(__alert);
		__alert.move(__xy[0], __xy[1]);
	}
	
	public static function confirm($text:String, $okHandler:Function, $cancelHandler:Function=null, $title:String="请确认"):void
	{
		var __alert:Alert = PopUpManager.createPopUp(Global.instance.root, Alert, true) as Alert;
		__alert.currentState = 'confirm';
		__alert.title = $title;
		__alert.text = $text;
		__alert.okHandler = $okHandler;
		__alert.cancelHandler = $cancelHandler;
		var __xy:Array = getAlertXY(__alert);
		__alert.move(__xy[0], __xy[1]);
	}
	
	private static function getAlertXY($alert:Alert):Array
	{
		return [(Global.instance.root.width-$alert.width)*.5, (Global.instance.root.height-$alert.height)*.5];
	}
	
}
}