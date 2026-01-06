import type { FC } from 'react'
import type { InputProps } from './Input.types'

export const Input: FC<InputProps> = ({
    label,
    variant = 'primary',
    ...props
}) => {
    return (
        <div style={{ display: 'flex', flexDirection: 'column', marginBottom: 12 }}>
            {label && <label style={{ marginBottom: 4 }}>{label}</label>}
            <input
                {...props}
                data-variant={variant}
                style={{
                    padding: 8,
                    borderRadius: 6,
                    border: '1px solid #ccc',
                    outline: 'none',
                    backgroundColor: variant === 'primary' ? '#fff' : '#f7f7f7',
                    borderColor: variant === 'primary' ? '#ccc' : '#999',
                }}
            />
        </div>
    )
}
