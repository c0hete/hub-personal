<?php
// File: app/Policies/TagPolicy.php

namespace App\Policies;

use App\Models\Tag;
use App\Models\User;

/**
 * @meta-start
 * @session: 2025-11-16-001
 * @file: app/Policies/TagPolicy.php
 * @refs: [AUTH:POLICY]
 * @changes: Created TagPolicy for tag authorization
 * @doc-update: [AUTH:POLICY] ADD TagPolicy with view, update, delete
 * @meta-end
 */
class TagPolicy
{
    /**
     * Determine if user can view the tag
     */
    public function view(User $user, Tag $tag): bool
    {
        return $user->id === $tag->user_id;
    }

    /**
     * Determine if user can update the tag
     */
    public function update(User $user, Tag $tag): bool
    {
        return $user->id === $tag->user_id;
    }

    /**
     * Determine if user can delete the tag
     */
    public function delete(User $user, Tag $tag): bool
    {
        return $user->id === $tag->user_id;
    }
}