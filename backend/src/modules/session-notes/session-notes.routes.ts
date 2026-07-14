import { Router } from "express";

import {
    createNotes,
    fetchNotes,
    editNotes,
    removeNotes
} from "./session-notes.controller";


import { requireAuth } from "../../middleware/auth";


const router = Router();



router.use(requireAuth);



// Add notes
// therapist only handled in service
router.post(
    "/:sessionId/notes",
    createNotes
);



// Read notes
router.get(
    "/:sessionId/notes",
    fetchNotes
);



// Update notes
router.patch(
    "/:sessionId/notes",
    editNotes
);



// Delete notes
router.delete(
    "/:sessionId/notes",
    removeNotes
);



export default router;