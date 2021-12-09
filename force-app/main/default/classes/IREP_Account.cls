/**
* @description   Interface for the Account Repository
* @testClass     N/A
* Modification Log 
* ------------------------------------------------------------------------------------  
* Developer                       Date                Description 
* Hugo Rodrigues                25/08/2021          Interface for the Account Repository
* Carolina Resende              25/11/2021          getAccountFromInvoice method added
* ------------------------------------------------------------------------------------ 
*/
public interface IREP_Account extends FW_ISObjectRep{
    List<Account> getAccountsById(Set<Id> accountsIds);
    List<Account> getAccountCompanyCode(Set<Id> accountsIds);
    Map<Id,Account> getAccountFromInvoice(Set<Id> accountIdSet);
}