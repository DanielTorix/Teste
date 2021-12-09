/**
* @description   Invoice trigger handler
* @testClass     TH_InvoiceTest
* Modification Log 
* ------------------------------------------------------------------------------------  
* Developer                       Date                Description  
* Carolina Resende             25/11/2021          Created Trigger Handler
* ------------------------------------------------------------------------------------ 
*/
public with sharing class TH_Invoice extends FW_TriggerHandler{
private List<Invoice__c> newList;
private Map<Id,Invoice__c> oldMap;

public TH_Invoice(){
    this.newList = (List<Invoice__c>) Trigger.New;
    this.oldMap = (Map<Id,Invoice__c>) Trigger.OldMap;
}

protected override void executeBeforeInsert() {
    new TW_Invoice_FillComplementaryFields().execute(newList);
}
protected override void executeAfterInsert() {
    new TW_Invoice_CreateNotification().execute(newList);
}
}