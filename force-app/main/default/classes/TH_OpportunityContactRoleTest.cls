/**
@author Guilherme Charro
@date    12/11/2021
@description Test class for TH_OpportunityContactRole
@TestClass         
Modification Log:
----------------------------------------------------------------------------------------------------
Developer                       Date                Description                           Coverage
----------------------------------------------------------------------------------------------------
Guilherme Charro                12/11/2021         Original Version                         100
*/
@isTest
public class TH_OpportunityContactRoleTest {
    @testSetup
    private static void makeData(){
        FW_TriggerHandlerSettings__c setting = new FW_TriggerHandlerSettings__c();
        insert setting;

        CEPSkipValidationRules__c skipValidation = new CEPSkipValidationRules__c();
        insert skipValidation;
    }

    @isTest
    static void eventTest(){
        User runningUser = FW_TestDataFactory.createUsers(1, true, 'System Administrator', null).get(0);
        System.runAs(runningUser){
            test.startTest();
            List<OpportunityContactRole> oppContactRoleList = FW_TestDataFactory.createOppContactRole(1, true);
            oppContactRoleList[0].Role = 'Other';
            update(oppContactRoleList);
            test.stopTest();
            System.assertEquals('Other', oppContactRoleList[0].Role);
        }
    }
}