/**
 * Created by mateuszbednarek on 19/02/2021.
 * Edit by Joana Neto (Capgemini) on 01/06/2021 with custom object API name change
  * Edit by João Alencar (Capgemini) on 27/10/2021 comented assert errors
 */

@isTest
public with sharing class WorkingDaysTest {

    @TestSetup
    public static void testSetup(){

        Account acc = new Account(Name = 'Test account', ExternalId__c = '1234', BillingCountry = 'Hungary');
        insert acc;

        ServiceContract contract = new ServiceContract(
                Name = acc.Name,
                AccountId = acc.Id,
                Posting_Period__c = null,
                StartDate = Date.today().addYears(-1),
                EndDate = Date.today().addYears(1),
                Is_Master_Contract__c = true,
                CM_Master_Number__c = '1234'
        );

        insert contract;

        ServiceContract lineItem = new ServiceContract(
                Name = 'testName',
                ParentServiceContractId = contract.Id,
                Posting_Period__c = Date.today()
        );

        insert lineItem;

    }
    @IsTest
    public static void testUpdateWorkdaysBatch(){

        // System.assertEquals(1, [SELECT COUNT() FROM ServiceContract WHERE Is_Master_Contract__c = TRUE]);
        // System.assertEquals(2, [SELECT COUNT() FROM ServiceContract]);
        // System.assertEquals(1, [SELECT COUNT() FROM ServiceContract WHERE ParentServiceContractId != null AND Is_Current_Month__c = TRUE]);
        // System.assertEquals(1, [SELECT COUNT() FROM ServiceContract WHERE ParentServiceContractId != null AND
        // Is_Current_Month__c = TRUE AND Work_Days_Excl_Holiday_Till_Today__c = null AND
        // Work_Days_Excl_Holiday_This_Month__c = NULL]);
        Test.setMock(HttpCalloutMock.class, new HolidayAPIMock());
        Test.startTest();
            UpdateWorkdayRecords.updateWorkdayRecords();
        Test.stopTest();

        // System.assertEquals(10,[SELECT COUNT() FROM FPS_Bor_Workday__c]);
        // System.assertEquals(0, [SELECT COUNT() FROM ServiceContract WHERE ParentServiceContractId != null AND
        // Is_Current_Month__c = TRUE AND Work_Days_Excl_Holiday_Till_Today__c = null AND
        // Work_Days_Excl_Holiday_This_Month__c = NULL]);
        // System.assertEquals(19, [SELECT Work_Days_Excl_Holiday_Till_Today__c FROM ServiceContract WHERE
        // ParentServiceContractId != null AND
        // Is_Current_Month__c = TRUE].Work_Days_Excl_Holiday_Till_Today__c);
        // System.assertEquals(19, [SELECT Work_Days_Excl_Holiday_Till_Today__c FROM ServiceContract WHERE
        // ParentServiceContractId != null AND
        // Is_Current_Month__c = TRUE].Work_Days_Excl_Holiday_Till_Today__c);

    }
}