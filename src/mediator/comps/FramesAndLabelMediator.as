package mediator.comps
{
import com.hurlant.util.asn1.parser.boolean;

import events.SSEvent;

import flash.display.BitmapData;
import flash.events.Event;
import flash.events.MouseEvent;
import flash.geom.Point;
import flash.geom.Rectangle;

import gnu.as3.gettext.FxGettext;

import model.SpriteSheetModel;

import mx.collections.ArrayCollection;
import mx.collections.ArrayList;
import mx.collections.IList;
import mx.collections.Sort;
import mx.collections.SortField;
import mx.events.CloseEvent;
import mx.events.FlexEvent;
import mx.managers.PopUpManager;

import org.robotlegs.mvcs.Mediator;
import org.zengrong.assets.Assets;
import org.zengrong.assets.AssetsEvent;
import org.zengrong.assets.AssetsProgressVO;
import org.zengrong.assets.AssetsType;
import org.zengrong.display.spritesheet.ISpriteSheetMetadata;
import org.zengrong.display.spritesheet.SpriteSheet;

import type.StateType;

import utils.Funs;

import view.comps.FramesAndLabels;
import view.comps.SSPreview;

import vo.BrowseFileDoneVO;
import vo.FrameVO;
import vo.FramesAndLabelChangeVO;
import vo.LabelListVO;
import vo.LabelVO;

public class FramesAndLabelMediator extends Mediator
{
	[Inject] public var v:FramesAndLabels;
	
	[Inject] public var ssModel:SpriteSheetModel;
	
	/**
	 * 用来载入新加入的帧或者SpriteSheet
	 */
	private var _assets:Assets;
	
	/**
	 * 加入帧的方式，true代表加入的是SpriteSheet，否则是普通图像
	 */
	private var _addSSFiles:BrowseFileDoneVO;
	
	/**
	 * 使用_assets每载入一个文件，这个索引加一
	 */
	private var _loadAssetsIndex:int=0;
	
	/**
	 * 保存所有帧
	 */
	private var _frames:ArrayCollection;
	
	private var _labelAL:ArrayList;
	
	//是否正在播放动画。如果是播放动画状态，那么valueCommit的时候，就不更新selectedFrameIndices的值
	private var playing:Boolean;
	
	/**
	 * 当前正在播放的帧在selectedFrameIndices中的索引
	 */
	private var _currentIndex:int=-1;
	
	public var selectedFrameNum:int;		//当前选择的帧编号
	
	//frameDG中选择的索引
	public var selectedFrameIndices:Vector.<int>;
	
	
	override public function onRegister():void
	{
		eventMap.mapListener(v.delFrameBTN,  MouseEvent.CLICK,handler_delFrameBTNclick);
		eventMap.mapListener(v.addPicBTN, MouseEvent.CLICK, handler_selectFile);
		
		eventMap.mapListener(v.frameDG, FlexEvent.VALUE_COMMIT, handler_frameDGValueCommit);
		eventMap.mapListener(v.frameInLabelDG, FlexEvent.VALUE_COMMIT, handler_frameInLabelDGValueCommit);
		eventMap.mapListener(v.upFrameBTN, MouseEvent.CLICK,  handler_upFrameBTNclick);
		eventMap.mapListener(v.downFrameBTN, MouseEvent.CLICK,  handler_downFrameBTNclick);
		
		eventMap.mapListener(v.labelDDL, FlexEvent.VALUE_COMMIT,  handler_labelDDLvalueComit);
		eventMap.mapListener(v.addLabelBTN, MouseEvent.CLICK, handler_addLabelBTNclick);
		eventMap.mapListener(v.removeLabelBTN, MouseEvent.CLICK, handler_removeLabelBTNclick);
		eventMap.mapListener(v.renameBTN, MouseEvent.CLICK, handler_renameBTNClick);
		
		addViewListener(SSEvent.FRAME_AND_LABEL_USING_LABEL, handler_frameOrLabelChange);
		
		addContextListener(SSEvent.PREVIEW_SS_PLAY, handler_ssPreviewPlay);
		addContextListener(SSEvent.PREVIEW_SS_RESIZE_SAVE, handler_saveResizeBTNclick);
		addContextListener(SSEvent.PREVIEW_CLICK, handler_previewClick);
		addContextListener(SSEvent.OPTIMIZE_SHEET_DONE, handler_optimizeDone);
		addContextListener(SSEvent.BROWSE_FILE_DONE, handler_browseFileDone);
		
		init();
	}
	

	override public function onRemove():void
	{
		eventMap.unmapListener(v.delFrameBTN,  MouseEvent.CLICK,handler_delFrameBTNclick);
		eventMap.unmapListener(v.addPicBTN, MouseEvent.CLICK, handler_selectFile);
		
		eventMap.unmapListener(v.frameDG, FlexEvent.VALUE_COMMIT, handler_frameDGValueCommit);
		eventMap.unmapListener(v.frameInLabelDG, FlexEvent.VALUE_COMMIT, handler_frameInLabelDGValueCommit);
		eventMap.unmapListener(v.upFrameBTN, MouseEvent.CLICK,  handler_upFrameBTNclick);
		eventMap.unmapListener(v.downFrameBTN, MouseEvent.CLICK,  handler_downFrameBTNclick);
		
		eventMap.unmapListener(v.labelDDL, FlexEvent.VALUE_COMMIT,  handler_labelDDLvalueComit);
		eventMap.unmapListener(v.addLabelBTN, MouseEvent.CLICK, handler_addLabelBTNclick);
		eventMap.unmapListener(v.removeLabelBTN, MouseEvent.CLICK, handler_removeLabelBTNclick);
		eventMap.unmapListener(v.renameBTN, MouseEvent.CLICK, handler_renameBTNClick);
		
		removeViewListener(SSEvent.FRAME_AND_LABEL_USING_LABEL, handler_frameOrLabelChange);
		
		removeContextListener(SSEvent.PREVIEW_SS_PLAY, handler_ssPreviewPlay);
		removeContextListener(SSEvent.PREVIEW_SS_RESIZE_SAVE, handler_saveResizeBTNclick);
		removeContextListener(SSEvent.PREVIEW_CLICK, handler_previewClick);
		removeContextListener(SSEvent.OPTIMIZE_SHEET_DONE, handler_optimizeDone);
		removeContextListener(SSEvent.BROWSE_FILE_DONE, handler_browseFileDone);
		
		destroy();
	}
	
	private function get app():SpriteSheetEditor
	{
		return contextView as SpriteSheetEditor;
	}
	
	public function init():void
	{
		var __meta:ISpriteSheetMetadata = ssModel.adjustedSheet.metadata;
		_frames = new ArrayCollection();
		var __frame:FrameVO = null;
		var i:int=0;
		for (i = 0; i < __meta.totalFrame; i++) 
		{
			__frame = new FrameVO();
			__frame.frameNum = i;
			__frame.frameName = __meta.hasName? __meta.names[i]:null;
			__frame.frameRect = __meta.frameRects[i];
			__frame.originRect = __meta.originalFrameRects[i];
			_frames.addItem(__frame);
		}
		v.framesData = _frames;
		
		_labelAL = new ArrayList();
		v.labelDDL.dataProvider = _labelAL;
		v.labelCB.selected = __meta.hasLabel;
		//处理位于label中的帧
		if(__meta.hasLabel)
		{
			var __label:String = '';
			var __framesIndex:Array = null;
			var __framesInLabel:ArrayList = null;
			for (i = 0; i < __meta.labels.length; i++) 
			{
				__label = __meta.labels[i];
				__framesIndex = __meta.labelsFrame[__label];
				__framesInLabel = new ArrayList();
				for (var k:int = 0; k < __framesIndex.length; k++) 
				{
					__framesInLabel.addItem(_frames.getItemAt(__framesIndex[k]));
				}
				_labelAL.addItem(new LabelVO(__label, __framesInLabel));
			}
		}
		selectedFrameIndices = new Vector.<int>;
		refreshFrameDG();
		v.frameDG.selectedIndices = selectedFrameIndices;
		selectFrameChange();
		if(!_assets)
		{
			_assets = new Assets();
			_assets.addEventListener(AssetsEvent.COMPLETE, handler_assetsComp);
			_assets.addEventListener(AssetsEvent.PROGRESS, handler_assetsProgress);
		}
		v.addEventListener(Event.ENTER_FRAME, handler_enterFrame);
		v.init();
	}
	
	public function destroy():void
	{
		if(_frames) _frames.removeAll();
		_frames = null;
		if(_assets)
		{
			_assets.removeEventListener(AssetsEvent.PROGRESS, handler_assetsProgress);
			_assets.removeEventListener(AssetsEvent.COMPLETE, handler_assetsComp);
			_assets = null;
		}
		if(_labelAL)	_labelAL.removeAll();
		_labelAL = null;
		selectedFrameIndices = null;
		selectFrameChange();
		v.destroy();
		play(false);
		v.removeEventListener(Event.ENTER_FRAME, handler_enterFrame);
	}
	
	private function play($play:Boolean):void
	{
		playing = $play;
		_currentIndex = playing ? 0 : -1;
		ssModel.playing = playing;
	}
	
	/**
	 * 载入一个图像文件成功后，将其加入spritesheet中
	 */
	private function handler_assetsProgress($evt:AssetsEvent):void
	{
		var __vo:AssetsProgressVO = $evt.vo;
		if(__vo.whole && __vo.done)
		{
			trace('FrameAndLabels.handler_assetsProgress:',__vo.toString());
			if(_addSSFiles.fileType == AssetsType.SPRITE_SHEET)
				addSSToSheet(__vo);
			else
				addPicToSheet(__vo);
		}
	}
	
	private function handler_assetsComp($evt:AssetsEvent):void
	{
		//labelList.selectedIndex = labelAL.length - 1;
		refreshFrameDG();
		dispatchOptimize();
	}
	
	/**
	 * 获取metadata中需要的label数据
	 */
	public function getLabels():LabelListVO
	{
		var __vo:LabelListVO = new LabelListVO();
		__vo.hasLabel = v.labelCB.selected && _labelAL.length>0;
		if(__vo.hasLabel)
		{
			__vo.labels = new Vector.<String>(_labelAL.length);
			__vo.labelsFrame = {};
			var __labelItem:LabelVO = null;
			for (var i:int = 0; i < _labelAL.length; i++) 
			{
				__labelItem = _labelAL.getItemAt(i) as LabelVO;
				__vo.labels[i] = __labelItem.name;
				__vo.labelsFrame[__labelItem.name] = __labelItem.getFramesIndex();
			}
		}
		return __vo;
	}
	
	public function selectFrameChange():void
	{
		ssModel.selectedFrameIndices = selectedFrameIndices;
		var __selectedFrames:Vector.<FrameVO> = new Vector.<FrameVO>;
		for (var i:int = 0; ssModel.selectedFrameIndices && i < ssModel.selectedFrameIndices.length>0; i++) 
		{
			__selectedFrames[i] = v.getFrameItemAt(ssModel.selectedFrameIndices[i]);
		}
		dispatch(new SSEvent(SSEvent.SELECTED_FRAMEINDICES_CHANGE, __selectedFrames));
	}
	
	/**
	 * 将选择的SpriteSheet加入到Sheet中
	 */
	private function addSSToSheet($vo:AssetsProgressVO):void
	{
		var __ss:SpriteSheet = _assets.getSpriteSheet($vo.name);
		//当前Sheet的总帧数
		var __sheetTotal:int = ssModel.originalSheet.metadata.totalFrame;
		//当前Sheet的最后一帧的Rect
		var __lastFrameRect:Rectangle = ssModel.originalSheet.metadata.frameRects[__sheetTotal-1];
		//加入的sheet的总帧数
		var __addSheetTotal:int = __ss.metadata.totalFrame;
		var __rect:Rectangle = null;
		var __origRect:Rectangle = null;
		var __bmd:BitmapData = null;
		var __frame:FrameVO = null;
		var __name:String = null;
		//所有帧的信息数组，保存起来，后面方便处理Label
		var __frameVOs:Vector.<FrameVO> = new Vector.<FrameVO>;
		for(var i:int=0;i<__addSheetTotal;i++)
		{
			__rect = __ss.metadata.frameRects[i].clone();
			//将加入的Sheet的所有帧的位置都放到当前Sheet的最后一行换行后的位置
			__rect.y += __lastFrameRect.bottom;
			__origRect = __ss.metadata.originalFrameRects[i].clone();
			__bmd = __ss.getBMDByIndex(i);
			
			__frame = new FrameVO();
			__frame.frameNum = __sheetTotal + i;
			__frame.frameRect = __rect;
			__frame.originRect = __origRect;
			
			//如果新加入的sheet有name，就直接使用。这里不必判断Sheet是否使用name，先加进来，最后用不用是保存时候的事情。
			if(__ss.metadata.hasName)
				__frame.frameName = __ss.metadata.names[i];
				//否则就自动根据资源名称和当前索引生成name
			else
				__frame.frameName = $vo.name + '_' + i;
			__name = __frame.frameName;
			__frameVOs[i] = __frame;
			//将ss中的帧加入当前帧列表
			_frames.addItem(__frame);
			ssModel.addOriginalFrame(__bmd, __rect, __origRect, __name);
		}
		//如果加入的Sheet包含Label，就使用它
		if(__ss.metadata.hasLabel)
		{
			//让当前的SpriteSheet支持Label，使用adjustedSheet即可
			ssModel.adjustedSheet.metadata.hasLabel = true;
			//打开Label面板
			v.labelCB.selected = true;
			var __labelList:Array = null;
			var __newLabelList:Array = null;
			var __labelFrameAL:ArrayList = null;
			//保存加入的Sheet中Label中某一帧的索引，这个索引值是原始的，没有加入当前Sheet总帧数的值
			var __frameNum:int = 0;
			for(var __labelName:String in __ss.metadata.labelsFrame)
			{
				__labelList = __ss.metadata.labelsFrame[__labelName];
				var __curSheetLabelsFrame:Object = ssModel.adjustedSheet.metadata.labelsFrame;
				
				//如果当前的Sheet包含Label，且新的Label中有与当前Label重名的，就不加入同名Label
				if(__curSheetLabelsFrame && (__labelName in __curSheetLabelsFrame)) continue;
				__newLabelList = [];
				__labelFrameAL = new ArrayList();
				//旧的label的index索引，要加上原始的sheet的总帧数，因为帧是加到末尾的
				for(var k:int=0;k<__labelList.length;k++)
				{
					__frameNum = __labelList[k];
					__newLabelList[k] = __frameNum+__sheetTotal;
					//从所有帧列表中删除当前Label中所属的帧，加入到Label列表
					__labelFrameAL.addItem(__frameVOs[__frameNum]);
				}
				_labelAL.addItem(new LabelVO(__labelName, __labelFrameAL));
			}
		}
	}
	
	/**
	 * 将选择的图像加入到Sheet中
	 */
	private function addPicToSheet($vo:AssetsProgressVO):void
	{
		var __bmd:BitmapData = _assets.getBitmapData($vo.name);
		var __total:int = ssModel.originalSheet.metadata.totalFrame;
		//基于最后一帧的rect位置，横向移动rect
		var __rect:Rectangle = ssModel.originalSheet.metadata.frameRects[__total-1].clone();
		__rect.x += __rect.width;
		__rect.width = __bmd.width;
		__rect.height = __bmd.height;
		//原始的rect，不裁切
		var __origRect:Rectangle = new Rectangle(0,0,__bmd.width, __bmd.height);
		//加入帧列表
		var __frame:FrameVO = new FrameVO();
		__frame.frameNum = __total;
		__frame.frameName = $vo.name;
		__frame.frameRect = __rect;
		__frame.originRect = __origRect;
		_frames.addItem(__frame);
		ssModel.addOriginalFrame(__bmd, __rect, __origRect, __frame.frameName);
	}
	
	/**
	 * 实现帧的动画预览
	 */
	private function handler_enterFrame($evt:Event):void
	{
		if(playing)
		{
			nextFrame();
		}
	}
	
	private function nextFrame():void
	{
		trace('nextFrame:', playing, v.frameDG.selectedIndex, selectedFrameIndices);
		if(app.ss.aniPreview.frameOrLabelRBG.selectedValue)
		{
			v.frameDG.selectedIndex = selectedFrameIndices[_currentIndex];
			if(_currentIndex == -1 || _currentIndex == selectedFrameIndices.length-1)
				_currentIndex = 0;
			else
				_currentIndex ++;
		}
		else
		{
			v.frameInLabelDG.selectedIndex = _currentIndex;
			if(_currentIndex == -1 || _currentIndex == v.framesAndLabelData.length-1)
				_currentIndex = 0;
			else
				_currentIndex ++;
		}
	}
	
	/**
	 * 根据选择情况刷新frameDG的显示
	 */
	public function refreshFrameDG():void
	{
		var i:int=0;
		if(!_frames.sort)
		{
			_frames.sort = new Sort();
			_frames.sort.fields = [new SortField('frameNum', false, false)];
		}
		_frames.refresh();
		//若选择的是label，就显示该Label中的所有帧
		if(v.labelCB.selected)
		{
			if(v.labelDDL.selectedIndex < 0)
			{
				v.framesAndLabelData = null;
			}
			else
			{
				var __selectedLabel:LabelVO = v.labelDDL.selectedItem as LabelVO;
				v.framesAndLabelData = __selectedLabel.frames;
			}
		}
		else
		{
			var __selectedIndex:int = (ssModel.selectedFrameIndex >= 0) ? ssModel.selectedFrameIndex : -1;
			v.frameDG.selectedIndex = __selectedIndex;
		}
	}
	
	protected function handler_labelDDLvalueComit($event:FlexEvent):void
	{
		refreshFrameDG();
		v.updateFrameOrLabelGRP();
		previewSSChange();
	}
	
	protected function handler_frameDGValueCommit($event:FlexEvent):void
	{
		//只有不在播放状态，才更新选择的帧列表
		if(!playing)
		{
			selectedFrameIndices = v.frameDG.selectedIndices.concat();
			//获取到的Vector是降序的，倒转它
			selectedFrameIndices.sort(Array.NUMERIC);
			trace('更新indices:', selectedFrameIndices);
			selectFrameChange();
		}
		selectedFrameNum = v.frameDG.selectedIndex==-1? -1 : FrameVO(v.frameDG.selectedItem).frameNum;
		trace('frameDGValueCommit:', selectedFrameNum);
		
		ssModel.selectedFrameIndex = v.selectedFrameIndex;
		ssModel.selectedFrmaeNum = selectedFrameNum;
		if(v.selectedFrameIndex > -1)
		{
			previewSSChange();
		}
		v.updateFrameBTNS(playing);
	}
	
	private function handler_frameInLabelDGValueCommit($evt:FlexEvent):void
	{
		selectedFrameNum = v.frameInLabelDG.selectedIndex==-1? -1 : FrameVO(v.frameInLabelDG.selectedItem).frameNum;
		trace('frameInLabelDGValueCommit:', selectedFrameNum);
		
		ssModel.selectedFrameIndex = v.selectedFrameInLabelIndex;
		ssModel.selectedFrmaeNum = selectedFrameNum;
		if(selectedFrameNum > -1)
		{
			previewSSChange();
		}
		v.updateFrameInLabelBTNS();
	}
	
	
	private function previewSSChange():void
	{
		dispatch(new SSEvent(SSEvent.PREVIEW_SS_CHANGE));
	}
	
	private function handler_renameBTNClick($evt:MouseEvent):void
	{
		var __selectedIndex:int = v.labelDDL.selectedIndex;
		var __item:Object = _labelAL.getItemAt(v.labelDDL.selectedIndex);
		__item.name = v.labelNameInput.text;
		_labelAL.setItemAt(__item, v.labelDDL.selectedIndex);
	}
	
	protected function handler_addLabelBTNclick($event:MouseEvent):void
	{
		trace(v.frameDG.selectedIndex, v.frameDG.selectedItem, v.frameDG.selectedItems, v.labelDDL.selectedItem);
		var __labelName:String = v.labelNameInput.text;
		if(!__labelName)
		{
			Funs.alert(FxGettext.gettext("Please enter label's name!"));
			return;
		}
		if(!v.frameDG.selectedItem)
		{
			Funs.alert(FxGettext.gettext("Please select the frame to add the label!"));
			v.addLabelBTN.enabled = false;
			return;
		}
		for (var i:int = 0; i < _labelAL.length; i++) 
		{
			if(LabelVO(_labelAL.getItemAt(i)).name == __labelName)
			{
				Funs.alert(FxGettext.gettext("Duplicate label's name is't allowed!"));
				return;
			}
		}
		var __framesInLabel:Vector.<FrameVO> =  Vector.<FrameVO>(v.frameDG.selectedItems.concat());
		__framesInLabel.sort(function($a:FrameVO, $b:FrameVO):int
		{
			return $a.frameNum - $b.frameNum;
		}
		);
		var __al:ArrayList = new ArrayList();
		while(__framesInLabel.length>0)
		{
			var __item:FrameVO = __framesInLabel.shift() as FrameVO;
			__al.addItem(__item);
			trace('向Label添加帧：', __item.frameNum);
		}
		_labelAL.addItem(new LabelVO(v.labelNameInput.text, __al));
		v.labelDDL.selectedIndex = _labelAL.length - 1;
		refreshFrameDG();
	}
	
	protected function handler_removeLabelBTNclick($event:MouseEvent):void
	{
		var __item:LabelVO = v.labelDDL.selectedItem as LabelVO;
		_labelAL.removeItem(__item);
		refreshFrameDG();
	}
	
	protected function handler_delFrameBTNclick($event:MouseEvent):void
	{
		if(!v.frameDG.selectedItem)
		{
			//spark的组件怎么这么多绑定bug TNND……
			Funs.alert(FxGettext.gettext("Please select the frame to remove."));
			v.delFrameBTN.enabled = false;
			return;
		}
		while(selectedFrameIndices.length>0)
		{
			var __delItem:FrameVO = v.getFrameItemAt(selectedFrameIndices.pop());
			ssModel.originalSheet.removeFrameAt(__delItem.frameNum);
			ssModel.adjustedSheet.removeFrameAt(__delItem.frameNum);
			ssModel.selectedFrameIndex = -1;
			trace('删除Sheet与adjustedSheet中的帧，删除后：', ssModel.originalSheet.metadata.totalFrame, ssModel.adjustedSheet.metadata.totalFrame);
			//若选择了Label，在labelVO中删除
			if(v.labelCB.selected && v.labelDDL.selectedItem)
			{
				//删除labelVO中的当前帧
				LabelVO(v.labelDDL.selectedItem).frames.removeItem(__delItem);
			}
			//修改所有label中的帧的编号
			for(var i:int=0;i<_labelAL.length;i++)
			{
				var __labelItem:LabelVO = _labelAL.getItemAt(i) as LabelVO;
				refreshFrameNum(__labelItem.frames, __delItem.frameNum);
			}
			//从帧列表中删除
			var __index:int = _frames.getItemIndex(__delItem);
			_frames.removeItemAt(__index);
			//修改帧列表中帧的编号
			refreshFrameNum(_frames, __delItem.frameNum);
		}
		selectedFrameIndices = null;
		selectFrameChange();
		//刷新frameDG的显示
		refreshFrameDG();
		//通知SSPanel已经删除了帧，SSPanel根据需求重新生成
		dispatchOptimize();
	}
	
	/**
	 * 将帧信息中保存的大于$frameNum的帧的索引减1
	 */
	public function refreshFrameNum($list:IList, $frameNum:int):void
	{
		trace('refreshFrameNum:', $list.length, $frameNum);
		//删除了1帧，就要将帧信息中保存的大于此帧索引的帧的索引减1
		for (var i:int = 0; i < $list.length; i++) 
		{
			var __item:FrameVO = $list.getItemAt(i) as FrameVO;
			if(__item.frameNum>$frameNum)
			{
				__item.frameNum --;
				$list.setItemAt(__item, i);
			}
		}
	}
	
	private function handler_ssPreviewPlay($evt:SSEvent):void
	{
		play($evt.info);
	}
	
	private function handler_selectFile($evt:Event):void
	{
		this.dispatch(new SSEvent(SSEvent.BROWSE_FILE, StateType.ADD_TO_SS));
	}
	
	private function handler_browseFileDone($evt:SSEvent):void 
	{
		_addSSFiles = $evt.info as BrowseFileDoneVO;
		if(_addSSFiles && _addSSFiles.openState == StateType.ADD_TO_SS)
		{
			_assets.load(_addSSFiles.toAssetsList());
		}
	}
	
	private function dispatchOptimize():void
	{
		dispatch(new SSEvent(SSEvent.OPTIMIZE_SHEET));
	}
	
	protected function handler_saveResizeBTNclick($evt:SSEvent):void
	{
		//修改选择的帧的初始大小，同时直接重新绘制该帧的bitmapData
		var __rect:Rectangle = ssModel.resizeRect;
		if(selectedFrameIndices)
		{
			var __frame:FrameVO= null;
			var __bmd:BitmapData = null;
			var __point:Point = new Point(0,0);
			var __frameNum:int = 0;
			for (var i:int = 0; i < selectedFrameIndices.length; i++) 
			{
				__bmd = new BitmapData(__rect.width, __rect.height, true, 0x00000000);
				__frame = v.getFrameItemAt(selectedFrameIndices[i]);
				//设置frameVO中保存的两个rect的值，frameVO中的两个rect是从adjustedSheet获取而来，而且使用的是引用，因此同时修改了Global中的adjustedSheet的值
				__frame.frameRect.width = __rect.width;
				__frame.frameRect.height = __rect.height;
				__frame.originRect.x = 0;
				__frame.originRect.y = 0;
				__frame.originRect.width = __rect.width;
				__frame.originRect.height = __rect.height;
				//根据调整的大小重新绘制当前帧的bmd
				__bmd.copyPixels(ssModel.originalSheet.getBMDByIndex(__frame.frameNum), __rect, __point, null, null, true);
				//设置adjustedSheet中的bmd，由于已经修改了两个rect的值，这里就不需要再重置rect
				ssModel.addAdjustedFrameAt(__frame.frameNum, __bmd);
				//设置sheet中的bmd，同时设置两个rect
				ssModel.addOriginalFrameAt(__frame.frameNum,__bmd.clone(), __frame.frameRect.clone(), __frame.originRect.clone());
				v.refreshFrame();
			}
		}
		dispatchOptimize();
		//ani.destroy();
	}
	
	//在大Sheet上点击的时候，寻找被点击到的frame
	private function handler_previewClick($evt:SSEvent):void
	{
		if(playing) return;
		v.findFrameByPoint($evt.info);
	}
	
	private function handler_optimizeDone($evt:SSEvent):void
	{
		init();
	}
	
	//向上移动帧
	protected function handler_upFrameBTNclick($evt:MouseEvent):void
	{
		moveFrame(v.frameDG.selectedIndex, -1);
	}
	
	//向下移动帧
	protected function handler_downFrameBTNclick($evt:MouseEvent):void
	{
		moveFrame(v.frameDG.selectedIndex, 1);
	}
	
	//移动帧
	private function moveFrame($index:int, $flag:int):void
	{
		var __oldFrame:FrameVO = v.getFrameItemAt($index);
		var __oldBmd:BitmapData = ssModel.originalSheet.getBMDByIndex($index).clone();
		ssModel.originalSheet.removeFrameAt(__oldFrame.frameNum);
		ssModel.adjustedSheet.removeFrameAt(__oldFrame.frameNum);
		ssModel.originalSheet.addFrameAt($index + $flag, __oldBmd, __oldFrame.frameRect, __oldFrame.originRect, __oldFrame.frameName);
		ssModel.adjustedSheet.addFrameAt($index + $flag, __oldBmd.clone(), __oldFrame.frameRect, __oldFrame.originRect, __oldFrame.frameName);
		//保存移动之后的index，方便在刷新Frame之后还原
		ssModel.selectedFrameIndex = $index + $flag;
		dispatchOptimize();
	}
	
	private function handler_frameOrLabelChange($evt:SSEvent):void 
	{
		previewSSChange();
	}
}
}