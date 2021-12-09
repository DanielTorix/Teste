/**
* @description   QuoteLineItem Repository
* @testClass     REP_QuoteLineItemTest
* Modification Log 
* ------------------------------------------------------------------------------------  
* Developer                       Date                Description 
* Guilherme Charro                29/07/2021          Created QuoteLineItem Repository
* ------------------------------------------------------------------------------------ 
*/
public class REP_QuoteLineItem extends FW_SobjectRep implements IREP_QuoteLineItem{
    public List<QuoteLineItem> getQuoteLineItemInfo(Set<Id> quoteLineItemsIdSet){
        return [SELECT Id, PricebookEntry.Product2Id, Quote.QuoteType__c, Quote.CompetitiveBandFuel__c, Quote.FuelVolumeBand__c 
                FROM QuoteLineItem 
                WHERE Quote.RecordTypeId = :DO_Quote.QUOTE_CARDS_RECORDTYPE_ID 
                AND Id IN :quoteLineItemsIdSet];
    }
}