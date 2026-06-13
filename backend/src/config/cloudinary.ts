import { v2 as cloudinary } from 'cloudinary';
import { env } from './env';

cloudinary.config({
  cloud_name: env.CLOUDINARY_CLOUD_NAME,
  api_key:    env.CLOUDINARY_API_KEY,
  api_secret: env.CLOUDINARY_API_SECRET,
  secure:     true,
});

export async function uploadToCloudinary(
  buffer: Buffer,
  folder: string,
  publicId: string,
  mimetype: string,
): Promise<string> {
  const resourceType = mimetype.startsWith('image/') ? 'image' : 'raw';
  return new Promise((resolve, reject) => {
    cloudinary.uploader.upload_stream(
      { folder, public_id: publicId, resource_type: resourceType, overwrite: true },
      (error, result) => {
        if (error || !result) return reject(error ?? new Error('Upload failed'));
        resolve(result.secure_url);
      },
    ).end(buffer);
  });
}
