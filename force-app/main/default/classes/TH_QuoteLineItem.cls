/**
* @description   QuoteLineItem trigger handler
* @testClass     TH_QuoteLineItemTest
* Modification Log 
* ------------------------------------------------------------------------------------  
* Developer                       Date                Description  
* Guilherme Charro                28/07/2021          Created QuoteLineItem Handler
* ------------------------------------------------------------------------------------ 
*/
public class TH_QuoteLineItem extends FW_TriggerHandler{
    private List<QuoteLineItem> newList;
    private Map<Id,QuoteLineItem> oldMap;

    public TH_QuoteLineItem(){
        this.newList = (List<QuoteLineItem>) Trigger.New;
        this.oldMap = (Map<Id,QuoteLineItem>) Trigger.OldMap;
    }

    protected override void executeBeforeInsert() {
        new TW_QuoteLineItem_AddDiscounts().execute(newList);
        
    }
    protected override void executeAfterUpdate() {
        new TW_QuoteLineItemChangeRecordType().execute(newList,OldMap);
    }

    protected override void executeBeforeDelete() {
        new TW_QuoteLineItem_PreventDeletion().execute(oldMap);
    }
}