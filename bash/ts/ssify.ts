#!/usr/bin/env -S deno run -A --ext=ts
/*
 * inuse
 * ts
 *
 * Created by Tanner Bennett on 2025-05-12
 * Copyright © 2025 Tanner Bennett. All rights reserved.
 */

import * as path from "jsr:@std/path";
import parseArgs, { abort } from './args-usage.ts';
import sharp from 'npm:sharp';

const args: {
    _: [string]
} = parseArgs(
    `usage: ssify <screenshot-or-recording>`,
    'Minify the input screenshot / screen recording.',
);

const file = args._[0];
if (!file) {
    abort('No file specified.');
}

const ext = path.extname(file).toLowerCase();

// Use sharp to check if the file is already HEIC
let isHeic = false;
try {
    const image = sharp(file);
    const meta = await image.metadata();
    isHeic = meta.format === 'heif';
} catch (_e) {
    // If sharp fails, fallback to extension check
    isHeic = ext === '.heic';
}

if (isHeic) {
    console.log('Input is already a HEIC image.');
    Deno.exit(0);
}

const outFile = path.join(path.dirname(file), path.basename(file, ext) + '.heic');

try {
    await sharp(file).toFile(outFile);
    console.log(`Converted to HEIC: ${outFile}`);
} catch (_e) {
    abort('Failed to convert image to HEIC. Ensure sharp is installed and supports HEIC.');
}

