// Generated automatically by nearley, version 2.20.1
// http://github.com/Hardmath123/nearley
(function () {
function id(x) { return x[0]; }

function omit() { return null; }
function compact(d) {
	d = d.flat();
	return d.filter(x => x !== null);
}
var grammar = {
    Lexer: undefined,
    ParserRules: [
    {"name": "dqstring$ebnf$1", "symbols": []},
    {"name": "dqstring$ebnf$1", "symbols": ["dqstring$ebnf$1", "dstrchar"], "postprocess": function arrpush(d) {return d[0].concat([d[1]]);}},
    {"name": "dqstring", "symbols": [{"literal":"\""}, "dqstring$ebnf$1", {"literal":"\""}], "postprocess": function(d) {return d[1].join(""); }},
    {"name": "sqstring$ebnf$1", "symbols": []},
    {"name": "sqstring$ebnf$1", "symbols": ["sqstring$ebnf$1", "sstrchar"], "postprocess": function arrpush(d) {return d[0].concat([d[1]]);}},
    {"name": "sqstring", "symbols": [{"literal":"'"}, "sqstring$ebnf$1", {"literal":"'"}], "postprocess": function(d) {return d[1].join(""); }},
    {"name": "btstring$ebnf$1", "symbols": []},
    {"name": "btstring$ebnf$1", "symbols": ["btstring$ebnf$1", /[^`]/], "postprocess": function arrpush(d) {return d[0].concat([d[1]]);}},
    {"name": "btstring", "symbols": [{"literal":"`"}, "btstring$ebnf$1", {"literal":"`"}], "postprocess": function(d) {return d[1].join(""); }},
    {"name": "dstrchar", "symbols": [/[^\\"\n]/], "postprocess": id},
    {"name": "dstrchar", "symbols": [{"literal":"\\"}, "strescape"], "postprocess": 
        function(d) {
            return JSON.parse("\""+d.join("")+"\"");
        }
        },
    {"name": "sstrchar", "symbols": [/[^\\'\n]/], "postprocess": id},
    {"name": "sstrchar", "symbols": [{"literal":"\\"}, "strescape"], "postprocess": function(d) { return JSON.parse("\""+d.join("")+"\""); }},
    {"name": "sstrchar$string$1", "symbols": [{"literal":"\\"}, {"literal":"'"}], "postprocess": function joiner(d) {return d.join('');}},
    {"name": "sstrchar", "symbols": ["sstrchar$string$1"], "postprocess": function(d) {return "'"; }},
    {"name": "strescape", "symbols": [/["\\/bfnrt]/], "postprocess": id},
    {"name": "strescape", "symbols": [{"literal":"u"}, /[a-fA-F0-9]/, /[a-fA-F0-9]/, /[a-fA-F0-9]/, /[a-fA-F0-9]/], "postprocess": 
        function(d) {
            return d.join("");
        }
        },
    {"name": "usage_string$string$1", "symbols": [{"literal":"u"}, {"literal":"s"}, {"literal":"a"}, {"literal":"g"}, {"literal":"e"}, {"literal":":"}], "postprocess": function joiner(d) {return d.join('');}},
    {"name": "usage_string", "symbols": ["usage_string$string$1", "__", "name", "__", "usage_args"], "postprocess": compact},
    {"name": "usage_args", "symbols": ["implicitly_required_args"]},
    {"name": "usage_args", "symbols": ["bracketed_args"]},
    {"name": "implicitly_required_args", "symbols": ["argname_or_flag", "__", "implicitly_required_args"], "postprocess": compact},
    {"name": "implicitly_required_args", "symbols": ["argname_or_flag"]},
    {"name": "bracketed_args", "symbols": ["arg", "__", "bracketed_args"], "postprocess": compact},
    {"name": "bracketed_args", "symbols": ["arg"]},
    {"name": "arg", "symbols": ["required_arg"], "postprocess": id},
    {"name": "arg", "symbols": ["optional_arg"], "postprocess": id},
    {"name": "required_arg", "symbols": [{"literal":"<"}, "argname_or_flag", {"literal":">"}], "postprocess": 
        (d) => ({
        	...d[1],
        	optional: false,
        })
        },
    {"name": "optional_arg", "symbols": [{"literal":"["}, "argname_or_flag", {"literal":"]"}], "postprocess": 
        (d) => ({
        	...d[1],
        	optional: true,
        })
        },
    {"name": "argname_or_flag", "symbols": ["flag"], "postprocess": id},
    {"name": "argname_or_flag", "symbols": ["argname"], "postprocess": id},
    {"name": "argname_or_flag", "symbols": ["rest"], "postprocess": id},
    {"name": "argname", "symbols": ["name"], "postprocess": 
        (d) => ({
        	flag: false,
        	name: d[0],
        })
        },
    {"name": "rest$string$1", "symbols": [{"literal":"."}, {"literal":"."}, {"literal":"."}], "postprocess": function joiner(d) {return d.join('');}},
    {"name": "rest", "symbols": ["str", "rest$string$1"], "postprocess": 
        (d) => ({
        	flag: false,
        	rest: true,
        	name: `${d[0]}...`,
        })
        },
    {"name": "flag", "symbols": ["flag_value"], "postprocess": id},
    {"name": "flag", "symbols": ["flag_novalue"], "postprocess": id},
    {"name": "flag_novalue", "symbols": ["flag_terminal"], "postprocess": id},
    {"name": "flag_value", "symbols": ["flag_terminal", "__", "value"], "postprocess": 
        (d) => ({
        	...d[0],
        	value: d[2],
        })
        },
    {"name": "flag_terminal", "symbols": [{"literal":"-"}, "char"], "postprocess": 
        (d) => ({
        	flag: true,
        	name: d[1],
        })
        },
    {"name": "flag_terminal$string$1", "symbols": [{"literal":"-"}, {"literal":"-"}], "postprocess": function joiner(d) {return d.join('');}},
    {"name": "flag_terminal", "symbols": ["flag_terminal$string$1", "name"], "postprocess": 
        (d) => ({
        	flag: true,
        	name: d[1],
        })
        },
    {"name": "name", "symbols": ["word"], "postprocess": id},
    {"name": "value", "symbols": ["word"], "postprocess": id},
    {"name": "char", "symbols": [/[a-zA-Z0-9_]/], "postprocess": id},
    {"name": "word$ebnf$1", "symbols": []},
    {"name": "word$ebnf$1", "symbols": ["word$ebnf$1", /[a-zA-Z0-9_\-]/], "postprocess": function arrpush(d) {return d[0].concat([d[1]]);}},
    {"name": "word", "symbols": ["char", "word$ebnf$1"], "postprocess":  // word cannot start with -
        d => d.flat().join('')
        },
    {"name": "str$ebnf$1", "symbols": []},
    {"name": "str$ebnf$1", "symbols": ["str$ebnf$1", /[a-zA-Z0-9_\- ]/], "postprocess": function arrpush(d) {return d[0].concat([d[1]]);}},
    {"name": "str", "symbols": ["char", "str$ebnf$1"], "postprocess":  // str cannot start with -
        d => d.flat().join('')
        },
    {"name": "_", "symbols": ["wschar"]},
    {"name": "_", "symbols": [], "postprocess": omit},
    {"name": "__", "symbols": ["wschar"], "postprocess": omit},
    {"name": "wschar", "symbols": [/[ ]/], "postprocess": id},
    {"name": "randoms$string$1", "symbols": [{"literal":"d"}, {"literal":"o"}, {"literal":"g"}], "postprocess": function joiner(d) {return d.join('');}},
    {"name": "randoms", "symbols": ["randoms$string$1"]},
    {"name": "randoms$string$2", "symbols": [{"literal":"c"}, {"literal":"a"}, {"literal":"t"}], "postprocess": function joiner(d) {return d.join('');}},
    {"name": "randoms", "symbols": ["randoms$string$2"]},
    {"name": "randoms$string$3", "symbols": [{"literal":"b"}, {"literal":"i"}, {"literal":"g"}, {"literal":"D"}, {"literal":"o"}, {"literal":"g"}], "postprocess": function joiner(d) {return d.join('');}},
    {"name": "randoms", "symbols": ["randoms$string$3"]},
    {"name": "randoms$string$4", "symbols": [{"literal":"s"}, {"literal":"m"}, {"literal":"o"}, {"literal":"l"}, {"literal":"C"}, {"literal":"a"}, {"literal":"t"}], "postprocess": function joiner(d) {return d.join('');}},
    {"name": "randoms", "symbols": ["randoms$string$4"]},
    {"name": "randoms$string$5", "symbols": [{"literal":"f"}, {"literal":"o"}, {"literal":"o"}], "postprocess": function joiner(d) {return d.join('');}},
    {"name": "randoms", "symbols": ["randoms$string$5"]},
    {"name": "randoms$string$6", "symbols": [{"literal":"b"}, {"literal":"a"}, {"literal":"r"}], "postprocess": function joiner(d) {return d.join('');}},
    {"name": "randoms", "symbols": ["randoms$string$6"]},
    {"name": "randoms$string$7", "symbols": [{"literal":"b"}, {"literal":"a"}, {"literal":"z"}], "postprocess": function joiner(d) {return d.join('');}},
    {"name": "randoms", "symbols": ["randoms$string$7"]},
    {"name": "randoms$string$8", "symbols": [{"literal":"q"}, {"literal":"u"}, {"literal":"x"}], "postprocess": function joiner(d) {return d.join('');}},
    {"name": "randoms", "symbols": ["randoms$string$8"]},
    {"name": "randoms$string$9", "symbols": [{"literal":"q"}, {"literal":"u"}, {"literal":"u"}, {"literal":"x"}], "postprocess": function joiner(d) {return d.join('');}},
    {"name": "randoms", "symbols": ["randoms$string$9"]},
    {"name": "randoms$string$10", "symbols": [{"literal":"c"}, {"literal":"o"}, {"literal":"r"}, {"literal":"g"}, {"literal":"e"}], "postprocess": function joiner(d) {return d.join('');}},
    {"name": "randoms", "symbols": ["randoms$string$10"]},
    {"name": "randoms$string$11", "symbols": [{"literal":"g"}, {"literal":"r"}, {"literal":"a"}, {"literal":"u"}, {"literal":"l"}, {"literal":"t"}], "postprocess": function joiner(d) {return d.join('');}},
    {"name": "randoms", "symbols": ["randoms$string$11"]},
    {"name": "randoms$string$12", "symbols": [{"literal":"g"}, {"literal":"a"}, {"literal":"r"}, {"literal":"p"}, {"literal":"l"}, {"literal":"y"}], "postprocess": function joiner(d) {return d.join('');}},
    {"name": "randoms", "symbols": ["randoms$string$12"]},
    {"name": "randoms$string$13", "symbols": [{"literal":"w"}, {"literal":"a"}, {"literal":"l"}, {"literal":"d"}, {"literal":"o"}], "postprocess": function joiner(d) {return d.join('');}},
    {"name": "randoms", "symbols": ["randoms$string$13"]},
    {"name": "randoms$string$14", "symbols": [{"literal":"f"}, {"literal":"r"}, {"literal":"e"}, {"literal":"d"}], "postprocess": function joiner(d) {return d.join('');}},
    {"name": "randoms", "symbols": ["randoms$string$14"]},
    {"name": "randoms$string$15", "symbols": [{"literal":"p"}, {"literal":"l"}, {"literal":"u"}, {"literal":"g"}, {"literal":"h"}], "postprocess": function joiner(d) {return d.join('');}},
    {"name": "randoms", "symbols": ["randoms$string$15"]},
    {"name": "randoms$string$16", "symbols": [{"literal":"t"}, {"literal":"h"}, {"literal":"u"}, {"literal":"d"}], "postprocess": function joiner(d) {return d.join('');}},
    {"name": "randoms", "symbols": ["randoms$string$16"]}
]
  , ParserStart: "usage_string"
}
if (typeof module !== 'undefined'&& typeof module.exports !== 'undefined') {
   module.exports = grammar;
} else {
   window.grammar = grammar;
}
})();
