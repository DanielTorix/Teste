/**
* @description   Invoice Trigger   
* Modification Log 
* ------------------------------------------------------------------------------------  
* Developer                       Date                Description 
* Carolina Resende                25/11/2021          Created Invoice Trigger
* ------------------------------------------------------------------------------------ 
*/

trigger InvoiceTrigger on Invoice__c (before insert, after insert) {
    new TH_Invoice().execute();
}