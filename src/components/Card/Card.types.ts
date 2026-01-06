import type { HTMLAttributes, ReactNode } from 'react'

export interface CardProps extends HTMLAttributes<HTMLDivElement> {
    variant?: 'elevated' | 'flat'
    children: ReactNode
}
