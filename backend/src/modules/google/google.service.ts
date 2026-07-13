import { google } from 'googleapis';
import { AppError } from '../../middleware/error';
import { env }    from '../../config/env';
import { createOAuthClient } from "./google.oauth";
import { encrypt, decrypt } from "../../utils/crypto";
import { CenterProfileModel } from "../../models/center-profile.model";

export async function handleGoogleCallback(
    code: string,
    centerHeadId: string
) {

    const client = createOAuthClient();


    const { tokens } =
        await client.getToken(code);

    console.log(tokens);


    if (!tokens.refresh_token) {

        throw new Error(
            "No refresh token received"
        );

    }


    // IMPORTANT
    client.setCredentials({
        access_token: tokens.access_token,
        refresh_token: tokens.refresh_token,
    });



    const oauth2 = google.oauth2({

        auth: client,

        version: "v2"

    });


    const userInfo =
        await oauth2.userinfo.get();



    console.log(
        "CONNECTED GOOGLE ACCOUNT:",
        userInfo.data.email
    );



    const encryptedToken =
        encrypt(tokens.refresh_token);



    const profile =
        await CenterProfileModel.findOneAndUpdate(

            {
                user_id:centerHeadId
            },

            {

                google_calendar: {

                    google_email:
                    userInfo.data.email,


                    refresh_token:
                    encryptedToken,


                    connected_at:
                    new Date()

                }

            },

            {
                new:true
            }

        );



    if(!profile){

        throw new Error(
            "Center profile not found"
        );

    }


    return {
        email:userInfo.data.email
    };

}

export interface CalendarEventPayload {
  sessionId:       string;
  centerId:         string;
  scheduledAt:     Date | string;
  durationMin:     number;
  childName:       string;
  parentEmail?:    string;
  therapistEmail?: string;
}

export interface CalendarEventResult {
  calendar_event_id: string;
  meeting_link:      string;
  calendar_provider: 'google' | 'manual';
}

export interface UpdateCalendarEventPayload {
  eventId: string;
  centerId: string;
  scheduledAt: Date | string;
  durationMin: number;
  childName: string;
  parentEmail?: string;
  therapistEmail?: string;
}

type CalendarClient = ReturnType<typeof google.calendar>;
type MeetClient = ReturnType<typeof google.meet>;

function normalizePrivateKey(key: string): string {
  return key.replace(/\\n/g, '\n');
}

function getGoogleAuth() {
  if (env.GOOGLE_CLIENT_EMAIL && env.GOOGLE_PRIVATE_KEY) {
    return new google.auth.JWT({
      email: env.GOOGLE_CLIENT_EMAIL,
      key: normalizePrivateKey(env.GOOGLE_PRIVATE_KEY),
      scopes: [
        "https://www.googleapis.com/auth/calendar",
        "https://www.googleapis.com/auth/userinfo.email",
        "https://www.googleapis.com/auth/userinfo.profile"
      ],
      subject: env.GOOGLE_IMPERSONATE_EMAIL,
    });
  }

  if (env.GOOGLE_CLIENT_ID && env.GOOGLE_CLIENT_SECRET && env.GOOGLE_REFRESH_TOKEN) {
    const auth = new google.auth.OAuth2(env.GOOGLE_CLIENT_ID, env.GOOGLE_CLIENT_SECRET);
    auth.setCredentials({ refresh_token: env.GOOGLE_REFRESH_TOKEN });
    return auth;
  }

  return null;
}

async function getCalendarClient(
  centerId:string
): Promise<CalendarClient> {


  const profile =
    await CenterProfileModel.findOne({
      user_id:centerId
    });


  if(!profile){

    throw new AppError(
      "NOT_FOUND",
      "Center profile not found"
    );

  }


  if(
    !profile.google_calendar ||
    !profile.google_calendar.refresh_token
  ){

    throw new AppError(
      "BAD_REQUEST",
      "Google Calendar not connected"
    );

  }


  const refreshToken =
    decrypt(
      profile.google_calendar.refresh_token
    );


  const client =
      createOAuthClient();


  client.setCredentials({

    refresh_token: refreshToken

  });


  return google.calendar({

    version:"v3",

    auth:client

  });

}

function getMeetClient(): MeetClient | null {
  const auth = getGoogleAuth();
  return auth ? google.meet({ version: 'v2', auth }) : null;
}

function fallbackResult(sessionId: string): CalendarEventResult {
  return {
    calendar_event_id: `naivisense-event-${sessionId}`,
    meeting_link:      `https://meet.naivisense.app/session/${sessionId}`,
    calendar_provider: 'manual',
  };
}

function eventMeetingLink(event: {
  hangoutLink?: string | null;
  conferenceData?: { entryPoints?: Array<{ entryPointType?: string | null; uri?: string | null }> } | null;
}): string | undefined {
  return event.hangoutLink ?? event.conferenceData?.entryPoints
    ?.find((entry) => entry.entryPointType === 'video')?.uri ?? undefined;
}

export async function createMeetingLink(sessionId: string): Promise<string> {
  return fallbackResult(sessionId).meeting_link;
}

export async function syncCalendarEvent(
payload: CalendarEventPayload
): Promise<CalendarEventResult> {


const calendar =
await getCalendarClient(
    payload.centerId
);



const scheduledAt =
new Date(payload.scheduledAt);



const endAt =
new Date(
 scheduledAt.getTime()
 +
 payload.durationMin * 60_000
);



const attendees =
[
 payload.parentEmail,
 payload.therapistEmail
]
.filter(
(email): email is string =>
Boolean(email)
)
.map(email=>({
 email
}));



const event =
await calendar.events.insert({

calendarId:"primary",

conferenceDataVersion:1,

sendUpdates:
attendees.length
? "all"
: "none",


requestBody:{


summary:
`NaiviSense session - ${payload.childName}`,


description:
"Therapy session scheduled from NaiviSense.",


start:{
 dateTime:
 scheduledAt.toISOString()
},


end:{
 dateTime:
 endAt.toISOString()
},


attendees,


conferenceData:{

createRequest:{

requestId:
`naivisense-${payload.sessionId}`,

conferenceSolutionKey:{
type:"hangoutsMeet"
}

}

}


}

});



return {


calendar_event_id:
event.data.id!,


meeting_link:
eventMeetingLink(event.data)
??
fallbackResult(
payload.sessionId
).meeting_link,


calendar_provider:
"google"


};


}

export async function fetchMeetAttendance(meetingLink: string, scheduledAt: Date | string) {
  const meet = getMeetClient();
  if (!meet) {
    throw new AppError('SERVICE_UNAVAILABLE', 'Google Meet attendance is not configured');
  }

  const meetingCode = meetingLink
    .split('/')
    .pop()
    ?.replace(/\?.*$/, '')
    .trim();

  if (!meetingCode) {
    throw new AppError('INVALID_INPUT', 'Meeting link does not contain a meeting code');
  }

  const start = new Date(scheduledAt);
  const from = new Date(start.getTime() - 2 * 60 * 60 * 1000).toISOString();
  const to = new Date(start.getTime() + 24 * 60 * 60 * 1000).toISOString();

  const records = await meet.conferenceRecords.list({
    filter: `space.meeting_code = "${meetingCode}" AND start_time >= "${from}" AND start_time <= "${to}"`,
    pageSize: 1,
  });

  const conference = records.data.conferenceRecords?.[0];
  if (!conference?.name) {
    return { participantCount: 0, participantNames: [] as string[] };
  }

  const participants = await meet.conferenceRecords.participants.list({
    parent: conference.name,
    pageSize: 250,
  });

  const participantNames = (participants.data.participants ?? [])
    .map((participant) => participant.signedinUser?.displayName ?? participant.anonymousUser?.displayName)
    .filter((name): name is string => Boolean(name));

  return {
    participantCount: participants.data.participants?.length ?? 0,
    participantNames,
  };
}

export async function updateCalendarEvent(
  payload: UpdateCalendarEventPayload
): Promise<CalendarEventResult> {

  const calendar = getCalendarClient(payload.centerId);

  if (!calendar) {
    throw new AppError(
      "SERVICE_UNAVAILABLE",
      "Google Calendar is not configured"
    );
  }

  const scheduledAt = new Date(payload.scheduledAt);

  const endAt = new Date(
    scheduledAt.getTime() +
    payload.durationMin * 60_000
  );

  const attendees = [
    payload.parentEmail,
    payload.therapistEmail,
  ]
    .filter((email): email is string => Boolean(email))
    .map((email) => ({ email }));

  const updatedEvent = await calendar.events.update({

    calendarId: env.GOOGLE_CALENDAR_ID,

    eventId: payload.eventId,

    sendUpdates: "all",

    requestBody: {

      summary: `NaiviSense session - ${payload.childName}`,

      description: "Therapy session updated from NaiviSense.",

      start: {
        dateTime: scheduledAt.toISOString(),
      },

      end: {
        dateTime: endAt.toISOString(),
      },

      attendees,
    },
  });

  return {

    calendar_event_id:
      updatedEvent.data.id ?? payload.eventId,

    meeting_link:
      eventMeetingLink(updatedEvent.data) ?? "",

    calendar_provider: "google",
  };
}

export async function deleteCalendarEvent(
  eventId: string
): Promise<void> {

  const calendar = getCalendarClient();

  if (!calendar) {
    throw new AppError(
      "SERVICE_UNAVAILABLE",
      "Google Calendar is not configured"
    );
  }

  await calendar.events.delete({
    calendarId: env.GOOGLE_CALENDAR_ID,
    eventId,
    sendUpdates: "all",
  });

}

export function getGoogleAuthUrl(centerId: string) {
  const client = createOAuthClient();

  return client.generateAuthUrl({
    access_type: "offline",
    prompt: "consent",
    scope: [
      "https://www.googleapis.com/auth/calendar",
      "https://www.googleapis.com/auth/userinfo.email",
      "https://www.googleapis.com/auth/userinfo.profile"
    ],
    state: centerId
  });
}


