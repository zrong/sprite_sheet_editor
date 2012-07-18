package mediator
{
import events.SSEvent;

import flash.filesystem.File;

import org.robotlegs.mvcs.Mediator;

import type.StateType;

import utils.FileProcessor;

import view.panel.SwfPanel;

/**
 * @author zrong
 * 创建日期：2012-07-18
 */
public class SwfPanelMediator extends Mediator
{
	[Inject] public var v:SwfPanel;
	
	private var _swfURL:String;
	
	override public function onRegister():void
	{
		
		eventMap.mapListener(v.buildSetting, SSEvent.BUILD, handler_buildClick);
		eventMap.mapListener(eventDispatcher, SSEvent.ENTER_STATE, handler_enterState);
		eventMap.mapListener(eventDispatcher, SSEvent.EXIT_STATE, handler_exitState);
	}
	
	private function handler_enterState($evt:SSEvent):void
	{
		trace('swfPanel.updateOnStateChanged:', $evt.info.oldState, $evt.info.newState);
		//如果是从START状态跳转过来的，就更新一次swfURL的值
		if($evt.info.oldState == StateType.START)
			_swfURL = File(FileProcessor.instance.selectedFiles[0]).url;
		trace('swfPanel.load:', _swfURL);
		v.swf.addEventListener(SSEvent.PREVIEW_LOAD_COMPLETE, handler_swfLoadDone);
		v.swf.source = _swfURL;
		v.swf.transf.init();
	}
	
	private function handler_exitState($evt:SSEvent):void
	{
		v.swf.removeEventListener(SSEvent.PREVIEW_LOAD_COMPLETE, handler_swfLoadDone);
		v.swf.source = null;
		v.swf.transf.destroy();
	}
	
	private function handler_buildClick($evt:SSEvent):void
	{
		//要生成必须重新载入swf，因为并不知晓swf当前播放到那一帧了
		v.state = StateType.WAIT_LOADED;
		v.swf.destroy();
		v.swf.source = _swfURL;
	}
	
	private function handler_swfLoadDone(event:SSEvent) : void
	{
		//若当前处于等待载入状态，则开始建立sheet
		if(v.state == StateType.WAIT_LOADED)
		{
			//开始capture
			v.capture();
		}
		else
		{
			v.state = StateType.LOAD_DONE;
		}
	}
}
}