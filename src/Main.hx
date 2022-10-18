package;

import parameters.Slider;
import parameters.ParameterDefinitions;
import lime.utils.Assets;
import peote.ui.interactive.UITextLine;
import peote.ui.util.Unique;
import peote.ui.style.interfaces.StyleID;
import peote.ui.interactive.UIElement;
import peote.ui.event.PointerEvent;
import peote.ui.PeoteUIDisplay;
import peote.ui.style.RoundBorderStyle;
import lime.app.Application;
import lime.ui.Window;
import peote.view.PeoteView;
import peote.view.Color;
import peote.text.Font;
import peote.ui.style.interfaces.FontStyle;

class Main extends Application {

	var display:PeoteUIDisplay;
	var peoteView:PeoteView;
	var sliderDisplay:PeoteUIDisplay;
	var scrollbarDisplay:PeoteUIDisplay;

	public function startSample(window:Window) {
		new Font<MyFontStyle>("assets/fonts/tiled/hack_ascii.json").load(onFontLoaded);
	}

	public function onFontLoaded(font:Font<MyFontStyle>)
	{
		var fontStyle = new MyFontStyle();

		peoteView = new PeoteView(window);

		sliderDisplay = new PeoteUIDisplay(20, 20, window.width - 100, window.height - 40, Color.GREY1);
		peoteView.addDisplay(sliderDisplay);

		var style = new RoundBorderStyle();
		style.color = Color.GREY1;
		style.borderColor = Color.GREY5;
		style.borderSize = 3.0;
		style.borderRadius = 40.0;
		var x = 10;
		var y = 10;

		// set up sliders
		var sliderHeight = 30;
		var sliderWidth = 360;
		var padding = 5;

		var loading = Assets.loadText("assets/ks-parameter-definitions-raw");
		loading.onComplete(text -> {
			var definitions = ParameterFile.loadDefinitions(text);
			trace('${definitions.parameters.length} definitions loaded');

			for (parameter in definitions.parameters) {
				if(parameter.now < 0){
					parameter.percent = 0.5;
				}
				var isVertical = false;
				var slider = new Slider(sliderDisplay, style, x, y, sliderWidth, sliderHeight, isVertical);

				var value = new UITextLine<MyFontStyle>(x + sliderWidth + padding, y, '${parameter.now}', font, fontStyle);
				sliderDisplay.add(value);

				var label = new UITextLine<MyFontStyle>(x + sliderWidth + padding + 50, y, parameter.name, font, fontStyle);
				sliderDisplay.add(label);
				// var percent = parameter.percent;
				slider.setPosition(parameter.percent);
				slider.onDrag = (uiElement, percentX, percentY) -> {
					parameter.percent = percentX;
					value.setText('${parameter.now}');
					value.update();
				}

				slider.onBackgroundClick = (uiElement, e) -> {
					var percent = slider.getPercentOfLength(e.x);
					parameter.percent = percent;
					slider.setPosition(percent);
					value.setText('${parameter.now}');
					value.update();
				}

				y += sliderHeight + padding;
			}

			// set up scroll bar
			scrollbarDisplay = new PeoteUIDisplay(window.width - 70, 20, 30, window.height - 40, Color.GREY1);
			peoteView.addDisplay(scrollbarDisplay);

			// x,y position is relative to display
			// here we fill the display are so copy it's geometry
			var isVertical = true;
			var scrollbar = new Slider(scrollbarDisplay, style, 0, 0, scrollbarDisplay.width, scrollbarDisplay.height, isVertical);
			scrollbar.onDrag = (uiElement, percentX, percentY) -> {
				var offset = (sliderDisplay.height + 60) * percentY;
				sliderDisplay.yOffset = -offset;
				// trace(offset);
			}

			PeoteUIDisplay.registerEvents(window);
		});
	}

	override function onPreloadComplete():Void {
		startSample(window);
	}
}

@:structInit
class MyFontStyle implements FontStyle implements StyleID {
	public var color:Color = Color.WHITE;

	public var width:Float = 12; // 20;
	public var height:Float = 25; // 36;

	// -----------------------------------------
	static var ID:Int = Unique.fontStyleID;

	public inline function getID():Int
		return ID;

	public var id(default, null):Int;

	public function new(id:Int = 0) {
		this.id = id;
	}

	public inline function copy():MyFontStyle {
		return new MyFontStyle(id);
	}
}
