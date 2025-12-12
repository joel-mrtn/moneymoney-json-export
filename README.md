# Structured JSON Export for MoneyMoney

A [MoneyMoney](https://moneymoney.app) extension that exports all accounts and transactions into a structured JSON format, preserving the full account hierarchy, transaction details, and metadata.

## Installation

Download the [`StructuredJSON.lua`](StructuredJSON.lua) extension file and move it into MoneyMoney's extensions folder. You can easily open MoneyMoney's database folder by selecting `Help → Show Database in Finder` from the menu bar and easily navigate back to the extensions folder.

## Usage

When selecting `Export Transactions…` from the menu, select the `Structured JSON (.json)` format. You can use AppleScript as well by specifying `json` as export format. Make sure this is the only JSON export extension installed to avoid conflicts with other JSON exporters.

## Example

> [!NOTE]
> For better readability, some fields are ommitted in the example below.

```json
{
  "exportDate": "2025-12-12",
  "exportTime": "12:00:00",
  "accounts": [
    {
      "name": "Checking Account",
      "owner": "John Doe",
      "accountNumber": "123456789",
      "bankCode": "10020030",
      "currency": "EUR",
      "balance": 1200.50,
      "transactions": [
        {
          "name": "ACME Corp",
          "amount": 250.0,
          "booked": true,
          "currency": "EUR",
          "bookingDate": 1765281600,
          "category": "Income\\Business"
        }
      ]
    }
  ]
}
```

## License

[MIT License](LICENSE) - free to use, modify, and distribute.
