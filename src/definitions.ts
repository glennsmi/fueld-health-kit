export interface fueldHKPlugin {
  echo(options: { value: string }): Promise<{ value: string }>;
}
