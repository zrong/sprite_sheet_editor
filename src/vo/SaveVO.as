package vo
{
import flash.display.BitmapData;

/**
 * 在保存执行之前暂存待保存的数据
 * @author zrong
 * 
 */
public class SaveVO
{
	public function SaveVO()
	{
	}
	
	/**
	 * 要保存元数据
	 */
	public var metadata:String;
	
	/**
	 * 要保存的图像
	 */
	public var bitmapData:BitmapData;
	
	/**
	 * 要保存的图像数组，用于保存序列图
	 */
	public var bitmapDataList:Vector.<BitmapData>;
	
	/**
	 * 要保存的文件名数组，用于保存序列图
	 */
	public var fileNameList:Vector.<String>;
	
	/**
	 * 图像文件类型
	 */
	public var picType:String;
	
	/**
	 * 元数据类型
	 */
	public var metaType:String;
	
	/**
	 * JPEG压缩质量
	 */
	public var quality:int;
	
	/**
	 * 见StateType
	 */
	public var type:String;
}
}