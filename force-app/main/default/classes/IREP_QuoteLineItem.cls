/**
* @description   Interface for QuoteLineItem Repository
* @testClass     
* Modification Log 
* ------------------------------------------------------------------------------------  
* Developer                       Date                Description 
* Guilherme Charro                29/07/2021          Created QuoteLineItem Repository interface
* ------------------------------------------------------------------------------------ 
*/
public interface IREP_QuoteLineItem extends FW_ISObjectRep{
    List<QuoteLineItem> getQuoteLineItemInfo(Set<Id> quoteLineItemsIdSet);
}