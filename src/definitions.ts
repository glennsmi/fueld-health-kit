export interface fueldHKPlugin {
  echo(options: { value: string }): Promise<{ value: string }>;
  requestAuthorization(): Promise<{ status: string }>;
  getAuthorizationStatus(options: { quantityTypeIdentifier: string }): Promise<{ status: string }>;
  getAllAuthorizationStatuses(): Promise<{ statuses: string }>;
  queryTotalCalories(): Promise<{ totalCalories: number, activeCalories: number, basalCalories: number }>;
  queryCaloriesTimeSeries(options: { startDate: string, endDate: string }): Promise<{ timeSeriesData: { date: string, activeCalories: number, basalCalories: number, totalCalories: number }[] }>;
}
