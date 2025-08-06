/*
* ffprobe.ts
* media
*
* Created by Tanner Bennett on 2025-02-25
* Copyright © 2025 Tanner Bennett. All rights reserved.
*/

// deno-lint-ignore-file no-explicit-any

import Command from '../command.ts';

type probe = {
    format: Record<string, any>;
    streams: Record<string, any>[];
};

export class FFProbeInfo {
    get format() { return this.probe.format; }
    get streams() { return this.probe.streams; }

    constructor(private readonly probe: probe) { }

    get video() {
        return this.streams.find(s => s.codec_type === 'video');
    }

    get audio() {
        return this.streams.find(s => s.codec_type === 'audio');
    }

    get hasSubtitles(): boolean {
        return this.streams.some(s => s.codec_type === 'subtitle');
    }
}

class ffprobe extends Command {
    static shared = new ffprobe();
    constructor() {
        super('ffprobe');
    }

    /** Print or save the JSON probe info of a file */
    async jsonInfo(infile: string, extraArgs: string[] = [], writeToFile?: string): Promise<FFProbeInfo> {
        const output = await this.spawn([
            '-v', 'quiet', '-print_format', 'json',
            '-show_format', '-show_streams',
            ...extraArgs, infile
        ]);

        if (writeToFile) {
            await Deno.writeTextFile(writeToFile, output);
        }

        return new FFProbeInfo(JSON.parse(output) satisfies probe);
    }

    /** Get the duration of a video in seconds */
    async duration(infile: string): Promise<number> {
        const output = await this.spawn([
            '-v', 'error', '-show_entries', 'format=duration',
            '-of', 'default=noprint_wrappers=1:nokey=1',
            infile
        ]);

        return parseFloat(output);
    }

    /** Get the frame count (as described in the file header) */
    async totalFrames(infile: string): Promise<number | undefined>
    async totalFrames(infile: string, computeIfNeeded: true): Promise<number>;
    async totalFrames(infile: string, computeIfNeeded?: true): Promise<number | undefined> {
        const frameArgs = (field: string) => [
            '-v', 'error', '-select_streams', 'v:0',
            '-show_entries', `stream=${field}`,
            '-of', 'default=noprint_wrappers=1:nokey=1',
        ];

        const frames = await this.spawn([
            ...frameArgs('nb_frames'), infile
        ]);

        if (!frames) {
            if (computeIfNeeded) {
                const forcedFrames = await this.spawn([
                    ...frameArgs('nb_read_frames'), '-count_frames', infile
                ]);

                if (forcedFrames) {
                    return parseInt(forcedFrames);
                }

                throw new Error('Could not get frame count (nb_read_frames)');
            }

            return undefined;
        }

        return parseInt(frames);
    }

    async resolution(infile: string): Promise<{ width: number, height: number }> {
        const output = await this.spawn([
            '-v', 'error', '-select_streams', 'v:0',
            '-show_entries', 'stream=width,height',
            '-of', 'csv=p=0:s=x', infile
        ]);

        const [width, height] = output.split('x').map(Number);
        return { width, height };
    }
}

export default ffprobe.shared as ffprobe;
