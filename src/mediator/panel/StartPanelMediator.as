package mediator.panel
{
import events.SSEvent;

import flash.events.MouseEvent;

import model.FileProcessor;

import org.robotlegs.mvcs.Mediator;

import type.StateType;

import view.panel.StartPanel;

public class StartPanelMediator extends Mediator
{
	[Inject] public var v:StartPanel;
	
	override public function onRegister():void
	{
		eventMap.mapListener(v.openBTN, MouseEvent.CLICK, handler_openBTNclick);
		//addContextListener(SSEvent.ENTER_STATE, handler_enterState);
	}
	
	override public function onRemove():void
	{
		eventMap.unmapListener(v.openBTN, MouseEvent.CLICK, handler_openBTNclick);
		//removeContextListener(SSEvent.ENTER_STATE, handler_enterState);
	}
	
	protected function handler_openBTNclick(event:MouseEvent):void
	{
		dispatch(new SSEvent(SSEvent.BROWSE_FILE, StateType.OPEN_OR_IMPORT));
	}
	
	public function handler_enterState($evt:SSEvent):void
	{
		//trace('StartPanelMediator.updateOnStateChanged:', $evt.info.oldState, $evt.info.newState);
	}
}
}