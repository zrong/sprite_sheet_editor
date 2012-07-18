package mediator
{
import events.SSEvent;

import mx.events.FlexEvent;

import org.robotlegs.mvcs.Mediator;

public class AppMediator extends Mediator
{
	[Inject] public var v:SpriteSheetEditor;
	
	override public function onRegister():void
	{
		v.startState.addEventListener(FlexEvent.EXIT_STATE, handler_exitState);
		v.picState.addEventListener(FlexEvent.EXIT_STATE, handler_exitState);
		v.ssState.addEventListener(FlexEvent.EXIT_STATE, handler_exitState);
		v.swfState.addEventListener(FlexEvent.EXIT_STATE, handler_exitState);
		eventMap.mapListener(eventDispatcher, SSEvent.ENTER_STATE, handler_enterState);
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