/*
 * messages.ts
 * ts
 *
 * Created by Tanner Bennett on 2025-05-06
 * Copyright © 2025 Tanner Bennett. All rights reserved.
 */

import { Database, SQLite3Connector, Model, DataTypes } from 'https://deno.land/x/denodb/mod.ts';

class ChatDB {
    static shared = new ChatDB();
    private db: Database;

    private constructor() {
        this.db = new Database(new SQLite3Connector({
            filepath: 'chat.db',
        }));
    }

    async getMessages(): Promise<any[]> {
        const messages = await this.db.query('SELECT * FROM message');
        return messages;
    }

    async getAttachments(): Promise<any[]> {
        const attachments = await this.db.query('SELECT * FROM attachment');
        return attachments;
    }

    async close() {
        await this.db.close();
    }
}
