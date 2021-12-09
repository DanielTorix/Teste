/**
* @description   worker class to update CloseDate on Quote when the Quote is Accepted or Denied
* @testClass     TW_Quote_UpdateCloseDateTest
* Modification Log 
* ------------------------------------------------------------------------------------  
* Developer                       Date                Description 
* Hugo Rodrigues               06/06/2021          Created Quote Worker
* ------------------------------------------------------------------------------------ 
*/
public without sharing class TW_Quote_UpdateCloseDate {
    private IREP_Quote quoteRepository;
    private IDO_Quote quoteDomain;
    
    //constructor
     public TW_Quote_UpdateCloseDate(){
         this.quoteRepository = new REP_Quote();
         this.quoteDomain = new DO_Quote();
      
    }
    
    //to use on test
    @TestVisible
    private TW_Quote_UpdateCloseDate(IREP_Quote quoteRepository, IDO_Quote quoteDomain){
        this.quoteRepository = quoteRepository;
        this.quoteDomain = quoteDomain;
        
    }

    //Method Execute
    public void execute(List<Quote> quoteList, Map<Id,Quote> quoteOldMap){

        
          //check all Quotes in the List
          for(Quote quoteToUpdate : quoteList){
              if(quoteOldMap==null){
                  //if the Status is Denied or Accepted
                if(quoteToUpdate.Status == DO_Quote.QUOTE_STATUS_ACCEPTED || quoteToUpdate.Status == DO_Quote.QUOTE_STATUS_DENIED ){
                   
                    quoteToUpdate.ClosedDate__c = Date.today();
                }
              }
            else {
                //if the Status changed
                if(quoteToUpdate.Status != quoteOldMap.get(quoteToUpdate.Id).Status){
                
                    //if the Status is Denied or Accepted
                    if(quoteToUpdate.Status == DO_Quote.QUOTE_STATUS_ACCEPTED || quoteToUpdate.Status == DO_Quote.QUOTE_STATUS_DENIED ){
                   
                        quoteToUpdate.ClosedDate__c = Date.today();
                    }
                }
            }
        }
        
        

    }
}