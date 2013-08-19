package interf
{
import flash.display.IBitmapDrawable;
import flash.events.IEventDispatcher;

public interface IPreview extends IEventDispatcher
{
	function destroy():void;
	function set source($so:*):void;
	function get content():IBitmapDrawable;
}
}