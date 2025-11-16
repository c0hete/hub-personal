<?php

namespace App\Policies;

use App\Models\Note;
use App\Models\User;

/**
 * @meta-start
 * @session: 2025-11-16-001
 * @file: app/Policies/NotePolicy.php
 * @refs: [AUTH:POLICY]
 * @changes: Created NotePolicy for note authorization
 * @doc-update: [AUTH:POLICY] ADD NotePolicy ensures users can only access their own notes
 * @meta-end
 */

class NotePolicy
{
    /**
     * Determinar si el usuario puede ver la nota
     */
    public function view(User $user, Note $note): bool
    {
        return $user->id === $note->user_id;
    }

    /**
     * Determinar si el usuario puede actualizar la nota
     */
    public function update(User $user, Note $note): bool
    {
        return $user->id === $note->user_id;
    }

    /**
     * Determinar si el usuario puede eliminar la nota
     */
    public function delete(User $user, Note $note): bool
    {
        return $user->id === $note->user_id;
    }

    /**
     * Determinar si el usuario puede restaurar la nota (soft delete)
     */
    public function restore(User $user, Note $note): bool
    {
        return $user->id === $note->user_id;
    }

    /**
     * Determinar si el usuario puede eliminar permanentemente la nota
     */
    public function forceDelete(User $user, Note $note): bool
    {
        return $user->id === $note->user_id;
    }
}