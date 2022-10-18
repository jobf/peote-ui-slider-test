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
import grig.midi.MidiMessage;
import grig.midi.MessageType;
import grig.midi.MidiFile;
import haxe.io.BytesInput;

class MidiLog extends Application {
	var display:PeoteUIDisplay;
	var peoteView:PeoteView;
	var scrollArea:PeoteUIDisplay;
	var scrollbarDisplay:PeoteUIDisplay;

	public function startSample(window:Window) {
		new Font<MyFontStyle>("assets/fonts/tiled/hack_ascii.json").load(onFontLoaded);
	}

	public function onFontLoaded(font:Font<MyFontStyle>) {
		var fontStyle = new MyFontStyle();

		peoteView = new PeoteView(window);

		scrollArea = new PeoteUIDisplay(20, 20, window.width - 100, window.height * 25, Color.GREY1);
		scrollArea.yOffset = 32700;

		peoteView.addDisplay(scrollArea);

		scrollbarDisplay = new PeoteUIDisplay(window.width - 70, 20, 30, window.height - 40, Color.GREY1);
		peoteView.addDisplay(scrollbarDisplay);
		var style = new RoundBorderStyle();
		style.color = Color.GREY1;
		style.borderColor = Color.GREY5;
		style.borderSize = 3.0;
		style.borderRadius = 40.0;
		var x = 10;
		var padding = 5;

		var total = 0;
		var lineHeight = 16;
		var showText = (text:String) -> {
			if (text.length > 0) {
				var line = new UITextLine<MyFontStyle>(x, lineHeight * total - 32700, '$total $text', font, fontStyle);
				line.onPointerOver = function(uiElement:UITextLine<MyFontStyle>, e:PointerEvent) {
					uiElement.fontStyle.color = Color.MAGENTA;
					uiElement.updateStyle();
				}
				line.onPointerOut = function(uiElement:UITextLine<MyFontStyle>, e:PointerEvent) {
					uiElement.fontStyle.color = Color.WHITE;
					uiElement.updateStyle();
				}
				scrollArea.add(line);
			}
		}

		var loadBytes = Assets.loadBytes("assets/jazzynight.mid");
		loadBytes.onComplete(bytes -> {
			var file = MidiFile.fromInput(new BytesInput(bytes));
			for (track in file.tracks) {
				for (fileEvent in track.midiEvents) {
					switch fileEvent.type {
						case ChannelPrefix(event):
							showText('$event');
						case EndTrack(event):
							showText('$event');
						case KeySignature(event):
							showText('$event');
						case MidiMessage(event):
							showText('$event');
						case PortPrefix(event):
							showText('$event');
						case Sequence(event):
							showText('$event');
						case SequencerSpecific(event):
							showText('$event');
						case SmtpeOffset(event):
							showText('$event');
						case TempoChange(event):
							showText('$event');
						case Text(event):
							showText('$event');
						case TimeSignature(event):
							showText('$event');
					}
					total++;
				}
			}

			var scrollMax = 32700 * 2;
			var scrollbar = new Slider(scrollbarDisplay, style, 0, 0, scrollbarDisplay.width, scrollbarDisplay.height, true);
			scrollbar.onDrag = (uiElement, percentX, percentY) -> {
				var offset = scrollMax * percentY;
				scrollArea.yOffset = -(-32700 + offset);
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

	public var width:Float = 10; // 20;
	public var height:Float = 14; // 36;

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
