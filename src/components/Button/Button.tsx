import type { FC } from 'react'
import type { ButtonProps } from './Button.types'


export const Button: FC<ButtonProps> = ({
    variant = 'primary',
    children,
    ...props
}) => {
    return (
        <button
            {...props}
            data-variant={variant}
            style={{
                padding: '8px 12px',
                borderRadius: 6,
                border: '1px solid #ccc',
                cursor: 'pointer',
                backgroundColor: variant === 'primary' ? '#2aff11' : '#fff'
            }}
        >
            {children}
        </button>
    )
}