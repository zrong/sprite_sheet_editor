package model
{
import events.SSEvent;

import org.robotlegs.mvcs.Actor;

public class StateModel extends Actor
{
	public function StateModel()
	{
	}
	
	private var _state:String;
	
	public function get state():String
	{
		return _state;
	}
	
	public function set state($state:String):void
	{
		this.dispatch(new SSEvent(SSEvent.ENTER_STATE, {oldState:_state, newState:$state}));
		_state = $state;
	}
}
}