////////////////////////////////////////////////////////////////////////////////
//  zengrong.net
//  创建者:	zrong(zrongzrong@gmail.com)
//  创建时间：2011-8-17
////////////////////////////////////////////////////////////////////////////////

package vo
{
import mx.collections.ArrayList;

/**
 * 保存一个Label的信息
 */
[Bindable]
public class LabelVO
{
	public function LabelVO($lableName:String, $labelFrames:ArrayList)
	{
		name = $lableName;
		frames = $labelFrames;
	}
	
	public var  name:String;
	public var  frames:ArrayList;
	
	/**
	 * 返回frames中保存的所有帧的帧号
	 */
	public function getFramesIndex():Array
	{
		var __framesIndex:Array = [];
		for (var i:int = 0; i < frames.length; i++) 
		{
			__framesIndex[i] = (frames.getItemAt(i) as FrameVO).frameNum;
		}
		return __framesIndex;
	}
}
}