package vo 
{
import air.update.utils.StringUtils;
import flash.filesystem.File;
import org.zengrong.assets.AssetsType;
import org.zengrong.display.spritesheet.SpriteSheetMetadataType;
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
	
	/**
	 * 如果选择的文件是SS格式，则这个值为AssetsType.SPRITE_SHEET
	 * @see org.zengrong.assets.AssetsType
	 */
	public var fileType:String;
	
	/**
	 * 若 fileType的值为AssetsType.SPRITE_SHEET，则这个值为SpriteSheetMetadataType中的值
	 * @see org.zengrong.display.spritesheet.SpriteSheetMetadataType
	 */
	public var metaType:String;
	
	/**
	 * 返回供Assets载入的列表
	 * @return
	 */
	public function toAssetsList():Array
	{
		if(!selectedFiles && selectedFiles.length == 0) return null;
		var __file:File = null;
		var __urls:Array = [];
		var __urlobj:Object = null;
		for(var i:int=0;i<selectedFiles.length;i++)
		{
			__file = selectedFiles[i] as File;
			__urlobj = {url:__file.url};
			__urlobj.ftype = __file.extension;
			if(fileType == AssetsType.SPRITE_SHEET)
			{
				__urlobj.ftype = AssetsType.SPRITE_SHEET;
				__urlobj.mtype = SpriteSheetMetadataType.getTypeExt(metaType);
			}
			__urls.push(__urlobj);
		}
		return __urls;
	}
}
}