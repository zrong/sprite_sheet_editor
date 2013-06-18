package model
{
import events.SSEvent;

import org.robotlegs.mvcs.Actor;

public class StateModel extends Actor
{
	public function StateModel()
	{
	}
	
	private var _state:String = 'start';
	
	private var _oldState:String;
	
	public function get oldState():String
	{
		return _oldState;
	}
	
	public function get state():String
	{
		return _state;
	}
	
	public function set state($state:String):void
	{
		_oldState = _state;
		_state = $state;
		this.dispatch(new SSEvent(SSEvent.ENTER_STATE, {oldState:_oldState, newState:$state}));
	}
}
}