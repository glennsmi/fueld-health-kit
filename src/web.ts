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

  async queryTotalCalories(): Promise<{  totalCalories: number, activeCalories: number, basalCalories: number }> {
    console.log('Query Total Calories');
    // Web implementation doesn't have access to HealthKit, so we'll return default values
    return {totalCalories: -1, activeCalories: -1, basalCalories: -1 };
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
    console.log('In the web Query All Time Calories Time Series');
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
    console.log('timeSeriesData', timeSeriesData);
    return { timeSeriesData };
  }

  async queryHeartRateForLastSevenDays(): Promise<{ heartRateData: { date: string, heartRate: number }[] }> {
    console.log('In the web Query Heart Rate for Last Seven Days');
    // Web implementation doesn't have access to HealthKit, so we'll return synthetic data
    const heartRateData = [];
    const today = new Date();
    
    for (let i = 6; i >= 0; i--) {
      const currentDate = new Date(today.getTime() - i * 24 * 60 * 60 * 1000);
      heartRateData.push({
        date: currentDate.toISOString(),
        heartRate: Math.floor(Math.random() * (100 - 60 + 1)) + 60, // Random between 60-100 bpm
      });
    }
    
    console.log('From the web mock data heartRateData', heartRateData);
    return { heartRateData };
  }

  async queryHRVForLastWeek(): Promise<{ hrvData: { date: string, hrv: number }[] }> {
    console.log('In the web Query HRV for Last Week');
    // Web implementation doesn't have access to HealthKit, so we'll return synthetic data
    const hrvData = [];
    const today = new Date();
    
    for (let i = 6; i >= 0; i--) {
      const currentDate = new Date(today.getTime() - i * 24 * 60 * 60 * 1000);
      hrvData.push({
        date: currentDate.toISOString(),
        hrv: Math.floor(Math.random() * (70 - 30 + 1)) + 30, // Random HRV between 30-70 ms
      });
    }
    
    console.log('From the web mock data hrvData', hrvData);
    return { hrvData };
  }

  async queryHRVAndBeatToBeatForLastDay(): Promise<{ hrvData: { date: string, hrv: number }[], beatToBeatData: { date: string, beatToBeat: number }[] }> {
    console.log('In the web Query HRV and Beat-to-Beat for Last Day');
    // Web implementation doesn't have access to HealthKit, so we'll return synthetic data
    const hrvData = [];
    const beatToBeatData = [];
    const today = new Date();
    
    // Generate 24 data points for the last day (one per hour)
    for (let i = 23; i >= 0; i--) {
      const currentDate = new Date(today.getTime() - i * 60 * 60 * 1000);
      hrvData.push({
        date: currentDate.toISOString(),
        hrv: Math.floor(Math.random() * (70 - 30 + 1)) + 30, // Random HRV between 30-70 ms
      });
      beatToBeatData.push({
        date: currentDate.toISOString(),
        beatToBeat: Math.floor(Math.random() * (1000 - 700 + 1)) + 700, // Random Beat-to-Beat between 700-1000 ms
      });
    }
    
    console.log('From the web mock data hrvData', hrvData);
    console.log('From the web mock data beatToBeatData', beatToBeatData);
    return { hrvData, beatToBeatData };
  }

  async querySleepData(options: { startDate: string, endDate: string }): Promise<{ sleepData: { date: string, duration: number, sleepValue: number }[] }> {
    console.log('In the web Query Sleep Data');
    // Web implementation doesn't have access to HealthKit, so we'll return synthetic data
    const sleepData = [];
    const startDate = new Date(options.startDate);
    const endDate = new Date(options.endDate);
    
    for (let currentDate = new Date(startDate); currentDate <= endDate; currentDate.setDate(currentDate.getDate() + 1)) {
      // Generate a random sleep duration between 5 and 9 hours
      const duration = Math.floor(Math.random() * (9 * 60 * 60 - 5 * 60 * 60 + 1)) + 5 * 60 * 60;
      
      // Generate a random sleep value (0: InBed, 1: Asleep, 2: Awake)
      const sleepValue = Math.floor(Math.random() * 3);
      
      sleepData.push({
        date: currentDate.toISOString(),
        duration: duration,
        sleepValue: sleepValue
      });
    }
    
    console.log('From the web mock data sleepData', sleepData);
    return { sleepData };
  }
  
}
