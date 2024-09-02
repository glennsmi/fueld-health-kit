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
* [`queryTotalCalories()`](#querytotalcalories)
* [`queryCaloriesTimeSeries(...)`](#querycaloriestimeseries)

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

</docgen-api>
# fueld-health-kit
