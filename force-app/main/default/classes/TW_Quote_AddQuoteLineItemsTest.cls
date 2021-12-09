/**
@author Guilherme Charro
@date   20/07/2021
@description Test class for TW_Quote_AddQuoteLineItems
@TestClass         
Modification Log:
----------------------------------------------------------------------------------------------------
Developer                       Date                Description                           Coverage
----------------------------------------------------------------------------------------------------
Guilherme Charro                20/07/2021         Original Version                         100
*/
@isTest
public with sharing class TW_Quote_AddQuoteLineItemsTest {
    static fflib_ApexMocks mocks = new fflib_ApexMocks();
    
    @isTest
    private static void TW_Quote_AddQuoteLineItemsTest() {
        IREP_PricebookEntry pricebookEntryRepository = (REP_PricebookEntry)mocks.mock(REP_PricebookEntry.class);
        IREP_QuoteLineItem quoteLineItemRepository = (REP_QuoteLineItem)mocks.mock(REP_QuoteLineItem.class);

        List<Product2> listProduct = new List<Product2>();
        listProduct.add(
            new Product2(
                Name = 'teste product',
                MandatoryQuoteType__c = 'Fleet PP',
                Family = 'Fuel'
            )  
        );

        List<Pricebook2> listPricebook = new List<Pricebook2>();
        listPricebook.add(
            new Pricebook2(
                Name = 'teste pricebook'
            )  
        );

        List<Quote> listQuote = new List<Quote>();
        listQuote.add(
            new Quote(
                Id = fflib_IDGenerator.generate(Quote.sObjectType),
                OpportunityId = fflib_IDGenerator.generate(Opportunity.sObjectType),
                Pricebook2 = listPricebook[0],
                QuoteType__c = 'Fleet PP',
                RecordTypeId = DO_Quote.QUOTE_CARDS_RECORDTYPE_ID
            )  
        );

        List<PricebookEntry> listPricebookEntry = new List<PricebookEntry>();
        listPricebookEntry.add(
            new PricebookEntry(
                Product2 = listProduct[0],
                Pricebook2 = listPricebook[0],
                UnitPrice = 5
            )  
        );

        mocks.startStubbing();
        mocks.when(pricebookEntryRepository.getMandatoryProducts((List<String>) fflib_match.anyList(), (List<String>) fflib_match.anyList())).thenReturn(listPricebookEntry);
        mocks.when(quoteLineItemRepository.insertSObjects((List<QuoteLineItem>)  fflib_match.anyList())).thenReturn(new List<Database.SaveResult>());
        mocks.stopStubbing();

        TW_Quote_AddQuoteLineItems jobExecutionWorker = new TW_Quote_AddQuoteLineItems();
        jobExecutionWorker = new TW_Quote_AddQuoteLineItems(pricebookEntryRepository, quoteLineItemRepository);
        
        jobExecutionWorker.execute(listQuote);
        
        ((IREP_PricebookEntry)mocks.verify(pricebookEntryRepository, 1)).getMandatoryProducts((List<String>) fflib_match.anyList(), (List<String>) fflib_match.anyList());
        ((IREP_QuoteLineItem)mocks.verify(quoteLineItemRepository, 1)).insertSObjects((List<QuoteLineItem>) fflib_match.anyList());
    }
}