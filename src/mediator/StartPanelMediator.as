package mediator
{
import org.robotlegs.mvcs.Mediator;

import view.panel.StartPanel;

public class StartPanelMediator extends Mediator
{
	[Inject] public var v:StartPanel;
	
	override public function onRegister():void
	{
		
	}
}
}