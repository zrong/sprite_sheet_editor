package mediator
{
import events.SSEvent;

import org.robotlegs.mvcs.Mediator;

import view.panel.SSPanel;

public class SSPanelMediator extends Mediator
{
	[Inject] public var v:SSPanel;
	
	override public function onRegister():void
	{
		eventMap.mapListener(eventDispatcher, SSEvent.ENTER_STATE, handler_enterState);
		eventMap.mapListener(eventDispatcher, SSEvent.EXIT_STATE, handler_exitState);
	}
	
	private function handler_enterState($evt:SSEvent):void
	{
		v.enterState($evt.info.oldState, $evt.info.newState);
	}
	
	private function handler_exitState():void
	{
		v.exitState();
	}
}
}