@isTest
public with sharing class REP_ProductDiscountTest {
    @isTest
    static void ProductDiscountTest() {
        User runningUser = FW_TestDataFactory.createUsers(1, true, 'System Administrator', null).get(0);
        System.runAs(runningUser){  
            List<Product2> productList = FW_TestDataFactory.createProduct(1, true);
            Set<Id> productsId = new Set<Id>();
            productsId.add(productList[0].Id);

            List<ProductDiscount__c> productDiscountList = FW_TestDataFactory.createProductDiscount(1, false);
            productDiscountList[0].Product__c = productList[0].Id;
            insert productDiscountList;

            test.startTest();
            REP_ProductDiscount productDiscountRepository = new REP_ProductDiscount();
            List<ProductDiscount__c> productDiscountReturned = productDiscountRepository.getProductDiscountsCriteria(productsId);
            test.stopTest();
            System.assertEquals(1, productDiscountReturned.size());
        }
    }
}