/**
    * @description   Batch Definition trigger handler
    * @testClass     FW_TH_BatchDefinitionTest
    * Modification Log 
	* ------------------------------------------------------------------------------------  
	* Developer                       Date                Description  
    * ------------------------------------------------------------------------------------ 
*/
public class FW_TH_BatchDefinition extends FW_TriggerHandler {

    private List<Batch_Definition__c> newList;

    public FW_TH_BatchDefinition(){
        this.newList = (List<Batch_Definition__c>) Trigger.New;
    }

    protected override void executeAfterInsert() {
        new FW_TW_BatchDefinition_DefaultParam().execute(newList);
    }

}