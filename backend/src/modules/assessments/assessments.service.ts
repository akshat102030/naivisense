import { AssessmentModel }             from '../../models/assessment.model';
import { ChildModel }                  from '../../models/child.model';
import { AppError }                    from '../../middleware/error';
import type { AuthPayload }            from '../../middleware/auth';
import type { CreateAssessmentInput }  from './assessments.schema';
import type { IDomainScores }          from '../../models/assessment.model';

// ── Score calculation helpers ─────────────────────────────────────────────

function calcStandard(items: Record<string, { score?: number }>): number {
  const vals = Object.values(items).map((v) => v.score ?? 0);
  if (vals.length === 0) return 0;
  return Math.round((vals.reduce((a, b) => a + b, 0) / (vals.length * 3)) * 100);
}

function calcBehavioral(items: Record<string, { present?: boolean; intensity?: number }>): number {
  const vals = Object.values(items);
  if (vals.length === 0) return 0;
  const scores: number[] = vals.map((v) => {
    if (!v.present) return 3;
    const intensity = v.intensity ?? 3;
    if (intensity <= 2) return 1;
    return 0;
  });
  return Math.round((scores.reduce((a: number, b: number) => a + b, 0) / (scores.length * 3)) * 100);
}

function calcSensory(modalities: Record<string, { pattern?: string; severity?: number }>): number {
  const vals = Object.values(modalities);
  if (vals.length === 0) return 0;
  const scores: number[] = vals.map((v) => {
    if (v.pattern === 'typical') return 3;
    const sev = v.severity ?? 3;
    if (sev <= 2) return 2;
    if (sev <= 4) return 1;
    return 0;
  });
  return Math.round((scores.reduce((a: number, b: number) => a + b, 0) / (scores.length * 3)) * 100);
}

function computeScores(domainData: Record<string, Record<string, unknown>>) {
  const d = domainData as Record<string, Record<string, any>>;

  const domain_scores: Partial<IDomainScores> = {
    attention:            calcStandard(d.attention            ?? {}),
    social_communication: calcStandard(d.social_communication ?? {}),
    receptive_language:   calcStandard(d.receptive_language   ?? {}),
    expressive_language:  calcStandard(d.expressive_language  ?? {}),
    speech_production:    calcStandard(d.speech_production    ?? {}),
    imitation:            calcStandard(d.imitation            ?? {}),
    visual_perception:    calcStandard(d.visual_perception    ?? {}),
    fine_motor:           calcStandard(d.fine_motor           ?? {}),
    gross_motor:          calcStandard(d.gross_motor          ?? {}),
    adl:                  calcStandard(d.adl                  ?? {}),
    academics:            calcStandard(d.academics            ?? {}),
    cognitive:            calcStandard(d.cognitive            ?? {}),
    emotional_regulation: calcStandard(d.emotional_regulation ?? {}),
    behavioral:           calcBehavioral(d.behavioral         ?? {}),
    sensory:              calcSensory(d.sensory               ?? {}),
  };

  const vals = Object.values(domain_scores) as number[];
  const nonZero = vals.filter((v) => v > 0);
  const overall_score_pct = nonZero.length
    ? Math.round(nonZero.reduce((a, b) => a + b, 0) / nonZero.length)
    : 0;

  const risk_level = overall_score_pct >= 70 ? 'green'
                   : overall_score_pct >= 40 ? 'amber'
                   : 'red';

  const developmental_quotient = overall_score_pct;

  return { domain_scores, overall_score_pct, risk_level, developmental_quotient } as const;
}

// ── Access check helper ───────────────────────────────────────────────────

async function assertAccess(childId: string, user: AuthPayload) {
  const child = await ChildModel.findById(childId).lean();
  if (!child) throw new AppError('NOT_FOUND', 'Child not found');

  const ok =
    user.role === 'center_head' ||
    (user.role === 'therapist' &&
      (child.therapists ?? []).some((t) => String(t.therapist_id) === user.sub)) ||
    (user.role === 'parent' && String(child.parent_id) === user.sub);

  if (!ok) throw new AppError('FORBIDDEN', 'Access denied');
  return child;
}

// ── Public functions ──────────────────────────────────────────────────────

export async function createAssessment(input: CreateAssessmentInput, user: AuthPayload) {
  if (user.role === 'parent') throw new AppError('FORBIDDEN', 'Only therapists and admins can create assessments');

  await assertAccess(input.child_id, user);

  const computed = computeScores(input.domain_data as Record<string, Record<string, unknown>>);

  const assessment = await AssessmentModel.create({
    child_id:     input.child_id,
    type:         input.type,
    date:         input.date ? new Date(input.date) : new Date(),
    assessed_by:  user.sub,
    is_complete:  true,
    domain_data:  input.domain_data,
    general_notes: input.general_notes,
    ...computed,
  });

  return assessment;
}

export async function listAssessments(childId: string, user: AuthPayload) {
  await assertAccess(childId, user);
  return AssessmentModel.find({ child_id: childId })
    .sort({ date: -1 })
    .select('-domain_data')   // omit heavy item data from list view
    .lean();
}

export async function getAssessment(id: string, user: AuthPayload) {
  const assessment = await AssessmentModel.findById(id).lean();
  if (!assessment) throw new AppError('NOT_FOUND', 'Assessment not found');

  await assertAccess(String(assessment.child_id), user);
  return assessment;
}
