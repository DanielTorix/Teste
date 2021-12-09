/**
* @description   Pricebook Entry Repository
* @testClass     REP_PricebookEntryTest
* Modification Log 
* ------------------------------------------------------------------------------------  
* Developer                       Date                Description 
* Guilherme Charro                21/07/2021          Created Pricebook Entry Repository
* ------------------------------------------------------------------------------------ 
*/
public class REP_PricebookEntry extends FW_SobjectRep implements IREP_PricebookEntry{
    public List<PricebookEntry> getMandatoryProducts(List<String> quoteTypes, List<String> pricebookIds){
        String types = '(\'' + String.join(quoteTypes, '\',\'') + '\')';
        String query = 'SELECT Id, Product2Id, UnitPrice, Pricebook2Id, Product2.MandatoryQuoteType__c, Product2.Family FROM PricebookEntry WHERE Product2.MandatoryQuoteType__c INCLUDES '+types+' AND Pricebook2Id IN :pricebookIds';
        return (List<PricebookEntry>)Database.query(query);
    }

    public List<PricebookEntry> getPricebookEntryInformation(Set<Id> pricebookEntryIdSet){
        return [SELECT Id, Product2Id FROM PricebookEntry WHERE Id IN :pricebookEntryIdSet];
    }
}