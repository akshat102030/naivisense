import { describe, it, expect, vi } from 'vitest';
import request from 'supertest';
import app from '../src/app';
import './setup';

vi.mock('../src/jobs/queues', () => ({
  snapshotQueue: { add: vi.fn().mockResolvedValue(undefined) },
  chunkQueue:    { add: vi.fn().mockResolvedValue(undefined) },
  embedQueue:    { add: vi.fn().mockResolvedValue(undefined) },
  reportQueue:   { add: vi.fn().mockResolvedValue(undefined) },
}));

const base     = '/api/v1';
const authBase = `${base}/auth`;

async function registerAndLogin(
  phone: string,
  role: 'center_head' | 'therapist' | 'parent',
): Promise<{ token: string; userId: string }> {
  const res = await request(app).post(`${authBase}/register`).send({
    name: `User ${phone}`, phone, password: 'pass1234', role,
  });
  return { token: res.body.accessToken, userId: res.body.user._id };
}

const consentRecord = {
  given_at: new Date().toISOString(),
  given_by: 'Parent Name',
};

describe('POST /api/v1/children', () => {
  it('center_head can create a child', async () => {
    const { token: chToken } = await registerAndLogin('+919000000010', 'center_head');
    const { userId: parentId } = await registerAndLogin('+919000000011', 'parent');

    const res = await request(app)
      .post(`${base}/children`)
      .set('Authorization', `Bearer ${chToken}`)
      .send({
        name:            'Arjun',
        dob:             '2018-01-01T00:00:00Z',
        gender:          'boy',
        diagnosis:       ['autism'],
        severity:        'mild',
        therapy_targets: ['speech'],
        parent_id:       parentId,
        consent_record:  consentRecord,
      });
    expect(res.status).toBe(201);
    expect(res.body.name).toBe('Arjun');
  });

  it('therapist cannot create a child — 403', async () => {
    const { token: tToken }   = await registerAndLogin('+919000000012', 'therapist');
    const { userId: parentId } = await registerAndLogin('+919000000013', 'parent');

    const res = await request(app)
      .post(`${base}/children`)
      .set('Authorization', `Bearer ${tToken}`)
      .send({
        name:            'Test Child',
        dob:             '2018-01-01T00:00:00Z',
        gender:          'girl',
        diagnosis:       ['adhd'],
        severity:        'moderate',
        therapy_targets: ['ot'],
        parent_id:       parentId,
        consent_record:  consentRecord,
      });
    expect(res.status).toBe(403);
    expect(res.body.error.code).toBe('FORBIDDEN');
  });
});

describe('GET /api/v1/children', () => {
  it('therapist only sees their assigned children', async () => {
    const { token: chToken }   = await registerAndLogin('+919000000020', 'center_head');
    const { userId: tId }      = await registerAndLogin('+919000000021', 'therapist');
    const { token: tToken }    = await request(app).post(`${authBase}/login`).send({
      phone: '+919000000021', password: 'pass1234',
    }).then((r) => ({ token: r.body.accessToken }));
    const { userId: parentId } = await registerAndLogin('+919000000022', 'parent');

    // Create child assigned to therapist
    await request(app)
      .post(`${base}/children`)
      .set('Authorization', `Bearer ${chToken}`)
      .send({
        name: 'Child A', dob: '2018-01-01T00:00:00Z', gender: 'boy',
        diagnosis: ['autism'], severity: 'mild', therapy_targets: ['speech'],
        parent_id: parentId, therapist_id: tId, consent_record: consentRecord,
      });

    // Create another child NOT assigned to therapist
    const { userId: parent2Id } = await registerAndLogin('+919000000023', 'parent');
    await request(app)
      .post(`${base}/children`)
      .set('Authorization', `Bearer ${chToken}`)
      .send({
        name: 'Child B', dob: '2019-01-01T00:00:00Z', gender: 'girl',
        diagnosis: ['adhd'], severity: 'moderate', therapy_targets: ['ot'],
        parent_id: parent2Id, consent_record: consentRecord,
      });

    const res = await request(app)
      .get(`${base}/children`)
      .set('Authorization', `Bearer ${tToken}`);

    expect(res.status).toBe(200);
    expect(res.body.every((c: { therapist_id: string }) => c.therapist_id === tId)).toBe(true);
  });

  it('parent only sees their own child', async () => {
    const { token: chToken }    = await registerAndLogin('+919000000030', 'center_head');
    const { userId: parentId, token: pToken } = await registerAndLogin('+919000000031', 'parent');

    await request(app)
      .post(`${base}/children`)
      .set('Authorization', `Bearer ${chToken}`)
      .send({
        name: 'My Child', dob: '2020-01-01T00:00:00Z', gender: 'boy',
        diagnosis: ['speech_delay'], severity: 'mild', therapy_targets: ['speech'],
        parent_id: parentId, consent_record: consentRecord,
      });

    const res = await request(app)
      .get(`${base}/children`)
      .set('Authorization', `Bearer ${pToken}`);

    expect(res.status).toBe(200);
    expect(res.body.every((c: { parent_id: string }) => c.parent_id === parentId)).toBe(true);
  });
});
