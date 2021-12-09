/**
@author Guilherme Charro
@date   28/07/2021
@description Test class for TW_QuoteLineItem_AddDiscounts
@TestClass         
Modification Log:
----------------------------------------------------------------------------------------------------
Developer                       Date                Description                           Coverage
----------------------------------------------------------------------------------------------------
Guilherme Charro                28/07/2021         Original Version                         97
*/
@isTest
public with sharing class TW_QuoteLineItem_AddDiscountsTest {
    static fflib_ApexMocks mocks = new fflib_ApexMocks();

    @isTest
    private static void TW_QuoteLineItem_AddDiscountsTest() {
        IREP_ProductDiscount productDiscountRepository = (REP_ProductDiscount)mocks.mock(REP_ProductDiscount.class);
        IREP_Quote quoteRepository = (REP_Quote)mocks.mock(REP_Quote.class);
        IREP_PricebookEntry pricebookEntryRepository = (REP_PricebookEntry)mocks.mock(REP_PricebookEntry.class);
        IDO_QuoteLineItem quoteLineItemDomain = (DO_QuoteLineItem)mocks.mock(DO_QuoteLineItem.class);

        List<Product2> listProduct = new List<Product2>();
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

        List<Quote> listQuote = new List<Quote>();
        listQuote.add(
            new Quote(
                Id = fflib_IDGenerator.generate(Quote.sObjectType),
                QuoteType__c = 'Fleet PP'
            )  
        );

        List<QuoteLineItem> listQuoteLineItem = new List<QuoteLineItem>();
        listQuoteLineItem.add(
            new QuoteLineItem(
                Id = fflib_IDGenerator.generate(QuoteLineItem.sObjectType),
                QuoteId = listQuote[0].Id,
                PricebookEntryId = listPricebookEntry[0].Id
            )  
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
                FieldValue__c = 'Fleet PP'
            )  
        );
        
        List<ProductDiscount__c> listaProductDiscount = (List<ProductDiscount__c>)fflib_ApexMocksUtils.makeRelationship(
                List<ProductDiscount__c>.class,
                listProductDiscount,
                ProductDiscountCriteria__c.ProductDiscount__c,
            	new List<List<ProductDiscountCriteria__c>> {listProductDiscountCriteria}
        );

        mocks.startStubbing();
        mocks.when(pricebookEntryRepository.getPricebookEntryInformation((Set<Id>) fflib_match.anyObject())).thenReturn(listPricebookEntry);
        mocks.when(quoteRepository.getCardsQuotes((Set<Id>) fflib_match.anyObject())).thenReturn(listQuote);
        mocks.when(productDiscountRepository.getProductDiscountsCriteria((Set<Id>) fflib_match.anyObject())).thenReturn(listaProductDiscount);
        mocks.when(quoteLineItemDomain.isToApplyDiscountToQuoteItem((Quote) fflib_match.anyObject(), (List<ProductDiscountCriteria__c>) fflib_match.anyList(), (Integer) fflib_Match.eq(1))).thenReturn(true);
        mocks.stopStubbing();

        TW_QuoteLineItem_AddDiscounts jobExecutionWorker = new TW_QuoteLineItem_AddDiscounts();
        jobExecutionWorker = new TW_QuoteLineItem_AddDiscounts(productDiscountRepository, quoteRepository, pricebookEntryRepository, quoteLineItemDomain);
        
        jobExecutionWorker.execute(listQuoteLineItem);
        
        ((IREP_PricebookEntry)mocks.verify(pricebookEntryRepository, 1)).getPricebookEntryInformation((Set<Id>) fflib_match.anyObject());
        ((IREP_Quote)mocks.verify(quoteRepository, 1)).getCardsQuotes((Set<Id>) fflib_match.anyObject());
        ((IREP_ProductDiscount)mocks.verify(productDiscountRepository, 1)).getProductDiscountsCriteria((Set<Id>) fflib_match.anyObject());
        ((IDO_QuoteLineItem)mocks.verify(quoteLineItemDomain, 1)).isToApplyDiscountToQuoteItem((Quote) fflib_match.anyObject(), (List<ProductDiscountCriteria__c>) fflib_match.anyList(), (Integer) fflib_Match.eq(1));
    }
}