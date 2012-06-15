
module(..., package.seeall)

local store

--[[

function transactionCallback(event)
    local transaction = event.transaction
    if transaction.state == "purchased" then
        print("Transaction succuessful!")
        print("productId", transaction.productId)
        print("quantity", transaction.quantity)
        print("transactionIdentifier", transaction.transactionIdentifier)
        print("date", os.date("%Y-%m-%d %H:%M:%S", transaction.date))
        print("receipt", transaction.receipt)
    elseif  transaction.state == "restored" then
        print("Transaction restored (from previous session)")
        print("productId", transaction.productId)
        print("receipt", transaction.receipt)
        print("transactionIdentifier", transaction.identifier)
        print("date", transaction.date)
        print("originalReceipt", transaction.originalReceipt)
        print("originalTransactionIdentifier", transaction.originalIdentifier)
        print("originalDate", transaction.originalDate)
    elseif transaction.state == "failed" then
        print("Transaction failed")
        print("errorCode", transaction.errorCode)
        print("errorString", transaction.errorString)
    else
        print("unknown event")
    end

    -- Once we are done with a transaction, call this to tell the store
    -- we are done with the transaction.
    -- If you are providing downloadable content, wait to call this until
    -- after the download completes.
    qeeplay.api.Store.finishTransaction(transaction)
end

qeeplay.api.Store.init(transactionCallback)

]]
function init(listener)
    if store then
        log.error("[qeeplay.api.Store] ERR, init() store already init")
        return false
    end

    if type(listener) ~= "function" then
        log.error("[qeeplay.api.Store] ERR, init() invalid listener")
        return false
    end

    store = CCStore:sharedStore()
    return store:postInitWithTransactionListenerLua(listener)
end

function getReceiptVerifyMode()
    if not store then
        log.error("[qeeplay.api.Store] ERR, getReceiptVerifyMode() store not init")
        return false
    end

    return store:getReceiptVerifyMode()
end

function setReceiptVerifyMode(mode, isSandbox)
    if not store then
        log.error("[qeeplay.api.Store] ERR, setReceiptVerifyMode() store not init")
        return false
    end

    if type(mode) ~= "number"
        or (mode ~= CCStoreReceiptVerifyModeNone
            and mode ~= CCStoreReceiptVerifyModeDevice
            and mode ~= CCStoreReceiptVerifyModeServer) then
        log.error("[qeeplay.api.Store] ERR, setReceiptVerifyMode() invalid mode")
        return false
    end

    if type(isSandbox) ~= "boolean" then isSandbox = true end
    store:setReceiptVerifyMode(mode, isSandbox)
end

function getReceiptVerifyServerUrl()
    if not store then
        log.error("[qeeplay.api.Store] ERR, getReceiptVerifyServerUrl() store not init")
        return false
    end

    return store:getReceiptVerifyServerUrl()
end

function setReceiptVerifyServerUrl(url)
    if not store then
        log.error("[qeeplay.api.Store] ERR, setReceiptVerifyServerUrl() store not init")
        return false
    end

    if type(url) ~= "string" then
        log.error("[qeeplay.api.Store] ERR, setReceiptVerifyServerUrl() invalid url")
        return false
    end

    store:setReceiptVerifyServerUrl(url)
end

function canMakePurchases()
    if not store then
        log.error("[qeeplay.api.Store] ERR, canMakePurchases() store not init")
        return false
    end

    return store:canMakePurchases()
end

--[[
function productCallback(event)
    print("showing valid products", #event.products)
    for i=1, #event.products do
        print(event.products[i].title)              -- string.
        print(event.products[i].description)        -- string.
        print(event.products[i].price)              -- number.
        print(event.products[i].localizedPrice)     -- string.
        print(event.products[i].productIdentifier)  -- string.
    end

    print("showing invalidProducts", #event.invalidProducts)
    for i=1, #event.invalidProducts do
        print(event.invalidProducts[i])
    end
end

local productsId = {
    "com.anscamobile.NewExampleInAppPurchase.ConsumableTier1",
    "com.anscamobile.NewExampleInAppPurchase.NonConsumableTier1",
    "com.anscamobile.NewExampleInAppPurchase.SubscriptionTier1",
    -- "bad.product.id",
}

qeeplay.api.Store.loadProducts(productsId, productCallback)
]]
function loadProducts(productsId, listener)
    if not store then
        log.error("[qeeplay.api.Store] ERR, loadProducts() store not init")
        return false
    end

    if type(listener) ~= "function" then
        log.error("[qeeplay.api.Store] ERR, loadProducts() invalid listener")
        return false
    end

    if type(productsId) ~= "table" then
        log.error("[qeeplay.api.Store] ERR, loadProducts() invalid productsId")
        return false
    end

    for i = 1, #productsId do
        if type(productsId[i]) ~= "string" then
            log.error("[qeeplay.api.Store] ERR, loadProducts() invalid id[#%d] in productsId", i)
            return false
        end
    end

    store:loadProductsLua(productsId, listener)
    return true
end

function cancelLoadProducts()
    if not store then
        log.error("[qeeplay.api.Store] ERR, cancelLoadProducts() store not init")
        return false
    end

    store:cancelLoadProducts()
end

function isProductLoaded(productId)
    if not store then
        log.error("[qeeplay.api.Store] ERR, isProductLoaded() store not init")
        return false
    end

    return store:isProductLoaded(productId)
end

--[[
qeeplay.api.Store.purchase("com.anscamobile.NewExampleInAppPurchase.ConsumableTier1")
]]
function purchase(productId)
    if not store then
        log.error("[qeeplay.api.Store] ERR, purchase() store not init")
        return false
    end

    if type(productId) ~= "string" then
        log.error("[qeeplay.api.Store] ERR, purchase() invalid productId")
        return false
    end

    return store:purchase(productId)
end

function finishTransaction(transaction)
    if not store then
        log.error("[qeeplay.api.Store] ERR, finishTransaction() store not init")
        return false
    end

    if type(transaction) ~= "table" or type(transaction.transactionIdentifier) ~= "string" then
        log.error("[qeeplay.api.Store] ERR, finishTransaction() invalid transaction")
        return false
    end

    return store:finishTransactionLua(transaction.transactionIdentifier)
end
