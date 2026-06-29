import prisma from '../config/database.config';
import qdrantClient from '../../config/qdrant';
import embeddingService from './embedding.service';
import { v4 as uuidv4 } from 'uuid';
import pdfParse, { Result } from 'pdf-parse';
import {ChunkRow} from '../../models/chunk.row';

class DocumentServiceRag {
    private chunkSize = 1000;
    private chunkOverlap = 200;

    async extractTextFromPDF(buffer: Buffer): Promise<string> {
        const data: Result = await pdfParse(buffer);
        return data.text;
    }

    async extractTextFromFile(buffer: Buffer, mimeType: string): Promise<string> {
        if (mimeType === 'application/pdf') {
            return this.extractTextFromPDF(buffer);
        } else if (mimeType === 'text/plain') {
            return buffer.toString('utf-8');
        } else {
            throw new Error(`Unsupported file type: ${mimeType}`);
        }
    }

    chunkText(text: string): string[] {
        const chunks: string[] = [];
        const words = text.split(/\s+/);

        let currentChunk: string[] = [];
        let currentLength = 0;

        for (const word of words) {
            if (currentLength + word.length + 1 > this.chunkSize && currentChunk.length > 0) {
                chunks.push(currentChunk.join(' '));

                const overlapWords = currentChunk.slice(-Math.floor(this.chunkOverlap / 10));
                currentChunk = [...overlapWords];
                currentLength = currentChunk.join(' ').length;
            }

            currentChunk.push(word);
            currentLength += word.length + 1;
        }

        if (currentChunk.length > 0) {
            chunks.push(currentChunk.join(' '));
        }

        return chunks;
    }

    async processDocument(tenantId: string, file: Express.Multer.File, metadata?: Record<string, any>) {
        const document = await prisma.document.create({
            data: {
                tenantId,
                filename: file.originalname,
                fileSize: file.size,
                mimeType: file.mimetype,
                metadata: metadata || {},
                status: 'PROCESSING',
            },
        });

        try {
            const text = await this.extractTextFromFile(file.buffer, file.mimetype);


            const chunks = this.chunkText(text);


            const embeddings = await embeddingService.generateBatchEmbeddings(chunks);


            const chunkRecords = [];
            const points = [];

            for (let i = 0; i < chunks.length; i++) {
                const chunkId = uuidv4();
                const vectorId = uuidv4();

                chunkRecords.push({
                    id: chunkId,
                    documentId: document.id,
                    tenantId,
                    content: chunks[i],
                    chunkIndex: i,
                    vectorId,
                    metadata: { chunkIndex: i, ...metadata },
                });

                points.push({
                    id: vectorId,
                    vector: embeddings[i],
                    payload: {
                        tenant_id: tenantId,
                        document_id: document.id,
                        chunk_id: chunkId,
                        content: chunks[i],
                        filename: file.originalname,
                        chunk_index: i,
                        metadata: JSON.stringify(metadata || {}),
                    },
                });
            }

            await prisma.documentChunk.createMany({
                data: chunkRecords,
            });

            await qdrantClient.upsert('document_chunks', {
                points,
            });


            await prisma.document.update({
                where: { id: document.id },
                data: {
                    status: 'COMPLETED',
                    chunkCount: chunks.length,
                    processedAt: new Date(),
                },
            });

            return document;
        } catch (error) {
            console.error('Error processing rag:', error);

            await prisma.document.update({
                where: { id: document.id },
                data: { status: 'FAILED' },
            });

            throw error;
        }
    }

    async getDocuments(tenantId: string, page: number = 1, limit: number = 10) {
        const skip = (page - 1) * limit;

        const [documents, total] = await Promise.all([
            prisma.document.findMany({
                where: { tenantId, status: { not: 'DELETED' } },
                skip,
                take: limit,
                orderBy: { uploadedAt: 'desc' },
                select: {
                    id: true,
                    filename: true,
                    fileSize: true,
                    mimeType: true,
                    status: true,
                    chunkCount: true,
                    uploadedAt: true,
                    processedAt: true,
                },
            }),
            prisma.document.count({
                where: { tenantId, status: { not: 'DELETED' } },
            }),
        ]);

        return { documents, total, page, limit };
    }


    async deleteDocument(tenantId: string, documentId: string) {
        const BATCH_SIZE = 500;
        let cursor: string | undefined = undefined;

        try {
            while (true) {
                const chunks: ChunkRow[] = await prisma.documentChunk.findMany({
                    where: {
                        documentId,
                        tenantId,
                    },
                    select: {
                        id: true,
                        vectorId: true,
                    },
                    take: BATCH_SIZE,
                    ...(cursor
                        ? {
                            skip: 1,
                            cursor: { id: cursor },
                        }
                        : {}),
                    orderBy: { id: 'asc' },
                });

                if (chunks.length === 0) break;

                const vectorIds: string[] = chunks.map((c: ChunkRow) => c.vectorId);

                if (vectorIds.length > 0) {
                    await qdrantClient.delete('document_chunks', {
                        points: vectorIds,
                    });
                }

                await prisma.documentChunk.deleteMany({
                    where: {
                        id: { in: chunks.map((c: ChunkRow) => c.id) },
                        tenantId,
                    },
                });

                cursor = chunks[chunks.length - 1].id;
            }

            await prisma.document.update({
                where: {
                    id: documentId,
                    tenantId,
                },
                data: {
                    status: 'DELETED',
                },
            });

            return { success: true };
        } catch (error) {
            console.error('Error deleting rag:', error);
            throw error;
        }
    }
}

export default new DocumentServiceRag();