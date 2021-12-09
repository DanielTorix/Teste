@isTest
public with sharing class TW_QuoteLineItem_PreventDeletionTest {
    static fflib_ApexMocks mocks = new fflib_ApexMocks();

    @isTest
    private static void TW_QuoteLineItem_PreventDeletionTest() {
        List<QuoteLineItem> listQuoteLineItem = new List<QuoteLineItem>();
        listQuoteLineItem.add(
            new QuoteLineItem(
                Id = fflib_IDGenerator.generate(QuoteLineItem.sObjectType),
                IsMandatoryProduct__c=true
            )  
        ); 
        Map <Id,QuoteLineItem> quoteLineItemMap = new Map<Id,QuoteLineItem> {listQuoteLineItem[0].Id=>listQuoteLineItem[0]};

        mocks.startStubbing();
        mocks.stopStubbing();

        TW_QuoteLineItem_PreventDeletion jobExecutionWorker = new TW_QuoteLineItem_PreventDeletion();
        jobExecutionWorker = new TW_QuoteLineItem_PreventDeletion();
        
        jobExecutionWorker.execute(quoteLineItemMap);
    }
}