/**
* @description   worker class to update TotalPotentialFuelVolume__c on Quote when the TotalPotentialFuelVolume__c is null
* @testClass     TW_QuoteUpdateTotalFuelFieldTest
* Modification Log 
* ------------------------------------------------------------------------------------  
* Developer                       Date                Description 
* Hugo Rodrigues               23/06/2021          Created Quote Worker
* ------------------------------------------------------------------------------------ 
*/
public without sharing  class TW_QuoteUpdateTotalFuelField {
    private IREP_Opportunity oppRepository;
    private IREP_Quote quoteRepository;
    
    //constructor
     public TW_QuoteUpdateTotalFuelField(){
         this.oppRepository = new REP_Opportunity();
         this.quoteRepository = new REP_Quote();
         
      
    }
    //to use on test
    @TestVisible
    private TW_QuoteUpdateTotalFuelField(IREP_Opportunity oppRepository,IREP_Quote quoteRepository){
        this.oppRepository = oppRepository;
        this.quoteRepository = quoteRepository;
       
        
    }
     //Method Execute
     public void execute(List<Quote> quoteList){
        
        Set<ID> quoteWithOpportunityFieldID = new  Set<ID>();
        List<Opportunity> opportunityList = new List<Opportunity>();
        
        //check all Quotes in the List
        for(Quote quoteToUpdate : quoteList){
            
            if(quoteToUpdate.TotalPotentialFuelVolume__c ==null){
                quoteWithOpportunityFieldID.add(quoteToUpdate.OpportunityID);
            }
            
            
        }
        if(!quoteWithOpportunityFieldID.isEmpty()){
            opportunityList=oppRepository.getOpportunityByID(quoteWithOpportunityFieldID);

            Map<ID,Opportunity> oppMap = new Map<Id,Opportunity>(opportunityList);

            for(Quote quoteToUpdate : quoteList){
                if(oppMap.containsKey(quoteToUpdate.Id)){
                    quoteToUpdate.TotalPotentialFuelVolume__c = oppMap.get(quoteToUpdate.OpportunityID).TotalPotentialFuelVolume__c;
                }
            }
        }
        
        
    }
     
}