/**
* @description   Contact Repository
* @testClass     REP_ContactTest
* Modification Log 
* ------------------------------------------------------------------------------------  
* Developer                       Date                Description 
* Guilherme Charro              01/10/2021         Created Contact Repository
* Hugo Rodrigues               13/10/2021          added getContactById
* Guilherme Charro             03/12/2021          Added getContactByAccountId
* ------------------------------------------------------------------------------------ 
*/
public class REP_Contact extends FW_SobjectRep implements IREP_Contact{
    public static final List<SObjectField> CONTACT_FIELDS = new SObjectField[] {
        Contact.Id,
        Contact.Name,
        Contact.LastModifiedDate,
        Contact.OwnerId,
        Contact.RelatedActivityDate__c
    };
     public List<Contact> getContactById(Set<Id> contactsIdSet){
        return [SELECT Id,Title ,MobilePhone,OtherPhone, RecordTypeId FROM Contact WHERE Id IN :contactsIdSet];
    }

    public List<Contact> getContactByAccountId(Set<Id> accountsIdSet){
        return [SELECT Id, AccountId FROM Contact WHERE AccountId IN :accountsIdSet];
    }
}