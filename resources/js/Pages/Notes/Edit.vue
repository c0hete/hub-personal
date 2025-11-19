<!-- File: resources/js/Pages/Notes/Edit.vue -->

<script setup>
import { ref } from 'vue'
import { Head, router } from '@inertiajs/vue3'
import AuthenticatedLayout from '@/Layouts/AuthenticatedLayout.vue'
import TagInput from '@/Components/TagInput.vue'

/**
 * @meta-start
 * @session: 2025-11-16-002
 * @file: resources/js/Pages/Notes/Edit.vue
 * @refs: [PRD:NOTES_SYSTEM, PRD:TAGS]
 * @changes: Added TagInput component to note editing form
 * @doc-update: [PRD:NOTES_SYSTEM] ADD Tag selection in note editing form
 * @meta-end
 */

// Props
const props = defineProps({
    note: {
        type: Object,
        required: true
    }
})

// Form data
const form = ref({
    title: props.note.title || '',
    content: props.note.content || '',
    date: props.note.date || '',
    time: props.note.time || '',
    is_pinned: props.note.is_pinned || false,
    color: props.note.color || 'yellow',
    priority: props.note.priority || 'medium',
    category_id: props.note.category_id || null,
    tags: props.note.tags || [], // Tags existentes de la nota
})

const errors = ref({})
const processing = ref(false)

// Submit
async function submit() {
    processing.value = true
    errors.value = {}

    try {
        // Preparar datos para envío
        const data = {
            ...form.value,
            // Extraer solo IDs de tags existentes
            tag_ids: form.value.tags
                .filter(tag => !tag.isNew)
                .map(tag => tag.id),
            // Extraer nombres de tags nuevos
            new_tags: form.value.tags
                .filter(tag => tag.isNew)
                .map(tag => tag.name),
        }

        router.put(`/notes/${props.note.id}`, data, {
            onSuccess: () => {
                // Redirect automático por Inertia
            },
            onError: (pageErrors) => {
                errors.value = pageErrors
            },
            onFinish: () => {
                processing.value = false
            }
        })
    } catch (error) {
        console.error('Error updating note:', error)
        processing.value = false
    }
}
</script>

<template>
    <AuthenticatedLayout>
        <Head title="Edit Note" />

        <div class="py-12">
            <div class="max-w-3xl mx-auto sm:px-6 lg:px-8">
                <div class="bg-white overflow-hidden shadow-sm sm:rounded-lg">
                    <div class="p-6">
                        <h2 class="text-2xl font-semibold text-gray-900 mb-6">Edit Note</h2>

                        <form @submit.prevent="submit" class="space-y-6">
                            <!-- Title -->
                            <div>
                                <label for="title" class="block text-sm font-medium text-gray-700">
                                    Title (optional)
                                </label>
                                <input
                                    id="title"
                                    v-model="form.title"
                                    type="text"
                                    class="mt-1 block w-full rounded-md border-gray-300 shadow-sm focus:border-blue-500 focus:ring-blue-500"
                                    placeholder="Enter title..."
                                />
                                <p v-if="errors.title" class="mt-1 text-sm text-red-600">
                                    {{ errors.title }}
                                </p>
                            </div>

                            <!-- Content -->
                            <div>
                                <label for="content" class="block text-sm font-medium text-gray-700">
                                    Content *
                                </label>
                                <textarea
                                    id="content"
                                    v-model="form.content"
                                    rows="8"
                                    class="mt-1 block w-full rounded-md border-gray-300 shadow-sm focus:border-blue-500 focus:ring-blue-500"
                                    placeholder="Write your note..."
                                    required
                                ></textarea>
                                <p v-if="errors.content" class="mt-1 text-sm text-red-600">
                                    {{ errors.content }}
                                </p>
                            </div>

                            <!-- Tags -->
                            <div>
                                <label class="block text-sm font-medium text-gray-700 mb-2">
                                    Tags
                                </label>
                                <TagInput v-model="form.tags" :max-tags="20" />
                                <p v-if="errors.tags" class="mt-1 text-sm text-red-600">
                                    {{ errors.tags }}
                                </p>
                            </div>

                            <!-- Date & Time -->
                            <div class="grid grid-cols-2 gap-4">
                                <div>
                                    <label for="date" class="block text-sm font-medium text-gray-700">
                                        Date (optional)
                                    </label>
                                    <input
                                        id="date"
                                        v-model="form.date"
                                        type="date"
                                        class="mt-1 block w-full rounded-md border-gray-300 shadow-sm focus:border-blue-500 focus:ring-blue-500"
                                    />
                                </div>

                                <div>
                                    <label for="time" class="block text-sm font-medium text-gray-700">
                                        Time (optional)
                                    </label>
                                    <input
                                        id="time"
                                        v-model="form.time"
                                        type="time"
                                        class="mt-1 block w-full rounded-md border-gray-300 shadow-sm focus:border-blue-500 focus:ring-blue-500"
                                    />
                                </div>
                            </div>

                            <!-- Color -->
                            <div>
                                <label class="block text-sm font-medium text-gray-700 mb-2">
                                    Color
                                </label>
                                <div class="flex gap-2">
                                    <button
                                        v-for="color in ['yellow', 'blue', 'green', 'pink', 'purple']"
                                        :key="color"
                                        type="button"
                                        @click="form.color = color"
                                        class="w-10 h-10 rounded-lg border-2 transition-all"
                                        :class="{
                                            'bg-yellow-200 border-yellow-400': color === 'yellow',
                                            'bg-blue-200 border-blue-400': color === 'blue',
                                            'bg-green-200 border-green-400': color === 'green',
                                            'bg-pink-200 border-pink-400': color === 'pink',
                                            'bg-purple-200 border-purple-400': color === 'purple',
                                            'ring-2 ring-offset-2 ring-gray-900': form.color === color,
                                        }"
                                    ></button>
                                </div>
                            </div>

                            <!-- Priority -->
                            <div>
                                <label class="block text-sm font-medium text-gray-700 mb-2">
                                    Priority
                                </label>
                                <div class="flex gap-2">
                                    <button
                                        v-for="priority in ['low', 'medium', 'high']"
                                        :key="priority"
                                        type="button"
                                        @click="form.priority = priority"
                                        class="px-4 py-2 rounded-lg border-2 transition-all capitalize"
                                        :class="{
                                            'border-blue-500 bg-blue-50 text-blue-700': form.priority === priority,
                                            'border-gray-300 bg-white text-gray-700': form.priority !== priority,
                                        }"
                                    >
                                        {{ priority }}
                                    </button>
                                </div>
                            </div>

                            <!-- Pinned -->
                            <div class="flex items-center">
                                <input
                                    id="is_pinned"
                                    v-model="form.is_pinned"
                                    type="checkbox"
                                    class="h-4 w-4 text-blue-600 focus:ring-blue-500 border-gray-300 rounded"
                                />
                                <label for="is_pinned" class="ml-2 block text-sm text-gray-900">
                                    Pin this note
                                </label>
                            </div>

                            <!-- Actions -->
                            <div class="flex items-center justify-end gap-4 pt-4 border-t">
                                <button
                                    type="button"
                                    @click="router.visit('/notes')"
                                    class="px-4 py-2 text-sm font-medium text-gray-700 bg-white border border-gray-300 rounded-lg hover:bg-gray-50"
                                >
                                    Cancel
                                </button>
                                <button
                                    type="submit"
                                    :disabled="processing"
                                    class="px-4 py-2 text-sm font-medium text-white bg-blue-600 rounded-lg hover:bg-blue-700 disabled:opacity-50 disabled:cursor-not-allowed"
                                >
                                    {{ processing ? 'Updating...' : 'Update Note' }}
                                </button>
                            </div>
                        </form>
                    </div>
                </div>
            </div>
        </div>
    </AuthenticatedLayout>
</template>