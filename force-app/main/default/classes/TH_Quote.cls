/**
* @description   Quote trigger handler class 
* @testClass     TH_QuoteTest
* Modification Log 
* ------------------------------------------------------------------------------------  
* Developer                       Date                Description 
* Hugo Rodrigues               06/06/2021          Created Quote Trigger handler
* Hugo Rodrigues               23/07/2021          Updated Quote Trigger Handler
* Carolina Resende             27/08/2021          Updated Quote Trigger Handler
* ------------------------------------------------------------------------------------ 
*/
public class TH_Quote extends FW_TriggerHandler{

    private List<Quote> newList;
    private Map<Id,Quote> oldMap;
    
    //create a new List a an old Map to use on the worker
    public TH_Quote() {
        this.newList = (List<Quote>) Trigger.New;
        this.oldMap = (Map<Id,Quote>) Trigger.OldMap;
    }
   
    protected override void executeBeforeUpdate() {
        
        //calling the worker and sending the List and the Map
       new TW_Quote_UpdateCloseDate().execute(newList, oldMap);
       new TW_QuoteRecordTypeChange().execute(newList, oldMap);
       new TW_Quote_PerfilVolumeFuelBand().execute(newList, oldMap);       
   }
   
    protected override void executeBeforeInsert() {  
       
        //calling the worker and sending the List and the Map
        new TW_Quote_UpdateCloseDate().execute(newList, null);
        new TW_QuoteRecordTypeChange().execute(newList, null);
        new TW_QuoteUpdateTotalFuelField().execute(newList);     
        new TW_Quote_PerfilVolumeFuelBand().execute(newList, null);
    }

    protected override void executeAfterInsert() {  
       
        //calling the worker and sending the List
        new TW_Quote_AddQuoteLineItems().execute(newList);
        new TW_Quote_SetContactRelatedActivity().execute(newList);      
    }
    
    protected override void executeAfterUpdate(){

         //calling the worker and sending the List
         new TW_QuoteDiscountChange().execute(newList,oldMap);
         new TW_Quote_SetContactRelatedActivity().execute(newList);
    }
  
}