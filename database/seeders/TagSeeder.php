<?php
// File: database/seeders/TagSeeder.php

namespace Database\Seeders;

use Illuminate\Database\Seeder;
use App\Models\Tag;
use App\Models\User;

/**
 * @meta-start
 * @session: 2025-11-16-002
 * @file: database/seeders/TagSeeder.php
 * @refs: [DB:SEEDERS, PRD:TAGS]
 * @changes: Created TagSeeder with common default tags
 * @doc-update: [DB:SEEDERS] ADD TagSeeder for creating default tags per user
 * @meta-end
 */
class TagSeeder extends Seeder
{
    /**
     * Run the database seeds.
     */
    public function run(): void
    {
        $commonTags = [
            ['name' => 'Personal', 'color' => 'blue'],
            ['name' => 'Trabajo', 'color' => 'indigo'],
            ['name' => 'Urgente', 'color' => 'red'],
            ['name' => 'Ideas', 'color' => 'yellow'],
            ['name' => 'Proyecto', 'color' => 'purple'],
            ['name' => 'Recordatorio', 'color' => 'pink'],
            ['name' => 'Importante', 'color' => 'red'],
            ['name' => 'Pendiente', 'color' => 'green'],
        ];

        // Crear tags para cada usuario existente
        User::all()->each(function ($user) use ($commonTags) {
            foreach ($commonTags as $tagData) {
                // Evitar duplicados
                $user->tags()->firstOrCreate(
                    ['name' => $tagData['name']],
                    ['color' => $tagData['color']]
                );
            }
        });

        $this->command->info('Common tags created for all users!');
    }
}