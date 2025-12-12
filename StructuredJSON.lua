---@diagnostic disable-next-line: undefined-global
Exporter {
    version       = 1.00,
    format        = MM.language == "de" and "Strukturierte JSON" or "Structured JSON",
    fileExtension = "json",
    description   = MM.language == "de"
        and "Exportiert Buchungen als strukturiere JSON-Datei mit allen Konto- und Transaktionsdaten"
        or "Export transactions as a structured JSON file containing all account and transaction data"
}

-- -------------------------
-- class section
-- -------------------------

---@class MM
---@field language string
---@field localizeText fun(str:string):string
---@field localizeDate fun(format:string|number, date:number?):string
---@field localizeNumber fun(format:string|number, num:number?):string
---@field localizeAmount fun(format:string|number, amount:number, currency:string|nil):string
---@field toEncoding fun(charset:string, str:string, bom:boolean|nil):any
---@field fromEncoding fun(charset:string, data:any):string
MM = {}

---@class MMTransaction
---@field name string
---@field accountNumber string
---@field bankCode string
---@field amount number
---@field currency string
---@field bookingDate number
---@field valueDate number
---@field purpose string
---@field transactionCode number
---@field textKeyExtension number
---@field purposeCode string
---@field bookingKey string
---@field bookingText string
---@field primanotaNumber string
---@field batchReference string
---@field endToEndReference string
---@field mandateReference string
---@field creditorId string
---@field returnReason string
---@field booked boolean
---@field checkmark boolean
---@field category string
---@field comment string
---@field id integer
MMTransaction = {}

---@class MMAccount
---@field name string
---@field owner string
---@field accountNumber string
---@field subAccount string
---@field bankCode string
---@field currency string
---@field iban string
---@field bic string
---@field type string
---@field attributes table<any, any>
---@field comment string
---@field balance integer
---@field balanceDate integer
MMAccount = {}

---@class Transaction
---@field name string
---@field accountNumber string
---@field bankCode string
---@field amount number
---@field currency string
---@field bookingDate number
---@field valueDate number
---@field purpose string
---@field transactionCode number
---@field textKeyExtension number
---@field purposeCode string
---@field bookingKey string
---@field bookingText string
---@field primanotaNumber string
---@field batchReference string
---@field endToEndReference string
---@field mandateReference string
---@field creditorId string
---@field returnReason string
---@field booked boolean
---@field checkmark boolean
---@field category string
---@field comment string
---@field id integer
---@field new fun(self:Transaction, mmTransaction:MMTransaction):Transaction
Transaction = {}
Transaction.__index = Transaction

---@param mmTransaction MMTransaction
---@return Transaction
function Transaction:new(mmTransaction)
    local t = {
        name              = mmTransaction.name,
        accountNumber     = mmTransaction.accountNumber,
        bankCode          = mmTransaction.bankCode,
        amount            = mmTransaction.amount,
        currency          = mmTransaction.currency,
        bookingDate       = mmTransaction.bookingDate,
        valueDate         = mmTransaction.valueDate,
        purpose           = mmTransaction.purpose,
        transactionCode   = mmTransaction.transactionCode,
        textKeyExtension  = mmTransaction.textKeyExtension,
        purposeCode       = mmTransaction.purposeCode,
        bookingKey        = mmTransaction.bookingKey,
        bookingText       = mmTransaction.bookingText,
        primanotaNumber   = mmTransaction.primanotaNumber,
        batchReference    = mmTransaction.batchReference,
        endToEndReference = mmTransaction.endToEndReference,
        mandateReference  = mmTransaction.mandateReference,
        creditorId        = mmTransaction.creditorId,
        returnReason      = mmTransaction.returnReason,
        booked            = mmTransaction.booked,
        checkmark         = mmTransaction.checkmark,
        category          = mmTransaction.category,
        comment           = mmTransaction.comment,
        id                = mmTransaction.id
    }
    setmetatable(t, Transaction)
    return t
end

---@class Account
---@field name string
---@field owner string
---@field accountNumber string
---@field subAccount string
---@field bankCode string
---@field currency string
---@field iban string
---@field bic string
---@field type string
---@field attributes table<any, any>
---@field comment string
---@field balance number
---@field balanceDate number
---@field transactions Transaction[]
---@field new fun(self:Account, mmAccount:MMAccount):Account
---@field addTransaction fun(self:Account, transaction:Transaction)
Account = {}
Account.__index = Account

---@param mmAccount MMAccount
---@return Account
function Account:new(mmAccount)
    local a = {
        name          = mmAccount.name,
        owner         = mmAccount.owner,
        accountNumber = mmAccount.accountNumber,
        subAccount    = mmAccount.subAccount,
        bankCode      = mmAccount.bankCode,
        currency      = mmAccount.currency,
        iban          = mmAccount.iban,
        bic           = mmAccount.bic,
        type          = mmAccount.type,
        attributes    = mmAccount.attributes,
        comment       = mmAccount.comment,
        balance       = mmAccount.balance,
        balanceDate   = mmAccount.balanceDate,
        transactions  = {}
    }
    setmetatable(a, Account)
    return a
end

---@param transaction Transaction
function Account:addTransaction(transaction)
    table.insert(self.transactions, transaction)
end

---@class ExportDataFile
---@field accounts table<string, Account>
---@field exportDate integer?
---@field new fun(self:ExportDataFile):ExportDataFile
---@field setExportDate fun(self:ExportDataFile, date:integer):nil
---@field getOrCreateAccount fun(self:ExportDataFile, mmAccount:MMAccount):Account
---@field addTransaction fun(self:ExportDataFile, mmAccount:MMAccount, mmTransaction:MMTransaction):nil
---@field getAllAccounts fun(self:ExportDataFile):Account[]
---@field serializeJSON fun(self:ExportDataFile):string
ExportDataFile = {}
ExportDataFile.__index = ExportDataFile

---@return ExportDataFile
function ExportDataFile:new()
    local storage = {
        accounts   = {},
        exportDate = nil
    }
    setmetatable(storage, ExportDataFile)
    return storage
end

---@param date integer
function ExportDataFile:setExportDate(date)
    self.exportDate = date
end

---@param mmAccount MMAccount
---@return Account
function ExportDataFile:getOrCreateAccount(mmAccount)
    local key = mmAccount.name
    if not self.accounts[key] then
        self.accounts[key] = Account:new(mmAccount)
    end
    return self.accounts[key]
end

---@param mmAccount MMAccount
---@param mmTransaction MMTransaction
function ExportDataFile:addTransaction(mmAccount, mmTransaction)
    local account = self:getOrCreateAccount(mmAccount)
    local transaction = Transaction:new(mmTransaction)
    account:addTransaction(transaction)
end

---@return Account[]
function ExportDataFile:getAllAccounts()
    local result = {}
    for _, account in pairs(self.accounts) do
        table.insert(result, account)
    end
    return result
end

---@return string
function ExportDataFile:serializeJSON()
    local out = {
        exportDate = self.exportDate,
        accounts   = {}
    }

    for _, account in pairs(self.accounts) do
        local accOut = {}
        for k, v in pairs(account) do
            if k ~= "transactions" then
                accOut[k] = v
            end
        end

        accOut.transactions = {}
        for _, t in ipairs(account.transactions) do
            local tOut = {}
            for k, v in pairs(t) do
                tOut[k] = v
            end
            table.insert(accOut.transactions, tOut)
        end

        table.insert(out.accounts, accOut)
    end

    return JSONParser.serialize(out)
end

---@class JSONParser
---@field escapeString fun(str:string):string
---@field isArray fun(tbl:table):boolean
---@field serialize fun(obj:any):string
JSONParser = {}

---@param str string
---@return string
function JSONParser.escapeString(str)
    str = tostring(str)
    str = str:gsub("\\", "\\\\")
    str = str:gsub('"', '\\"')
    str = str:gsub("\b", "\\b")
    str = str:gsub("\f", "\\f")
    str = str:gsub("\n", "\\n")
    str = str:gsub("\r", "\\r")
    str = str:gsub("\t", "\\t")
    return '"' .. str .. '"'
end

---@param table table<any, any>
---@return boolean
function JSONParser.isArray(table)
    local i = 0
    for _ in pairs(table) do
        i = i + 1
        if table[i] == nil then return false end
    end
    return true
end

---@param obj any
---@return string
function JSONParser.serialize(obj)
    local tp = type(obj)

    if tp == "string" then
        return JSONParser.escapeString(obj)
    elseif tp == "number" or tp == "boolean" then
        return tostring(obj)
    elseif tp == "table" then
        if JSONParser.isArray(obj) then
            local parts = {}
            for _, v in ipairs(obj) do
                parts[#parts + 1] = JSONParser.serialize(v)
            end
            return "[" .. table.concat(parts, ",") .. "]"
        else
            local parts = {}
            for k, v in pairs(obj) do
                parts[#parts + 1] =
                    JSONParser.escapeString(k) .. ":" .. JSONParser.serialize(v)
            end
            return "{" .. table.concat(parts, ",") .. "}"
        end
    end

    return "null"
end

-- -------------------------
-- main section
-- -------------------------

local exportFile = ExportDataFile:new()

---@param account MMAccount only gives one account even when account group is selected
---@param startDate integer POSIX time stamp
---@param endDate integer POSIX time stamp
---@param transactionCount integer total number of exporting transactions
function WriteHeader(account, startDate, endDate, transactionCount)
    ---@diagnostic disable-next-line: param-type-mismatch
    local date = os.time(os.date("!*t"))

    exportFile:setExportDate(date)
end

---@param account MMAccount
---@param transactions MMTransaction[]
function WriteTransactions(account, transactions)
    for _, t in ipairs(transactions) do
        exportFile:addTransaction(account, t)
    end
end

---@param account MMAccount only gives one account even when account group is selected
function WriteTail(account)
    assert(io.write(exportFile:serializeJSON()))
end
