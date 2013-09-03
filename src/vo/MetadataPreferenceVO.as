package vo
{
import flash.display.BitmapData;
import org.zengrong.display.spritesheet.SpriteSheetType;
import org.zengrong.display.spritesheet.ISpriteSheetMetadata;

/**
 * 在保存执行之前暂存待保存的数据
 * @author zrong
 * 
 */
public class MetadataPreferenceVO
{
	public function MetadataPreferenceVO()
	{
	}
	
	/**
	 * 要保存元数据
	 */
	public var metadata:ISpriteSheetMetadata;
	
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
	public var picType:String = "png";
	
	/**
	 * 元数据类型
	 */
	public var metaType:String = "ssexml";
	
	/**
	 * JPEG压缩质量
	 */
	public var quality:int = 80;
	
	/**
	 * 见StateType
	 * @see type.StateType
	 */
	public var type:String;
	
	/**
	 * 仅包含简单信息
	 */
	public var isSimple:Boolean = false;
	
	/**
	 * 包含文件名
	 */
	public var includeName:Boolean = true;
	
	/**
	 * 蒙版类型
	 */
	public var maskType:int = 0;
	
	public var spriteSheetType:String = SpriteSheetType.PNG_IMAGE;
}
}