/**
* @description   worker class to change disccount on QuoteLineItems depending on discount criteria
* @testClass     TW_QuoteDiscountChangeTest
* Modification Log 
* ------------------------------------------------------------------------------------  
* Developer                     Date                Description 
* Carolina Resende              27/08/2021          
* ------------------------------------------------------------------------------------ 
*/

public class TW_Quote_PerfilDataFromQuoteType {
    
    public TW_Quote_PerfilDataFromQuoteType(){
        
    }
    /*
* @TestVisible
private TW_Quote_PerfilDataFromQuoteType(){

}
*/
    public void execute(List<Quote> quoteList){
        //check all Quotes in the List
        /*for(Quote quoteToUpdate : quoteList){
            if(quoteToUpdate.QuoteType__c == 'Fleet PP'){
                quoteToUpdate.PriceType__c = 'Pump Price';
            }
            else if(quoteToUpdate.QuoteType__c == 'E-Mobility'){
                quoteToUpdate.PriceType__c = 'N/A';
            }
            else{
                quoteToUpdate.PriceType__c = 'List Price';
            }
            
        }*/
    }
    
}