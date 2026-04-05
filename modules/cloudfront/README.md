# HextV2 AWS Infrastructure — Content Delivery

Terraform/Terragrunt modules for hosting downloadable game scenes via S3 + CloudFront.

---

## Architecture

```
Unity Game Client
    |
    v
CloudFront CDN (HTTPS)
    |  cdn.dev.hextv2.mikenesta.com   (dev)
    |  cdn.hextv2.mikenesta.com       (prod)
    |
    v
S3 Bucket (private, OAC-protected)
    hextv2-scenes-{env}-{accountId}
    |
    +-- manifests/
    |     scenes.json          <-- scene catalog (short TTL: 5 min)
    |
    +-- bundles/
          iOS/
            hidden_lake        <-- AssetBundle files (long TTL: 30 days)
            volcanic_coast
          Android/
            ...
```

---

## Modules

### `s3-scenes`

The S3 bucket storing scene bundles and manifests.

**Resources created:**
- S3 bucket with versioning, AES256 encryption, public access blocked
- Seed manifest object (`manifests/scenes.json`)
- IAM user `hextv2-editor-upload-{env}` with permissions to upload bundles and invalidate CloudFront

**Outputs:**
- `bucket_name`, `bucket_arn`, `bucket_regional_domain_name`
- `editor_upload_user_name`, `editor_upload_user_arn`
- `manifest_key`

### `cloudfront`

The CDN distribution serving content to game clients.

**Resources created:**
- CloudFront distribution with Origin Access Control (OAC)
- ACM certificate for custom domain (auto-validated via Route53)
- Route53 A record (alias to CloudFront)
- S3 bucket policy allowing CloudFront OAC read access

**Cache behaviors:**
| Path | TTL | Rationale |
|------|-----|-----------|
| `manifests/*` | 5 min default, 10 min max | Updated frequently when new scenes are published |
| Everything else (bundles) | 30 days default, 365 days max | Immutable — bundles are versioned by content hash |

**Outputs:**
- `distribution_id`, `distribution_arn`, `distribution_domain_name`
- `cdn_fqdn` (e.g. `cdn.dev.hextv2.mikenesta.com`)
- `cdn_url` (e.g. `https://cdn.dev.hextv2.mikenesta.com`)

---

## Environments

| Environment | CDN Domain | S3 Bucket |
|-------------|-----------|-----------|
| dev | `cdn.dev.hextv2.mikenesta.com` | `hextv2-scenes-dev-081823476824` |
| prod | `cdn.hextv2.mikenesta.com` | `hextv2-scenes-prod-081823476824` |

---

## Deployment

### Prerequisites

- Terraform >= 1.5.0
- Terragrunt
- AWS CLI configured with appropriate credentials

### Apply

```bash
# Apply a single module
make apply-module ENV=dev MOD=s3-scenes
make apply-module ENV=dev MOD=cloudfront

# Apply all modules (dependency order)
make apply ENV=dev

# Plan before applying
make plan-module ENV=dev MOD=cloudfront
```

### Dependency order

CloudFront depends on s3-scenes (needs bucket name, ARN, regional domain).

```
dynamodb -> s3-scenes -> lambda -> api-gateway -> dns -> cloudfront
```

### Destroy

```bash
make destroy-module ENV=dev MOD=cloudfront    # Destroy CloudFront first
make destroy-module ENV=dev MOD=s3-scenes     # Then S3
```

---

## Editor Upload IAM User

Each environment creates an IAM user for Unity Editor uploads:

- **User**: `hextv2-editor-upload-{env}`
- **Permissions**: S3 PutObject/GetObject/ListBucket/DeleteObject + CloudFront CreateInvalidation

### Setup

1. Create access keys in AWS Console: IAM > Users > hextv2-editor-upload-dev > Security credentials
2. Configure AWS CLI:
   ```bash
   aws configure --profile hextv2-editor
   ```
3. In Unity: **Tools > HextV2 > Content Delivery > Set AWS Profile** (defaults to `hextv2-editor`)

---

## Upload Flow

From Unity Editor (**Tools > HextV2 > Content Delivery > Upload Bundles to S3**):

1. Reads bundles from `{project}/Bundles/{platform}/`
2. Uploads each bundle to `s3://{bucket}/bundles/{platform}/{bundleName}`
3. Uploads manifest to `s3://{bucket}/manifests/scenes.json`
4. Invalidates CloudFront cache for `manifests/*`

Or manually via CLI:

```bash
# Upload a bundle
aws --profile hextv2-editor s3 cp Bundles/iOS/my_scene \
  s3://hextv2-scenes-dev-081823476824/bundles/iOS/my_scene

# Upload manifest
aws --profile hextv2-editor s3 cp Bundles/iOS/manifest.json \
  s3://hextv2-scenes-dev-081823476824/manifests/scenes.json \
  --content-type application/json

# Invalidate CloudFront cache
aws --profile hextv2-editor cloudfront create-invalidation \
  --distribution-id E2SUCKO0BPJK2J \
  --paths "/manifests/*"
```

---

## Verifying

```bash
# Check manifest is served
curl https://cdn.dev.hextv2.mikenesta.com/manifests/scenes.json

# Check bundle is accessible (HEAD request)
curl -I https://cdn.dev.hextv2.mikenesta.com/bundles/iOS/hidden_lake

# Check CloudFront distribution status
aws cloudfront get-distribution --id E2SUCKO0BPJK2J --query 'Distribution.Status'
```
