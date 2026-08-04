using CatalogService as service from '../../srv/CatalogService';

annotate service.PurchaseOrderSet with @(


    UI.SelectionFields    : [
        PO_ID,
        PARTNER_GUID.COMPANY_NAME,
        PARTNER_GUID.ADDRESS_GUID.COUNTRY,
        GROSS_AMOUNT,
        CURRENCY_code,
        OVERALL_STATUS
    ],

    UI.LineItem           : [
        {
            $Type: 'UI.DataField',
            Value: PO_ID,
        },
        {
            $Type: 'UI.DataField',
            Value: PARTNER_GUID.COMPANY_NAME,
        },
        {
            $Type: 'UI.DataField',
            Value: PARTNER_GUID.ADDRESS_GUID.COUNTRY,
        },
        {
            $Type: 'UI.DataField',
            Value: GROSS_AMOUNT,
        },
        {
            $Type : 'UI.DataFieldForAction',
            Label : 'Boost PO Gross Amount',
            Action: 'CatalogService.boost',
        },
        {
            $Type: 'UI.DataField',
            Value: CURRENCY_code,
        },
        {
            $Type      : 'UI.DataField',
            Criticality: StatusCriticality,
            Value      : OverallStatusText,
        },
        {
            $Type : 'UI.DataFieldForAction',
            Label : 'Copy Purchase Order',
            Action: 'CatalogService.copyPurchaseOrder',
        },
    ],

    UI.HeaderInfo         : {
        TypeName      : 'Purchase Order',
        TypeNamePlural: 'Purchase Orders',
        Title         : {Value: PO_ID},
        Description   : {Value: PARTNER_GUID.COMPANY_NAME},
        ImageUrl      : 'data:image/png;base64,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'
    },

    UI.Facets             : [
        {
            $Type : 'UI.CollectionFacet',
            Label : 'General Information',
            Facets: [
                {
                    $Type : 'UI.ReferenceFacet',
                    Label : 'Order Details',
                    Target: '@UI.Identification'
                },

                {
                    $Type : 'UI.ReferenceFacet',
                    Label : 'Pricing Details',
                    Target: '@UI.FieldGroup#Pricing'
                },

                {
                    $Type : 'UI.ReferenceFacet',
                    Label : 'Status Info',
                    Target: '@UI.FieldGroup#Status'
                }

            ]

        },
        {
            $Type : 'UI.ReferenceFacet',
            Label : 'Purchase Order Items',
            Target: 'Items/@UI.LineItem'
        }
    ],

    UI.Identification     : [
        {
            $Type: 'UI.DataField',
            Value: PO_ID
        },
        {
            $Type: 'UI.DataField',
            Value: PARTNER_GUID_NODE_KEY
        },
        {
            $Type: 'UI.DataField',
            Value: LIFECYCLE_STATUS
        },
        {
            $Type : 'UI.DataFieldForAction',
            Label : 'Approve',
            Action: 'CatalogService.setApproved'
        }

    ],

    UI.FieldGroup #Pricing: {

        Label: 'Pricing',
        Data : [
            {
                $Type: 'UI.DataField',
                Value: GROSS_AMOUNT
            },
            {
                $Type: 'UI.DataField',
                Value: NET_AMOUNT
            },
            {
                $Type: 'UI.DataField',
                Value: TAX_AMOUNT
            },
            {
                $Type: 'UI.DataField',
                Value: CURRENCY_code
            },
        ]
    },

    UI.FieldGroup #Status : {

        Label: 'Status Info',
        Data : [

        {
            $Type      : 'UI.DataField',
            Criticality: StatusCriticality,
            Value      : OVERALL_STATUS
        }]
    },

    UI.PresentationVariant: {
        $Type    : 'UI.PresentationVariantType',
        SortOrder: [{
            $Type     : 'UI.SortOrderType',
            Property  : PO_ID, // CHANGED: unquoted property path, not 'PO_ID' string
            Descending: false
        }]
    },
    UI.SelectionPresentationVariant #table : {
        $Type : 'UI.SelectionPresentationVariantType',
        PresentationVariant : {
            $Type : 'UI.PresentationVariantType',
            Visualizations : [
                '@UI.LineItem',
            ],
            SortOrder : [
                {
                    $Type : 'Common.SortOrderType',
                    Property : PO_ID,
                    Descending : true,
                },
            ],
        },
        SelectionVariant : {
            $Type : 'UI.SelectionVariantType',
            SelectOptions : [
            ],
        },
    },

);

annotate service.PurchaseOrderItemSet with @(

    UI.SelectionFields              : [
        PO_ITEM_POS,
        PRODUCT_GUID,
        PARENT_KEY,
        GROSS_AMOUNT,
        CURRENCY
    ],

    UI.LineItem                     : [
        {
            $Type: 'UI.DataField',
            Value: PO_ITEM_POS
        },
        {
            $Type: 'UI.DataField',
            Value: PRODUCT_GUID_NODE_KEY
        },
        {
            $Type: 'UI.DataField',
            Value: GROSS_AMOUNT
        },
        {
            $Type: 'UI.DataField',
            Value: NET_AMOUNT
        },
        {
            $Type: 'UI.DataField',
            Value: TAX_AMOUNT
        },
        {
            $Type: 'UI.DataField',
            Value: CURRENCY_code
        }
    ],

    UI.HeaderInfo                   : {
        TypeName      : 'Purchase Order Item',
        TypeNamePlural: 'Purchase Order Items',
        Title         : {Value: PO_ITEM_POS},
        Description   : {Value: PRODUCT_GUID.ProductName}
    },

    UI.Facets                       : [
        {
            $Type : 'UI.CollectionFacet',
            ID    : 'ItemGeneralInformation',
            Label : 'General Information',
            Facets: [
                {
                    $Type : 'UI.ReferenceFacet',
                    ID    : 'ItemDetails',
                    Label : 'Item Details',
                    Target: '@UI.Identification'
                },
                {
                    $Type : 'UI.ReferenceFacet',
                    ID    : 'ItemPricingDetails',
                    Label : 'Pricing Details',
                    Target: '@UI.FieldGroup#Pricing'
                }
            ]
        },
        {
            $Type : 'UI.CollectionFacet',
            ID    : 'ProductInformation',
            Label : 'Product Information',
            Facets: [
                {
                    $Type : 'UI.ReferenceFacet',
                    ID    : 'ProductDetails',
                    Label : 'Product Details',
                    Target: '@UI.FieldGroup#ProductInfo'
                },
                {
                    $Type : 'UI.ReferenceFacet',
                    ID    : 'ProductPricing',
                    Label : 'Product Price',
                    Target: '@UI.FieldGroup#ProductPricing'
                },
                {
                    $Type : 'UI.ReferenceFacet',
                    ID    : 'ProductDimensions',
                    Label : 'Product Dimensions',
                    Target: '@UI.FieldGroup#ProductDimensions'
                }
            ]
        }
    ],

    UI.Identification               : [
        {
            $Type: 'UI.DataField',
            Value: NODE_KEY
        },
        {
            $Type: 'UI.DataField',
            Value: PARENT_KEY_NODE_KEY
        },
        {
            $Type: 'UI.DataField',
            Value: PO_ITEM_POS
        },
        {
            $Type: 'UI.DataField',
            Value: PRODUCT_GUID_NODE_KEY
        }
    ],

    UI.FieldGroup #Pricing          : {
        Label: 'Pricing Details',
        Data : [
            {
                $Type: 'UI.DataField',
                Value: GROSS_AMOUNT
            },
            {
                $Type: 'UI.DataField',
                Value: NET_AMOUNT
            },
            {
                $Type: 'UI.DataField',
                Value: TAX_AMOUNT
            },
            {
                $Type: 'UI.DataField',
                Value: CURRENCY_code
            }
        ]
    },

    UI.FieldGroup #ProductInfo      : {
        Label: 'Product Information',
        Data : [
            {
                $Type: 'UI.DataField',
                Value: PRODUCT_GUID.ProductId
            },
            {
                $Type: 'UI.DataField',
                Value: PRODUCT_GUID.ProductName
            },
            {
                $Type: 'UI.DataField',
                Value: PRODUCT_GUID.Category
            }
        ]
    },

    UI.FieldGroup #ProductPricing   : {
        Label: 'Product Price',
        Data : [{
            $Type: 'UI.DataField',
            Value: PRODUCT_GUID.Price
        }]
    },

    UI.FieldGroup #ProductDimensions: {
        Label: 'Product Dimensions',
        Data : [{
            $Type: 'UI.DataField',
            Value: PRODUCT_GUID
        }]
    }


);

annotate service.PurchaseOrderSet with {
    PARTNER_GUID   @(
        Common.Text     : PARTNER_GUID.COMPANY_NAME,
        ValueList.entity: service.BusinessPartnerSet
    );
    OVERALL_STATUS @(
        Common.Text           : OverallStatusText,
        Common.TextArrangement: #TextOnly
    );
};

annotate service.PurchaseOrderItemSet with {
    PRODUCT_GUID @(
        Common.Text     : PRODUCT_GUID.ProductName,
        ValueList.entity: service.ProductSet
    )
};

//Define a value help from an entity
@cds.odata.valuelist
annotate service.BusinessPartnerSet with @(UI.Identification: [{
    $Type: 'UI.DataField',
    Value: COMPANY_NAME,
}]);

@cds.odata.valuelist
annotate service.ProductSet with @(UI.Identification: [{
    $Type: 'UI.DataField',
    Value: ProductName,
}]);

//annotate service.PurchaseOrderSet with actions {
//    setApproved @Common.SideEffects: {TargetProperties: [OVERALL_STATUS]};
//};
