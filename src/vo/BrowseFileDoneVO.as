package vo 
{
/**
 * 选择一个或者一组文件成功后发出事件所带VO
 * @author zrong
 * Creation: 2013-06-18
 */
public class BrowseFileDoneVO 
{
	
	public function BrowseFileDoneVO($state:String=null, $files:Array=null) 
	{
		openState = $state;
		selectedFiles = $files;
	}
	
	public var openState:String;
	public var selectedFiles:Array;
	
}
}