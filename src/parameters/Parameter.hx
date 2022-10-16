package parameters;

class Parameter  {
	public function new(name:String, id:Int, type:ParameterType, minimumValue:Int, maximumValue:Int) {
		this.name = name;
		this.id = id;
		this.type = type;
		this.value = {
			min: minimumValue,
			max: maximumValue,
			percent: 0.0
		}
	}

	public var value(default, null):ParameterValue;
	public var name(default, null):String;
	public var id(default, null):Int;
	public var type(default, null):ParameterType;
	public var now(get, null):Int;
	public var percent(get, set):Float;

	
	function get_now() {
		return value.value;
	}

	function set_percent(v:Float):Float {
		value.percent = v;
		return value.percent;
	}
	
		function get_percent():Float {
			return value.percent;
		}

	var percentOfRange:Float;
}
 
enum ParameterType {
	NONE;
	CC;
	NRPN;
}

@:structInit
class ParameterValue {
	var min:Int = 0;
	var max:Int = 127;

	@:isVar public var percent(default, set):Float;

	function set_percent(value:Float):Float {
		if (value < 0.0) {
			value = 0.0;
		}
		if (value > 1.0) {
			value = 1.0;
		}
		return percent = value;
	}

	public var value(get, null):Int = 0;
	function get_value():Int {
		return Std.int(min + (max - min) * percent);
	}	
}
