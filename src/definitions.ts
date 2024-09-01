export interface fueldHKPlugin {
  echo(options: { value: string }): Promise<{ value: string }>;
  requestAuthorization(): Promise<{ status: string }>;
}
