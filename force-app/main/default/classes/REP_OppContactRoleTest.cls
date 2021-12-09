/**
@author Guilherme Charro
@date    12/11/2021
@description Test class for REP_Opportunity
@TestClass         
Modification Log:
----------------------------------------------------------------------------------------------------
Developer                       Date                Description                           Coverage
----------------------------------------------------------------------------------------------------
Guilherme Charro                12/11/2021         Original Version                         100
*/
@isTest
public class REP_OppContactRoleTest {
    @testSetup
    private static void makeData(){
        FW_TriggerHandlerSettings__c setting = new FW_TriggerHandlerSettings__c();
        insert setting;

        CEPSkipValidationRules__c skipValidation = new CEPSkipValidationRules__c();
        insert skipValidation;
    }
    
    @isTest
    static void OppContactRoleTest() {
        User runningUser = FW_TestDataFactory.createUsers(1, true, 'System Administrator', null).get(0);
        System.runAs(runningUser){  
            List<opportunityContactRole> oppContactRoleList = FW_TestDataFactory.createOppContactRole(1, false);
            
            test.startTest();
                List<Opportunity> oppList = FW_TestDataFactory.createOpportunity(1, true);
                oppContactRoleList[0].OpportunityId = oppList[0].Id;
                insert(oppContactRoleList);
                REP_OppContactRole oppContactRoleRepository = new REP_OppContactRole();
                List<opportunityContactRole> oppoContactRolesReturned = oppContactRoleRepository.getOppContactRoleByOppId(new Set<ID> {oppList[0].Id});
            test.stopTest();

            System.assertEquals(1, oppoContactRolesReturned.size());
        }
    }
}