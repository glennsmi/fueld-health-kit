import { registerPlugin } from '@capacitor/core';

import type { fueldHKPlugin } from './definitions';

const fueldHK = registerPlugin<fueldHKPlugin>('fueldHK', {
  web: () => import('./web').then(m => new m.fueldHKWeb()),
});

export * from './definitions';
export { fueldHK };
