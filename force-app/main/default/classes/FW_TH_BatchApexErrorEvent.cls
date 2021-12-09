/**
    * @description   BatchApexErrorEvent After trigger handler
    * @testClass     FW_TH_BatchApexErrorEventTest
    * Modification Log 
	* ------------------------------------------------------------------------------------  
	* Developer                       Date                Description  
    * ------------------------------------------------------------------------------------ 
*/
public class FW_TH_BatchApexErrorEvent extends FW_TriggerHandler{

    private List<BatchApexErrorEvent> newList;

    public FW_TH_BatchApexErrorEvent(){
        this.newList = (List<BatchApexErrorEvent>) Trigger.New;
    }
    
    protected override void executeAfterInsert() {
        new FW_TW_BatchApexErrorEventLog().execute(newList);
    }
    
}