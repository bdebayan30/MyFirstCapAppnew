sap.ui.define([
    "sap/fe/test/JourneyRunner",
	"mycapapp/manageprod/test/integration/pages/ProductSetList.gen",
	"mycapapp/manageprod/test/integration/pages/ProductSetObjectPage.gen"
], function (JourneyRunner, ProductSetListGenerated, ProductSetObjectPageGenerated) {
    'use strict';

    const runner = new JourneyRunner({
        launchUrl: sap.ui.require.toUrl('mycapapp/manageprod') + '/test/flp.html#app-preview',
        pages: {
			onTheProductSetListGenerated: ProductSetListGenerated,
			onTheProductSetObjectPageGenerated: ProductSetObjectPageGenerated
        },
        async: true
    });

    return runner;
});

