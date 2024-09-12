# fueld-hk

This plugin lets Ionic Capacitor App access iOS HealthKit data

## Install

```bash
npm install fueld-hk
npx cap sync
```

## API

<docgen-index>

* [`echo(...)`](#echo)
* [`requestAuthorization()`](#requestauthorization)
* [`getAuthorizationStatus(...)`](#getauthorizationstatus)
* [`getAllAuthorizationStatuses()`](#getallauthorizationstatuses)
* [`queryTotalCalories()`](#querytotalcalories)
* [`queryCaloriesTimeSeries(...)`](#querycaloriestimeseries)
* [`queryAllTimeCaloriesTimeSeries()`](#queryalltimecaloriestimeseries)
* [`queryHeartRateForLastSevenDays()`](#queryheartrateforlastsevendays)
* [`queryHRVForLastWeek()`](#queryhrvforlastweek)
* [`queryHRVAndBeatToBeatForLastDay()`](#queryhrvandbeattobeatforlastday)
* [`querySleepData(...)`](#querysleepdata)

</docgen-index>

<docgen-api>
<!--Update the source file JSDoc comments and rerun docgen to update the docs below-->

### echo(...)

```typescript
echo(options: { value: string; }) => Promise<{ value: string; }>
```

| Param         | Type                            |
| ------------- | ------------------------------- |
| **`options`** | <code>{ value: string; }</code> |

**Returns:** <code>Promise&lt;{ value: string; }&gt;</code>

--------------------


### requestAuthorization()

```typescript
requestAuthorization() => Promise<{ status: string; }>
```

**Returns:** <code>Promise&lt;{ status: string; }&gt;</code>

--------------------


### getAuthorizationStatus(...)

```typescript
getAuthorizationStatus(options: { quantityTypeIdentifier: string; }) => Promise<{ status: string; }>
```

| Param         | Type                                             |
| ------------- | ------------------------------------------------ |
| **`options`** | <code>{ quantityTypeIdentifier: string; }</code> |

**Returns:** <code>Promise&lt;{ status: string; }&gt;</code>

--------------------


### getAllAuthorizationStatuses()

```typescript
getAllAuthorizationStatuses() => Promise<{ statuses: string; }>
```

**Returns:** <code>Promise&lt;{ statuses: string; }&gt;</code>

--------------------


### queryTotalCalories()

```typescript
queryTotalCalories() => Promise<{ totalCalories: number; activeCalories: number; basalCalories: number; }>
```

**Returns:** <code>Promise&lt;{ totalCalories: number; activeCalories: number; basalCalories: number; }&gt;</code>

--------------------


### queryCaloriesTimeSeries(...)

```typescript
queryCaloriesTimeSeries(options: { startDate: string; endDate: string; }) => Promise<{ timeSeriesData: { date: string; activeCalories: number; basalCalories: number; totalCalories: number; }[]; }>
```

| Param         | Type                                                 |
| ------------- | ---------------------------------------------------- |
| **`options`** | <code>{ startDate: string; endDate: string; }</code> |

**Returns:** <code>Promise&lt;{ timeSeriesData: { date: string; activeCalories: number; basalCalories: number; totalCalories: number; }[]; }&gt;</code>

--------------------


### queryAllTimeCaloriesTimeSeries()

```typescript
queryAllTimeCaloriesTimeSeries() => Promise<{ timeSeriesData: { date: string; activeCalories: number; basalCalories: number; totalCalories: number; }[]; }>
```

**Returns:** <code>Promise&lt;{ timeSeriesData: { date: string; activeCalories: number; basalCalories: number; totalCalories: number; }[]; }&gt;</code>

--------------------


### queryHeartRateForLastSevenDays()

```typescript
queryHeartRateForLastSevenDays() => Promise<{ heartRateData: { date: string; heartRate: number; }[]; }>
```

**Returns:** <code>Promise&lt;{ heartRateData: { date: string; heartRate: number; }[]; }&gt;</code>

--------------------


### queryHRVForLastWeek()

```typescript
queryHRVForLastWeek() => Promise<{ hrvData: { date: string; hrv: number; }[]; }>
```

**Returns:** <code>Promise&lt;{ hrvData: { date: string; hrv: number; }[]; }&gt;</code>

--------------------


### queryHRVAndBeatToBeatForLastDay()

```typescript
queryHRVAndBeatToBeatForLastDay() => Promise<{ hrvData: { date: string; hrv: number; }[]; beatToBeatData: { date: string; beatToBeat: number; }[]; }>
```

**Returns:** <code>Promise&lt;{ hrvData: { date: string; hrv: number; }[]; beatToBeatData: { date: string; beatToBeat: number; }[]; }&gt;</code>

--------------------


### querySleepData(...)

```typescript
querySleepData(options: { startDate: string; endDate: string; }) => Promise<{ sleepData: { date: string; duration: number; sleepValue: number; }[]; }>
```

| Param         | Type                                                 |
| ------------- | ---------------------------------------------------- |
| **`options`** | <code>{ startDate: string; endDate: string; }</code> |

**Returns:** <code>Promise&lt;{ sleepData: { date: string; duration: number; sleepValue: number; }[]; }&gt;</code>

--------------------

</docgen-api>
# fueld-health-kit
