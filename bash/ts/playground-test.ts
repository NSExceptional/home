/*
 * playground-test.ts
 * ts
 *
 * Created by Tanner Bennett on 2025-05-16
 * Copyright © 2025 Tanner Bennett. All rights reserved.
 */

import { assert, assertEquals } from "jsr:@std/assert";
import { commonPrefix, sliceup } from "./playground.ts";

Deno.test("values", () => {
    assertEquals(commonPrefix(['ababaa']), [11]);
    assertEquals(commonPrefix(['abcabcd']), [10]);
});

Deno.test("tables", () => {
    const tables = {
        ababaa: [
            ['', 'ababaa'], // 6
            ['a', 'babaa'], // 0
            ['ab', 'abaa'], // 2
            ['aba', 'baa'], // 0
            ['abab', 'aa'], // 1
            ['ababa', 'a'], // 1
        ],
        abcabcd: [
            ['', 'abcabcd'],
            ['a', 'bcabcd'],
            ['ab', 'cabcd'],
            ['abc', 'abcd'],
            ['abca', 'bcd'],
            ['abcab', 'cd'],
            ['abcabc', 'd'],
        ],
    }

    for (const [input, expected] of Object.entries(tables)) {
        const slices = sliceup(input);
        assertEquals(slices, expected, `Sliceup for ${input} failed`);
    }
});
