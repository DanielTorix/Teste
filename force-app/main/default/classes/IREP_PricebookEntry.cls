/**
* @description   Interface for the Pricebook Entry Repository
* @testClass     N/A
* Modification Log 
* ------------------------------------------------------------------------------------  
* Developer                       Date                Description 
* Guilherme Charro                21/07/2021          Interface for the Pricebook Entry Repository
* ------------------------------------------------------------------------------------ 
*/
public interface IREP_PricebookEntry extends FW_ISObjectRep{
    List<PricebookEntry> getMandatoryProducts(List<String> quoteTypes, List<String> pricebookIds);
    List<PricebookEntry> getPricebookEntryInformation(Set<Id> pricebookEntryIdSet);
}