const { readFileSync } = require("fs")

const { fd } = process.stdin
const args = process.argv.slice(2)

const input = readFileSync(fd, { encoding: "utf8" })

function eol(str) {
    return str + (str.endsWith("\n") ? "" : "\n")
}

try {
    let x = JSON.parse(input)

    for (const a of args)
        if (x !== undefined && x !== null)
            x = x[a]

    if (typeof x === "object")
        x = JSON.stringify(x, null, 2)

    else
        x = String(x)

    process.stdout.write(eol(x))

} catch (e) {
    process.stdout.write(eol(input))
}
