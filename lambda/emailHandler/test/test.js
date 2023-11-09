// Mock event
const event = require('./test_event')

process.env.AWS_REGION = 'us-east-1'
process.env.localTest = true
process.env.bucketName = 'centeredge-ops-emails'
process.env.dbTtlDays = 90

const { handler } = require('../dist/index')

const main = async () => {
  console.time('localTest')
  await handler(event)
  console.timeEnd('localTest')
}

main().catch(error => console.error(error))