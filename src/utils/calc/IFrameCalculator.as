package utils.calc
{
import flash.geom.Rectangle;

import vo.OptimizedResultVO;
import vo.PicPreferenceVO;

/**
 * 帧计算器，用于计算帧的大小
 * @author zrong(zengrong.net) 
 * Creation: 2013-09-17
 */
public interface IFrameCalculator
{
	/**
	 * 重新优化图像，返回一个新的已经优化过的OptimizedResultVO
	 * @param $optimizedResult 待优化对象
	 * @return 返回一个已经优化过的OptimizedResultVO
	 */
	function calc($optimizedResult:OptimizedResultVO):OptimizedResultVO;
	
	/**
	 * 更新在Sheet中帧的Rect的位置，根据Rect位置计算出大Sheet的WH
	 * 会直接修改$rectInSheet和$whRect参数的值。
	 * @param $rectInSheet	当前处理的帧在整个Sheet中的位置和大小，会修改此参数的值
	 * @param $bigSheetRect	最终生成的大Sheet的尺寸，会修改此参数的值
	 * @param $frameRect	要处理的帧大小的Rect
	 * @param $limitW		为true代表限制宽度，否则是显示高度
	 */
	function updateRectInSheet($rectInSheet:Rectangle, $bigSheetRect:Rectangle,$frameRect:Rectangle,$limitW:Boolean):void;
	
	/**
	 * 计算并更新第一帧信息
	 */
	function calculateFirstRect( $bigSheetRect:Rectangle, $frameRect:Rectangle, $explicitSize:int):void;
	
	function get picPreference():PicPreferenceVO;
	function set picPreference($vo:PicPreferenceVO):void;
}
}