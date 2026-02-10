interface User {
	id: number;
	name: string;
	email: string;
	role: 'admin' | 'user' | 'guest';
}

class UserService {
	private users: Map<number, User> = new Map();

	addUser(user: User): void {
		this.users.set(user.id, user);
	}

	findById(id: number): User | undefined {
		return this.users.get(id);
	}

	findByRole(role: User['role']): User[] {
		return Array.from(this.users.values()).filter(u => u.role === role);
	}

	async fetchRemoteUser(id: number): Promise<User> {
		const response = await fetch(`/api/users/${id}`);
		if (!response.ok) {
			throw new Error(`Failed to fetch user ${id}: ${response.statusText}`);
		}
		return response.json() as Promise<User>;
	}
}

export { User, UserService };
