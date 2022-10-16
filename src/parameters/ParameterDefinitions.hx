package parameters;

import json2object.JsonParser;
import parameters.Parameter;

using StringTools;

using parameters.ParameterDefinitions.ParameterHelper;


class ParameterDefinitionMap {
	var ccDefinitions:Map<Int, ParameterDefinition>;
	var nrpnDefinitions:Map<Int, ParameterDefinition>;

	public var parameters(default, null):Array<Parameter>;

	public function new(parameters:Array<ParameterJSON>) {
		ccDefinitions = new Map<Int, ParameterDefinition>();
		nrpnDefinitions = new Map<Int, ParameterDefinition>();
		this.parameters = new Array<Parameter>();
		var singleParameters = parameters.filter(f -> f.NumParts == 1 && f.BitCount == 7);
		for (p in singleParameters) {
			var d = initDefinition(p);
			this.parameters.push(p.fromJSON());
			// trace(p.Name);
		}
		var packedParameters = parameters.filter(f -> f.NumParts > 1 && f.BitCount == 7);
		for (p in packedParameters) {
			var definition = initDefinition(p);
			// this.parameters.push(p.parameter());
			definition.components = parameters.filter(f -> f.Id == p.Id && f.BitCount < 7);
			for (c in definition.components) {
				this.parameters.push(c.fromJSON());
			}
		}
	}

	public function getDefinition(id:Int, type:ParameterType):ParameterDefinition {
		return switch (type) {
			case ParameterType.NRPN:
				nrpnDefinitions[id];
			default:
				ccDefinitions[id];
		}
	}

	function initDefinition(p:ParameterJSON):ParameterDefinition {
		var definition = new ParameterDefinition(p);
		switch (definition.type) {
			case ParameterType.NRPN:
				nrpnDefinitions[definition.id] = definition;
			default:
				ccDefinitions[definition.id] = definition;
		}
		return definition;
	}
}

class ParameterDefinition {
	public var id(default, null):Int;
	public var type(default, null):ParameterType;
	public var base:ParameterJSON;
	public var components:Array<ParameterJSON>;

	public function new(base:ParameterJSON) {
		components = [];
		this.base = base;
		id = base.Id;
		type = base.Type.determineParameterType();
	}
}

typedef ParameterJSON = {
	var Name:String;
	var Id:Int;
	@:default("CC")
	var Type:String;
	@:default(0)
	var Min:Int;
	@:default(127)
	var Max:Int;
	@:default(0)
	var ZeroSign:Int;
	@:default(1)
	var NumParts:Int;
	@:default(0)
	var StartBit:Int;
	@:default(7)
	var BitCount:Int;
}


class ParameterHelper {
	public static function fromJSON(parameterJSON:ParameterJSON):Parameter {
		return new Parameter(parameterJSON.Name, parameterJSON.Id, determineParameterType(parameterJSON.Type), parameterJSON.Min, parameterJSON.Max);
	}

	public static function parameterJSON(text:String):ParameterJSON {
		var parser = new JsonParser<ParameterJSON>();
		try {
			parser.fromJson(text);
		} catch (e) {
			throw 'error in parser.fromJson ${text}';
		}
		if (parser.errors.length > 0) {}
		var def = parser.value;
		return def;
	}

	public static function determineParameterType(t:String):ParameterType {
		return t.startsWith("NRPN") ? ParameterType.NRPN : t.startsWith("CC") ? ParameterType.CC : ParameterType.NONE;
	}
}



class ParameterFile {
	public static function loadDefinitions(text:String):ParameterDefinitionMap {
		var lines = text.split("\n");
			var parameters = [];
			for (l in lines) {
				try {
					var p = l.parameterJSON();
					if (p != null && p.Type != "NONE") {
						parameters.push(p);
					}
				} catch (e) {
					throw e;
				}
			}
			return new ParameterDefinitionMap(parameters);
	}
}
