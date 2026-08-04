using {
    cuid,
    Currency
} from '@sap/cds/common';
using {myCapApp.commons as commons} from './commons';


namespace myCapApp.db;

context master {
    type Guid : String(32);

    entity product {
        key NODE_KEY       : commons.Guid                   @title: '{i18n>XLBL_PRODUCT_KEY}';
            PRODUCT_ID     : String(28)                     @title: '{i18n>XLBL_PRODUCT_ID}';
            TYPE_CODE      : String(2)                      @title: '{i18n>XLBL_TYPE_CODE}';
            CATEGORY       : String(32)                     @title: '{i18n>XLBL_CATEGORY}';
            DESCRIPTION    : localized String(255)          @title: '{i18n>XLBL_DESCRIPTION}';
            SUPPLIER_GUID  : Association to businesspartner @title: '{i18n>XLBL_SUPPLIER_KEY}';
            TAX_TARIF_CODE : Integer                        @title: '{i18n>XLBL_TAX_TARIFF_CODE}';
            MEASURE_UNIT   : String(2)                      @title: '{i18n>XLBL_MEASURE_UNIT}';
            WEIGHT_MEASURE : Decimal(5, 2)                  @title: '{i18n>XLBL_WEIGHT_MEASURE}';
            WEIGHT_UNIT    : String(2)                      @title: '{i18n>XLBL_WEIGHT_UNIT}';
            CURRENCY_CODE  : String(4)                      @title: '{i18n>XLBL_CURRENCY_CODE}';
            PRICE          : Decimal(15, 2)                 @title: '{i18n>XLBL_PRICE}';
            WIDTH          : Decimal(15, 2)                 @title: '{i18n>XLBL_WIDTH}';
            DEPTH          : Decimal(15, 2)                 @title: '{i18n>XLBL_DEPTH}';
            HEIGHT         : Decimal(15, 2)                 @title: '{i18n>XLBL_HEIGHT}';
            DIM_UNIT       : String(2)                      @title: '{i18n>XLBL_DIMENSION_UNIT}';
    }

    entity businesspartner {
        key NODE_KEY      : commons.Guid               @title: '{i18n>XLBL_BPKEY}';
            BP_ROLE       : String(2)                  @title: '{i18n>XLBL_BP_ROLE}';
            EMAIL_ADDRESS : String(105)                @title: '{i18n>XLBL_EMAIL_ADDRESS}';
            PHONE_NUMBER  : String(32)                 @title: '{i18n>XLBL_PHONE_NUMBER}';
            FAX_NUMBER    : String(32)                 @title: '{i18n>XLBL_FAX_NUMBER}';
            WEB_ADDRESS   : String(44)                 @title: '{i18n>XLBL_WEB_ADDRESS}';
            BP_ID         : String(32)                 @title: '{i18n>XLBL_BPID}';
            COMPANY_NAME  : String(250)                @title: '{i18n>XLBL_COMPANY}';
            ADDRESS_GUID  : Association to one address @title: '{i18n>XLBL_ADDRKEY}';
    }


    entity address {
        key NODE_KEY         : commons.Guid @title: '{i18n>XLBL_ADDRESS_KEY}';
            CITY             : String(44)   @title: '{i18n>XLBL_CITY}';
            POSTAL_CODE      : String(8)    @title: '{i18n>XLBL_POSTAL_CODE}';
            STREET           : String(44)   @title: '{i18n>XLBL_STREET}';
            BUILDING         : String(128)  @title: '{i18n>XLBL_BUILDING}';
            COUNTRY          : String(44)   @title: '{i18n>XLBL_COUNTRY}';
            ADDRESS_TYPE     : String(44)   @title: '{i18n>XLBL_ADDRESS_TYPE}';
            VAL_START_DATE   : Date         @title: '{i18n>XLBL_VALID_FROM}';
            VAL_END_DATE     : Date         @title: '{i18n>XLBL_VALID_TO}';
            LATITUDE         : Decimal      @title: '{i18n>XLBL_LATITUDE}';
            LONGITUDE        : Decimal      @title: '{i18n>XLBL_LONGITUDE}';
            BUSINESS_PARTNER : Association to one businesspartner
                                   on BUSINESS_PARTNER.ADDRESS_GUID = $self
                                            @title: '{i18n>XLBL_BUSINESS_PARTNER}';
    }

    entity Employee : cuid {
        nameFirst     : String(40)           @title: '{i18n>XLBL_FIRST_NAME}';
        nameMiddle    : String(40)           @title: '{i18n>XLBL_MIDDLE_NAME}';
        nameLast      : String(40)           @title: '{i18n>XLBL_LAST_NAME}';
        nameInitials  : String(40)           @title: '{i18n>XLBL_INITIALS}';
        sex           : commons.Gender       @title: '{i18n>XLBL_GENDER}';
        language      : String(1)            @title: '{i18n>XLBL_LANGUAGE}';
        phoneNumber   : commons.PhoneNumber  @title: '{i18n>XLBL_PHONE_NUMBER}';
        email         : commons.EmailAddress @title: '{i18n>XLBL_EMAIL}';
        CURRENCY      : String(4)            @title: '{i18n>XLBL_CURRENCY}';
        salaryAmount  : commons.AmountT      @title: '{i18n>XLBL_SALARY_AMOUNT}';
        accountNumber : String(20)           @title: '{i18n>XLBL_ACCOUNT_NUMBER}';
        bankId        : String(20)           @title: '{i18n>XLBL_BANK_ID}';
        bankName      : String(64)           @title: '{i18n>XLBL_BANK_NAME}';
    }
}

context transaction {
    entity purchaseorder : commons.Amount {
        key NODE_KEY         : commons.Guid                              @title: '{i18n>XLBL_PO_KEY}';
            PO_ID            : String(40)                                @title: '{i18n>XLBL_PO_ID}';
            PARTNER_GUID     : Association to one master.businesspartner @title: '{i18n>XLBL_PARTNER_KEY}';
            LIFECYCLE_STATUS : String(1)                                 @title: '{i18n>XLBL_LIFECYCLE_STATUS}';
            OVERALL_STATUS   : String(1)                                 @title: '{i18n>XLBL_OVERALL_STATUS}';
            Items            : Composition of many poitems
                                   on Items.PARENT_KEY = $self
                                                                         @title: '{i18n>XLBL_ITEMS}';
    };

    entity poitems : commons.Amount {
        key NODE_KEY     : commons.Guid                      @title: '{i18n>XLBL_POITEM_KEY}';
            PARENT_KEY   : Association to one purchaseorder  @title: '{i18n>XLBL_PARENT_KEY}';
            PO_ITEM_POS  : Integer                           @title: '{i18n>XLBL_PO_ITEM_POSITION}';
            PRODUCT_GUID : Association to one master.product @title: '{i18n>XLBL_PRODUCT_KEY}';
    }
}
