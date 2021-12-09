/**
* @description   Interface for the Contact Repository
* @testClass     N/A
* Modification Log 
* ------------------------------------------------------------------------------------  
* Developer                       Date                Description 
* Guilherme Charro              01/10/2021         Created Interface for Contact Repository
*  Hugo Rodrigues               13/10/2021          added getContactById
* Guilherme Charro             03/12/2021          Added getContactByAccountId
* ------------------------------------------------------------------------------------ 
*/
public interface IREP_Contact extends FW_ISObjectRep{
    List<Contact> getContactById(Set<Id> contactsIdSet);
    List<Contact> getContactByAccountId(Set<Id> accountsIdSet);
}