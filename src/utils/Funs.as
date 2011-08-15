package utils
{
import comps.Alert;

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
	 * 更新在Sheet中帧的Rect的位置，会直接修改$rectInSheet和$whRect参数的值。
	 */
	public static function updateRectInSheet($rectInSheet:Rectangle, 
											 $whRect:Rectangle,
											 $frameRect:Rectangle,
											 $limitW:Boolean):void
	{
		//限制宽度的计算
		if($limitW)
		{
			//若限制宽度小于帧的宽度，就扩大限制宽度
			if($whRect.width < $frameRect.width)
			{
				$whRect.width = $frameRect.width;
				$rectInSheet.x = 0;
				$rectInSheet.y += $frameRect.height;
			}
				//如果这一行的宽度已经不够放下当前的位图，就将其放在下一行的开头
			else if($rectInSheet.right + $frameRect.width > $whRect.width)
			{
				$rectInSheet.x = 0;
				$rectInSheet.y += $frameRect.height;
			}
			else
			{
				$rectInSheet.x += $rectInSheet.width;
			}
			//更新帧的宽高
			$rectInSheet.width = $frameRect.width;
			$rectInSheet.height = $frameRect.height;
			$whRect.height = $rectInSheet.bottom;
		}
			//限制高度的计算
		else
		{
			if($whRect.height < $frameRect.height)
			{
				$whRect.height = $frameRect.height;
				$rectInSheet.y = 0;
				$rectInSheet.x += $frameRect.width;
			}
				//如果这一列的高度已经放不下当前的位图，就将其放在下一列的开头
			else if($rectInSheet.bottom + $frameRect.height > $whRect.height)
			{
				$rectInSheet.y = 0;
				$rectInSheet.x += $frameRect.width;
			}
			else
			{
				$rectInSheet.y += $rectInSheet.height;
			}
			//更新帧的宽高
			$rectInSheet.width = $frameRect.width;
			$rectInSheet.height = $frameRect.height;
			$whRect.width = $rectInSheet.right;
		}
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
	
	public static function confirm($text:String, $okHandler:Function, $title:String="请确认"):void
	{
		var __alert:Alert = PopUpManager.createPopUp(Global.instance.root, Alert, true) as Alert;
		__alert.currentState = 'confirm';
		__alert.title = $title;
		__alert.text = $text;
		__alert.okHandler = $okHandler;
		var __xy:Array = getAlertXY(__alert);
		__alert.move(__xy[0], __xy[1]);
	}
	
	private static function getAlertXY($alert:Alert):Array
	{
		return [(Global.instance.root.width-$alert.width)*.5, (Global.instance.root.height-$alert.height)*.5];
	}
	
}
}