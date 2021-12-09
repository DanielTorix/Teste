@isTest
public with sharing class REP_PricebookEntryTest {
    @isTest
    static void REP_PricebookEntryTest() {
        User runningUser = FW_TestDataFactory.createUsers(1, true, 'System Administrator', null).get(0);
        System.runAs(runningUser){
            List<Product2> listProduct = FW_TestDataFactory.createProduct(1, true);

            Id pricebookId = Test.getStandardPricebookId();

            List<String> pricebookIds = new List<String>();
            pricebookIds.add(pricebookId);

            Set<Id> pricebookEntryIds = new Set<Id>();
            pricebookEntryIds.add(pricebookId);

            List<PricebookEntry> listPricebooks = FW_TestDataFactory.createPricebookEntry(1, true, pricebookIds[0], listProduct[0].Id);

            List<String> quoteTypes = new List<String>();
            String type = 'Fleet PP';
            quoteTypes.add(type);
            
            test.startTest();
                REP_PricebookEntry pricebookEntryRepository = new REP_PricebookEntry();
                List<PricebookEntry> pricebookInfosReturned = pricebookEntryRepository.getPricebookEntryInformation(pricebookEntryIds);
                List<PricebookEntry> pricebookReturned = pricebookEntryRepository.getMandatoryProducts(quoteTypes, pricebookIds);
            test.stopTest();
            System.assertEquals(1, pricebookReturned.size());
            System.assertEquals(0, pricebookInfosReturned.size());
        }
    }
}