////////////////////////////////////////////////////////////////////////////////
//  zengrong.net
//  创建者:	zrong(zrongzrong@gmail.com)
//  创建时间：2011-8-17
////////////////////////////////////////////////////////////////////////////////

package vo
{
import flash.geom.Rectangle;

/**
 * 保存一帧的信息
 */
[Bindable]
public class FrameVO
{
	public function FrameVO()
	{
	}
	
	public var  frameNum:int;
	public var  frameName:String;
	public var  frameRect:Rectangle;
	public var  originRect:Rectangle;
	
	public function get frameSize():String
	{
		return frameRect.x+','+frameRect.y+','+frameRect.width+','+frameRect.height;
	}
	
	public function get originSize():String
	{
		return originRect.x+','+originRect.y+','+originRect.width+','+originRect.height;
	}
}
}