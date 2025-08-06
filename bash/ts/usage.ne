#
#  usage.ne
#  ts
#
#  Created by Tanner Bennett on 2025-03-01
#  Copyright © 2025 Tanner Bennett. All rights reserved.
#

@builtin "string.ne"

@{%
function omit() { return null; }
function compact(d) {
	d = d.flat();
	return d.filter(x => x !== null);
}
%}

# Top level usage node
usage_string -> "usage:" __ name __ usage_args {% compact %}

# Two possible syntaxes:
# 1. All required:     usage: command arg1 arg2 --flag
# 2. With optionality: usage: command <arg1> <arg2> [--flag]
usage_args -> implicitly_required_args | bracketed_args

# 1. All args are required
implicitly_required_args -> argname_or_flag __ implicitly_required_args {% compact %} | argname_or_flag
# 2. Args indicate their optionality
bracketed_args -> arg __ bracketed_args {% compact %} | arg
arg -> required_arg {% id %} | optional_arg {% id %}

# <arg>
required_arg -> "<" argname_or_flag ">" {%
	(d) => ({
		...d[1],
		optional: false,
	})
%}

# [arg] or [-f] or [--flag] or [--flag value]
optional_arg -> "[" argname_or_flag "]" {%
	(d) => ({
		...d[1],
		optional: true,
	})
%}

# -f/--flag or foo/bar
argname_or_flag -> flag {% id %} | argname {% id %} | rest {% id %}

# Just here to repackage `name` into an object
argname -> name {%
	(d) => ({
		flag: false,
		name: d[0],
	})
%}

# i.e. <the rest ...>
rest -> str "..." {%
	(d) => ({
		flag: false,
		rest: true,
		name: `${d[0]}...`,
	})
%}

# Flags, shorthand or long, with args or without
flag -> flag_value {% id %} | flag_novalue {% id %}
# -f or --flag
flag_novalue -> flag_terminal {% id %}
# --flag value
flag_value -> flag_terminal __ value {%
	(d) => ({
		...d[0],
		value: d[2],
	})
%}

# -f or --flag
flag_terminal -> "-" char {%
	(d) => ({
		flag: true,
		name: d[1],
	})
%} | "--" name {%
	(d) => ({
		flag: true,
		name: d[1],
	})
%}

# Identifiers, unquoted strings, etc

name -> word {% id %}
value -> word {% id %}
char -> [a-zA-Z0-9_] {% id %}
# word -> randoms {%
word -> char [a-zA-Z0-9_\-]:* {% // word cannot start with -
	d => d.flat().join('')
%}
str -> char [a-zA-Z0-9_\- ]:* {% // str cannot start with -
	d => d.flat().join('')
%}

# Spaces

_  -> wschar | null {% omit %}
__ -> wschar {% omit %}

wschar -> [ ] {% id %}

# For testing

randoms -> "dog" | "cat" | "bigDog" | "smolCat" | "foo" | "bar" | "baz" | "qux" | "quux" | "corge" | "grault" | "garply" | "waldo" | "fred" | "plugh" | "thud"
