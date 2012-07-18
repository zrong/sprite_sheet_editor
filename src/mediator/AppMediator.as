package mediator
{
import events.SSEvent;

import mx.binding.utils.ChangeWatcher;
import mx.events.FlexEvent;
import mx.events.PropertyChangeEvent;

import org.robotlegs.mvcs.Mediator;

import utils.Global;

public class AppMediator extends Mediator
{
	[Inject] public var v:SpriteSheetEditor;
	
	override public function onRegister():void
	{
		ChangeWatcher.watch(Global.instance, 'currentState', fun_currentStateChange);
		v.startState.addEventListener(FlexEvent.EXIT_STATE, handler_exitState);
		v.picState.addEventListener(FlexEvent.EXIT_STATE, handler_exitState);
		v.ssState.addEventListener(FlexEvent.EXIT_STATE, handler_exitState);
		v.swfState.addEventListener(FlexEvent.EXIT_STATE, handler_exitState);
	}
	
	private function fun_currentStateChange($evt:PropertyChangeEvent):void
	{
		var __new:String = String($evt.newValue);
		var __old:String = String($evt.oldValue);
		eventDispatcher.dispatchEvent(new SSEvent(SSEvent.ENTER_STATE, {newState:__new, oldState:__old}));
		trace('状态改变:', __old, __new);
	}
	
	protected function handler_exitState($event:FlexEvent):void
	{
		trace('退出状态', v.currentState);
		eventDispatcher.dispatchEvent(new SSEvent(SSEvent.EXIT_STATE));
	}
}
}