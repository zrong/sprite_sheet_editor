package type
{
import flash.net.FileFilter;
import gnu.as3.gettext.FxGettext;
/**
 * 文件扩展名 
 * @author zrong
 * 创建日期：2012-07-20
 */
public class ExtendedNameType
{
	/**
	 * 要打开的图像文件类型
	 */	
	public static const PNG_FILTER:FileFilter = new FileFilter(FxGettext.gettext("PNG image"), '*.png');
	public static const JPG_FILTER:FileFilter = new FileFilter(FxGettext.gettext("JPEG image"), '*.jpg;*.jpeg');
	public static const JPEG_XR_FILTER:FileFilter = new FileFilter(FxGettext.gettext("JPEG-XR image"), '*.wdp;*.hdp');
	public static const SWF_FILTER:FileFilter = new FileFilter(FxGettext.gettext("SWF animation"), '*.swf');
	public static const ALL_PIC_FILTER:FileFilter = new FileFilter(FxGettext.gettext("All compatible image"), PNG_FILTER.extension + ';' + JPG_FILTER.extension + ';' + JPEG_XR_FILTER.extension);
	
	public static const ALL_PIC_FILTER_LIST:Array = [ ALL_PIC_FILTER, PNG_FILTER, JPG_FILTER, JPEG_XR_FILTER];
	
}
}