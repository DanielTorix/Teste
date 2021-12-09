/**
* @description   Apex Test class for controller of the lwc communityImageCardController
* @testClass     communityImageCardControllerTest
* Modification Log 
* ------------------------------------------------------------------------------------  
* Developer                       Date                Description 
* António Santos               29/09/2021           Created Test Class
* ------------------------------------------------------------------------------------ 
*/
@isTest public with sharing class communityImageCardControllerTest {
    @isTest
    public static void testImageCardController() {
        Test.startTest();
    
        String result = communityImageCardController.getDocumentURL('TestDoc');

        System.assert(result != null);

        Test.stopTest();
    }
}