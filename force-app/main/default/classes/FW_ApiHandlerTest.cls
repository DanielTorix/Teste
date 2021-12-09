/**
* @description    CEP Api Handler Test
* @testClass     
* Modification Log 
* ------------------------------------------------------------------------------------  
* Developer                       Date                Description 
* Antonio Santos                23/08/2021          Created CEP Api Handler Test
* ------------------------------------------------------------------------------------ 
*/
@isTest
public class FW_ApiHandlerTest {
    public class MockOutput {
        public String testResult;
    }

    @isTest
    static void apiHandlerTest() {
        User runningUser = FW_TestDataFactory.createUsers(1, true, 'System Administrator', null).get(0);
        
        System.runAs(runningUser) {
            upsert new CEP_ApiSetting__c(LogicalEnvironmentDeveloperName__c = 'Test');

            Test.startTest();

            FW_ApiHandler fwApiHandler = FW_ApiHandler.getInstance();

            System.assert(fwApiHandler != null);

            FW_ApiMethod fwApiMethod = fwApiHandler.getMethod('TEST');

            System.assert(fwApiMethod != null);

            Account a = new Account(Name = 'TEST');

            Object o = fwApiHandler.call(fwApiMethod, a);

            System.assert(o != null);

            Object o2 = fwApiHandler.call(fwApiMethod, new Map<String,Object> { 'test' => 'test value' });

            System.assert(o2 != null);

            Test.stopTest();
        }
    }
}