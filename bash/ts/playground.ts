/*
 * playground.ts
 * ts
 *
 * Created by Tanner Bennett on 2025-05-16
 * Copyright © 2025 Tanner Bennett. All rights reserved.
 */

import { _ } from "https://dev.jspm.io/npm:debug@4.3.4/_/0ce6db63.js";

export function sliceup(s: string): [string, string][] {
    return Array.from({ length: s.length }).map((_, i) => {
        return [s.slice(0, i), s.slice(i, s.length)];
    });
}

export function commonPrefix(inputs: string[]): number[] {
    return inputs.map(s => {
        let sum = s.length;
        return Array.from({ length: s.length }).map((_, i) => {
            const suffix = s.slice(i, s.length);

            for (let j = 0; j < suffix.length && j < s.length; j++) {
                if (suffix[j] !== s[j]) {
                    sum += j;
                    return j;
                }
            }

            sum += Math.min(s.length, suffix.length);
            return Math.min(s.length, suffix.length);
        }).reduce((sum, value) => sum + value, 0);
    });
}

console.log(commonPrefix(['ababaa']));
