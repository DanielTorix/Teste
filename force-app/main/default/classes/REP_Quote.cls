/**
* @description   Quote Repository
* @testClass     REP_QuoteTest
* Modification Log 
* ------------------------------------------------------------------------------------  
* Developer                       Date                Description 
* Hugo Rodrigues               25/06/2021          Created Quote Repository
* ------------------------------------------------------------------------------------ 
*/
public class REP_Quote extends FW_SobjectRep implements IREP_Quote{

    public static final List<SObjectField> QUOTE_FIELDS = new SObjectField[] {
        Quote.Id,
        Quote.Name,
        Quote.ValidityDate__c,
        Quote.Status ,
        Quote.ClosedDate__c,
        Quote.OpportunityId,
        Quote.OwnerId
        
    };

    List<String> quoteFields = new List<String>(Schema.getGlobalDescribe().get('Quote').getDescribe().fields.getMap().keySet());

    public List<Quote> getQuoteByID(Set<ID> quoteIdSet) {

        return [SELECT iD,OwnerId, Name, ValidityDate__c, Status,OpportunityId,Opportunity.TotalPotentialFuelVolume__c, RecordTypeID   
                From Quote 
                Where Id=:quoteIdSet];

    }

    public List<Quote> getQuoteByOpportunityID(Set<ID> qopportunityIdSet) {

        return [SELECT iD,OwnerId, Name,Status, ValidityDate__c,OpportunityId,ClosedDate__c  
                From Quote 
                Where OpportunityId=:qopportunityIdSet];

    }
    

    public List<Quote> getCardsQuotes(Set<ID> quoteIdSet) {
        Set<ID> quoteCardsIdSet = new Set<ID>();
        quoteCardsIdSet.add(DO_Quote.QUOTE_CARDS_RECORDTYPE_ID);
        quoteCardsIdSet.add(DO_Quote.QUOTE_CARDS_WITH_APPROVAL_RECORDTYPE_ID);
        return (List<Quote>)Database.query('SELECT '+String.join(quoteFields, ',')+
        +' FROM Quote WHERE Id IN :quoteIdSet AND RecordTypeId IN :quoteCardsIdSet');
    }

    public List<Quote> getQuoteWithItemsById(Set<ID> quoteIdSet){
        String query ='SELECT '+String.join(quoteFields, ',')+ 
        ',(SELECT Id, PricebookEntry.Product2Id,QuoteId, DiscountValue__c  FROM QuoteLineItems) FROM Quote WHERE Id IN :quoteIdSet';
        return Database.query(query);
    }
    
}