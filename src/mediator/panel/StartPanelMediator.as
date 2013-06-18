package mediator.panel
{
import events.SSEvent;
import flash.events.MouseEvent;
import org.robotlegs.mvcs.Mediator;
import type.StateType;
import view.panel.StartPanel;

public class StartPanelMediator extends Mediator
{
	[Inject] public var v:StartPanel;
	
	override public function onRegister():void
	{
		eventMap.mapListener(v.openSWFBTN, MouseEvent.CLICK, handler_openSWFBTNClick);
		eventMap.mapListener(v.openPicBTN, MouseEvent.CLICK, handler_openPicBTNClick);
		eventMap.mapListener(v.openSSBTN, MouseEvent.CLICK, handler_openSSBTNclick);
	}
	
	override public function onRemove():void
	{
		eventMap.unmapListener(v.openSWFBTN, MouseEvent.CLICK, handler_openSWFBTNClick);
		eventMap.unmapListener(v.openPicBTN, MouseEvent.CLICK, handler_openPicBTNClick);
		eventMap.unmapListener(v.openSSBTN, MouseEvent.CLICK, handler_openSSBTNclick);
	}
	
	
	protected function handler_openSWFBTNClick(event:MouseEvent):void
	{
		dispatch(new SSEvent(SSEvent.BROWSE_FILE,StateType.SWF));
	}
	
	protected function handler_openPicBTNClick(event:MouseEvent):void
	{
		dispatch(new SSEvent(SSEvent.BROWSE_FILE,StateType.PIC));
	}
	
	protected function handler_openSSBTNclick(event:MouseEvent):void
	{
		dispatch(new SSEvent(SSEvent.BROWSE_FILE,StateType.SS));
	}
}
}