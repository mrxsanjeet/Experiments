# Sales Copilot Agent for Business Central

A comprehensive AI-powered Sales Copilot extension for Microsoft Dynamics 365 Business Central that provides intelligent assistance to sales users through discount recommendations and order anomaly detection.

## Features

### 1. Intelligent Discount Recommendation
- Analyzes customer tier based on purchase history
- Considers order volume and value
- Evaluates inventory aging for slow-moving items
- Maintains minimum margin targets
- Provides confidence levels based on data availability

### 2. Order Anomaly Detection
- **Quantity Spike Detection**: Flags orders where quantity exceeds customer's average by configurable multiplier
- **Price Deviation Detection**: Identifies unit prices significantly below standard pricing
- **New Ship-to Address Detection**: Alerts when established customers use new shipping addresses

### 3. Customer Insights
- Automatic customer tier classification (Standard, Bronze, Silver, Gold, Platinum)
- Churn risk prediction based on order frequency patterns
- Purchase behavior analytics

## Installation

### Prerequisites
- Business Central 24.0 or later
- AL Language extension for VS Code

### Steps

1. **Clone or download** this extension to your development environment

2. **Configure app.json**:
   - Update the `id` with a unique GUID for your organization
   - Update `publisher` with your company name
   - Adjust `idRanges` if needed to avoid conflicts

3. **Download symbols**:
   ```
   Ctrl+Shift+P → AL: Download Symbols
   ```

4. **Build and deploy**:
   ```
   Ctrl+Shift+P → AL: Publish
   ```

5. **Initial Setup**:
   - Search for "Sales Copilot Setup" in Business Central
   - Configure thresholds and parameters
   - Assign permission sets to users

## Configuration

### Sales Copilot Setup Page

Navigate to **Sales Copilot Setup** to configure:

#### Discount Recommendation Settings
| Field | Description | Default |
|-------|-------------|---------|
| Enable Discount Copilot | Toggle feature on/off | Yes |
| Minimum Margin % | Minimum margin to maintain | 20% |
| Maximum Discount % | Maximum allowed discount | 30% |
| Inventory Age Threshold | Days for slow-moving classification | 90 |
| Slow Moving Discount Bonus | Extra discount for aged inventory | 5% |

#### Anomaly Detection Settings
| Field | Description | Default |
|-------|-------------|---------|
| Enable Anomaly Detection | Toggle feature on/off | Yes |
| Quantity Spike Multiplier | Multiplier of average to trigger alert | 3x |
| Price Deviation Threshold | % below standard to trigger alert | 20% |
| Check New Ship-to Address | Enable address verification | Yes |
| Order History Months | Months of history to analyze | 12 |

#### Customer Tier Thresholds
| Tier | Default Minimum Sales | Discount Bonus |
|------|----------------------|----------------|
| Bronze | $10,000 | 2% |
| Silver | $50,000 | 5% |
| Gold | $100,000 | 8% |
| Platinum | $250,000 | 12% |

## Usage

### Discount Recommendation

1. Open a **Sales Order**
2. Click **Sales Copilot** → **Suggest Discount**
3. Review the Copilot analysis:
   - Customer tier and history
   - Margin impact
   - Inventory status
4. Click **Apply** to accept or **Discard** to cancel

### Anomaly Detection

1. Open a **Sales Order**
2. Click **Sales Copilot** → **Check Anomalies**
3. Review any detected anomalies
4. Take appropriate action based on recommendations

### Customer Analysis

1. Open a **Customer Card**
2. View the **Copilot Insights** section for:
   - Customer tier
   - Churn risk level
   - Order statistics
3. Click **Analyze Customer** for detailed insights

## Architecture

```
┌─────────────────────────────────────────────────────────────┐
│                    Sales Copilot Agent                       │
├─────────────────────────────────────────────────────────────┤
│  ┌─────────────────┐  ┌─────────────────┐                   │
│  │ PromptDialog    │  │ Page Extensions │                   │
│  │ (Copilot UI)    │  │ (Sales Order,   │                   │
│  │                 │  │  Customer Card) │                   │
│  └────────┬────────┘  └────────┬────────┘                   │
│           │                    │                             │
│           ▼                    ▼                             │
│  ┌─────────────────────────────────────────┐                │
│  │         Sales Copilot Impl              │                │
│  │    (Main Business Logic Codeunit)       │                │
│  └────────┬────────────────────┬───────────┘                │
│           │                    │                             │
│     ┌─────▼─────┐        ┌─────▼─────┐                      │
│     │ Discount  │        │ Anomaly   │                      │
│     │Calculator │        │ Detector  │                      │
│     └─────┬─────┘        └─────┬─────┘                      │
│           │                    │                             │
│           ▼                    ▼                             │
│  ┌─────────────────────────────────────────┐                │
│  │         Customer Insight Calc           │                │
│  │    (Customer Analytics Engine)          │                │
│  └─────────────────────────────────────────┘                │
│                        │                                     │
│                        ▼                                     │
│  ┌─────────────────────────────────────────┐                │
│  │              Data Layer                  │                │
│  │  - Sales Copilot Setup                  │                │
│  │  - Copilot Suggestion Log               │                │
│  │  - Order Anomaly Entry                  │                │
│  │  - Customer Insight                     │                │
│  └─────────────────────────────────────────┘                │
└─────────────────────────────────────────────────────────────┘
```

## Permission Sets

| Permission Set | Description | Assignable |
|---------------|-------------|------------|
| SJT Sales Copilot Admin | Full access including setup | Yes |
| SJT Sales Copilot User | Use features, no setup access | Yes |
| SJT Sales Copilot Objects | All objects (internal use) | No |

## Example Scenarios

### Scenario 1: Discount Recommendation for Gold Customer

**Situation**: Sales rep creates order for Contoso Ltd (Gold tier customer) with $45,000 order value.

**Copilot Analysis**:
```
Customer Tier: Gold
Order Value: $45,000.00
Current Margin: 42%
Contains slow-moving inventory items - additional discount applied.
Recommended Discount: 15%

Confidence: High (based on 20+ historical orders)
Margin Impact: Maintains 27% margin after discount
Inventory Status: Slow-moving items detected: ITEM-1001, ITEM-1005
```

**Recommendation**: "Recommended discount: 15% (maintains 27% margin, clears slow-moving inventory)"

### Scenario 2: Quantity Spike Anomaly

**Situation**: Customer typically orders 50 units of ITEM-2000, but current order has 200 units.

**Copilot Detection**:
```
⚠️ 1 anomaly detected

• Quantity Spike: Item ITEM-2000: Quantity 200 is 4x the customer average of 50

Recommendation: Verify the quantity with the customer. Check if this is a
special order or bulk purchase.
```

### Scenario 3: Price Deviation Alert

**Situation**: Sales rep enters unit price of $80 for item with standard price of $120.

**Copilot Detection**:
```
⚠️ 1 anomaly detected

• Price Deviation: Item ITEM-3000: Unit price $80.00 is 33% below standard
  price $120.00

Recommendation: Review the pricing. Ensure proper authorization for discounts
below standard price.
```

### Scenario 4: New Shipping Address Warning

**Situation**: Established customer (50+ orders) uses a new shipping address.

**Copilot Detection**:
```
⚠️ 1 anomaly detected

• New Ship-to Address: Order uses a new shipping address: 123 New Street,
  New City. Customer has 52 previous orders.

Recommendation: Confirm the new shipping address with the customer before
processing.
```

### Scenario 5: Customer Churn Risk

**Situation**: Customer who typically orders monthly hasn't ordered in 90 days.

**Copilot Insights**:
```
Customer: CUST-001 - Fabrikam Inc
Tier: Silver
Total Sales: $75,000.00
Total Orders: 24
Average Order Value: $3,125.00
Days Since Last Order: 92
Churn Risk: High

Recommendation: Customer showing signs of reduced engagement. Recommend
follow-up call.
```

## Telemetry and Logging

When enabled, the extension logs:
- All Copilot suggestions with full analysis details
- User acceptance/rejection of suggestions
- Applied values vs suggested values
- Anomaly detection results

This data can be used for:
- Analyzing Copilot effectiveness
- Training and improving recommendations
- Audit trails for discount approvals

## Extending the Solution

### Adding New Anomaly Types

1. Add new value to `SJT Anomaly Type` enum
2. Implement detection logic in `SJT Anomaly Detector` codeunit
3. Add recommendation text in `GetRecommendation` procedure

### Adding New Customer Tiers

1. Add new value to `SJT Customer Tier` enum
2. Add threshold field to `SJT Sales Copilot Setup` table
3. Update `CalculateCustomerTier` in `SJT Discount Calculator`
4. Add discount bonus field and logic

## Troubleshooting

### Copilot Not Showing Suggestions
- Verify "Enable Discount Copilot" is enabled in setup
- Check user has appropriate permission set assigned
- Ensure sales order has lines with items

### Anomalies Not Being Detected
- Verify "Enable Anomaly Detection" is enabled
- Check customer has sufficient order history
- Review threshold settings (may be too high)

### Customer Insights Not Calculating
- Run "Refresh Insights" action on Customer Card
- Check for posted invoices for the customer
- Verify customer ledger entries exist

## Support

For issues or feature requests, please contact your system administrator or the extension publisher.

## License

This extension is provided under the terms specified in the EULA. See app.json for details.

---

**Version**: 1.0.0.0
**Platform**: Business Central 24.0+
**Publisher**: Sanjeet Solutions

