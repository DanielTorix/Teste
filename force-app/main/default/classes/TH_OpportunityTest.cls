/**
@author Guilherme Charro
@date    21/07/2021
@description Test class for TH_Opportunity
@TestClass         
Modification Log:
----------------------------------------------------------------------------------------------------
Developer                       Date                Description                           Coverage
----------------------------------------------------------------------------------------------------
Guilherme Charro                21/07/2021         Original Version                         100
*/
@isTest
public with sharing class TH_OpportunityTest {
    @isTest
    static void TH_OpportunityTest() {
        User runningUser = FW_TestDataFactory.createUsers(1, true, 'System Administrator', null).get(0);
        System.runAs(runningUser){
            test.startTest();
            List<Opportunity> listOpportunity = FW_TestDataFactory.createOpportunity(1, true); 
            listOpportunity[0].Name = 'teste update';
            update(listOpportunity);
            test.stopTest();
            System.assertNotEquals(null, listOpportunity[0].Id);
            System.assertEquals('teste update', listOpportunity[0].Name);
        }
    }
}