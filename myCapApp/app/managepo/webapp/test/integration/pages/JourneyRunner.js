sap.ui.define([
    "sap/fe/test/JourneyRunner",
	"mycapapp/po/managepo/test/integration/pages/PurchaseOrderSetList.gen",
	"mycapapp/po/managepo/test/integration/pages/PurchaseOrderSetObjectPage.gen",
	"mycapapp/po/managepo/test/integration/pages/PurchaseOrderItemSetObjectPage.gen"
], function (JourneyRunner, PurchaseOrderSetListGenerated, PurchaseOrderSetObjectPageGenerated, PurchaseOrderItemSetObjectPageGenerated) {
    'use strict';

    const runner = new JourneyRunner({
        launchUrl: sap.ui.require.toUrl('mycapapp/po/managepo') + '/test/flp.html#app-preview',
        pages: {
			onThePurchaseOrderSetListGenerated: PurchaseOrderSetListGenerated,
			onThePurchaseOrderSetObjectPageGenerated: PurchaseOrderSetObjectPageGenerated,
			onThePurchaseOrderItemSetObjectPageGenerated: PurchaseOrderItemSetObjectPageGenerated
        },
        async: true
    });

    return runner;
});

