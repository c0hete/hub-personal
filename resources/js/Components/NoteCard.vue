/**
 * @meta-start
 * @session: 2025-11-24-001
 * @file: resources/js/Components/NoteCard.vue
 * @refs: [DESIGN:COMPONENTS, DB:SCHEMA_NOTES]
 * @changes: Created NoteCard using shadcn Card and Badge components
 * @doc-update: [DESIGN:COMPONENTS] ADD NoteCard.vue app-specific card for note display
 * @meta-end
 */

<script setup lang="ts">
import { computed } from 'vue'
import { Link } from '@inertiajs/vue3'
import Card from '@/components/ui/Card.vue'
import CardContent from '@/components/ui/CardContent.vue'
import Badge from '@/components/ui/Badge.vue'
import Button from '@/components/ui/button.vue'

interface Note {
  id: number
  title?: string | null
  content: string
  color: string
  priority: string
  is_pinned: boolean
  date?: string | null
  time?: string | null
  tags?: Array<{ id: number; name: string; color?: string }>
}

interface Props {
  note: Note
}

const props = defineProps<Props>()

const colorClasses = computed(() => {
  const colors: Record<string, string> = {
    yellow: 'bg-yellow-50 border-yellow-200 dark:bg-yellow-950/20 dark:border-yellow-800',
    blue: 'bg-blue-50 border-blue-200 dark:bg-blue-950/20 dark:border-blue-800',
    green: 'bg-green-50 border-green-200 dark:bg-green-950/20 dark:border-green-800',
    pink: 'bg-pink-50 border-pink-200 dark:bg-pink-950/20 dark:border-pink-800',
    purple: 'bg-purple-50 border-purple-200 dark:bg-purple-950/20 dark:border-purple-800',
  }
  return colors[props.note.color] || colors.yellow
})

const priorityBadgeVariant = computed(() => {
  const variants: Record<string, any> = {
    low: 'secondary',
    medium: 'default',
    high: 'destructive',
  }
  return variants[props.note.priority] || 'secondary'
})

const truncatedContent = computed(() => {
  return props.note.content.substring(0, 150) + (props.note.content.length > 150 ? '...' : '')
})
</script>

<template>
  <Link :href="`/notes/${note.id}/edit`" class="block hover:shadow-md transition-shadow">
    <Card :class="colorClasses">
      <CardContent class="pt-4">
        <div class="space-y-2">
          <!-- Header with title and pin -->
          <div class="flex items-start justify-between gap-2">
            <div class="flex-1 min-w-0">
              <h3 v-if="note.title" class="font-semibold text-sm truncate">
                {{ note.title }}
              </h3>
              <p class="text-xs text-slate-500 dark:text-slate-400">
                {{ note.date ? new Date(note.date).toLocaleDateString() : 'No date' }}
              </p>
            </div>
            <div v-if="note.is_pinned" class="text-lg">📌</div>
          </div>

          <!-- Content preview -->
          <p class="text-sm text-slate-700 dark:text-slate-300 line-clamp-3">
            {{ truncatedContent }}
          </p>

          <!-- Footer with badges and priority -->
          <div class="flex flex-wrap gap-2 items-center pt-2 border-t border-slate-200 dark:border-slate-800">
            <!-- Priority badge -->
            <Badge :variant="priorityBadgeVariant" class="capitalize text-xs">
              {{ note.priority }}
            </Badge>

            <!-- Tag badges -->
            <div v-if="note.tags && note.tags.length" class="flex flex-wrap gap-1">
              <Badge
                v-for="tag in note.tags.slice(0, 2)"
                :key="tag.id"
                variant="outline"
                class="text-xs"
              >
                {{ tag.name }}
              </Badge>
              <Badge
                v-if="note.tags.length > 2"
                variant="outline"
                class="text-xs"
              >
                +{{ note.tags.length - 2 }}
              </Badge>
            </div>
          </div>
        </div>
      </CardContent>
    </Card>
  </Link>
</template>
