import type { FC } from 'react'
import { users } from './Table.constant'

export const Table: FC = () => {
    return (
        <div className="overflow-x-auto">
            <table className="min-w-full border border-gray-300 divide-y divide-gray-200 rounded-lg shadow-sm">
                <thead className="bg-gray-100">
                <tr>
                    <th className="px-6 py-3 text-left text-sm font-semibold text-gray-700">ID</th>
                    <th className="px-6 py-3 text-left text-sm font-semibold text-gray-700">Name</th>
                    <th className="px-6 py-3 text-left text-sm font-semibold text-gray-700">Email</th>
                    <th className="px-6 py-3 text-left text-sm font-semibold text-gray-700">Role</th>
                </tr>
                </thead>
                <tbody className="bg-white divide-y divide-gray-200">
                {users.map((user, index) => (
                    <tr
                        key={user.id}
                        className={index % 2 === 0 ? 'bg-white' : 'bg-gray-50 hover:bg-gray-100'}
                    >
                        <td className="px-6 py-4 text-sm text-gray-800 font-medium">{user.id}</td>
                        <td className="px-6 py-4 text-sm text-gray-800">{user.name}</td>
                        <td className="px-6 py-4 text-sm text-gray-700">{user.email}</td>
                        <td className="px-6 py-4 text-sm text-gray-700">{user.role}</td>
                    </tr>
                ))}
                </tbody>
            </table>
        </div>
    )
}
