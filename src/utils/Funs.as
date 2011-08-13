package utils
{
import comps.Alert;

import flash.display.BitmapData;
import flash.geom.Point;

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