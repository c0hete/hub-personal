/**
 * @meta-start
 * @session: 2025-11-24-001
 * @file: resources/js/components/ui/Input.vue
 * @refs: [DESIGN:COMPONENTS]
 * @changes: Created Input component from shadcn-vue
 * @doc-update: [DESIGN:COMPONENTS] ADD Input.vue with full accessibility
 * @meta-end
 */

<script setup lang="ts">
import { cn } from '@/lib/utils'
import type { InputHTMLAttributes } from 'vue'

interface Props extends InputHTMLAttributes {
  modelValue?: string | number
}

withDefaults(defineProps<Props>(), {})

const emit = defineEmits<{
  (e: 'update:modelValue', value: string | number): void
}>()
</script>

<template>
  <input
    :value="modelValue"
    @input="emit('update:modelValue', ($event.target as HTMLInputElement).value)"
    :class="cn(
      'flex h-10 w-full rounded-md border border-slate-200 bg-white px-3 py-2 text-sm',
      'ring-offset-white placeholder:text-slate-500',
      'focus-visible:outline-none focus-visible:ring-2 focus-visible:ring-slate-950 focus-visible:ring-offset-2',
      'disabled:cursor-not-allowed disabled:opacity-50',
      'dark:border-slate-800 dark:bg-slate-950 dark:ring-offset-slate-950',
      'dark:placeholder:text-slate-400 dark:focus-visible:ring-slate-300',
      $attrs.class
    )"
    v-bind="$attrs"
  />
</template>
