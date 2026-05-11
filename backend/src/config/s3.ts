import { S3Client, PutObjectCommand } from '@aws-sdk/client-s3';
import { getSignedUrl }               from '@aws-sdk/s3-request-presigner';
import { env }                        from './env';

export const s3 = new S3Client({
  region:      env.S3_REGION,
  credentials: {
    accessKeyId:     env.AWS_ACCESS_KEY_ID,
    secretAccessKey: env.AWS_SECRET_ACCESS_KEY,
  },
});

export async function presignUpload(key: string, contentType: string): Promise<string> {
  const cmd = new PutObjectCommand({
    Bucket:      env.S3_BUCKET,
    Key:         key,
    ContentType: contentType,
  });
  return getSignedUrl(s3, cmd, { expiresIn: 900 });
}

export async function uploadBuffer(buffer: Buffer, key: string, contentType: string): Promise<string> {
  await s3.send(new PutObjectCommand({
    Bucket:      env.S3_BUCKET,
    Key:         key,
    Body:        buffer,
    ContentType: contentType,
  }));
  return s3Url(key);
}

export function s3Url(key: string): string {
  return `https://${env.S3_BUCKET}.s3.${env.S3_REGION}.amazonaws.com/${key}`;
}
