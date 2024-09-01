import { WebPlugin } from '@capacitor/core';

import type { fueldHKPlugin } from './definitions';

export class fueldHKWeb extends WebPlugin implements fueldHKPlugin {
  async echo(options: { value: string }): Promise<{ value: string }> {
    console.log('ECHO', options);
    return options;
  }

  async requestAuthorization(): Promise<{ status: string }> {
    console.log('Request Authorization');
    return { status: 'Authorization request sent' };
  }
}
