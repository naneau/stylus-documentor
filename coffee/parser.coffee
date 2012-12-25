# parser.coffee
#
# *Very* naive Stylus documentor
#
# Makes assumption that all methods are documented with a number of lines

# Node.js file system
fs = require 'fs'

# Parse a stylus file
parseFile = (file) ->

    # Initialize parsing tree
    tree =
        file      : file
        intro     : []
        imports   : []
        variables : []
        functions : []

    # State machine for parser
    parsingState =

        # Current line number
        currentLineNumber   : 0

        # In a multi line (/* ... */) comment?
        inMultiLineComment  : false

        # Is the current line the last one of a multi line comment?
        endMultiLineComment : false

        # Are we parsing a function header?
        parsingHeader       : false

        # Is the next non-empty line supposed to be a function?
        functionOrAssignmentNext        : false

        # Line that starts the current function
        openingLine          : -1

        # Line buffers
        assignmentDocBuffer  : []
        assignmentBuffer     : []

    # Lines in the file
    lines = (fs.readFileSync file, 'utf-8').split "\n"

    # Parse every line using the state machine
    for line in lines

        do (line, tree, parsingState) ->

            # Up the line number
            parsingState.currentLineNumber = parsingState.currentLineNumber + 1

            # Skip empty lines
            return if (do line.trim).length is 0

            # Parse non empty lines
            parseLine line, tree, parsingState

    return tree

# Parse a line depending on state
parseLine = (line, tree, parsingState) ->

    # Parse multi line
    return if parseMultiLine line, tree, parsingState

    # Skip last line of multiline comment
    if parsingState.endMultiLineComment
        parsingState.endMultiLineComment = false
        return

    # Parse import line
    return if parseImport line, tree, parsingState

    # Were we parsing a funciton header?
    wasParsingHeader = parsingState.parsingHeader

    # Parse function header
    parsingState.parsingHeader = parseFunctionHeader line, tree, parsingState

    # If we are parsing a header, return
    return if parsingState.parsingHeader

    # Parse function itself right after parsing of a header
    parsingState.functionOrAssignmentNext = true if wasParsingHeader

    # If we are expecting function header lines
    if parsingState.functionOrAssignmentNext

        # Parsed a variable
        parsedVariable = parseVariable line, tree, parsingState

        return parsingState.functionOrAssignmentNext = false if parsedVariable

        parsingState.functionOrAssignmentNext = parseFunction line, tree, parsingState

# Parse import statement
parseImport = (line, tree, parsingState) ->
    return false if (line.substr 0, 1) isnt '@'

    tree.imports.push line

    true

# Parse a assignment
parseVariable = (line, tree, parsingState) ->

    # Line has no variable
    return false if not lineHasVariable line

    # Open entry
    openEntry line, parsingState

    # Add variable to stack
    variableEntry = entry parsingState, 'variable'

    # Name of the variable
    variableEntry.shortName = variableEntry.assignment.substr 0, (variableEntry.assignment.indexOf ' ')

    tree.variables.push variableEntry

    resetState parsingState

    return true

# Parse function
parseFunction = (line, tree, parsingState) ->

    # Open entry
    openEntry line, parsingState

    # This line ends the function header
    if functionEndsOnLine line

        # Function opening is done
        functionEntry = entry parsingState, 'function'

        # Short name of the function
        functionEntry.shortName = functionEntry.assignment.substr 0, (functionEntry.assignment.indexOf '(')

        tree.functions.push functionEntry

        # Function is no longer coming up
        parsingState.functionOrAssignmentNext = false

        resetState parsingState

        return false

    # We can continue
    return true

# Open an entry
openEntry = (line, parsingState) ->

    # Set the opening line number
    parsingState.openingLine = parsingState.currentLineNumber if parsingState.openingLine is -1

    # Add the line of the function to the buffer
    parsingState.assignmentBuffer.push line

# Function or variable entry
entry = (parsingState, type) ->
    line        : parsingState.openingLine
    assignment  : parsingState.assignmentBuffer.join "\n"
    description : parsingState.assignmentDocBuffer.join "\n"
    type        : type

# Reset parsing state
resetState = (parsingState) ->

    # And we reset the line
    parsingState.openingLine = -1

    # Reset buffers
    parsingState.assignmentBuffer   = []
    parsingState.assignmentDocBuffer = []

# Parse the header of a function
parseFunctionHeader = (line, tree, parsingState) ->

    # Single line comment state
    return false if (line.substr 0, 2) isnt '//'

    # Push to buffer for single lines when in single line comment
    parsingState.assignmentDocBuffer.push (unComment line)

    true

# Parse multi line
parseMultiLine = (line, tree, parsingState) ->
    # Determine multiline comment status

    # Opening multiline comment
    if (line.substr 0, 2) is '/*'
        parsingState.inMultiLineComment  = true
        parsingState.endMultiLineComment = false
        return true

    return false if not parsingState.inMultiLineComment

    if (line.substr -2) is '*/'
        parsingState.inMultiLineComment  = false
        parsingState.endMultiLineComment = true
        return false

    tree.intro.push line

    true

# In function?
inFunction = (line) -> (line.substr 0, 4) is '    '

# Function ends on a line
functionEndsOnLine = (line) -> (line.indexOf(')') isnt -1)

# See if a line has a variable assignment
lineHasVariable = (line) -> line.match /^[a-z\-]+ *\?*=.*/im

# Uncomment a line
unComment = (line) ->

    # Strip comment '//'
    withoutComments = ((do line.trimLeft).substr 2)

    # If the first character after // is a space, strip that too
    return (withoutComments.substr 1) if (withoutComments.substr 0, 1) is ' '

    # Return the line without comments
    return withoutComments

# Export the parseFile method
module.exports = parseFile
