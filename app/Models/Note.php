<?php

// File: app/Models/Note.php

/**
 * @meta-start
 * @session: 2025-11-15-001
 * @file: app/Models/Note.php
 * @refs: [DB:SCHEMA_NOTES]
 * @changes: Added priority and color fields to Note model
 * @doc-update: [DB:SCHEMA_NOTES] ADD priority VARCHAR(10) DEFAULT 'medium'
 * @doc-update: [DB:SCHEMA_NOTES] ADD color VARCHAR(20) DEFAULT 'yellow'
 * @meta-end
 */

namespace App\Models;

use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\SoftDeletes;

class Note extends Model
{
    use SoftDeletes;

    protected $fillable = [
        'user_id',
        'title',
        'content',
        'date',
        'is_pinned',
    ];

    protected $casts = [
        'date' => 'date',
        'is_pinned' => 'boolean',
    ];

    // Relacion: Nota pertenece a un usuario
    public function user()
    {
        return $this->belongsTo(User::class);
    }

             
}
