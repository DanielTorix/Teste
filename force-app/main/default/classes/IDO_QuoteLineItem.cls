/**
* @description   interface for QuoteLineItem domain object class
* @testClass     
* Modification Log 
* ------------------------------------------------------------------------------------  
* Developer                       Date                Description 
* Guilherme Charro                03/08/2021          Created QuoteLineItem domain interface
* ------------------------------------------------------------------------------------ 
*/
public interface IDO_QuoteLineItem {
    Boolean isToApplyDiscountToQuoteItem(Quote quoteInfo, List<ProductDiscountCriteria__c> criteriasList, Integer quantityOfCriterias);
}