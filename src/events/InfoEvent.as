package events
{
import flash.events.Event;

public class InfoEvent extends Event
{
	public static const FRAME_CHANGE:String = 'frameChange';
	
	public var info:*;
	
	public function InfoEvent($type:String, $info:*=null, $bubbles:Boolean=false, $cancelable:Boolean=false)
	{
		super($type, $bubbles, $cancelable);
		info = $info;
	}
	
	override public function clone():Event
	{
		return new InfoEvent(type, info, bubbles, cancelable);
	}		
}
}