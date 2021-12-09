/**
* @description   Apex Test class for controller of the lwc communityPrivacyPolicy
* @testClass     communityPrivacyPolicyControllerTest
* Modification Log 
* ------------------------------------------------------------------------------------  
* Developer                       Date                Description 
* António Santos               28/09/2021           Created Test Class
* ------------------------------------------------------------------------------------ 
*/
@isTest public with sharing class communityPrivacyPolicyControllerTest {
    @isTest
    public static void testCommunityPrivacyPolicyController() {
        Test.startTest();

        communityPrivacyPolicyController.PrivacyPolicyResult result = communityPrivacyPolicyController.getPrivacyPolicy('Europe/Lisbon');
        communityPrivacyPolicyController.PrivacyPolicyResult result2 = communityPrivacyPolicyController.getPrivacyPolicy('Europe/Budapest');

        System.assert(result != null);

        System.assert(result2 != null);

        Test.stopTest();
    }
}