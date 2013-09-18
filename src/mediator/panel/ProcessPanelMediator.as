package mediator.panel
{
import org.robotlegs.mvcs.Mediator;

import view.panel.ProcessPanel;
import events.SSEvent;
import mx.managers.PopUpManager;

/**
 * 处理进度界面的中介
 * @author zrong(zengrong.net)
 * Creation: 2013-09-18
 */
public class ProcessPanelMediator extends Mediator
{
	public function ProcessPanelMediator()
	{
		super();
	}
	
	[Inject] public var v:ProcessPanel;
	
	override public function onRegister():void
	{
		this.addContextListener(SSEvent.PROCESS, handler_process);
		this.addContextListener(SSEvent.END_PROCESS, handler_endProcess);
	}
	
	override public function onRemove():void
	{
		this.removeContextListener(SSEvent.PROCESS, handler_process);
		this.removeContextListener(SSEvent.END_PROCESS, handler_endProcess);
	}
	
	private function handler_process($evt:SSEvent):void
	{
		//var __current:int = $evt.info.current/$evt.info.total*100;
		//v.setProgress(__current);
		if($evt.info.label)
			v.setLabel($evt.info.label);
		v.setProgress($evt.info.current,$evt.info.total);
	}
	
	private function handler_endProcess($evt:SSEvent):void
	{
		PopUpManager.removePopUp(v);
		mediatorMap.removeMediator(this);
	}
}
}