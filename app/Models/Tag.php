<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;
use Illuminate\Database\Eloquent\Relations\BelongsToMany;

/**
 * @meta-start
 * @session: 2025-11-16-001
 * @file: app/Models/Tag.php
 * @refs: [ARCH:FOLDERS, DB:SCHEMA_TAGS]
 * @changes: Created Tag model for note tagging system
 * @doc-update: [ARCH:FOLDERS] ADD Tag.php in app/Models/
 * @meta-end
 */

class Tag extends Model
{
    /**
     * Campos asignables en masa
     */
    protected $fillable = [
        'name',
        'color',
    ];

    /**
     * Relación: tag pertenece a un usuario
     */
    public function user(): BelongsTo
    {
        return $this->belongsTo(User::class);
    }

    /**
     * Relación: tag tiene muchas notas
     */
    public function notes(): BelongsToMany
    {
        return $this->belongsToMany(Note::class, 'notes_tags');
    }

    /**
     * Scope: tags del usuario autenticado
     */
    public function scopeForUser($query, $userId)
    {
        return $query->where('user_id', $userId);
    }

    /**
     * Scope: buscar tag por nombre
     */
    public function scopeByName($query, $name)
    {
        return $query->where('name', 'LIKE', "%{$name}%");
    }
}