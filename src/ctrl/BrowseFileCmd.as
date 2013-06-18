package ctrl 
{
import air.update.utils.StringUtils;
import events.SSEvent;
import model.FileProcessor;
import org.robotlegs.mvcs.Command;
	
/**
 * 选择一个或者一组文件
 * @author zrong
 */
public class BrowseFileCmd extends Command 
{
	[Inject]
	public var file:FileProcessor;
	
	[Inject]
	public var evt:SSEvent;
	
	override public function execute():void 
	{
		file.open(evt.info as String);
	}
}
}