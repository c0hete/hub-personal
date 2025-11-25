/**
 * @meta-start
 * @session: 2025-11-24-001
 * @file: resources/js/Components/TagBadge.vue
 * @refs: [DESIGN:COMPONENTS, DB:SCHEMA_TAGS]
 * @changes: Created TagBadge using shadcn Badge component
 * @doc-update: [DESIGN:COMPONENTS] ADD TagBadge.vue for tag display with remove action
 * @meta-end
 */

<script setup lang="ts">
import Badge from '@/components/ui/Badge.vue'
import { computed } from 'vue'

interface Tag {
  id: number
  name: string
  color?: string
}

interface Props {
  tag: Tag
  removable?: boolean
  onRemove?: (tagId: number) => void
}

const props = withDefaults(defineProps<Props>(), {
  removable: false,
})

const emit = defineEmits<{
  (e: 'remove', tagId: number): void
}>()

const handleRemove = () => {
  emit('remove', props.tag.id)
  if (props.onRemove) {
    props.onRemove(props.tag.id)
  }
}

const colorVariant = computed(() => {
  // Map tag colors to badge variants if color is set
  const colorMap: Record<string, any> = {
    blue: 'default',
    green: 'secondary',
    red: 'destructive',
  }
  return colorMap[props.tag.color || ''] || 'default'
})
</script>

<template>
  <div class="inline-flex items-center gap-1">
    <Badge :variant="colorVariant" class="text-xs">
      {{ tag.name }}
    </Badge>
    <button
      v-if="removable"
      @click="handleRemove"
      type="button"
      class="ml-1 text-xs font-semibold text-slate-500 hover:text-slate-700 dark:text-slate-400 dark:hover:text-slate-300 focus:outline-none"
      :aria-label="`Remove tag ${tag.name}`"
    >
      ✕
    </button>
  </div>
</template>
