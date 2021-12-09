/**
* @description   Invoice Repository
* @testClass     REP_InvoiceTest
* Modification Log 
* ------------------------------------------------------------------------------------  
* Developer                       Date                Description 
* Carolina Resende               28/11/2021          Created Invoice Repository
* ------------------------------------------------------------------------------------ 
*/
public  class REP_Invoice extends FW_SobjectRep implements IREP_Invoice{  
    public static final List<SObjectField> INVOICE_FIELDS = new SObjectField[] {
        Invoice__c.Id,
        Invoice__c.SendRemainder__c,
        Invoice__c.DueDate__c,
        Invoice__c.Account__c
    };
}