package mediator
{
import events.SSEvent;

import org.robotlegs.mvcs.Mediator;

import type.StateType;

import utils.FileProcessor;

import view.panel.PicPanel;

public class PicPanelMediator extends Mediator
{
	[Inject] public var v:PicPanel;
	
	override public function onRegister():void
	{
		eventMap.mapListener(eventDispatcher, SSEvent.ENTER_STATE, handler_enterState);
		eventMap.mapListener(eventDispatcher, SSEvent.EXIT_STATE, handler_exitState);
	}
	
	
	public function handler_enterState($evt:SSEvent):void
	{
		trace('picPanel.updateOnStateChanged:', $evt.info.oldState, $evt.info.newState);
		//如果是从START状态跳转过来的，就更新一次fileList的值
		if($evt.info.oldState == StateType.START)
			v.fileM.setFileList(FileProcessor.instance.selectedFiles);
		v.pic.transf.init();
		v.fileM.init();
	}
	
	public function handler_exitState($evt:SSEvent):void
	{
		v.pic.viewer.source = null;
		v.pic.transf.destroy();
	}
}
}