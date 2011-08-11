////////////////////////////////////////////////////////////////////////////////
//  zengrong.net
//  创建者:	zrong zrongzrong@gmail.com
//  创建时间：2011-8-3
////////////////////////////////////////////////////////////////////////////////

package type
{
/**
 * 保存State的名称
 * @author zrong
 */
public class StateType
{
	//----------------------------------------
	// 以下是编辑器的主状态
	//----------------------------------------
	
	/**
	 * 编辑器处于start状态
	 */	
	public static const START:String = 'start';
	
	/**
	 * 编辑器处于载入SWF状态
	 */	
	public static const SWF:String = 'swf';
	
	/**
	 * 编辑器处于载入图片状态
	 */	
	public static const PIC:String = 'pic';
	
	/**
	 * 编辑器处于开启SS文件状态
	 */	
	public static const SS:String = 'ss';
	
	/**
	 * 检测$state是不是主编辑器状态
	 */	
	public static function isMainState($state:String):Boolean
	{
		var __mainState:Vector.<String> = Vector.<String>([START, SWF, PIC, SS]);
		for (var i:int = 0; i < __mainState.length; i++) 
		{
			if(__mainState[i] == $state)
				return true;
		}
		return false;
	}
	
	//----------------------------------------
	// 以下是保存状态
	//----------------------------------------
	
	/**
	 * 保存Metadata文件
	 */	
	public static const SAVE_META:String = 'saveMeta';
	
	/**
	 * 保存SpriteSheet文件
	 */	
	public static const SAVE_SHEET:String = 'saveSheet';
	
	/**
	 * 同时保存SpriteSheet和metadata文件
	 */	
	public static const SAVE_ALL:String = 'saveAll';
	
	/**
	 * 保存序列
	 */	
	public static const SAVE_SEQ:String = 'saveSeq';
	
	//----------------------------------------
	// 以下是其他状态
	//----------------------------------------
	
	/**
	 * 等待载入完毕的状态
	 */
	public static const WAIT_LOADED:String = 'waitLoaded';
	
	/**
	 * 正在建立的状态
	 */
	public static const PROCESSING:String = 'processing';
	
	/**
	 * 载入完成的状态
	 */
	public static const LOAD_DONE:String = 'loadDone';
}
}