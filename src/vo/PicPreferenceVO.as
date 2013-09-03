package vo
{
/**
 * 保存Sheet图像时候的选项
 * @author zrong
 * Creation: 2013-09-01
 */
public class PicPreferenceVO
{
	public function PicPreferenceVO()
	{
	}
	
	/**
	 * 是否透明
	 */
	public var transparent:Boolean = true;
		
	/**
	 * 生成sheet图的背景色
	 */
	public var bgColor:uint = 0x00000000;
	
	/**
	 * 限制宽度（true）还是限制高度（false）
	 */
	public var limitWidth:Boolean = true;
	
	/**
	 * 明确指定Sheet的宽度或高度
	 */
	public var explicitSize:int = 200;
	
	/**
	 * 是否开启2的幂
	 */
	public var powerOf2:Boolean = false;
	
	/**
	 * 是否开启正方形
	 */
	public var square:Boolean = false;
		
	/**
	 * 是否修剪空白
	 */
	public var trim:Boolean = false;
	
	/**
	 * 是否重设帧大小（仅当trim为true时可用）
	 */
	public var resetRect:Boolean = false;
}
}