'use strict';

const path = require('path');
const fs = require('fs');

const DEFAULT_CONFIG = {
    outputDir: 'dist',
    minify: true,
    sourceMaps: false,
    target: 'es2020',
};

function loadConfig(configPath) {
    const fullPath = path.resolve(process.cwd(), configPath);
    if (!fs.existsSync(fullPath)) {
        console.warn(`Config not found at ${fullPath}, using defaults.`);
        return { ...DEFAULT_CONFIG };
    }
    const raw = fs.readFileSync(fullPath, 'utf-8');
    const userConfig = JSON.parse(raw);
    return { ...DEFAULT_CONFIG, ...userConfig };
}

function ensureOutputDir(config) {
    const dir = path.resolve(process.cwd(), config.outputDir);
    fs.mkdirSync(dir, { recursive: true });
    return dir;
}

module.exports = { loadConfig, ensureOutputDir, DEFAULT_CONFIG };
