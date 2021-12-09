/**
* @description   Interface for the Quote Repository
* @testClass     N/A
* Modification Log 
* ------------------------------------------------------------------------------------  
* Developer                       Date                Description 
* Hugo Rodrigues                25/06/2021          Interface for the Quote Repository
* ------------------------------------------------------------------------------------ 
*/
public interface IREP_Quote extends FW_ISObjectRep{
    List<Quote> getQuoteByID(Set<ID> quoteIdSet);
    List<Quote> getQuoteByOpportunityID(Set<ID> qopportunityIdSet);
    List<Quote> getCardsQuotes(Set<ID> quoteIdSet);
    List<Quote> getQuoteWithItemsById(Set<ID> quoteIdSet);   
   
}