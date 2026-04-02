import json
import os

import boto3

dynamodb = boto3.resource("dynamodb")
table = dynamodb.Table(os.environ["SCORES_TABLE"])
GSI_NAME = os.environ["GSI_NAME"]

HEADERS = {
    "Content-Type": "application/json",
    "Access-Control-Allow-Origin": "*",
    "Access-Control-Allow-Methods": "GET,OPTIONS",
    "Access-Control-Allow-Headers": "Content-Type",
}

MAX_LIMIT = 50
DEFAULT_LIMIT = 10


def lambda_handler(event, context):
    params = event.get("queryStringParameters") or {}

    try:
        limit = min(int(params.get("limit", DEFAULT_LIMIT)), MAX_LIMIT)
    except (ValueError, TypeError):
        limit = DEFAULT_LIMIT

    if limit < 1:
        limit = DEFAULT_LIMIT

    response = table.query(
        IndexName=GSI_NAME,
        KeyConditionExpression="scorePartition = :pk",
        ExpressionAttributeValues={":pk": "GLOBAL"},
        ScanIndexForward=False,
        Limit=limit,
    )

    scores = [
        {
            "playerId": item["playerId"],
            "score": int(item["score"]),
            "highHex": int(item.get("highHex", 0)),
            "displayName": item.get("displayName", "Anonymous"),
            "timestamp": item["timestamp"],
        }
        for item in response.get("Items", [])
    ]

    return {
        "statusCode": 200,
        "headers": HEADERS,
        "body": json.dumps({"scores": scores, "count": len(scores)}),
    }
