import std/os
import std/strutils
import std/times

proc deobfuscate(inputFilename: string) =    
    var input = inputFilename.open()
    var dictionary: seq[seq[string]]
    var timeStart = now()
    
    # We will start with making dictionary
    while true:
        var originalLine = input.readLine()
        if originalLine.len == 0 or originalLine.startsWith("//"):
            continue

        if originalLine.startsWith("var "):
            originalLine = originalLine[4..(^1)]

        var line = originalLine.strip(chars = {' ', ';', ','})
        var splittedLine = line.split(" = ", maxsplit = 1)
        
        var key = splittedLine[0]
        var value = splittedLine[1]
        
        dictionary.add(@[key, value])

        # We'll use ";" at end to determine whether we are at end of dictionary or not.
        if originalLine.len > 0 and originalLine[^1] == ';':
            break
    
    var timeEnd = now()

    echo "Took ", (timeEnd-timeStart).inMilliseconds, "ms to get dictionary whose length is ", dictionary.len, ", will now deobfuscate rest of file."

    # Now actual deobfuscating part
    timeStart = now()
    
    var actualContent = ""
    for line in input.lines:
        actualContent.add(line)
        actualContent.add("\n")    
    for i in countdown(dictionary.len-1, 0):
        actualContent = actualContent.replace(dictionary[i][0], dictionary[i][1])
    
    "output.js".writeFile actualContent

    timeEnd = now()
    echo "Done!"
    echo "Took ", (timeEnd - timeStart).inMilliseconds, "ms"


# CLI.
if paramCount() == 0:
    echo "No arguments have been passed."
    quit()

deobfuscate paramStr(1)