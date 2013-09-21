////////////////////////////////////////////////////////////////////////////////
//  zengrong.net
//  创建者:	zrong(zrongzrong@gmail.com)
//  创建时间：2013-06-14
////////////////////////////////////////////////////////////////////////////////

package vo
{
import flash.display.BitmapData;
import flash.geom.Rectangle;

/**
 * 保存Sheet的修改后的rect列表、原始的rect列表和位图列表
 */
[Bindable]
public class OptimizedResultVO
{
	public static function createByLength($len:int):OptimizedResultVO
	{
		return new OptimizedResultVO(
		new Vector.<BitmapData>($len),
		new Vector.<Rectangle>($len),
		new Vector.<Rectangle>($len),
		new Rectangle());
	}
	public function OptimizedResultVO($bmds:Vector.<BitmapData>=null, 
										$origin:Vector.<Rectangle>=null, 
										$frame:Vector.<Rectangle>=null,
										$bigRect:Rectangle=null,
										$preference:PicPreferenceVO=null)
	{
		bmds = $bmds?$bmds:new Vector.<BitmapData>;
		originRects = $origin?$origin:new Vector.<Rectangle>;
		frameRects = $frame?$frame:new Vector.<Rectangle>;
		bigSheetRect = $bigRect?$bigRect:new Rectangle();
		preference = $preference;
	}
	
	/**
	 * 在大sheet中的rect列表，包含坐标和尺寸（修剪过的）信息
	 */
	public var frameRects:Vector.<Rectangle>;
	
	/**
	 * 原始大小的（未修剪）rect列表
	 */
	public var originRects:Vector.<Rectangle>;
	
	/**
	 * 所有的BitmapData列表（修剪过的）
	 */
	public var bmds:Vector.<BitmapData>;
	
	/**
	 * 合并而成的大Sheet的尺寸
	 */
	public var bigSheetRect:Rectangle;
	
	/**
	 * 合并的时候使用的参数
	 */
	public var preference:PicPreferenceVO;
}
}