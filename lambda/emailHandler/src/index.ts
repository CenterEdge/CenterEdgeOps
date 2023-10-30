import { DynamoDBClient, PutItemCommand, PutItemInput, PutItemOutput } from "@aws-sdk/client-dynamodb";
import { DeleteObjectCommand, DeleteObjectOutput, DeleteObjectRequest, GetObjectCommand, GetObjectOutput, GetObjectRequest, S3Client } from "@aws-sdk/client-s3";
import { marshall } from "@aws-sdk/util-dynamodb";
import { Context, SNSEvent } from "aws-lambda";
import { ParsedMail } from "mailparser";
import { DbLogEmail } from "./Types";
const simpleParser = require('mailparser').simpleParser;
import https, { RequestOptions } from 'https';

const timeToLive: number = parseInt(process.env.dbTtlDays || '90');
const s3Bucket = process.env.bucketName || 'centeredge-ops-emails'
const s3 = new S3Client({ region: 'us-east-1' })
const ddb = new DynamoDBClient({ region: 'us-east-1' })

export async function handler(
  event: SNSEvent,
  context: Context
) {

  console.log(JSON.stringify(event, null, 2))

  // For each email message in the notification
  for (let record of event.Records)
  {
    const json = JSON.parse(record.Sns.Message)
    if (json.mail.commonHeaders.to.includes("supportlogdb@centeredgesoftware.com")) // DB Processing Emails
    {
      
      const res = await getS3Object(s3Bucket, json.mail.messageId)
      if (res.Body)
      {
        const parsedBody: ParsedMail = await simpleParser(res.Body)
        if (parsedBody.text) {
          let text = await replaceCommonSuffixes(parsedBody.text)
          try {
            const emailData = JSON.parse(text)
            console.log("parsed email data:", emailData)
            await postToDdb("adv-db-msgs", emailData)
            await deleteS3Object(s3Bucket, json.mail.messageId)
          }
          catch(err) {
            console.log("Email body cannot be parsed as JSON:", err)
            console.log("Email body:", parsedBody)
          }
        }
      }
    }
    else if (json.mail.destination.includes("supportlog@centeredgesoftware.com")) // Web Comm Down emails (no longer expected)
    {
      await postSlackMessage("supportlog@ message: " + json.mail.messageId)
    }
  }
}

async function getS3Object(bucketName: string, objectKey: string): Promise<GetObjectOutput> {
  const req: GetObjectRequest = {
    Bucket: bucketName,
    Key: objectKey
  }
  const command = new GetObjectCommand(req)
  const res: GetObjectOutput = await s3.send(command)
  return res
}

async function deleteS3Object(bucketName: string, objectKey: string) {
  const req: DeleteObjectRequest = {
    Bucket: bucketName,
    Key: objectKey
  }
  const command = new DeleteObjectCommand(req)
  const res: DeleteObjectOutput = await s3.send(command)
  return res
}

async function replaceCommonSuffixes(content: string): Promise<string> {
  // Remove Google Groups' disclaimer
  let result = content.replace(/--\s*To unsubscribe from this group and stop receiving emails from it, send an email to supportlogdb\+unsubscribe@centeredgesoftware.com./g," ");
  // Remove TrustWave confidentiality disclaimers
  result = result.replace(/#{82}[^#]*#{82}/gm, "")

  return result
}

async function postToDdb(tableName: string, json: DbLogEmail) {
  const createdAt = new Date(json.createdAt);
  const ttl = Math.round((createdAt.getTime() + (timeToLive * 24 * 60 * 60 * 1000)) / 1000);
  json["ttl"] = ttl;
  const req: PutItemInput = {
    TableName: tableName,
    Item: marshall(json)
  }
  const command = new PutItemCommand(req)
  const res: PutItemOutput = await ddb.send(command)
  return res
}

async function postSlackMessage(message: string): Promise<void> {
  const data = { text: "[lambda_emailHandler] " + message }
  const params: RequestOptions = {
    hostname: "hooks.slack.com",
    method: "POST",
    path: "/services/T0RHYNXT2/BL1AZ03RV/xiIVomztPJosQrQ9g2AqRs7F",
    port: 443,
    headers: {
      "Content-Type": "application/json"
    }
  }
  let req = https.request(params, async (res) => {
    res.setEncoding('utf8');
    res.on('data', (chunk) => {
      console.log("Response:" + chunk)
    })
  })
  req.write(JSON.stringify(data));
  req.end();
}