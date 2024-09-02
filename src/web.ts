import { WebPlugin } from '@capacitor/core';

import type { fueldHKPlugin } from './definitions';

export class fueldHKWeb extends WebPlugin implements fueldHKPlugin {
  async echo(options: { value: string }): Promise<{ value: string }> {
    console.log('ECHO', options.value);
    const enhancedValue = options.value + " tweak web";
    console.log('ECHO', enhancedValue);
    return { value: enhancedValue };
  }

  async requestAuthorization(): Promise<{ status: string }> {
    console.log('Request Authorization');
    return { status: 'Authorization request sent' };
  }

  async getAuthorizationStatus(options: { quantityTypeIdentifier: string }): Promise<{ status: string }> {
    console.log('Get Authorization Status', options.quantityTypeIdentifier);
    // Web implementation doesn't have access to HealthKit, so we'll return a default status
    return { status: 'Not Available' };
  }

  async queryTotalCalories(): Promise<{ totalCalories: number, activeCalories: number, basalCalories: number }> {
    console.log('Query Total Calories');
    // Web implementation doesn't have access to HealthKit, so we'll return default values
    return { totalCalories: -1, activeCalories: -1, basalCalories: -1 };
  }

  private addDays(date: Date, days: number): Date {
    const result = new Date(date);
    result.setDate(result.getDate() + days);
    return result;
  }

  async queryCaloriesTimeSeries(options: { startDate: string, endDate: string }): Promise<{ timeSeriesData: { date: string, activeCalories: number, basalCalories: number, totalCalories: number }[] }> {
    console.log('Query Calories Time Series', options.startDate, options.endDate);
    // Web implementation doesn't have access to HealthKit, so we'll return default values for 8 days
    const startDate = new Date(options.startDate);
    const endDate = new Date(options.endDate);
    const daysDiff = Math.ceil((endDate.getTime() - startDate.getTime()) / (1000 * 3600 * 24));
    
    const timeSeriesData = [];
    for (let i = 0; i <= (daysDiff -1); i++) {
      const currentDate = this.addDays(startDate, i);
      timeSeriesData.push({
        date: currentDate.toISOString(),
        activeCalories: Math.floor(Math.random() * (500 - 400 + 1)) + 400, // Random between 400-500
        basalCalories: Math.floor(Math.random() * (1560 - 1525 + 1)) + 1525, // Random between 1525-1560
        get totalCalories() { return this.activeCalories + this.basalCalories; }
      });
    }
    // const timeSeriesData = [
    //   {
    //     date: options.startDate,
    //     activeCalories: 400,
    //     basalCalories: 1550,
    //     totalCalories: 1950
    //   },
    //   {
    //     date: this.addDays(new Date(options.startDate), 1).toISOString(),
    //     activeCalories: 450,
    //     basalCalories: 1540,
    //     totalCalories: 1990
    //   },
    //   {
    //     date: this.addDays(new Date(options.startDate), 2).toISOString(),
    //     activeCalories: 420,
    //     basalCalories: 1560,
    //     totalCalories: 1980
    //   },
    //   {
    //     date: this.addDays(new Date(options.startDate), 3).toISOString(),
    //     activeCalories: 480,
    //     basalCalories: 1530,
    //     totalCalories: 2010
    //   },
    //   {
    //     date: this.addDays(new Date(options.startDate), 4).toISOString(),
    //     activeCalories: 430,
    //     basalCalories: 1545,
    //     totalCalories: 1975
    //   },
    //   {
    //     date: this.addDays(new Date(options.startDate), 5).toISOString(),
    //     activeCalories: 460,
    //     basalCalories: 1535,
    //     totalCalories: 1995
    //   },
    //   {
    //     date: this.addDays(new Date(options.startDate), 6).toISOString(),
    //     activeCalories: 470,
    //     basalCalories: 1540,
    //     totalCalories: 2010
    //   },
    //   {
    //     date: options.endDate,
    //     activeCalories: 500,
    //     basalCalories: 1525,
    //     totalCalories: 2025
    //   }
    // ];
    return { timeSeriesData };
  }
}
