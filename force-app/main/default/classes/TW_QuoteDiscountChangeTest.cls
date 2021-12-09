/**
@author Hugo Rodrigues
@date    05/08/2021
@description Test class for TW_QuoteDiscountChange
@TestClass         
Modification Log:
----------------------------------------------------------------------------------------------------
Developer                       Date                Description                           Coverage
----------------------------------------------------------------------------------------------------
Hugo Rodrigues                   05/08/2021         Original Version                         98
Hugo Rodrigues                   28/08/2021          Adjustment on class for best pratices   98
*/
@isTest
public with sharing class TW_QuoteDiscountChangeTest {
    static fflib_ApexMocks mocks = new fflib_ApexMocks();

    @isTest
    private static void TW_QuoteDiscountChangeTest() {
        IREP_ProductDiscount productDiscountRepository = (REP_ProductDiscount)mocks.mock(REP_ProductDiscount.class);
        IREP_Quote quoteRepository = (REP_Quote)mocks.mock(REP_Quote.class);
        IREP_PricebookEntry pricebookEntryRepository = (REP_PricebookEntry)mocks.mock(REP_PricebookEntry.class);
        IDO_QuoteLineItem quoteLineItemDomain = (DO_QuoteLineItem)mocks.mock(DO_QuoteLineItem.class);
        IREP_QuoteLineItem quoteLineItemRepository = (REP_QuoteLineItem)mocks.mock(REP_QuoteLineItem.class);
        Set<ID> pricebookEntryIDSet = new Set<ID>();
        Set<ID> quoteIDSet = new Set<ID>();
        
        List<Product2> listProduct = new List<Product2>();
        listProduct.add(
            new Product2(
                Id = fflib_IDGenerator.generate(Product2.sObjectType)
            )
        );
        listProduct.add(
           
            new Product2(
                Id = fflib_IDGenerator.generate(Product2.sObjectType)
            )  
        );

        List<PricebookEntry> listPricebookEntry = new List<PricebookEntry>();
        listPricebookEntry.add(
            new PricebookEntry(
                Id = fflib_IDGenerator.generate(PricebookEntry.sObjectType),
                Product2 = listProduct[0]
            )
        );
        listPricebookEntry.add(
            
            new PricebookEntry(
                Id = fflib_IDGenerator.generate(PricebookEntry.sObjectType),
                Product2 = listProduct[1]
            )    
        );
        pricebookEntryIDSet.add(listPricebookEntry[0].ID);
        pricebookEntryIDSet.add(listPricebookEntry[1].ID);
        List<Quote> listQuote = new List<Quote>();
        listQuote.add(
            new Quote(
                Id = fflib_IDGenerator.generate(Quote.sObjectType),
                QuoteType__c = Do_Quote.QUOTE_TYPE_FLEET_PP,
                RecordTypeId = DO_Quote.QUOTE_CARDS_RECORDTYPE_ID
            )  
        );
        Map<Id, Quote> oldQuoteMap = new Map<Id, Quote>();
        oldQuoteMap.put(listQuote[0].Id, new Quote(Id = listQuote[0].Id, 
        QuoteType__c = Do_Quote.QUOTE_TYPE_FLEET_LP));

        listQuote[0].QuoteType__c = Do_Quote.QUOTE_TYPE_FLEET_PP;

        List<QuoteLineItem> listQuoteLineItem = new List<QuoteLineItem>();
        listQuoteLineItem.add(
            new QuoteLineItem(
                Id = fflib_IDGenerator.generate(QuoteLineItem.sObjectType),
                QuoteId = listQuote[0].Id,
                PricebookEntryId = listPricebookEntry[0].Id
            )
        ); 
        listQuoteLineItem.add(
            new QuoteLineItem(
                Id = fflib_IDGenerator.generate(QuoteLineItem.sObjectType),
                QuoteId = listQuote[0].Id,
                PricebookEntryId = listPricebookEntry[1].Id
            )  
        ); 

        
        
        List<Quote> newlistQuote = (List<Quote>)fflib_ApexMocksUtils.makeRelationship(
                List<Quote>.class,
                listQuote,
                QuoteLineItem.QuoteId,
            	new List<List<QuoteLineItem>> {listQuoteLineItem}
        );

        List<ProductDiscount__c> listProductDiscount = new List<ProductDiscount__c>();
        listProductDiscount.add(
            new ProductDiscount__c(
                Id = fflib_IDGenerator.generate(ProductDiscount__c.sObjectType),
                Product__r = listProduct[0],
                DiscountValue__c = 10,
                DiscountUnit__c = '€'
            )
        );
        
        
        listProductDiscount[0] = (ProductDiscount__c)fflib_ApexMocksUtils.setReadOnlyFields(
                listProductDiscount[0],
                ProductDiscount__c.class,
                new Map<SObjectField, Object> {ProductDiscount__c.QuantityOfCriteria__c => 1}
        );
        


        List<ProductDiscountCriteria__c> listProductDiscountCriteria = new List<ProductDiscountCriteria__c>();
        listProductDiscountCriteria.add(
            new ProductDiscountCriteria__c(
                Id = fflib_IDGenerator.generate(ProductDiscountCriteria__c.sObjectType),
                ProductDiscount__c = listProductDiscount[0].Id,
                ProductDiscount__r = listProductDiscount[0],
                Name = 'QuoteType__c',
                FieldValue__c = Do_Quote.QUOTE_TYPE_FLEET_PP
            )  
        );
        
        List<ProductDiscount__c> listaProductDiscount = (List<ProductDiscount__c>)fflib_ApexMocksUtils.makeRelationship(
                List<ProductDiscount__c>.class,
                listProductDiscount,
                ProductDiscountCriteria__c.ProductDiscount__c,
            	new List<List<ProductDiscountCriteria__c>> {listProductDiscountCriteria}
        );
        quoteIDSet.add(newlistQuote[0].Id);
        mocks.startStubbing();
        mocks.when(pricebookEntryRepository.getPricebookEntryInformation((Set<Id>) fflib_match.anyObject())).thenReturn(listPricebookEntry);
        mocks.when(quoteRepository.getQuoteWithItemsById((Set<Id>) fflib_match.anyObject())).thenReturn(newlistQuote);
        mocks.when(productDiscountRepository.getProductDiscountsCriteria((Set<Id>) fflib_match.anyObject())).thenReturn(listaProductDiscount);
        mocks.when(quoteLineItemDomain.isToApplyDiscountToQuoteItem((Quote) fflib_match.anyObject(), (List<ProductDiscountCriteria__c>) fflib_match.anyList(), (Integer) fflib_Match.eq(1))).thenReturn(true);
        mocks.when(quoteLineItemRepository.updateSObjects((List<QuoteLineItem>)  fflib_match.anyList())).thenReturn(new List<Database.SaveResult>());
        mocks.stopStubbing();

        TW_QuoteDiscountChange jobExecutionWorker = new TW_QuoteDiscountChange();
        jobExecutionWorker = new TW_QuoteDiscountChange(productDiscountRepository,quoteRepository, pricebookEntryRepository, quoteLineItemDomain, quoteLineItemRepository);
        
        jobExecutionWorker.execute(listQuote,oldQuoteMap);
        
        ((IREP_PricebookEntry)mocks.verify(pricebookEntryRepository, 1)).getPricebookEntryInformation((Set<Id>) fflib_match.eq(pricebookEntryIDSet));
        ((IREP_Quote)mocks.verify(quoteRepository, 1)).getQuoteWithItemsById((Set<Id>) fflib_match.eq(quoteIDSet));
        ((IREP_ProductDiscount)mocks.verify(productDiscountRepository, 1)).getProductDiscountsCriteria((Set<Id>) fflib_match.anyObject());
        ((IDO_QuoteLineItem)mocks.verify(quoteLineItemDomain, 2)).isToApplyDiscountToQuoteItem((Quote) fflib_match.anyObject(), (List<ProductDiscountCriteria__c>) fflib_match.anyList(), (Integer) fflib_Match.eq(1));
    	((IREP_QuoteLineItem)mocks.verify(quoteLineItemRepository, 1)).updateSObjects((List<QuoteLineItem>) fflib_match.anyList());

        mocks.startStubbing();
        mocks.when(quoteLineItemDomain.isToApplyDiscountToQuoteItem((Quote) fflib_match.anyObject(), (List<ProductDiscountCriteria__c>) fflib_match.anyList(), (Integer) fflib_Match.eq(1))).thenReturn(false);
        mocks.stopStubbing();

        TW_QuoteDiscountChange jobExecutionWorker2 = new TW_QuoteDiscountChange();
        jobExecutionWorker2 = new TW_QuoteDiscountChange(productDiscountRepository,quoteRepository, pricebookEntryRepository, quoteLineItemDomain, quoteLineItemRepository);
        
        jobExecutionWorker2.execute(listQuote,oldQuoteMap);
        
        ((IREP_PricebookEntry)mocks.verify(pricebookEntryRepository, 2)).getPricebookEntryInformation((Set<Id>) fflib_match.eq(pricebookEntryIDSet));
        ((IREP_Quote)mocks.verify(quoteRepository, 2)).getQuoteWithItemsById((Set<Id>) fflib_match.eq(quoteIDSet));
        ((IREP_ProductDiscount)mocks.verify(productDiscountRepository, 2)).getProductDiscountsCriteria((Set<Id>) fflib_match.anyObject());
        ((IDO_QuoteLineItem)mocks.verify(quoteLineItemDomain, 4)).isToApplyDiscountToQuoteItem((Quote) fflib_match.anyObject(), (List<ProductDiscountCriteria__c>) fflib_match.anyList(), (Integer) fflib_Match.eq(1));
    	((IREP_QuoteLineItem)mocks.verify(quoteLineItemRepository, 2)).updateSObjects((List<QuoteLineItem>) fflib_match.anyList());

    }
}