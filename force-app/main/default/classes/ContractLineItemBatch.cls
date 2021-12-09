/**
 * Created by mateuszbednarek on 21/01/2021.
 * Edit by Joana Neto (Capgemini) on 01/06/2021 with custom object API name change
 */

public with sharing class ContractLineItemBatch implements Database.Batchable<sObject>{
    String query = 'SELECT\n' +
            '        Adjusted_Quantity__c,\n' +
            '        Allocated_Quantity__c,\n' +
            '        ATP_VSOP_Region__c,\n' +
            '        CM_Master_Description__c,\n' +
            '        CM_Master_Number__c,\n' +
            '        Contract_Line_Item_Unique_Id__c,\n' +
            '        Contracted_Quantity__c,\n' +
            '        Contracted_Quantity_MAX__c,\n' +
            '        Contracted_Quantity_MIN__c,\n' +
            '        Contracted_Quantity_UoM__c,\n' +
            '        CreatedById,\n' +
            '        CreatedDate,\n' +
            '        CurrencyIsoCode,\n' +
            '        Customer__c,\n' +
            '        Customer_Group__c,\n' +
            '        Customer_Group_Name__c,\n' +
            '        Id,\n' +
            '        Is_Service_Contract__c,\n' +
            '        IsDeleted,\n' +
            '        LastModifiedById,\n' +
            '        LastModifiedDate,\n' +
            '        LastReferencedDate,\n' +
            '        LastViewedDate,\n' +
            '        Lifted_Quantity__c,\n' +
            '        Minus_tolerance_in__c,\n' +
            '        Multi_Item_Master__c,\n' +
            '        Name,\n' +
            '        Open_Quantity__c,\n' +
            '        OwnerId,\n' +
            '        Penalty_Amount__c,\n' +
            '        Penalty_Interval__c,\n' +
            '        Penalty_UoM__c,\n' +
            '        Plus_tolerance_in__c,\n' +
            '        Posting_Period__c,\n' +
            '        Posting_Period_Date__c,\n' +
            '        Product_Category_Group__c,\n' +
            '        Product_Group__c,\n' +
            '        Product_Group_Name__c,\n' +
            '        Sales_Representative__c,\n' +
            '        Service_Contract_Name__c,\n' +
            '        Shifted_Quantity__c,\n' +
            '        Storage__c,\n' +
            '        SystemModstamp,\n' +
            '        Valid_From__c,\n' +
            '        Valid_From_Date__c,\n' +
            '        Valid_to__c,Plant__c,\n' +
            '        Valid_To_Date__c\n' +
            'FROM FPS_Bor_Temporary_Storage__c\n' +
            'WHERE Is_Service_Contract__c = false';
    public Database.QueryLocator start(Database.BatchableContext bc) {
        return Database.getQueryLocator(query);
    }
    public void execute(Database.BatchableContext bc, List<FPS_Bor_Temporary_Storage__c> scope){
        system.debug('Scope size line items ===> '+scope.size());
        ContractLineItemConverter.convert(scope);
    }
    public void finish(Database.BatchableContext bc){
        if(Test.isRunningTest()){
            Database.executeBatch(new ClearTemporaryStorageBatch(), 200);
        }else{
            Database.executeBatch(new ClearTemporaryStorageBatch(), 200);
        }
    }
}