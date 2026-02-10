import { readFile, writeFile } from 'node:fs/promises';
import { join, dirname } from 'node:path';
import { fileURLToPath } from 'node:url';

const __dirname = dirname(fileURLToPath(import.meta.url));

export class ConfigLoader {
    #defaults;
    #overrides;

    constructor(defaults = {}) {
        this.#defaults = defaults;
        this.#overrides = {};
    }

    async loadFromFile(filename) {
        const filePath = join(__dirname, filename);
        const raw = await readFile(filePath, 'utf-8');
        this.#overrides = JSON.parse(raw);
        return this;
    }

    get(key) {
        return this.#overrides[key] ?? this.#defaults[key];
    }

    async save(filename) {
        const merged = { ...this.#defaults, ...this.#overrides };
        const filePath = join(__dirname, filename);
        await writeFile(filePath, JSON.stringify(merged, null, 2));
    }
}

const loader = new ConfigLoader({ port: 3000, debug: false });
await loader.loadFromFile('config.json');
console.log(`Server port: ${loader.get('port')}`);
