package view.panel
{
import flash.display.BitmapData;
import flash.geom.Matrix;
import flash.geom.Rectangle;

import spark.components.HGroup;

import view.widget.BuildSetting;
import view.widget.ImagePreview;
import view.widget.TransformToolControlBar;

import vo.PicPreferenceVO;

/**
 * SWFPanel和PicPanel的基类
 * @author zrong(zengrong.net)
 * Creation: 2013-09-18
 */
public class DrawablePanel extends HGroup
{
	public function DrawablePanel()
	{
		super();
	}
	
	[Bindable]
	public var transControlBar:TransformToolControlBar;
	
	public var preview:ImagePreview;
	
	public var buildSetting:BuildSetting;
	
	public function get preference():PicPreferenceVO
	{
		return buildSetting.preference;
	}
	
	
	/**
	 * 根据界面控件的值中新建Rect
	 */
	public function getFrameRect():Rectangle
	{
		if(!transControlBar.useCustom)
			return new Rectangle(0,0,preview.sourceWidth, preview.sourceHeight);
		return transControlBar.transformRect;
	}
	
	/**
	 * 获取一个偏移用的Matrix，子类覆盖
	 */
	protected function getOffsetMatrix($x:int, $y:int):Matrix
	{
		if(transControlBar.useCustom)
		{
			//需要向“左上角”移动，将当前帧绘制成位图
			var __ma:Matrix = new Matrix();
			__ma.translate(-1*$x, -1*$y);
			return __ma;
		}
		return null;	
	}
	
	/**
	 * 绘制当前帧，返回位图
	 * @param $rect 位图的大小和偏移
	 */
	public function drawBMD($rect:Rectangle):BitmapData
	{
		var __bmd:BitmapData = new BitmapData($rect.width, 
			$rect.height, 
			preference.transparent, 
			preference.bgColor);
		var __ma:Matrix = getOffsetMatrix($rect.x, $rect.y);
		__bmd.draw(preview.content, __ma, null, null, null, preference.smooth);
		return __bmd;
	}
}
}