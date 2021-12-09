@isTest
public with sharing class TW_ProductDiscountCriteria_CheckAPITest {
    static fflib_ApexMocks mocks = new fflib_ApexMocks();

    @isTest
    private static void TW_ProductDiscountCriteria_CheckAPITest() {
        List<ProductDiscountCriteria__c> productDiscountCriteriaList = new List<ProductDiscountCriteria__c>();
        productDiscountCriteriaList.add(
            new ProductDiscountCriteria__c(
                Id = fflib_IDGenerator.generate(ProductDiscountCriteria__c.sObjectType),
                Name = 'teste API errado'
            )  
        ); 

        mocks.startStubbing();
        mocks.stopStubbing();

        TW_ProductDiscountCriteria_CheckAPIName jobExecutionWorker = new TW_ProductDiscountCriteria_CheckAPIName();
        jobExecutionWorker = new TW_ProductDiscountCriteria_CheckAPIName();
        
        jobExecutionWorker.execute(productDiscountCriteriaList);
    }
}