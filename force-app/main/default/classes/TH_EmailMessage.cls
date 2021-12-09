public class TH_EmailMessage extends FW_TriggerHandler{
    public List<EmailMessage> newList;
    public Map<Id, EmailMessage> oldMap;

    public TH_EmailMessage(){
        this.newList = (List<EmailMessage>) Trigger.New;
        this.oldMap = (Map<Id,EmailMessage>) Trigger.OldMap;
    }

    protected override void executeAfterInsert() {
        //calling the worker and sending the List and the Map
       new TW_EmailMessage_CheckCaseEmails().execute(newList);
    }
    protected override void executeBeforeInsert() {
        //calling the worker and sending the List and the Map
       new TW_EmailMessage_PreventLoops().execute(newList);
    }

}