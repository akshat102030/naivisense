# Therapist Schedule Assignment

**Objective:** When admin assigns a therapist to a child, also set a recurring weekly schedule (days of week + time range). Show these scheduled sessions in therapist home and parent child detail screens.

## Steps

- [x] Backend: add `schedule` to therapist assignment subdocument in `child.model.ts`
- [x] Backend: add `schedule` to `CreateChildSchema` therapists array in `children.schema.ts`
- [x] Flutter model: add `SessionSchedule` class + `schedule` field to `TherapistAssignmentModel` in `child.dart`
- [x] Flutter admin: add day-picker + time-range UI to Step 6 of `enrollment_wizard_screen.dart`; include schedule in submit payload
- [x] Flutter therapist home: add "Scheduled Sessions" section to `therapist_home_screen.dart`
- [x] Flutter parent: add "Scheduled Sessions" section to `child_detail_screen.dart`

## Verification

- [x] `flutter analyze` — 0 errors, 0 new warnings (only pre-existing info hints)

## Result

Complete. All 6 files modified with no new errors.
