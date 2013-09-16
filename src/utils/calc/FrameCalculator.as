package utils.calc
{
import flash.errors.IllegalOperationError;
import flash.geom.Rectangle;

import gnu.as3.gettext.FxGettext;

import mx.core.Singleton;

import vo.OptimizedResultVO;
import vo.PicPreferenceVO;

/**
 * 帧计算器，用于计算帧的大小
 * @author zrong(zengrong.net)
 * Creation: 2013-09-16
 */
public class FrameCalculator
{
	private static var _calculators:Object = {};
	
	public static function getCalculator($type:String):FrameCalculator
	{
		var __cal:FrameCalculator = _calculators[$type] as FrameCalculator;
		if(!__cal)
		{
			if($type == CalculatorType.BASIC)
			{
				__cal = new BasicCalculator();
				_calculators[$type] = __cal;
			}
		}
		return __cal;
	}
	
	public function FrameCalculator()
	{
		//throw new IllegalOperationError(FxGettext.gettext("Please use getCalculator() method to get a calculateor!"));
	}
	
	public function calc($optimizedResult:OptimizedResultVO, $picPref:PicPreferenceVO):OptimizedResultVO
	{
		return null;
	}
}
}
