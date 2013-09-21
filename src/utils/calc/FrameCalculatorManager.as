package utils.calc
{
import flash.errors.IllegalOperationError;
import flash.geom.Rectangle;

import gnu.as3.gettext.FxGettext;

import mx.core.Singleton;

import vo.OptimizedResultVO;
import vo.PicPreferenceVO;

/**
 * 管理帧计算器，用于计算帧的大小
 * @author zrong(zengrong.net)
 * Creation: 2013-09-16
 */
public class FrameCalculatorManager
{
	private static var _calculators:Object = {};
	
	public static function getCalculator($type:String):IFrameCalculator
	{
		var __cal:IFrameCalculator = _calculators[$type] as IFrameCalculator;
		if(!__cal)
		{
			if($type == CalculatorType.BASIC)
			{
				__cal = new BasicCalculator();
				_calculators[$type] = __cal;
			}
			else if($type == CalculatorType.MAX_RECTS)
			{
				__cal = new MaxRectsCalculator();
				_calculators[$type] = __cal;
			}
				
		}
		return __cal;
	}
	
	public function FrameCalculatorManager()
	{
		throw new IllegalOperationError(FxGettext.gettext("Please use getCalculator() method to get a calculateor!"));
	}
}
}
