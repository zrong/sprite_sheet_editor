package ctrl
{
import events.SSEvent;

import mx.managers.PopUpManager;

import org.robotlegs.mvcs.Command;

import utils.Global;

import view.panel.ProcessPanel;

/**
 * 创建一个处理器，显示它
 */
public class CreateProcessCmd extends Command
{
	[Inject]
	public var evt:SSEvent;
	
	override public function execute():void
	{
		var __panel:ProcessPanel = PopUpManager.createPopUp(Global.root, ProcessPanel, true) as ProcessPanel;
		if(evt.info) __panel.setLabel(evt.info as String);
		PopUpManager.centerPopUp(__panel);
		mediatorMap.createMediator(__panel);
	}
}
}