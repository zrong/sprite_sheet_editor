package ctrl 
{
import events.SSEvent;
import gnu.as3.gettext.FxGettext;
import model.FileOpenerModel;
import model.StateModel;
import org.robotlegs.mvcs.Command;
import type.StateType;
import utils.Funs;

/**
 * 处理一个拖放文件
 * @author zrong
 * Creation: 2013-08-19
 */
public class DragFileCmd extends Command 
{
	[Inject] public var evt:SSEvent;
	[Inject] public var fileOpener:FileOpenerModel;
	[Inject] public var stateModel:StateModel;
	
	public override function execute():void 
	{
		var __files:Array = evt.info as Array;
		var __state:String = Funs.getStateByFile(__files[0]);
		if(!__state)
		{
			Funs.alert(FxGettext.gettext("These files are not supported!"));
			return;
		}
		if(__state == StateType.PIC)
		{
			//若当前位于PicPanel中，则将状态改为增加图像到列表
			if(stateModel.state == StateType.PIC) __state = StateType.ADD_TO_PIC_List;
			//若位于SSPanel中，则将状态改为增加到ss
			else if(stateModel.state == StateType.SS) __state = StateType.ADD_TO_SS;
			fileOpener.openFileByDrag(__files, __state);
		}
		else if(__state == StateType.SS)
		{
			//若位于SSPanel中，则将状态改为增加到SS
			if(stateModel.state == StateType.SS)  
			{
				__state = StateType.ADD_TO_SS;
				fileOpener.openFileByDrag(__files, __state);
			}
			//否则直接切换到SS列表
			else fileOpener.openFileByDrag(__files[0], __state);
		}
		else if(__state == StateType.SWF)
		{
			fileOpener.openFileByDrag(__files[0], __state);
		}
	}
}
}