package view.comps
{
import events.SSEvent;
import flash.events.Event;
import flash.events.MouseEvent;
import flash.geom.Point;
import flash.geom.Rectangle;
import spark.core.SpriteVisualElement;

/**
 * 一个以拖动方式更改大小的矩形，用于确定截取范围
 * @author zrong(zengrong.net)
 * Creation: 2011-8-3
 * Modification: 2013-08-20
 */
[Event(name = "transformChange",type="events.SSEvent" )]
public class TransformTool extends SpriteVisualElement
{
	
	public function TransformTool()
	{
		super();
		this.addEventListener(MouseEvent.MOUSE_DOWN, handler_mouseDown);
	}
	
	[Bindable] public var maxDragW:int;
	[Bindable] public var maxDragH:int;
	
	private var _handlerW:int = 10;
	private var _handlerH:int = 10;
	private var _handlerRectList:Object = { };
	
	private var _mouseDownX:int = 0;
	private var _mouseDownY:int = 0;
	private var _curHandlerLoc:String;
	private var _oldRect:Rectangle;
	
	private function addCheckRelease():void
	{		
		this.addEventListener(MouseEvent.MOUSE_UP, handler_mouseUp);
		this.addEventListener(MouseEvent.RELEASE_OUTSIDE, handler_mouseUp);
	}
	
	private function removeCheckRelease():void
	{
		this.removeEventListener(MouseEvent.MOUSE_UP, handler_mouseUp);
		this.removeEventListener(MouseEvent.RELEASE_OUTSIDE, handler_mouseUp);
	}
	
	private function addenterFrameHandler():void
	{
		this.addEventListener(Event.ENTER_FRAME, handler_enterFrame);
	}
	
	private function removeEnterFrameHandler():void
	{
		this.removeEventListener(Event.ENTER_FRAME, handler_enterFrame);
	}
	
	private function dispatchChange():void
	{
		this.dispatchEvent(new SSEvent(SSEvent.TRANSFORM_CHANGE, transformRect));
		
	}
	
	private function draw():void
	{
		this.graphics.clear();
		
		this.graphics.lineStyle(2, 0);
		this.graphics.beginFill(0, .2);
		this.graphics.drawRect(0, 0, this.width, this.height);
		this.graphics.endFill();
		
		updateHandlerPos();
		
		drawHandler(_handlerRectList.top);
		drawHandler(_handlerRectList.right);
		drawHandler(_handlerRectList.bottom);
		drawHandler(_handlerRectList.left);
		
		dispatchChange();
	}
	
	private function updateHandlerPos():void
	{
		_handlerRectList["top"] = new Rectangle((this.width - _handlerW) / 2, 0, _handlerW, _handlerH);
		_handlerRectList["right"] = new Rectangle(this.width - _handlerW, (this.height-_handlerH)/2, _handlerW, _handlerH);
		_handlerRectList["bottom"] = new Rectangle((this.width - _handlerW) / 2, this.height-_handlerH, _handlerW, _handlerH);
		_handlerRectList["left"] = new Rectangle(0, (this.height-_handlerH)/2, _handlerW, _handlerH);
	}
	
	private function drawHandler($rect:Rectangle):void
	{
		this.graphics.lineStyle(2, 0xFFFFFF);
		this.graphics.beginFill(0);
		this.graphics.drawRect($rect.x, $rect.y, $rect.width, $rect.height);
		this.graphics.endFill();
	}
	
	override public function set width($w:Number):void
	{
		super.width = $w;
		//trace("set width:", this.width);
		draw();
	}
	
	override public function set height($h:Number):void
	{
		super.height = $h;
		//trace("set height:", this.height);
		draw();
	}
	
	public function get transformRect():Rectangle
	{
		return new Rectangle(this.x, this.y, this.width, this.height);
	}
	
	public function set transformRect($rect:Rectangle):void
	{
		move($rect.x, $rect.y);
		resize($rect.width, $rect.height);
	}
	
	private function move($x:int, $y:int):void
	{
		this.x = $x;
		this.y = $y;
		dispatchChange();
	}
	private function resize($w:int, $h:int):void
	{
		this.width = $w;
		this.height = $h;
	}
	
	private function getCurHandlerLoc():String
	{
		_mouseDownX = this.mouseX;
		_mouseDownY = this.mouseY;
		for (var __rectName:String in _handlerRectList)
		{
			var __rect:Rectangle = _handlerRectList[__rectName] as Rectangle;
			if(__rect.contains(_mouseDownX,  _mouseDownY))
			{
				_curHandlerLoc = __rectName;
				_oldRect = this.getRect(this.parent);
				return __rectName;
			}
		}
		_oldRect = null;
		return null;
	}
	
	protected function handler_mouseDown($event:MouseEvent):void
	{
		addCheckRelease();
		addenterFrameHandler();
		
		_curHandlerLoc = getCurHandlerLoc();
	}
	
	protected function handler_mouseUp($event:Event):void
	{
		_curHandlerLoc = null;
		_oldRect = null;
		removeCheckRelease();
		removeEnterFrameHandler();
	}
	
	protected function handler_enterFrame($event:Event):void
	{
		var __mouseX:int = this.parent.mouseX;
		var __mouseY:int = this.parent.mouseY;
		var __x:int = __mouseX - _mouseDownX;
		var __y:int = __mouseY - _mouseDownY;
		//移动
		if(!_curHandlerLoc)
		{
			if(__mouseX -_mouseDownX< 0) __x = 0;
			else if(__mouseX - _mouseDownX > maxDragW - this.width) __x = maxDragW - this.width;
			if(__mouseY - _mouseDownY < 0) __y = 0;
			else if(__mouseY - _mouseDownY > maxDragH - this.height) __y = maxDragH - this.height ;
			move(__x, __y);
			return;
		}
		//下面是改变大小
		var __h:int = 0;
		var __w:int = 0;
		if (_curHandlerLoc == "top")
		{
			__h = _oldRect.height - (__mouseY - _oldRect.y);
			if (__h < 0)
				__h = 0;
			else if (__h > maxDragH - this.y)
				__h = maxDragH - this.y;
			if (__h > 0 && __mouseY > 0)
				this.y = __mouseY;
			this.height = __h;
		}
		else if (_curHandlerLoc == "bottom")
		{
			__h = __mouseY - _oldRect.y;
			if (__h < 0)
				__h = 0;
			else if (__h > maxDragH - this.y)
				__h = maxDragH - this.y;
			else
				//貌似高度计算有点问题 +2试试看
				__h += 2;
			this.height = __h;
		}
		else if (_curHandlerLoc == "left")
		{
			__w = _oldRect.width - (__mouseX - _oldRect.x);
			if (__w < 0)
				__w = 0;
			else if (__w > maxDragW - this.x)
				__w = maxDragW - this.x;
			if (__w > 0 && __mouseX > 0)
				this.x = __mouseX;
			this.width = __w;
		}
		else if (_curHandlerLoc == "right")
		{
			__w = __mouseX - _oldRect.x;
			if (__w < 0)
				__w = 0;
			else if (__w > maxDragW - this.x)
				__w = maxDragW - this.x;
			this.width = __w;
		}
	}
}
}
