package vo
{
/**
 * 保存预览变动的时候，从FrameAndLabel传出的值
 * @author zrong
 * Creation: 2013-09-04
 */
public class FramesAndLabelChangeVO
{
	/**
	 * 为true代表显示Label，false代表显示选择的Frame
	 */
	public var labelEnabled:Boolean = false;
	public var labelName:String = "";
	public function FramesAndLabelChangeVO()
	{
	}
}
}