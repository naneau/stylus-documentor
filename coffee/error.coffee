# Error out of the process
module.exports = (message) ->

    # Log the message
    console.error message

    # Non-zero exit
    process.exit 1
