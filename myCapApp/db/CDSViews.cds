namespace myCapApp.myviews;

using {
    myCapApp.db.master,
    myCapApp.db.transaction
} from '../db/data-model';

context CDSViews {
    define view ![POWorklist] as
        select from transaction.purchaseorder {
            key PO_ID                             as ![PurchaseOrderId],
                Items.PO_ITEM_POS                 as ![ItemPosition],
                PARTNER_GUID.BP_ID                as ![BusinessPartnerId],
                PARTNER_GUID.COMPANY_NAME         as ![CompanyName],
                Items.GROSS_AMOUNT                as ![GrossAmount],
                Items.NET_AMOUNT                  as ![NetAmount],
                Items.TAX_AMOUNT                  as ![TaxAmount],
                Items.CURRENCY                    as ![Currency],
                OVERALL_STATUS                    as ![OverallStatus],
                Items.PRODUCT_GUID.CATEGORY       as ![ProductCategory],
                Items.PRODUCT_GUID.DESCRIPTION    as ![ProductDescription],
                PARTNER_GUID.ADDRESS_GUID.COUNTRY as ![Country],
                PARTNER_GUID.ADDRESS_GUID.CITY    as ![City],
        };

    define view ![ProductHelpView] as
        select from master.product {
            @EndUserText.Label: [{
                language: 'EN',
                text    : 'Product Id'
            }]
            PRODUCT_ID                 as ![ProductId],

            @EndUserText.Label: [{
                language: 'EN',
                text    : 'Description'
            }]
            DESCRIPTION                as ![Description],

            CATEGORY                   as ![Category],
            PRICE                      as ![Price],
            CURRENCY_CODE              as ![CurrencyCode],
            SUPPLIER_GUID.COMPANY_NAME as ![SupplierName]
        };

    define view ![ItemView] as
        select from transaction.poitems {
            key NODE_KEY                         as ![ItemKey],
                PARENT_KEY.PARTNER_GUID.NODE_KEY as ![SupplierId],
                PRODUCT_GUID.NODE_KEY            as ![ProductKey],
                GROSS_AMOUNT                     as ![GrossAmount],
                NET_AMOUNT                       as ![NetAmount],
                TAX_AMOUNT                       as ![TaxAmount],
                CURRENCY                         as ![CurrencyCode],
                PARENT_KEY.OVERALL_STATUS        as ![Status]
        };

    define view ![ProductView] as
        select from master.product
        ///Mixin - is a keyword to define loose coupling of dependent data
        ///which tells framework to never load the dependent data until requested
        mixin {
            //$projection - predicate indicates the selection list of defined fields with alias
            PO_ITEMS : Association to many ItemView
                           on PO_ITEMS.ProductKey = $projection.ProductId;

        }
        into {
            NODE_KEY                           as ![ProductId],
            DESCRIPTION                        as ![ProductName],
            CATEGORY                           as ![Category],
            SUPPLIER_GUID.BP_ID                as ![SupplierId],
            SUPPLIER_GUID.COMPANY_NAME         as ![SupplierName],
            SUPPLIER_GUID.ADDRESS_GUID.COUNTRY as ![Country],

            //exposed association, @ Runtime the data will be loaded on-demand - lazy loading
            PO_ITEMS                           as ![To_Items]
        };

    //Create a consumption view - view on view, aggregation
    define view CProductSalesAnalytics as
        select from ProductView {

            key ProductName,
                Country,
                sum(To_Items.GrossAmount) as ![TotalPurchaseAmount] : Decimal(15, 2),
                To_Items.CurrencyCode     as ![CurrencyCode]

        }
        group by
            ProductName,
            Country,
            To_Items.CurrencyCode;

}
