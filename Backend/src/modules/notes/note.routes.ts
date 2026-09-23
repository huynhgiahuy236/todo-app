import { Router } from 'express';
import { NoteController } from './note.controller';
import { authenticateJWT } from '../../middlewares/auth.middleware';

const router = Router();

router.use(authenticateJWT);

router.get('/', NoteController.getNotes);
router.post('/', NoteController.createNote);
router.patch('/:id', NoteController.updateNote);
router.patch('/:id/pin', NoteController.togglePin);
router.delete('/:id', NoteController.deleteNote);

export const noteRoutes = router;
