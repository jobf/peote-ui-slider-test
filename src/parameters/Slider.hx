package parameters;

import peote.view.Color;
import peote.ui.interactive.UIElement;
import peote.ui.PeoteUIDisplay;
import peote.ui.event.PointerEvent;

import peote.ui.style.RoundBorderStyle;

class Slider {
	var draggerSize:Int;
	var length:Int;
	var background:UIElement;
	var dragger:UIElement;
	var isVertical:Bool;
	
	public function new(display:PeoteUIDisplay, style:RoundBorderStyle, x:Int, y:Int, width:Int, height:Int, isVertical:Bool) {
		// ------ background for dragging area ------

		background = new UIElement(x, y, width, height, style);
		background.onPointerDown  = function(uiElement:UIElement, e:PointerEvent) {
			onBackgroundClick(uiElement, e);
		}
		display.add(background);

		// ------ element to drag -----
		this.isVertical = isVertical;
		draggerSize = isVertical ? width : height;
		length = isVertical ? height : width;

		dragger = new UIElement(x, y, draggerSize, draggerSize, style);
		display.add(dragger);

		dragger.setDragArea(background.x, background.y, background.width, background.height);

		dragger.onPointerDown = function(uiElement:UIElement, e:PointerEvent) {
			uiElement.startDragging(e);
			uiElement.style.color = Color.YELLOW;
			uiElement.updateStyle();
		}

		dragger.onPointerUp = function(uiElement:UIElement, e:PointerEvent) {
			uiElement.stopDragging(e);
			uiElement.style.color = Color.GREY1;
			uiElement.updateStyle();
		}

		// onDrag event
		dragger.onDrag = function(uiElement:UIElement, percentX:Float, percentY:Float) {
			// trace('Dragger at: x:${percentX * 100}%, y:${percentY * 100}%');
			onDrag(uiElement, percentX, percentY);
		}
	}

	public var onDrag:(uiElement:UIElement, percentX:Float, percentY:Float) -> Void = (_, _, _) -> trace("give me something to drag !");
	public var onBackgroundClick:(uiElement:UIElement, e:PointerEvent) -> Void = (_, _) -> trace("give me something to click !");

	public function setPosition(percentOfLength:Float) {
		var position = Std.int(length * percentOfLength);
		trace('position $position $percentOfLength $length');
		if (isVertical) {
			dragger.y = position;
		} else {
			dragger.x = position;
		}
		dragger.update();
	}

	public function getPercentOfLength(clicked_position:Float):Float{
		if(clicked_position < 0){
			clicked_position = 0;
		}
		if(clicked_position > length){
			clicked_position = length;
		}
		var position = isVertical ? background.localY(clicked_position) : background.localX(clicked_position);
		return clicked_position / length;
	}


}
