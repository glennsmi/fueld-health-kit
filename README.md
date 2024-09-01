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

</docgen-api>
# fueld-health-kit
