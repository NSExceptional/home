/*
 * ffmpeg.ts
 * media
 *
 * Created by Tanner Bennett on 2025-02-02
 * Copyright © 2025 Tanner Bennett. All rights reserved.
 */

import Command from '../command.ts';
import * as path from 'jsr:@std/path';
import ffprobe from './ffprobe.ts';

type FFmpegArgs = {
    /** The input file */
    input: string;
    /**
     * The output file for operations that output video,
     * or an output folder for operations that output multiple files.
     */
    output?: string;
};

type FFmpegExtractFramesArgs = FFmpegArgs & {
    frames: number;
    totalFrames?: number;
    /** Put each extracted frame in numbered folders in the output folder */
    inFolders?: boolean;
};

class ffmpeg extends Command {
    static shared = new ffmpeg();
    constructor() {
        super('ffmpeg');
    }

    private hevcSupportedContainers = [
        'mov', 'mp4', 'matroska', 'webm', 'mpegts', 'flv'
    ];

    private quicktimeFlags = [
        '-tag:v', 'hvc1', '-movflags', 'use_metadata_tags', '-copyts',
    ];

    private outfile(options: FFmpegArgs, suffix: string, ext: string = 'mp4'): string {
        return options.output || options.input.replace(path.extname(options.input), `.${suffix}.${ext}`);
    }

    /** Tag a video with hvc1 */
    async tag(options: FFmpegArgs): Promise<string> {
        const infile = options.input;
        const outfile = this.outfile(options, 'hvc1');

        await this.spawn([
            '-i', infile, '-c', 'copy',
            ...this.quicktimeFlags,
            outfile
        ]);

        return outfile;
    }

    /** Transcode any video to h.265 */
    async transcode(options: FFmpegArgs & { crf?: number }): Promise<string> {
        const crf = options.crf;
        const outfile = this.outfile(options, crf ? `${crf}.h265` : 'h265');

        await this.spawn([
            '-i', options.input,
            '-c:v', 'libx265', '-c:a', 'copy',
            ...this.quicktimeFlags,
            ...(options.crf ? ['-crf', options.crf.toString()] : []),
            outfile,
        ]);

        return outfile;
    }

    /** Extract specified number of frames from a video */
    async extractNFrames(options: FFmpegExtractFramesArgs): Promise<void> {
        const framesToSave = options.frames;
        const infile = options.input;
        const outDir = options.output || './frames'

        if (framesToSave < 1) {
            throw new Error('Cannot save 0 frames');
        }

        // Create the output directory if needed
        this.mkdirp(outDir);

        // Compute resolution, total number of frames in the video,
        // and the interval by which to extract frames (i.e. every 250th frame)
        const res = await ffprobe.resolution(infile);
        const frameCount = options.totalFrames || await ffprobe.totalFrames(infile, true);
        const frameInterval = Math.floor(frameCount / (framesToSave + 1));

        if (frameInterval < framesToSave) {
            throw new Error('Not enough frames to extract.');
        }

        // Log some info about the extraction
        const suffix = ['th', 'st', 'nd', 'rd'][(frameInterval % 10) > 3 ? 0 : (frameInterval % 10)];
        console.log(`${frameCount} total frames in ${infile}`);
        console.log(`Extracting every ${frameInterval}${suffix} frame (total: ${framesToSave})`);

        // Compute frame filenames and frame indexes
        const fileBasename = path.basename(infile, path.extname(infile));
        const outputFormatString = path.join(outDir, `${fileBasename}_frame_%04d.png`);
        const frames = Array.from(
            { length: framesToSave },
            (_, i) => (i + 1) * frameInterval
        );

        const selectFilter = frames
            .map(f => `eq(n,${f})`)
            .join('+');

        await this.spawn([
            '-i', infile,
            '-vf', `select='${selectFilter}',scale=${res.width}:${res.height}`,
            '-fps_mode', 'passthrough',
            outputFormatString
        ]);

        // Move the frames to their respective folders if needed
        if (options.inFolders) {
            await this.moveFramesToFolders(options);
        }
    }

    /** Move extracted frames to their individual numbered folders */
    private async moveFramesToFolders(options: FFmpegExtractFramesArgs): Promise<void> {
        const fileBasename = path.basename(options.input, path.extname(options.input));
        const outputFormatString = path.join(options.output || './frames', `${fileBasename}_frame_%04d.png`);

        for (let i = 0; i < options.frames; i++) {
            const folder = path.join(options.output || './frames', `${i + 1}`);
            await this.mkdirp(folder);

            const existing = outputFormatString.replace('%04d', `${(i + 1).toString().padStart(4, '0')}`);
            const filename = path.basename(existing);
            const renamed = path.join(folder, filename);
            await Deno.rename(existing, renamed);
        }
    }

    async h26ify(options: FFmpegArgs & { crf?: number }): Promise<string> {
        const info = await ffprobe.jsonInfo(options.input);

        const checkCompatability = () => {
            // Check the audio codec
            const audioCodec = info.audio?.codec_name;
            if (audioCodec && !['aac', 'mp3', 'opus'].includes(audioCodec)) {
                throw new Error(`Error: The audio codec '${audioCodec}' may not be compatible with the target container.`);
            }

            // Check for subtitles
            if (info.hasSubtitles) {
                console.warn('Warning: The file contains subtitles which may not be compatible with the target container');
            }

            // Check the container format
            const containers: string[] | undefined = info.format?.format_name.split(',');
            if (!containers) {
                console.warn('Warning: No container format detected.');
            }
            else if (!containers.some(c => this.hevcSupportedContainers.includes(c))) {
                throw new Error(`Error: The container format '${containers.join(',')}' is not compatible with HEVC.`);
            }
        }

        const changeContainer = async (): Promise<string> => {
            // Change the container format
            return await this.tag(options);
        };

        const transcode = async (): Promise<string> => {
            checkCompatability();

            return await this.transcode({
                input: options.input,
                crf: options.crf
            });
        };

        // Check the video codec
        const codec = info.video?.codec_name;
        switch (codec) {
            case 'hevc':
                console.info('video is already encoded in h.265/HEVC');
                return await changeContainer();
            case 'h264':
            case 'av1':
                checkCompatability();
                return await transcode();
            default:
                throw new Error(`Unsupported video codec '${codec}'`);
        }
    }
}

export default ffmpeg.shared as ffmpeg;
