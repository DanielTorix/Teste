@isTest
public with sharing class TH_ProductDiscountCriteriaTest {
    @isTest
    static void TH_ProductDiscountCriteriaTest() {
        User runningUser = FW_TestDataFactory.createUsers(1, true, 'System Administrator', null).get(0);
        List<ProductDiscount__c> productDiscountList = FW_TestDataFactory.createProductDiscount(1, true);

        System.runAs(runningUser){
            test.startTest();
            List<ProductDiscountCriteria__c> productDiscountCriteriaList = FW_TestDataFactory.createProductDiscountCriteria(1, true, productDiscountList[0], 'QuoteType__c', 'teste'); 
            test.stopTest();
            System.assertNotEquals(null, productDiscountCriteriaList[0].Id);
        }
    }
}