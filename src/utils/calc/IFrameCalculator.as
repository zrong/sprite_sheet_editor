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
	
	function get picPreference():PicPreferenceVO;
	function set picPreference($vo:PicPreferenceVO):void;

	/**
	 * 重新优化图像，返回一个新的已经优化过的OptimizedResultVO
	 * @param $optimizedResult 待优化对象
	 * @return 返回一个已经优化过的OptimizedResultVO
	 */
	function optimize($optimizedResult:OptimizedResultVO):OptimizedResultVO;
	
	
}
}