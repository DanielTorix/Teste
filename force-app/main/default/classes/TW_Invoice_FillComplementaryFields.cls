/**
@description    worker class to automatically fill Invoice Source
@testClass      TW_Invoice_ComplementaryFieldsTest
* Modification Log 
* ------------------------------------------------------------------------------------  
* Developer                       Date                Description  
* Carolina Resende              25/11/2021          Created the class
* ------------------------------------------------------------------------------------        
*/
public with sharing class TW_Invoice_FillComplementaryFields {

private IREP_Account accountRepository;

public TW_Invoice_FillComplementaryFields(){
    this.accountRepository = new REP_Account();
}

@TestVisible
private TW_Invoice_FillComplementaryFields(IREP_Account accountRepository){
    this.accountRepository = accountRepository;
}

public void execute(List<Invoice__c> invoiceList) {
    Set<Id> accountIdSet = new Set<Id>();
    Map<Id,Account> accountMapByID = new Map<Id,Account>();
    for (Invoice__c invoice : invoiceList) {
        accountIdSet.add(invoice.Account__c); 
    }
    if (!accountIdSet.isEmpty()) {
        accountMapByID = accountRepository.getAccountFromInvoice(accountIdSet);
    }
    for (Invoice__c invoice : invoiceList) {
        invoice.BillingEmail__c = accountMapByID.get(invoice.Account__c).BillingEmail__c;
    }
} 
}