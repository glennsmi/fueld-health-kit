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

  async getAllAuthorizationStatuses(): Promise<{ statuses: string }> {
    console.log('Get All Authorization Statuses');
    // Web implementation doesn't have access to HealthKit, so we'll return a default status for all types
    const defaultStatuses = {
      "HKQuantityTypeIdentifierActiveEnergyBurned": {
        "isAuthorized": false,
        "status": "Not Available"
      },
      "HKQuantityTypeIdentifierBasalEnergyBurned": {
        "isAuthorized": false,
        "status": "Not Available"
      },
      "HKQuantityTypeIdentifierStepCount": {
        "isAuthorized": false,
        "status": "Not Available"
      },
      "HKQuantityTypeIdentifierDistanceWalkingRunning": {
        "isAuthorized": false,
        "status": "Not Available"
      }
    };
    return { statuses: JSON.stringify(defaultStatuses) };
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

    return { timeSeriesData };
  }

  async queryAllTimeCaloriesTimeSeries(): Promise<{ timeSeriesData: { date: string, activeCalories: number, basalCalories: number, totalCalories: number }[] }> {
    console.log('Query All Time Calories Time Series');
    // Web implementation doesn't have access to HealthKit, so we'll return default values
    const timeSeriesData = [];
    const today = new Date();
    const thirtyDaysAgo = new Date(today.getTime() - 30 * 24 * 60 * 60 * 1000);

    for (let i = 0; i < 30; i++) {
      const currentDate = new Date(thirtyDaysAgo.getTime() + i * 24 * 60 * 60 * 1000);
      timeSeriesData.push({
        date: currentDate.toISOString(),
        activeCalories: Math.floor(Math.random() * (600 - 300 + 1)) + 300, // Random between 300-600
        basalCalories: Math.floor(Math.random() * (1800 - 1400 + 1)) + 1400, // Random between 1400-1800
        get totalCalories() { return this.activeCalories + this.basalCalories; }
      });
    }
    return { timeSeriesData: [] };
  }
}
