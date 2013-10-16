mandrill       = require('node-mandrill')('9TCCEzf01Iz6pFSgaKxTUg')
module.exports = mandrill

return




mandrill '/messages/send',
  message:
    to: [
      name:  'Casey Flynn'
      email: 'casey_flynn@cobarsystems.com'
    ]
    from_email: 'no-reply@voxtracker.com'
    from_name:  'Cobar Systems'
    subject: 'testing'
    text: 'Testing123'
, (error, response) ->
