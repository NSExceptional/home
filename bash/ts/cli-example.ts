/**
 * @title Command line arguments
 * @difficulty beginner
 * @tags cli
 * @run <url> Deno Sushi --help --version=1.0.0 --no-color
 * @resource {https://docs.deno.com/api/deno/~/Deno.args} Doc: Deno.args
 * @resource {https://jsr.io/@std/cli/doc/parse-args/~} Doc: @std/cli
 * @group CLI
 *
 * Command line arguments are often used to pass configuration options to a
 * program.
 */

// import { parseArgs as denoParseArgs } from "jsr:@std/cli/parse-args";
import parseArgs from "./args-usage.ts";

const args: {
    _: [string, string]
// } = parseArgs(`usage: cmd -f foo bar`);
} = parseArgs(`usage: ffcompare <file1> <file2> <frame-count>`);

console.log(args);
