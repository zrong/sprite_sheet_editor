package ctrl
{
import events.SSEvent;

import flash.display.BitmapData;
import flash.geom.Rectangle;

import model.SpriteSheetModel;

import org.robotlegs.mvcs.Command;

/**
 * 显示帧改变
 * @author zrong
 * 创建日期：2012-07-26
 */
public class PreviewSSChangeCmd extends Command
{
	[Inject] public var ssModel:SpriteSheetModel;
	
	override public function execute():void
	{
		updateFrameDisplay();
	}
	
	/**
	 * 更新帧显示
	 */
	private function updateFrameDisplay():void
	{
		var __frameBmd:BitmapData = null;
		//根据选择显示原始的或者修剪过的Frame
		if(ssModel.displayCrop)
		{
			__frameBmd = ssModel.adjustedSheet.getTrimBMDByIndex(ssModel.selectedFrameIndex);
		}
		else
		{
			__frameBmd = ssModel.adjustedSheet.getBMDByIndex(ssModel.selectedFrameIndex);
		}
		//rect永远使用剪切过的值
		var __rect:Rectangle = ssModel.adjustedSheet.metadata.frameRects[ssModel.selectedFrameIndex];
		trace('更新帧：', __frameBmd.rect, ssModel.displayCrop);
		dispatch(new SSEvent(SSEvent.PREVIEW_SS_SHOW, {bmd:__frameBmd, rect:__rect}));
	}
}
}