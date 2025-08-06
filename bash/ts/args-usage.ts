/*
 * args-usage.ts
 * ts
 *
 * Created by Tanner Bennett on 2025-02-25
 * Copyright © 2025 Tanner Bennett. All rights reserved.
 */

// import { parseFlags, ValidationError } from "jsr:@cliffy/flags@1.0.0-rc.7";
import { parseArgs as denoParseArgs } from "jsr:@std/cli/parse-args";
import nearley from "npm:nearley";
import grammar from "./usage.cjs";

type UsageString = `usage: ${string} ${string}`;

function formattedUsage(usage: string, body?: string): string {
    usage = usage.trim();
    body = body?.trim();
    const indent = '    ';

    if (!body) {
        return `${indent}${usage}`;
    }

    return `\n${usage}\n\n${indent}${body.replaceAll('\n', `\n${indent}`)}\n`
        .replaceAll('\n', `\n${indent}`)
}

/// In cases where the usage could be ambiguous, like in this command:
/// ```
/// usage: cmd -f foo bar
/// ```
/// where `foo` could be the flag's value or a required argument,
/// we will assume it is a required argument. In the future, if the
/// optionality of arguments is not specified with `[]` or `<>`, you should
/// use the `=` operator to specify the value of a flag, like `-f=foo`
export default function parseArgs<T extends Record<string, unknown>>(usage: UsageString, ...body: string[]): T {
    if (!usage.trim()) {
        console.error('Error: usage string is empty.');
        Deno.exit(1);
    }

    const abort = (msg: string) => {
        console.error(msg);
        console.log(usageMsg);
        Deno.exit(1);
    }

    const usageMsg = formattedUsage(usage, body.join('\n'));

    // Parse usage with nearley
    // Output will resemble this example structure
    // [
    //     [
    //         'usage:',
    //         'open',
    //         [
    //             { flag: true, name: 'a', value: 'app', required: false },
    //             { flag: false, name: 'infile', required: true },
    //             { flag: false, name: 'outfile', required: false }
    //         ]
    //     ]
    // ]
    const parser = new nearley.Parser(nearley.Grammar.fromCompiled(grammar));
    parser.feed(usage.split('\n')[0]);
    const parsedUsage = parser.results.pop(); // Pull out the first parse result
    const usageArgs = parsedUsage?.pop() as { // Skip to the args
        name: string;
        flag?: boolean;
        value?: string;
        optional?: boolean;
        rest?: boolean;
    }[];

    // Count required and optional non-flag args; optional args only follow required args
    let requiredCount = 0;
    let optionalCount = 0;
    let requiredHasRest = false;
    for (const arg of usageArgs) {
        if (arg.flag) continue;

        if (!arg.optional) {
            requiredCount++;
            if (arg.rest) {
                requiredHasRest = true;
            }
        } else {
            optionalCount++;
            if (arg.flag && requiredCount > 0) {
                console.error('Error: optional flags must precede all required arguments.');
                Deno.exit(1);
            }
        }
    }

    // Actually parse the args with Deno
    const parsed: Record<string, unknown> = denoParseArgs(Deno.args);

    // Check for `help` or `-h` or `--help`
    if (parsed.help || parsed.h) {
        console.log(usageMsg);
        Deno.exit(0);
    }

    // Check if we have all required unnamed args
    const parsedNonFlagArgs = parsed._ as string[];
    if (parsedNonFlagArgs.length > requiredCount + optionalCount) {
        if (!requiredHasRest) {
            abort('Error: too many arguments.');
        }
    }
    if (parsedNonFlagArgs.length < requiredCount) {
        abort('Error: missing required arguments.');
    }

    // Check if user supplied any unknown flags
    for (const key of Object.keys(parsed)) {
        if (key === "_") continue; // Skip non-flag args

        const flag = usageArgs.find(arg => arg.name === key && arg.flag);
        if (!flag) {
            abort(`Error: unknown flag: ${key}`);
        }
    }

    // Ensure all required flags were supplied
    const requiredFlags = usageArgs.filter(arg => arg.flag && !arg.optional);
    for (const flag of requiredFlags) {
        if (!parsed[flag.name]) {
            abort(`Error: missing required flag: ${flag.name}`);
        }
    }

    return parsed as T;
}

export function abort(msg: string): never {
    console.error(msg);
    Deno.exit(1);
}
