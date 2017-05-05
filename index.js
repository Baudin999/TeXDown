

const parser = require('./parser.js');
const fs = require('fs');
const source = fs.readFileSync(__dirname + '/text.td', 'utf8');
try {
    const AST = parser.parse(source);
    console.log(JSON.stringify(AST, null, 4));
}
catch (ex) {
    console.log(JSON.stringify(ex, null, 4));
}