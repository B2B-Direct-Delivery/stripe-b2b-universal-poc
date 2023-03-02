Savepoint sp = Database.setSavepoint();
try {

    Product2 product = new Product2(Name = 'cool product',
            Description = 'it\'s very cool...',
            ProductCode = '99999999');

    insert product;

    Pricebook2 pricebook2 = [SELECT Id FROM Pricebook2 WHERE IsStandard = TRUE LIMIT 1];

    PricebookEntry pricebookEntry = new PricebookEntry(
            Pricebook2Id = pricebook2.Id,
            Product2Id = product.Id,
            UnitPrice = 10);

    insert pricebookEntry;

    Account account = new Account(Name = 'Bob Jones');

    insert account;

    Order order = new Order();

    order.Pricebook2Id = pricebook2.Id;
    order.AccountId = account.Id;
    order.EffectiveDate = System.today();
    order.Status = 'Draft';

//    order.TotalAmount = 55;

    insert order;

    OrderItem item = new OrderItem(
            OrderId = order.Id,
            Quantity = 1,
            UnitPrice = 49.99,
            Description = 'SKU: 223324234 Name: Real product name',
            PricebookEntryId = pricebookEntry.Id,
            Product2Id = product.Id,
            Type = 'Order Product');

    OrderItem itemEcoTax = new OrderItem(
            OrderId = order.Id,
            Description = 'Eco-Tax',
            Quantity = 1,
            UnitPrice = 0,
            PricebookEntryId = pricebookEntry.Id,
            Product2Id = product.Id,
            Type = 'Fee');

    insert new SObject[]{
            item, itemEcoTax
    };

    // normal tax
    OrderItemTaxLineItem taxLine = new OrderItemTaxLineItem(
            OrderItemId = item.Id,
            Amount = 5,
            Name = 'itemtax',
            Type = 'Actual',
            TaxEffectiveDate = Date.today()
    );

    // eco tax
    OrderItemTaxLineItem ecoTaxLine = new OrderItemTaxLineItem(
            OrderItemId = itemEcoTax.Id,
            Amount = 1,
            Name = 'itemtax',
            Description = 'ecotax',
            Type = 'Actual',
            TaxEffectiveDate = Date.today()
    );

    insert new SObject[]{
            taxLine, ecoTaxLine
    };

    order = [
            SELECT FIELDS(STANDARD)
            FROM Order
            WHERE Id = :order.Id
            LIMIT 1
    ];

    System.debug(JSON.serializePretty(order));

    OrderItem[] items = [
            SELECT FIELDS(STANDARD)
            FROM OrderItem
            WHERE OrderId = :order.Id
            LIMIT 10
    ];

    OrderDeliveryMethod orderDeliveryMethod = new OrderDeliveryMethod(Name = 'External Order Delivery Method');

    OrderDeliveryGroup orderDeliveryGroup = new OrderDeliveryGroup(
            OrderId = order.Id,
            OrderDeliveryMethod = orderDeliveryMethod,
            DeliverToName = 'Bob\'s Pools'
    );

    insert orderDeliveryGroup;


    item.OrderDeliveryGroupId = orderDeliveryGroup.Id;
    itemEcoTax.OrderDeliveryGroupId = orderDeliveryGroup.Id;
    update new SObject [] {item, itemEcoTax};
//    System.debug(JSON.serializePretty(items, true));

    order.Status = 'Activated';

    update order;

    ConnectApi.OrderSummaryInputRepresentation orderSummaryInputRepresentation = new ConnectApi.OrderSummaryInputRepresentation();

    orderSummaryInputRepresentation.orderId = order.Id;
    orderSummaryInputRepresentation.orderLifeCycleType = 'UNMANAGED';

    ConnectApi.OrderSummaryOutputRepresentation osOut = ConnectApi.OrderSummaryCreation.createOrderSummary(orderSummaryInputRepresentation);

    System.debug(JSON.serializePretty(osOut));
    Id osId = osOut.orderSummaryId;

    OrderSummary orderSummary = [SELECT FIELDS(STANDARD) FROM OrderSummary WHERE Id = :osId LIMIT 1];

    System.debug(JSON.serializePretty(orderSummary));
    /*
    // DOESN'T WORK WITH UNMANAGED ORDER SUMMARIES
    ConnectApi.AdjustOrderItemSummaryInputRepresentation adjustOrderItemSummaryInputRepresentation = new ConnectApi.AdjustOrderItemSummaryInputRepresentation();

    ConnectApi.AdjustItemInputRepresentation adjustItemInputRepresentation = new ConnectApi.AdjustItemInputRepresentation();

    Id oiiId = [SELECT Id FROM OrderItemSummary WHERE OrderSummaryId = :orderSummary.Id LIMIT 1].Id;

    adjustItemInputRepresentation.orderItemSummaryId = oiiId;
    adjustItemInputRepresentation.amount = -10;
    adjustItemInputRepresentation.adjustmentType = 'AmountWithoutTax';
    adjustItemInputRepresentation.reason = 'Damaged';
    adjustItemInputRepresentation.description = 'test 123';

    adjustOrderItemSummaryInputRepresentation.adjustItems = new ConnectApi.AdjustItemInputRepresentation[] { adjustItemInputRepresentation };

    ConnectApi.OrderSummary.adjustPreview(orderSummary.Id, adjustOrderItemSummaryInputRepresentation);
    */
//    OrderItemAdjustmentLineItem orderItemAdjustmentLineItem = new OrderItemAdjustmentLineItem(
//            OrderItemId = item.Id,
//            Amount = -25
//    );
//    insert orderItemAdjustmentLineItem;
} finally {
    Database.rollback(sp);
}

