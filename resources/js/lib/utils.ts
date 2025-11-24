/**
 * @meta-start
 * @session: 2025-11-24-001
 * @file: resources/js/lib/utils.ts
 * @refs: [DESIGN:COMPONENTS]
 * @changes: Created utility functions for shadcn-vue components
 * @doc-update: [DESIGN:COMPONENTS] ADD utils.ts for cn() class merging utility
 * @meta-end
 */

import { type ClassValue, clsx } from 'clsx'
import { twMerge } from 'tailwind-merge'

export function cn(...inputs: ClassValue[]) {
  return twMerge(clsx(inputs))
}
