package mediator.panel
{
import flash.events.MouseEvent;

import model.FileProcessor;

import org.robotlegs.mvcs.Mediator;

import view.panel.StartPanel;

public class StartPanelMediator extends Mediator
{
	[Inject] public var v:StartPanel;
	
	[Inject] public var file:FileProcessor;
	
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
		file.openSwf();
	}
	
	protected function handler_openPicBTNClick(event:MouseEvent):void
	{
		file.openPics();
	}
	
	protected function handler_openSSBTNclick(event:MouseEvent):void
	{
		file.openSS();
	}
}
}