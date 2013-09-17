package utils.calc
{
import vo.OptimizedResultVO;
import vo.PicPreferenceVO;
import flash.geom.Rectangle;

/**
 * 帧计算器，用于计算帧的大小
 * @author zrong(zengrong.net) 
 * Creation: 2013-09-17
 */
public interface IFrameCalculator
{
	function calc($optimizedResult:OptimizedResultVO, $picPref:PicPreferenceVO):OptimizedResultVO;
	function updateRectInSheet($rectInSheet:Rectangle, $bigSheetRect:Rectangle,$frameRect:Rectangle,$limitW:Boolean):void;
}
}