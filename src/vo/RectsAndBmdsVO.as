////////////////////////////////////////////////////////////////////////////////
//  zengrong.net
//  创建者:	zrong(zrongzrong@gmail.com)
//  创建时间：2013-06-14
////////////////////////////////////////////////////////////////////////////////

package vo
{
import flash.geom.Rectangle;
import flash.display.BitmapData;

/**
 * 保存Sheet的修改后的rect列表、原始的rect列表和位图列表
 */
[Bindable]
public class RectsAndBmdsVO
{
	public function RectsAndBmdsVO($bmds:Vector.<BitmapData>, $origin:Vector.<Rectangle>, $frame:Vector.<Rectangle>)
	{
		bmds = $bmds;
		originRects = $origin;
		frameRects = $frame;
	}
	
	/**
	 * 在大sheet中的rect列表
	 */
	public var  frameRects:Vector.<Rectangle>;
	
	/**
	 * 原始的（在程序中使用的）rect列表
	 */
	public var  originRects:Vector.<Rectangle>;
	
	/**
	 * 所有的BitmapData列表
	 */
	public var  bmds:Vector.<BitmapData>;
}
}