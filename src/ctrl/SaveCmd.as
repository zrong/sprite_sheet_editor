package ctrl 
{
import events.SSEvent;
import model.FileProcessor;
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
	
	[Inject]
	public var file:FileProcessor;
	
	override public function execute():void
	{
		var __vo:SaveVO = evt.info as SaveVO;
		file.save(__vo);
	}
}
}