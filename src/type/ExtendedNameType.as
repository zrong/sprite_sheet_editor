package type
{
import flash.net.FileFilter;

import gnu.as3.gettext.FxGettext;
/**
 * 文件扩展名 
 * @author zrong
 * Creation: 2012-07-20
 * Modification: 2013-09-09
 */
public class ExtendedNameType
{
	/**
	 * 支持打开的图像文件类型
	 */	
	public static const PNG_FILTER:FileFilter = new FileFilter(FxGettext.gettext("PNG image"), '*.png');
	public static const JPG_FILTER:FileFilter = new FileFilter(FxGettext.gettext("JPEG image"), '*.jpg;*.jpeg');
	public static const JPEG_XR_FILTER:FileFilter = new FileFilter(FxGettext.gettext("JPEG-XR image"), '*.wdp;*.hdp');
	/**
	 * 所有支持的图像类型
	 */
	public static const ALL_PIC_FILTER:FileFilter = new FileFilter(FxGettext.gettext("All compatible image file"), 
		PNG_FILTER.extension + ';' + JPG_FILTER.extension + ';' + JPEG_XR_FILTER.extension);
	public static const ALL_PIC_FILTER_LIST:Array = [ ALL_PIC_FILTER, PNG_FILTER, JPG_FILTER, JPEG_XR_FILTER];

	/**
	 * SWF文件类型，很孤单不是？
	 */
	public static const SWF_FILTER:FileFilter = new FileFilter(FxGettext.gettext("SWF animation"), '*.swf');
	
	/**
	 * 支持打开的metadata配置文件类型
	 */
	public static const PLIST_FILTER:FileFilter = new FileFilter(FxGettext.gettext("PLIST file"), "*.plist");
	public static const XML_FILTER:FileFilter = new FileFilter(FxGettext.gettext("XML file"), "*.xml");
	public static const JSON_FILTER:FileFilter = new FileFilter(FxGettext.gettext("JSON file"), "*.json");
	/**
	 * 所有支持的metadata文件类型
	 */
	public static const ALL_TEXT_FILTER:FileFilter = new FileFilter(FxGettext.gettext("All compatible text file"), 
		PLIST_FILTER.extension+";"+XML_FILTER.extension+";"+JSON_FILTER.extension); 
	public static const ALL_TEXT_FILTER_LIST:Array = [ ALL_TEXT_FILTER, XML_FILTER, JSON_FILTER, PLIST_FILTER];
	
	/**
	 * 所有支持的文件类型
	 */
	public static const ALL_FILTER:FileFilter = new FileFilter(FxGettext.gettext("All compatible file"),
		ALL_PIC_FILTER.extension+";"+ALL_TEXT_FILTER.extension+";"+SWF_FILTER.extension);
	public static const ALL_FILTER_LIST:Array = [ALL_FILTER, ALL_PIC_FILTER,ALL_TEXT_FILTER,SWF_FILTER, PNG_FILTER, JPG_FILTER, JPEG_XR_FILTER,XML_FILTER, JSON_FILTER, PLIST_FILTER];
	
	public static function getAllFileExtensions():String
	{
		var __fileTypes:String = ALL_PIC_FILTER.extension + ";";
		__fileTypes += SWF_FILTER.extension + ";";
		__fileTypes += ALL_TEXT_FILTER.extension;
		return __fileTypes;
	}
	
}
}