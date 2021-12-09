@isTest
public with sharing class TH_QuoteLineItemTest {
    static fflib_ApexMocks mocks = new fflib_ApexMocks();
    @isTest
    static void TH_QuoteLineItemTest() {
        User runningUser = FW_TestDataFactory.createUsers(1, true, 'System Administrator', null).get(0);
        System.runAs(runningUser){  
            Id pricebookId = Test.getStandardPricebookId();

            List<Quote> quoteList = FW_TestDataFactory.createQuote(1, false);
            quoteList[0].Pricebook2Id = pricebookId;
            insert quoteList;

            List<Product2> productList = FW_TestDataFactory.createProduct(1, true);
            

            List<PricebookEntry> pricebookEntryList = FW_TestDataFactory.createPricebookEntry(1, true, pricebookId, productList[0].Id);

            List<QuoteLineItem> quoteLineItemList = new List<QuoteLineItem>();
            
            User adminUser = FW_TestDataFactory.createUsers(1, true, 'System Administrator', null).get(0);
            
            test.startTest();
            System.runAs(adminUser){
               
                quoteLineItemList = FW_TestDataFactory.createQuoteLineItem(1, true, quoteList[0], pricebookEntryList[0]);
                
                quoteLineItemList.get(0).DiscountValue__c = 2;
                update quoteLineItemList;

                delete quoteLineItemList;
            }
            test.stopTest();
            System.assertNotEquals(null, quoteLineItemList[0].Id);
            System.assertEquals(0, [SELECT Id  FROM QuoteLineItem].size());
        }
    }
}