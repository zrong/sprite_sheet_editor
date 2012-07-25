package mediator.panel
{
import events.SSEvent;

import flash.events.Event;
import flash.events.MouseEvent;

import model.StateModel;

import org.robotlegs.mvcs.Mediator;
import org.zengrong.utils.SOUtil;

import type.StateType;

import utils.Funs;

import view.panel.TopPanel;

public class TopPanelMediator extends Mediator
{
	[Inject] public var v:TopPanel;
	
	[Inject] public var stateModel:StateModel;
	
	private var _prevState:String;

	private var _so:SOUtil;
	
	override public function onRegister():void
	{
		eventMap.mapListener(v.prevBTN, MouseEvent.CLICK, handler_prievBTNClick);
		eventMap.mapListener(v.fpsNS, Event.CHANGE, handler_fpsNSChange);
		
		eventMap.mapListener(eventDispatcher, SSEvent.ENTER_STATE, handler_enterState);
		
		_so = SOUtil.getSOUtil('sprite_sheet_editor');
		showFPS();
	}	
	
	private function handler_enterState($evt:SSEvent):void
	{
		enterState($evt.info.oldState, $evt.info.newState);
	}
	
	private function showFPS():void
	{
		v.fpsGRP.visible = (stateModel.state != StateType.START);
		var __frameRate:int = int(_so.get('frameRate'));
		if(__frameRate > 0)
		{
			v.fpsNS.value = __frameRate;
			v.stage.frameRate = v.fpsNS.value;
		}
	}
	
	private function enterState($oldState:String, $newState:String):void
	{
		if(!$oldState && !$newState) return;
		v.stateNameLabel.text = StateType.toMainStateName($newState);
		if($newState == StateType.START)
		{
			_prevState = null;
		}
		else
		{
			_prevState = $oldState;
			//如果状态是反向跳转（从后一步跳转到前一步），那么就将返回按钮指向第一步
			if( ($newState == StateType.PIC || $newState == StateType.SWF) &&
				($oldState != StateType.START) )
				_prevState = StateType.START;
		}
		trace(_prevState);
		v.prevBTN.enabled = (_prevState != null);
		showFPS();
	}
	
	protected function handler_fpsNSChange(event:Event):void
	{
		v.stage.frameRate = v.fpsNS.value;
		_so.save(v.fpsNS.value, 'frameRate');
	}
	
	protected function handler_prievBTNClick(event:MouseEvent):void
	{
		stateModel.state = _prevState;
	}
}
}