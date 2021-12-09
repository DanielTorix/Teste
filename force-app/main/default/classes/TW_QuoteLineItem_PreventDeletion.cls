/**
* @description   worker class to prevent quote item deletion
* @testClass     TW_QuoteLineItem_PreventDeletionTest
* Modification Log 
* ------------------------------------------------------------------------------------  
* Developer                       Date                Description 
* David Favinha               04/08/2021          Created QuoteLineItem Worker
* ------------------------------------------------------------------------------------ 
*/
public with sharing class TW_QuoteLineItem_PreventDeletion {
    public void execute(Map<Id,QuoteLineItem>  quoteLineItemList){
        for (QuoteLineItem quoteLineItemDeleted : quoteLineItemList.values()) {
            if (quoteLineItemDeleted.IsMandatoryProduct__c==true) {
                quoteLineItemDeleted.addError(Label.ApexPreventQuoteLineItemDeletion);
            }
        }
    }
}