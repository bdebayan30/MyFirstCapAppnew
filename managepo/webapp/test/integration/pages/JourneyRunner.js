sap.ui.define([
    "sap/fe/test/JourneyRunner",
	"mycap/managepo/test/integration/pages/PurchaseOrderSetList.gen",
	"mycap/managepo/test/integration/pages/PurchaseOrderSetObjectPage.gen",
	"mycap/managepo/test/integration/pages/PurchaseOrderItemSetObjectPage.gen"
], function (JourneyRunner, PurchaseOrderSetListGenerated, PurchaseOrderSetObjectPageGenerated, PurchaseOrderItemSetObjectPageGenerated) {
    'use strict';

    const runner = new JourneyRunner({
        launchUrl: sap.ui.require.toUrl('mycap/managepo') + '/test/flp.html#app-preview',
        pages: {
			onThePurchaseOrderSetListGenerated: PurchaseOrderSetListGenerated,
			onThePurchaseOrderSetObjectPageGenerated: PurchaseOrderSetObjectPageGenerated,
			onThePurchaseOrderItemSetObjectPageGenerated: PurchaseOrderItemSetObjectPageGenerated
        },
        async: true
    });

    return runner;
});

