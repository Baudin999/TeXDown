var fs = require('fs');
var peg = require('pegjs');
var pegjsCode = fs.readFileSync(__dirname + '/texdown.pegjs', 'utf8');
var parser = peg.generate(pegjsCode.trim());

module.exports = parser; 
