/**
@author Guilherme Charro
@date    08/10/2021
@description Test class for DO_Contact
@TestClass         
Modification Log:
----------------------------------------------------------------------------------------------------
Developer                       Date                Description                           Coverage
----------------------------------------------------------------------------------------------------
Guilherme Charro                08/10/2021         Original Version                         100
*/
@isTest
private class DO_ContactTest {
    @isTest
    static void DO_ContactTest() {
        List<Contact> contactList = new List<Contact>{
            new Contact(
                Id = fflib_IDGenerator.generate(Contact.sObjectType)
            )
        };

        test.startTest();
        DO_Contact contactDomain = new DO_Contact();
        Contact returnedContact = contactDomain.createContact(contactList[0].Id);
        test.stopTest();
        System.assertEquals(contactList[0].Id, returnedContact.Id);
    }
}