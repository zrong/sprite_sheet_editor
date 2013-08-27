package ctrl 
{
import air.update.utils.StringUtils;
import events.SSEvent;
import model.FileOpenerModel;
import org.robotlegs.mvcs.Command;
	
/**
 * 选择一个或者一组文件
 * @author zrong
 */
public class BrowseFileCmd extends Command 
{
	[Inject]
	public var fileOpener:FileOpenerModel;
	
	[Inject]
	public var evt:SSEvent;
	
	override public function execute():void 
	{
		fileOpener.open(evt.info as String);
	}
}
}