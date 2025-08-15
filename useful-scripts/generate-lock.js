/**
 * A Node.js script to reverse-engineer a `package-lock.json` from an existing `node_modules` directory.
 *
 * HOW IT WORKS:
 * This script recursively walks through the `node_modules` directory. For each package it finds,
 * it reads the `package.json` to determine its name and version.
 *
 * It then makes a network request to the official npm registry for that specific package version.
 * From the registry's response, it extracts the canonical "integrity" hash and "resolved" tarball URL.
 * This guarantees the generated lockfile is correct and avoids EINTEGRITY errors.
 *
 * USAGE:
 * 1. Place this script file (e.g., `generate-lock.js`) in the root of your project.
 * 2. Run the script from your terminal: `node generate-lock.js`
 * 3. A new `package-lock.json` file will be created.
 *
 * CAVEATS:
 * - This script requires an active internet connection to contact the npm registry.
 * - It will fail if your project uses private packages not available on the public registry.
 * - The process can be slow as it makes a separate network request for each dependency.
 */

const fs = require('fs');
const path = require('path');
const https = require('https');

const ROOT_DIR = process.cwd();
const NODE_MODULES_PATH = path.join(ROOT_DIR, 'node_modules');
const OUTPUT_LOCKFILE_PATH = path.join(ROOT_DIR, 'package-lock.json');
const NPM_REGISTRY_URL = 'https://registry.npmjs.org';

/**
 * Fetches package metadata from the npm registry.
 * @param {string} name - The name of the package.
 * @param {string} version - The version of the package.
 * @returns {Promise<{resolved: string, integrity: string}>}
 */
function fetchPackageMetadata(name, version) {
    return new Promise((resolve, reject) => {
        const url = `${NPM_REGISTRY_URL}/${name}/${version}`;
        const req = https.get(url, (res) => {
            if (res.statusCode < 200 || res.statusCode >= 300) {
                return reject(new Error(`Failed for ${name}@${version}. Status: ${res.statusCode}`));
            }
            let data = '';
            res.on('data', (chunk) => (data += chunk));
            res.on('end', () => {
                try {
                    const parsed = JSON.parse(data);
                    const { integrity, tarball } = parsed.dist;
                    if (!integrity || !tarball) {
                        reject(new Error(`Invalid metadata for ${name}@${version}`));
                    }
                    resolve({ resolved: tarball, integrity });
                } catch (e) {
                    reject(new Error(`Failed to parse JSON for ${name}@${version}`));
                }
            });
        });
        req.on('error', (e) => reject(e));
        req.end();
    });
}

/**
 * Main function to orchestrate the lockfile generation.
 */
async function generateLockfile() {
    console.log('Starting lockfile generation from existing node_modules...');

    if (!fs.existsSync(NODE_MODULES_PATH)) {
        console.error('Error: `node_modules` directory not found. Please run `npm install` first.');
        process.exit(1);
    }

    try {
        const rootPackageJsonPath = path.join(ROOT_DIR, 'package.json');
        const rootPackageJson = JSON.parse(fs.readFileSync(rootPackageJsonPath, 'utf8'));

        const packages = {};
        packages[''] = {
            name: rootPackageJson.name,
            version: rootPackageJson.version,
            dependencies: rootPackageJson.dependencies,
            devDependencies: rootPackageJson.devDependencies,
        };

        console.log('Scanning node_modules and fetching official metadata from npm registry...');
        await walkNodeModules(NODE_MODULES_PATH, '', packages);

        const lockfile = {
            name: rootPackageJson.name,
            version: rootPackageJson.version,
            lockfileVersion: 3,
            requires: true,
            packages: packages,
        };

        fs.writeFileSync(OUTPUT_LOCKFILE_PATH, JSON.stringify(lockfile, null, 2));
        console.log(`\nSuccess! ✅\nGenerated package-lock.json at: ${OUTPUT_LOCKFILE_PATH}`);

    } catch (error) {
        console.error('\nAn error occurred during lockfile generation:');
        console.error(error);
        process.exit(1);
    }
}

/**
 * Recursively walks the node_modules directories to build the package map.
 * @param {string} dirPath - The current directory to scan.
 * @param {string} parentPath - The relative path for the lockfile key.
 * @param {object} packages - The accumulating map of all packages.
 */
async function walkNodeModules(dirPath, parentPath, packages) {
    const entries = fs.readdirSync(dirPath, { withFileTypes: true });

    for (const entry of entries) {
        if (entry.name.startsWith('.')) continue;

        const fullPath = path.join(dirPath, entry.name);
        
        if (entry.name.startsWith('@') && entry.isDirectory()) {
            await walkNodeModules(fullPath, parentPath, packages);
            continue;
        }

        if (entry.isDirectory()) {
            const packageJsonPath = path.join(fullPath, 'package.json');

            if (fs.existsSync(packageJsonPath)) {
                const packageJson = JSON.parse(fs.readFileSync(packageJsonPath, 'utf8'));
                const lockfilePath = path.join(parentPath, 'node_modules', packageJson.name).replace(/\\/g, '/');

                // Avoid re-processing a package we've already handled.
                if (packages[lockfilePath]) continue;

                process.stdout.write(`  ... Fetching ${packageJson.name}@${packageJson.version}\r`);
                
                try {
                    const metadata = await fetchPackageMetadata(packageJson.name, packageJson.version);
                    
                    packages[lockfilePath] = {
                        version: packageJson.version,
                        resolved: metadata.resolved,
                        integrity: metadata.integrity,
                        ...(packageJson.dependencies && { dependencies: packageJson.dependencies }),
                        ...(packageJson.peerDependencies && { peerDependencies: packageJson.peerDependencies }),
                        ...(packageJson.optionalDependencies && { optionalDependencies: packageJson.optionalDependencies }),
                        ...(packageJson.bin && { bin: packageJson.bin }),
                        ...(packageJson.engines && { engines: packageJson.engines }),
                    };
                } catch (error) {
                    console.warn(`\n[!] Warning: Could not fetch metadata for ${packageJson.name}@${packageJson.version}. It may be a private package. Skipping. Error: ${error.message}`);
                }
                
                const nestedNodeModules = path.join(fullPath, 'node_modules');
                if (fs.existsSync(nestedNodeModules)) {
                    await walkNodeModules(nestedNodeModules, lockfilePath, packages);
                }
            }
        }
    }
}

// Run the script
generateLockfile();

