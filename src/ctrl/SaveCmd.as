package ctrl 
{
import events.SSEvent;
import org.robotlegs.mvcs.Command;
import vo.SaveVO;

/**
 * 用于保存文件的Cmd
 * @author zrong
 * Creation: 2013-06-13
 */
public class SaveCmd extends Command 
{
	[Inject]
	public var evt:SSEvent;
	
	override public function execute():void
	{
		var __vo:SaveVO = evt.info as SaveVO;
		trace(__vo.bitmapData, __vo.metadata);
	}
}
}