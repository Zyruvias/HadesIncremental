const fs = require('fs')

const fileContent = fs.readFileSync("C://Program Files (x86)//Steam//steamapps//common//Hades//Content/Scripts/TraitData.lua", "utf-8")
console.log(fileContent.length)
const lines = fileContent.split("\r\n")
for (line of lines) {
    if (line.startsWith("\t") && line[1] !== "\t" && line[1] != "{" && line[1] !== "}") {
        if (/Trait/.test(line)) {
            console.log(line + " 1,")
        }
    }
    
}