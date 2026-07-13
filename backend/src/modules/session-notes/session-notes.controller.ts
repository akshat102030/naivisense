import { Request, Response } from "express";

import {
    addNotes,
    getNotes,
    updateNotes,
    deleteNotes
} from "./session-notes.service";

import {
    SessionNotesSchema
} from "./session-notes.schema";



export async function createNotes(
    req: Request,
    res: Response
){

    const input =
        SessionNotesSchema.parse(req.body);


    const notes =
        await addNotes(
            req.params.sessionId,
            input,
            req.user!
        );


    res.status(201).json({
        message:"Session notes added successfully",
        data:notes
    });

}





export async function fetchNotes(
    req:Request,
    res:Response
){

    const notes =
        await getNotes(
            req.params.sessionId,
            req.user!
        );


    res.status(200).json({
        data:notes
    });

}





export async function editNotes(
    req:Request,
    res:Response
){

    const input =
        SessionNotesSchema.parse(req.body);



    const notes =
        await updateNotes(
            req.params.sessionId,
            input,
            req.user!
        );



    res.status(200).json({

        message:
        "Session notes updated successfully",

        data:notes

    });

}






export async function removeNotes(
    req:Request,
    res:Response
){

    const result =
        await deleteNotes(
            req.params.sessionId,
            req.user!
        );


    res.status(200).json(result);

}