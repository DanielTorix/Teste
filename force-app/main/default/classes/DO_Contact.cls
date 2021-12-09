/**
* @description   Contact domain object class
* @testClass     DO_ContactTest
* Modification Log 
* ------------------------------------------------------------------------------------  
* Developer                       Date                Description 
* Guilherme Charro                01/19/2021          Created Contact domain
* ------------------------------------------------------------------------------------ 
*/
public class DO_Contact implements IDO_Contact{
    public final static String Contact_GDPR_NO = 'No';
    public final static String Contact_GDPR_YES = 'Yes';
    public final static String CONTACT_RECORDTYPE_CEPCARDS = 'CEPCardsContact';
    public final static Id CONTACT_RECORDTYPEID_CEPCARDS = Schema.SObjectType.Contact.getRecordTypeInfosByDeveloperName().get(CONTACT_RECORDTYPE_CEPCARDS).getRecordTypeId();

    /**
    * @description method to create new Contact record so that it can update an existing one
    * @author Guilherme Charro | 01-10-2021 
    * @param id Id of the Contact to copy so that it can be updated
    * @return Contact return the new created Contact
    **/
    public Contact createContact(Id id){
        Contact contactToReturn = new Contact(
            Id = id,
            FirstName = System.Label.ContactCheckGDPR,
            LastName = System.Label.ContactCheckGDPR2+' '+Date.today().format(),
            MobilePhone = '',
            OtherPhone = '',
            Email = ''
        );

        return contactToReturn;
    }
}