/**
* @description   Apex Test class for controller of the lwc communityRelatedRecordController
* @testClass     communityRelatedRecordControllerTest.cls
* Modification Log 
* ------------------------------------------------------------------------------------  
* Developer                       Date                Description 
* António Santos               29/09/2021           Created Test Class
* ------------------------------------------------------------------------------------ 
*/
@isTest public with sharing class communityRelatedRecordControllerTest {
    @isTest
    public static void testRelatedRecord() {
        Test.startTest();
    
        SObject result = communityRelatedRecordController.getRelatedRecord(
            'User',
            'Id = :UserInfo.getUserId()',
            'Contact',
            new List<String> {
                'AccountId'
            }
        );

        System.assert(result != null);

        Test.stopTest();
    }
}