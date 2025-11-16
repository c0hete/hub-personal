<?php

// File: app/Models/Note.php

/**
 * @meta-start
 * @session: 2025-11-15-001
 * @type: model
 * @file: app/Models/Note.php
 * @feature: notes-system
 * @refs: [DB:SCHEMA_NOTES#L610]
 * @changes: Created Note model with user relationship
 * @doc-update: [ROADMAP:MVP#L3340] MARK notes-crud IN_PROGRESS
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

        // 
          // sdsadasd
          // sdsadasd
            // sdsadasd
             // sdsadasd
                // sdsadasd
                   // sdsadasd
                    // sdsadasd
                        // sdsadasd
                        // sdsadasd
                   

             
}
