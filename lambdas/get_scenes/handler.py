import json
import os

import boto3

s3 = boto3.client("s3")
BUCKET = os.environ["SCENES_BUCKET"]
KEY = os.environ["MANIFEST_KEY"]

HEADERS = {
    "Content-Type": "application/json",
    "Access-Control-Allow-Origin": "*",
    "Access-Control-Allow-Methods": "GET,OPTIONS",
    "Access-Control-Allow-Headers": "Content-Type",
    "Cache-Control": "public, max-age=300",
}

_cached_manifest = None
_cached_etag = None


def lambda_handler(event, context):
    global _cached_manifest, _cached_etag

    try:
        head = s3.head_object(Bucket=BUCKET, Key=KEY)
        current_etag = head["ETag"]
    except Exception as e:
        return {
            "statusCode": 500,
            "headers": HEADERS,
            "body": json.dumps({"error": f"Failed to check manifest: {str(e)}"}),
        }

    if _cached_manifest is not None and _cached_etag == current_etag:
        return {
            "statusCode": 200,
            "headers": HEADERS,
            "body": _cached_manifest,
        }

    try:
        response = s3.get_object(Bucket=BUCKET, Key=KEY)
        manifest = response["Body"].read().decode("utf-8")
        _cached_manifest = manifest
        _cached_etag = current_etag
    except Exception as e:
        return {
            "statusCode": 500,
            "headers": HEADERS,
            "body": json.dumps({"error": f"Failed to read manifest: {str(e)}"}),
        }

    return {
        "statusCode": 200,
        "headers": HEADERS,
        "body": manifest,
    }
