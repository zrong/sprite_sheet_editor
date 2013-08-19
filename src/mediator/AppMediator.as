package mediator
{
import events.SSEvent;
import flash.desktop.ClipboardFormats;
import flash.desktop.NativeDragManager;
import flash.events.NativeDragEvent;
import mx.events.FlexEvent;
import org.robotlegs.mvcs.Mediator;

public class AppMediator extends Mediator
{
	[Inject] public var v:SpriteSheetEditor;
	
	override public function onRegister():void
	{
//		v.startState.addEventListener(FlexEvent.EXIT_STATE, handler_exitState);
//		v.picState.addEventListener(FlexEvent.EXIT_STATE, handler_exitState);
//		v.ssState.addEventListener(FlexEvent.EXIT_STATE, handler_exitState);
//		v.swfState.addEventListener(FlexEvent.EXIT_STATE, handler_exitState);
		eventMap.mapListener(eventDispatcher, SSEvent.ENTER_STATE, handler_enterState);
		v.addEventListener(NativeDragEvent.NATIVE_DRAG_ENTER, handler_nativeDragEnter);
		v.addEventListener(NativeDragEvent.NATIVE_DRAG_DROP, handler_nativeDragDrop);
	}
	
	private function handler_nativeDragDrop($evt:NativeDragEvent):void 
	{
		dispatch(new SSEvent(SSEvent.DRAG_FILE, $evt.clipboard.getData(ClipboardFormats.FILE_LIST_FORMAT) as Array));
	}
	
	private function handler_nativeDragEnter($evt:NativeDragEvent):void 
	{
		if($evt.clipboard.hasFormat(ClipboardFormats.FILE_LIST_FORMAT))
		{
			NativeDragManager.acceptDragDrop(v);
		}
	}
	
	private function handler_enterState($evt:SSEvent):void
	{
		v.currentState = $evt.info.newState;
	}
	
	protected function handler_exitState($event:FlexEvent):void
	{
		trace('退出状态', v.currentState);
		dispatch(new SSEvent(SSEvent.EXIT_STATE));
	}
}
}