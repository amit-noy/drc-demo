import type { FC } from 'react'
import type { CardProps } from './Card.types'

export const Card: FC<CardProps> = ({
    variant = 'elevated',
    children,
    ...props
}) => {
    return (
        <div
            {...props}
            data-variant={variant}
            style={{
                padding: '16px',
                borderRadius: 8,
                border: '1px solid #ccc',
                backgroundColor: '#fff',
                boxShadow: variant === 'elevated' ? '0 2px 8px rgba(0,0,0,0.1)' : 'none',
            }}
        >
            {children}
        </div>
    )
}
