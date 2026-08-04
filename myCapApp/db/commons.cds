namespace myCapApp.commons;

using {Currency} from '@sap/cds/common';

type Guid         : String(32);
type PhoneNumber  : String(32); //@assert.format: '/^[6-9]\d{9}$/';
type EmailAddress : String(105); //@assert.format: '/^[^\s@]+@[^\s@]+\.[^\s@]+$/';

type Gender       : String(1) enum {
    Male = 'M';
    Female = 'F';
    Undisclosed = 'U';
};

type AmountT      : Decimal(10, 2) @(
    Semantics.amount.currencyCode: 'CURRENCY_code',
    sap.units                    : 'CURRENCY_code'
);

aspect Amount {
    CURRENCY     : Currency;
    GROSS_AMOUNT : AmountT @title: '{i18n>XLBL_GROSSAMT}';
    NET_AMOUNT   : AmountT @title: '{i18n>XLBL_NETAMT}';
    TAX_AMOUNT   : AmountT @title: '{i18n>XLBL_TAXAMT}';

}
