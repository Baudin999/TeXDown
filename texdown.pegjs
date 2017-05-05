{
	const definitions = [];
} 


Document = Newline* idiom:(Define / MultiComment / SingleComment / Command / Paragraph)* ___ Eof {
	return {
		definitions: definitions,
		AST: idiom.filter(i => i)
	}
}


/*
Define commands and inline commands in code
*/

Define = ___ "DEF" __ ":" __ word:Word {
	definitions.push({
		type : "command",
		key: word.value
	});
}

/* We'll need to be able to add comments to the code */
MultiComment = ___ "/*" (!"*/" .)* "*/" {
	return undefined;
}
SingleComment = ___ '//' (!"\n" .)* "\n" {
	return undefined;
}


/*
A simple Command
*/

Command = ___ w:Word _ "{" ___ attributes:Attributes ___ "}" __ {
	return { 
		type : "command", 
		name : w.value,
		attributes : attributes
	}
}


/* 
An inline command
*/

InlineCommand = "{" __ commands:(__ cmd:Word __ "|" __ {return cmd;})* __ s:Sentence "}" __ {
	
	return {
		type: "inline",
		commands: commands,
		value: s
	}
}


/*
A simple Paragraph 
*/

Paragraph = ___ s:Sentence { 
	return {
		type : "paragraph",
		value: s
	}; 
}



/*
Commands consist of Attributes
*/

Attribute "Attribute"
	= key:Word __ "=" __ value:(w:Word __ { return w.value;})* __ {
		return {
			type: "attribute",
			key: key.value,
			value: value.join(" ")
		}
	}

Attributes "Attributes"
	= attrib:Attribute ___ as:("|" ___ a:Attribute { return a; })* {
		as.push(attrib);
		return as;
	}

/*
Sentence: A sentence part in the application. This implementation is
a whole mess of iterating through lists finding the right values of 
the list and merging them into real text fields.
*/

Sentence = words:(Word/_/Enter/InlineCommand)+ {
	
	const _words = words.filter(w => !!w);
	
	let result = [];
	let temp = [];
	
	_words.forEach(w => {
		if (w.type === "text") {
			temp.push(w.value);
		}
		else {
			if (temp.length > 0) {
				result.push({
					type: "text",
					value: temp.join(" ")
				});
				temp = [];
			}
			result.push(w);
		}
	});
	if (temp.length > 0) {
		result.push({
			type: "text",
			value: temp.join(" ")
		});
	}
	return result;
}



Word = w:$(Letter / Digit / Character)+ { return { type: "text", value: w}; }
Number = d:$Digit+ { return +d; }
Eos = Character

Letter = [a-zA-Z]
Digit = [0-9]
Character = "." / "!" 

Whitespace "Whitespace" 
	= " "
_ = Whitespace+ { return undefined; }
__ = Whitespace*  { return undefined; }
___ = (_ / Newline)*  { return undefined; }

Enter = (Newline !Newline) { return { type: "text", value: "\r\n"}; }
Newline "Newline" 
	= "\r\n"
	
Eof = !.