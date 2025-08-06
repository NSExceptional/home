/*
* command.ts
* ts
*
* Created by Tanner Bennett on 2025-02-02
* Copyright © 2025 Tanner Bennett. All rights reserved.
*/

// deno-lint-ignore-file no-explicit-any

export default class Command {
    constructor(
        readonly binary: string,
    ) {}

    quiet = false;

    private spawnRetryCount = 0;

    async spawn(args: string[]): Promise<string> {
        if (!this.quiet) console.log(`> ${this.binary} ${args.join(' ')}\n`);

        const process = await this._spawn(args);
        const result = await process.output();
        const output = new TextDecoder().decode(result.stdout);
        const errorOutput = new TextDecoder().decode(result.stderr);

        this.spawnRetryCount = 0;

        if (errorOutput && errorOutput.includes('error')) {
            throw new Error(errorOutput.trim());
        }

        return output.trim();
    }

    private async _spawn(args: string[]): Promise<Deno.ChildProcess> {
        try {
            return new Deno.Command(
                this.binary, { args, stdout: 'piped', stderr: 'piped' }
            ).spawn();
        }
        catch (error: any) {
            if (error.code === 'EAGAIN') {
                if (this.spawnRetryCount++ > 3) {
                    console.error('Process spawn failed due to EAGAIN 3 times. Giving up.');
                    Deno.exit(1);
                }

                console.warn('Process spawn failed due to EAGAIN. Retrying in 2s...');
                await new Promise(resolve => setTimeout(resolve, 2000));
                return this._spawn(args);
            }
            else {
                console.error('Error spawning process:', error);
                Deno.exit(1);
            }
        }
    }

    protected async mkdirp(path: string): Promise<void> {
        if (!await Deno.stat(path).catch(() => false)) {
            await Deno.mkdir(path, { recursive: true });
        }
    }
}
