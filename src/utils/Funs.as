package utils
{
import flash.display.BitmapData;

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
		//使用不带参数的SpriteSheet，是为了不让其执行parseBMD方法。因为这里的位图是空位图，并不需要解析
		Global.instance.sheet = new SpriteSheet();
		if($bmd)
			Global.instance.sheet.bitmapData = $bmd;
		if($meta)
			Global.instance.sheet.metadata = $meta;
		else
			Global.instance.sheet.metadata = new SpriteSheetMetadata();
	}
	
}
}