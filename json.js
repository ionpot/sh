const { readFileSync } = require("fs")
const { fd } = process.stdin
const str = readFileSync(fd, { encoding: "utf8" })
function eol(str) {
    return str + (str.endsWith("\n") ? "" : "\n")
}
try {
    process.stdout.write(eol(JSON.stringify(JSON.parse(str), null, 2)))
} catch (e) {
    process.stderr.write(eol(e.toString()))
}
