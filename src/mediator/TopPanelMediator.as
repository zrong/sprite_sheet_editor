package mediator
{
import events.SSEvent;

import flash.events.Event;
import flash.events.MouseEvent;

import org.robotlegs.mvcs.Mediator;
import org.zengrong.utils.SOUtil;

import type.StateType;

import utils.Funs;

import view.panel.TopPanel;

public class TopPanelMediator extends Mediator
{
	[Inject] public var v:TopPanel;
	
	private var _prevState:String;
	
	private var _oldState:String;
	private var _newState:String;
	
	private var _so:SOUtil;
	
	override public function onRegister():void
	{
		eventMap.mapListener(v.prevBTN, MouseEvent.CLICK, handler_prievBTNClick);
		eventMap.mapListener(v.fpsNS, Event.CHANGE, handler_fpsNSChange);
		
		eventMap.mapListener(eventDispatcher, SSEvent.ENTER_STATE, handler_enterState);
		
		_so = SOUtil.getSOUtil('sprite_sheet_editor');
	}
	
	private function handler_enterState($evt:SSEvent):void
	{
		var __frameRate:int = int(_so.get('frameRate'));
		if(__frameRate > 0)
		{
			v.fpsNS.value = __frameRate;
			v.stage.frameRate = v.fpsNS.value;
		}
		_oldState = $evt.info.oldState;;
		_newState = $evt.info.newState;
		v.stateName = StateType.toMainStateName(_newState);
		if(_newState == StateType.START)
		{
			_prevState = null;
			return;
		}
		_prevState = _oldState;
		//如果状态是反向跳转（从后一步跳转到前一步），那么就将返回按钮指向第一步
		if( (_newState == StateType.PIC || _newState == StateType.SWF) &&
			(_oldState != StateType.START) )
			_prevState = StateType.START;
		v.prevBTN.enabled = (_prevState !=null)
	}
	
	protected function handler_fpsNSChange(event:Event):void
	{
		v.stage.frameRate = v.fpsNS.value;
		_so.save(v.fpsNS.value, 'frameRate');
	}
	
	protected function handler_prievBTNClick(event:MouseEvent):void
	{
		Funs.changeState(_prevState);
	}
}
}