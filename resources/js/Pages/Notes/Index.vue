<!-- File: resources/js/Pages/Notes/Index.vue -->

<script setup>
import { ref, computed } from 'vue'
import { Head, Link, router } from '@inertiajs/vue3'
import AuthenticatedLayout from '@/Layouts/AuthenticatedLayout.vue'
import { PlusIcon, PencilIcon, TrashIcon } from '@heroicons/vue/20/solid'

/**
 * @meta-start
 * @session: 2025-11-16-002
 * @file: resources/js/Pages/Notes/Index.vue
 * @refs: [PRD:NOTES_SYSTEM, PRD:TAGS]
 * @changes: Added tags display in note cards
 * @doc-update: [PRD:NOTES_SYSTEM] ADD Tag badges display in note cards
 * @meta-end
 */

// Props
const props = defineProps({
    notes: {
        type: Array,
        default: () => []
    }
})

// State
const confirmDelete = ref(null)

// Methods
function deleteNote(noteId) {
    if (confirm('Are you sure you want to delete this note?')) {
        router.delete(`/notes/${noteId}`, {
            onSuccess: () => {
                // Success message handled by flash
            }
        })
    }
}

function getColorClasses(color) {
    const colors = {
        yellow: 'bg-yellow-100 border-yellow-300',
        blue: 'bg-blue-100 border-blue-300',
        green: 'bg-green-100 border-green-300',
        pink: 'bg-pink-100 border-pink-300',
        purple: 'bg-purple-100 border-purple-300',
    }
    return colors[color] || colors.yellow
}

function getTagColorClasses(color) {
    const colors = {
        blue: 'bg-blue-100 text-blue-800',
        green: 'bg-green-100 text-green-800',
        yellow: 'bg-yellow-100 text-yellow-800',
        red: 'bg-red-100 text-red-800',
        purple: 'bg-purple-100 text-purple-800',
        pink: 'bg-pink-100 text-pink-800',
        indigo: 'bg-indigo-100 text-indigo-800',
    }
    return colors[color] || 'bg-gray-100 text-gray-800'
}

function truncateContent(content, maxLength = 150) {
    if (content.length <= maxLength) return content
    return content.substring(0, maxLength) + '...'
}
</script>

<template>
    <AuthenticatedLayout>
        <Head title="Notes" />

        <div class="py-12">
            <div class="max-w-7xl mx-auto sm:px-6 lg:px-8">
                <!-- Header -->
                <div class="flex items-center justify-between mb-6">
                    <h2 class="text-2xl font-semibold text-gray-900">My Notes</h2>
                    <Link
                        :href="route('notes.create')"
                        class="inline-flex items-center gap-2 px-4 py-2 bg-blue-600 text-white rounded-lg hover:bg-blue-700 transition"
                    >
                        <PlusIcon class="w-5 h-5" />
                        New Note
                    </Link>
                </div>

                <!-- Notes Grid -->
                <div v-if="notes.length > 0" class="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-4">
                    <div
                        v-for="note in notes"
                        :key="note.id"
                        class="border-2 rounded-lg p-4 hover:shadow-lg transition-shadow"
                        :class="getColorClasses(note.color)"
                    >
                        <!-- Title & Actions -->
                        <div class="flex items-start justify-between mb-2">
                            <h3 class="text-lg font-semibold text-gray-900 flex-1">
                                {{ note.title || 'Untitled' }}
                            </h3>
                            <div class="flex gap-1">
                                <Link
                                    :href="route('notes.edit', note.id)"
                                    class="p-1 text-gray-600 hover:text-blue-600 transition"
                                >
                                    <PencilIcon class="w-4 h-4" />
                                </Link>
                                <button
                                    @click="deleteNote(note.id)"
                                    class="p-1 text-gray-600 hover:text-red-600 transition"
                                >
                                    <TrashIcon class="w-4 h-4" />
                                </button>
                            </div>
                        </div>

                        <!-- Content -->
                        <p class="text-gray-700 text-sm mb-3">
                            {{ truncateContent(note.content) }}
                        </p>

                        <!-- Tags -->
                        <div v-if="note.tags && note.tags.length > 0" class="flex flex-wrap gap-1 mb-3">
                            <span
                                v-for="tag in note.tags"
                                :key="tag.id"
                                class="inline-flex items-center px-2 py-1 rounded-full text-xs font-medium"
                                :class="getTagColorClasses(tag.color)"
                            >
                                {{ tag.name }}
                            </span>
                        </div>

                        <!-- Meta info -->
                        <div class="flex items-center justify-between text-xs text-gray-600 pt-2 border-t border-gray-300">
                            <div class="flex items-center gap-2">
                                <span
                                    v-if="note.priority"
                                    class="px-2 py-1 rounded capitalize"
                                    :class="{
                                        'bg-red-100 text-red-700': note.priority === 'high',
                                        'bg-yellow-100 text-yellow-700': note.priority === 'medium',
                                        'bg-green-100 text-green-700': note.priority === 'low',
                                    }"
                                >
                                    {{ note.priority }}
                                </span>
                                <span v-if="note.is_pinned" class="text-blue-600 font-medium">
                                    📌 Pinned
                                </span>
                            </div>
                            <span v-if="note.date">
                                {{ new Date(note.date).toLocaleDateString() }}
                            </span>
                        </div>
                    </div>
                </div>

                <!-- Empty State -->
                <div v-else class="text-center py-12">
                    <p class="text-gray-500 mb-4">No notes yet. Create your first note!</p>
                    <Link
                        :href="route('notes.create')"
                        class="inline-flex items-center gap-2 px-4 py-2 bg-blue-600 text-white rounded-lg hover:bg-blue-700 transition"
                    >
                        <PlusIcon class="w-5 h-5" />
                        Create Note
                    </Link>
                </div>
            </div>
        </div>
    </AuthenticatedLayout>
</template>