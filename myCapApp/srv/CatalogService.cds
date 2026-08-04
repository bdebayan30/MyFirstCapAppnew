using {
    myCapApp.db.master,
    myCapApp.db.transaction
} from '../db/data-model';

using {myCapApp.myviews.CDSViews} from '../db/CDSViews';

service CatalogService @(
    path    : 'CatalogService',
    requires: 'authenticated-user'
) {

    //Entity set which offers all the GET,PUT,POST,DELETE
    //@readonly -> to make entity read-only
    //@Capabilities: {
    //    Updatable: false,
    //    Deletable: false
    //}
    entity EmployeeSet @(restrict: [
        {
            grant: ['READ'],
            to   : 'Display',
            where: 'bankName = $user.BankName'
        },
        {
            grant: ['WRITE'],
            to   : 'Edit'
        }
    ])                          as projection on master.Employee;

    entity BusinessPartnerSet   as projection on master.businesspartner;

    entity AddressSet @(restrict: [{
        grant: 'READ',
        to   : 'Display',
        where: 'COUNTRY = $user.Country'
    }])                         as projection on master.address;

    entity PurchaseOrderSet @(
        odata.draft.enabled         : true,
        Common.DefaultValuesFunction: 'getOrderDefaultStatus'
    )                           as
        projection on transaction.purchaseorder {
            *,
            //case
            //    when OVERALL_STATUS = 'A'
            //         then 'Approved'
            //    when OVERALL_STATUS = 'P'
            //         then 'Pending'
            //    when OVERALL_STATUS = 'R'
            //         then 'Rejected'
            //end as OverallStatusText : String(10) @title: '{i18n>XLBL_OVERALLSTATTEXT}',

            //case
            //    when OVERALL_STATUS = 'A'
            //         then 3
            //    when OVERALL_STATUS = 'P'
            //         then 2
            //    when OVERALL_STATUS = 'R'
            //         then 1
            //end as StatusCriticality : Integer,
            virtual null as OverallStatusText : String(10) @title: '{i18n>XLBL_OVERALLSTATTEXT}',
            virtual null as StatusCriticality : Integer
        }
        actions {
            //action to increse the Product Amount
            action boost()             returns PurchaseOrderSet;
            action setApproved()       returns PurchaseOrderSet;
            action copyPurchaseOrder() returns PurchaseOrderSet;
        }

    entity PurchaseOrderItemSet as projection on transaction.poitems;

    //Expose the CDS Entity
    entity ProductSet           as projection on CDSViews.ProductView;

    //a non-instance bound function -- if you want multiple => function getMostExpensiveOrder() returns array of PurchaseOrderSet;
    function getMostExpensiveOrder() returns PurchaseOrderSet;

    function getOrderDefaultStatus() returns PurchaseOrderSet;


}
