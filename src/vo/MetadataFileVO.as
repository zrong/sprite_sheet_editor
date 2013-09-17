package vo
{
import flash.filesystem.File;

/**
 * 保存Metadata文件以及Metadata类型
 */
public class MetadataFileVO
{
	public function MetadataFileVO($file:File, $type:String=null)
	{
		file = $file;
		type = $type;
	}
	
	/**
	 * Metadata对应的文件信息
	 */
	public var file:File;
	
	/**
	 * SpriteSheetMedataType类型 
	 * @see org.zengrong.display.spritesheet.SpriteSheetMetadataType
	 */
	public var type:String;
}
}