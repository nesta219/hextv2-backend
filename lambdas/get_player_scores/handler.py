import json
import os

import boto3

dynamodb = boto3.resource("dynamodb")
table = dynamodb.Table(os.environ["SCORES_TABLE"])

HEADERS = {
    "Content-Type": "application/json",
    "Access-Control-Allow-Origin": "*",
    "Access-Control-Allow-Methods": "GET,OPTIONS",
    "Access-Control-Allow-Headers": "Content-Type",
}

MAX_LIMIT = 50
DEFAULT_LIMIT = 10


def lambda_handler(event, context):
    path_params = event.get("pathParameters") or {}
    player_id = path_params.get("playerId")

    if not player_id:
        return {"statusCode": 400, "headers": HEADERS, "body": json.dumps({"error": "playerId path parameter required"})}

    params = event.get("queryStringParameters") or {}
    try:
        limit = min(int(params.get("limit", DEFAULT_LIMIT)), MAX_LIMIT)
    except (ValueError, TypeError):
        limit = DEFAULT_LIMIT

    response = table.query(
        KeyConditionExpression="playerId = :pk",
        ExpressionAttributeValues={":pk": player_id},
        ScanIndexForward=False,
        Limit=limit,
    )

    # Sort by score descending (table sorts by timestamp, we want by score)
    items = sorted(response.get("Items", []), key=lambda x: int(x.get("score", 0)), reverse=True)[:limit]

    scores = [
        {
            "playerId": item["playerId"],
            "score": int(item["score"]),
            "highHex": int(item.get("highHex", 0)),
            "initials": item.get("initials", "???"),
            "displayName": item.get("displayName", "Anonymous"),
            "timestamp": item["timestamp"],
        }
        for item in items
    ]

    return {
        "statusCode": 200,
        "headers": HEADERS,
        "body": json.dumps({"scores": scores, "count": len(scores)}),
    }
