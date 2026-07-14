import { SessionModel } from "../../models/session.model";
import { ChildModel } from "../../models/child.model";
import { AppError } from "../../middleware/error";

import type { AuthPayload } 
from "../../middleware/auth";

import type {
 SessionNotesInput
}
from "./session-notes.schema";



export async function addNotes(

    sessionId:string,

    input:SessionNotesInput,

    user:AuthPayload

){

    if(user.role !== "therapist")
    {
        throw new AppError(
            "FORBIDDEN",
            "Only therapists can add notes"
        );
    }



    const session =
    await SessionModel.findById(sessionId);



    if(!session)
    {
        throw new AppError(
            "NOT_FOUND",
            "Session not found"
        );
    }



    if(
        session.therapist_id.toString()
        !== user.sub
    )
    {
        throw new AppError(
            "FORBIDDEN",
            "This is not your session"
        );
    }



    if(session.notes)
    {
        throw new AppError(
            "CONFLICT",
            "Notes already exist"
        );
    }



    session.notes = {

        ...input,

        submitted_at:new Date()

    };



    session.status="completed";


    await session.save();


    return session;

}






export async function updateNotes(

    sessionId:string,

    input:SessionNotesInput,

    user:AuthPayload

){

    if(user.role !== "therapist")
    {
        throw new AppError(
            "FORBIDDEN",
            "Only therapists can update notes"
        );
    }



    const session =
    await SessionModel.findById(sessionId);



    if(!session)
    {
        throw new AppError(
            "NOT_FOUND",
            "Session not found"
        );
    }



    if(
        session.therapist_id.toString()
        !==user.sub
    )
    {
        throw new AppError(
            "FORBIDDEN",
            "Not your session"
        );
    }



    if(!session.notes)
    {
        throw new AppError(
            "NOT_FOUND",
            "Notes not found"
        );
    }



    session.notes = {

        ...session.notes,

        ...input,

        submitted_at:new Date()

    };



    await session.save();


    return session.notes;

}







export async function getNotes(

    sessionId:string,

    user:AuthPayload

){

    const session =
    await SessionModel.findById(sessionId);



    if(!session)
    {
        throw new AppError(
            "NOT_FOUND",
            "Session not found"
        );
    }



    const child =
    await ChildModel.findById(
        session.child_id
    );



    if(!child)
    {
        throw new AppError(
            "NOT_FOUND",
            "Child not found"
        );
    }




    const allowed =

    // center head
    user.role==="center_head"


    ||

    // lead therapist
    user.role==="lead_therapist"


    ||

    // session therapist
    (
        user.role==="therapist"
        &&
        session.therapist_id.toString()
        ===user.sub
    )


    ||

    // child's parent
    (
        user.role==="parent"
        &&
        child.parent_id.toString()
        ===user.sub
    );



    if(!allowed)
    {
        throw new AppError(
            "FORBIDDEN",
            "Access denied"
        );
    }



    return session.notes ?? null;

}








export async function deleteNotes(

    sessionId:string,

    user:AuthPayload

){


    if(user.role !== "therapist")
    {
        throw new AppError(
            "FORBIDDEN",
            "Only therapists can delete notes"
        );
    }



    const session =
    await SessionModel.findById(sessionId);



    if(!session)
    {
        throw new AppError(
            "NOT_FOUND",
            "Session not found"
        );
    }



    if(
        session.therapist_id.toString()
        !==user.sub
    )
    {
        throw new AppError(
            "FORBIDDEN",
            "Not your session"
        );
    }



    session.notes = undefined;


    await session.save();



    return {
        message:"Notes deleted successfully"
    };

}