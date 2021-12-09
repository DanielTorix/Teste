@isTest
public with sharing class TW_QuoteLineItemChangeRecordTypeTest {
    static fflib_ApexMocks mocks = new fflib_ApexMocks();
    
    @isTest


    private static void TW_QuoteLineItemChangeRecordTypeTest() {

        IREP_Quote quoteRepository = (REP_Quote)mocks.mock(REP_Quote.class);
        
        List<Quote> listQuote = new List<Quote>();
        listQuote.add(
            new Quote(
                Id = fflib_IDGenerator.generate(Quote.sObjectType),
                QuoteType__c = 'Fleet PP',
                RecordTypeId = DO_Quote.QUOTE_CARDS_RECORDTYPE_ID
            )  
        );
        List<QuoteLineItem> listQuoteLineItem = new List<QuoteLineItem>();
        List<QuoteLineItem> listQuoteLineItemUpdated = new List<QuoteLineItem>();
        listQuoteLineItem.add(
            new QuoteLineItem(
                Id = fflib_IDGenerator.generate(QuoteLineItem.sObjectType),
                QuoteId = listQuote[0].Id

            )  
        ); 

        listQuoteLineItemUpdated.add(
            new QuoteLineItem(
                Id = listQuoteLineItem[0].Id,
                DiscountValue__c = 1
            )
        );
        
        List<Quote> newlistQuote = (List<Quote>)fflib_ApexMocksUtils.makeRelationship(
                List<Quote>.class,
                listQuote,
                QuoteLineItem.QuoteId,
            	new List<List<QuoteLineItem>> {listQuoteLineItem}
        );
        mocks.startStubbing();
        
        // mocks.when(quoteRepository.getQuoteByID((Set<Id>) fflib_match.anyObject())).thenReturn(listQuote);
        
        mocks.stopStubbing();

        TW_QuoteLineItemChangeRecordType jobExecutionWorker = new TW_QuoteLineItemChangeRecordType();
        jobExecutionWorker = new TW_QuoteLineItemChangeRecordType(quoteRepository);
        
        jobExecutionWorker.execute(listQuoteLineItemUpdated,new Map<ID,QuoteLineItem>(listQuoteLineItem));

        
        // ((IREP_Quote)mocks.verify(quoteRepository, 1)).getQuoteByID((Set<Id>) fflib_match.anyObject());
    }
}