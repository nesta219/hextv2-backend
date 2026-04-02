import json
import os
from datetime import datetime, timezone

import boto3

dynamodb = boto3.resource("dynamodb")
table = dynamodb.Table(os.environ["SCORES_TABLE"])

HEADERS = {
    "Content-Type": "application/json",
    "Access-Control-Allow-Origin": "*",
    "Access-Control-Allow-Methods": "POST,OPTIONS",
    "Access-Control-Allow-Headers": "Content-Type",
}


def lambda_handler(event, context):
    try:
        body = json.loads(event.get("body") or "{}")
    except json.JSONDecodeError:
        return {"statusCode": 400, "headers": HEADERS, "body": json.dumps({"error": "Invalid JSON"})}

    player_id = body.get("playerId")
    score = body.get("score")

    if not player_id or not isinstance(player_id, str):
        return {"statusCode": 400, "headers": HEADERS, "body": json.dumps({"error": "playerId is required (string)"})}

    if score is None or not isinstance(score, (int, float)) or score < 0:
        return {"statusCode": 400, "headers": HEADERS, "body": json.dumps({"error": "score is required (non-negative number)"})}

    score = int(score)
    high_hex = int(body.get("highHex", 0))
    display_name = str(body.get("displayName", "Anonymous"))[:20]
    timestamp = datetime.now(timezone.utc).isoformat()

    item = {
        "playerId": player_id,
        "timestamp": timestamp,
        "score": score,
        "highHex": high_hex,
        "displayName": display_name,
        "scorePartition": "GLOBAL",
    }

    table.put_item(Item=item)

    return {
        "statusCode": 200,
        "headers": HEADERS,
        "body": json.dumps(item, default=str),
    }
