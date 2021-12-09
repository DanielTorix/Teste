@isTest
public with sharing class DO_QuoteLineItemTest {
    @isTest
    static void DO_QuoteLineItemTest() {
            List<Quote> listQuote = new List<Quote>();
            listQuote.add(
                new Quote(
                    Id = fflib_IDGenerator.generate(Quote.sObjectType),
                    QuoteType__c = 'Fleet PP'
                )  
            );

            List<ProductDiscount__c> listProductDiscount = new List<ProductDiscount__c>();
            listProductDiscount.add(
                new ProductDiscount__c(
                    Id = fflib_IDGenerator.generate(ProductDiscount__c.sObjectType)
                )  
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

            List<ProductDiscountCriteria__c> listProductDiscountCriteria2 = new List<ProductDiscountCriteria__c>();
            listProductDiscountCriteria.add(
                new ProductDiscountCriteria__c(
                    Id = fflib_IDGenerator.generate(ProductDiscountCriteria__c.sObjectType),
                    ProductDiscount__c = listProductDiscount[0].Id,
                    ProductDiscount__r = listProductDiscount[0],
                    Name = 'QuoteType__c',
                    FieldValue__c = 'Fleet LP'
                )
            );

            test.startTest();
            DO_QuoteLineItem quoteLineItemDomain = new DO_QuoteLineItem();
            Boolean isToApplyDiscountToQuoteItem = quoteLineItemDomain.isToApplyDiscountToQuoteItem(listQuote[0], listProductDiscountCriteria, 1);
            Boolean isToApplyDiscountToQuoteItem2 = quoteLineItemDomain.isToApplyDiscountToQuoteItem(listQuote[0], listProductDiscountCriteria2, 1);
            test.stopTest();
            System.assertEquals(true, isToApplyDiscountToQuoteItem);
            System.assertEquals(false, isToApplyDiscountToQuoteItem2);
    }
}