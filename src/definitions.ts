export interface fueldHKPlugin {
  echo(options: { value: string }): Promise<{ value: string }>;
  requestAuthorization(): Promise<{ status: string }>;
  getAuthorizationStatus(options: { quantityTypeIdentifier: string }): Promise<{ status: string }>;
  getAllAuthorizationStatuses(): Promise<{ statuses: string }>;
  queryTotalCalories(): Promise<{ totalCalories: number, activeCalories: number, basalCalories: number }>;
  queryCaloriesTimeSeries(options: { startDate: string, endDate: string }): Promise<{ timeSeriesData: { date: string, activeCalories: number, basalCalories: number, totalCalories: number }[] }>;
  queryAllTimeCaloriesTimeSeries(): Promise<{ timeSeriesData: { date: string, activeCalories: number, basalCalories: number, totalCalories: number }[] }>;
  queryHeartRateForLastSevenDays(): Promise<{ heartRateData: { date: string, heartRate: number }[] }>;
  queryHRVForLastWeek(): Promise<{ hrvData: { date: string, hrv: number }[] }>;
  queryHRVAndBeatToBeatForLastDay(): Promise<{ hrvData: { date: string, hrv: number }[], beatToBeatData: { date: string, beatToBeat: number }[] }>;
  querySleepData(options: { startDate: string, endDate: string }): Promise<{ sleepData: { date: string, duration: number, sleepValue: number }[] }>;
}
