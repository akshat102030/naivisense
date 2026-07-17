import { AssessmentModel } from "../../models/assessment.model";
import { SessionModel } from "../../models/session.model";
import { HomeTaskLogModel } from "../../models/home-task-log.model";
import { ChildModel } from "../../models/child.model";
import { AppError } from "../../middleware/error";
import type { AuthPayload } from "../../middleware/auth";

async function assertParentAccess(childId: string, user: AuthPayload) {
  const child = await ChildModel.findById(childId).lean();

  if (!child) {
    throw new AppError("NOT_FOUND", "Child not found");
  }

  if (user.role !== "parent" || child.parent_id.toString() !== user.sub) {
    throw new AppError("FORBIDDEN", "Access denied");
  }

  return child;
}

export async function showProgress(
  childId: string,

  user: AuthPayload
) {
  await assertParentAccess(childId, user);

  const assessment = await AssessmentModel.findOne({
    child_id: childId,
  }).lean();

  if (!assessment) {
    throw new AppError("NOT_FOUND", "Assessment not found");
  }

  return {
    previous: assessment.previous ?? null,

    latest: assessment.latest ?? null,
  };
}

export async function getUpcomingSessions(
  childId: string,

  user: AuthPayload
) {
  await assertParentAccess(childId, user);

  const now = new Date();

  return SessionModel.find({
    child_id: childId,

    scheduled_at: {
      $gte: now,
    },

    status: "scheduled",
  })

    .sort({
      scheduled_at: 1,
    })

    .lean();
}

export async function getSessionHistory(
  childId: string,

  user: AuthPayload
) {
  await assertParentAccess(childId, user);

  return SessionModel.find({
    child_id: childId,

    status: "completed",
  })

    .sort({
      scheduled_at: -1,
    })

    .lean();
}

export async function getSessionNotes(
  sessionId: string,

  user: AuthPayload
) {
  const session = await SessionModel.findById(sessionId).lean();

  if (!session) {
    throw new AppError("NOT_FOUND", "Session not found");
  }

  await assertParentAccess(
    session.child_id.toString(),

    user
  );

  return {
    session_id: session._id,

    scheduled_at: session.scheduled_at,

    therapist_id: session.therapist_id,

    notes: session.notes ?? null,
  };
}

export async function getHomework(
  childId: string,

  user: AuthPayload
) {
  await assertParentAccess(
    childId,

    user
  );

  return HomeTaskLogModel.find({
    child_id: childId,
  })

    .sort({
      logged_at: -1,
    })

    .lean();
}

export async function getDashboard(user: AuthPayload) {
  const child = await ChildModel.findOne({
    parent_id: user.sub,
  }).lean();

  if (!child) {
    throw new AppError(
      "NOT_FOUND",

      "Child not found"
    );
  }

  const assessment = await AssessmentModel.findOne({
    child_id: child._id,
  }).lean();

  const upcomingSessions = await SessionModel.countDocuments({
    child_id: child._id,

    status: "scheduled",

    scheduled_at: {
      $gte: new Date(),
    },
  });

  const completedSessions = await SessionModel.countDocuments({
    child_id: child._id,

    status: "completed",
  });

  const homeworkPending = await HomeTaskLogModel.countDocuments({
    child_id: child._id,

    status: "pending",
  });

  return {
    child: {
      id: child._id,

      name: child.name,
    },

    assessment: {
      previous: assessment?.previous ?? null,

      latest: assessment?.latest ?? null,
    },

    sessions: {
      upcoming: upcomingSessions,

      completed: completedSessions,
    },

    homework: {
      pending: homeworkPending,
    },
  };
}
