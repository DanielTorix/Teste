/**
@author David Favinha
@date    24/11/2021
@description Test class for TW_Contact_FillComplementaryFields
@TestClass         
Modification Log:
----------------------------------------------------------------------------------------------------
Developer                       Date                Description                           Coverage
----------------------------------------------------------------------------------------------------
David Favinha                24/11/2021            Original Version                         100
*/
@isTest
public class TW_Contact_FillComplementaryFieldsTest {
	static fflib_ApexMocks mocks = new fflib_ApexMocks();

    @isTest
    static void FillComplementaryFieldsTest() {
        List<Contact> contactList = new List<Contact>{
            new Contact(
                Id = fflib_IDGenerator.generate(Contact.sObjectType),
                Phone = '123456789',
                MobilePhone = '987654321',
                OtherPhone = '198765432'
            )
        };
            
        List<Contact> otherContactList = new List<Contact>{
            new Contact(
                Id = fflib_IDGenerator.generate(Contact.sObjectType),
                Phone = '123456789',
                MobilePhone = '456456456',
                OtherPhone = '198765432'
            )
        };
            
        Map<Id,Contact> oldContactMap = new Map<Id,Contact>();
        oldContactMap.put(contactList[0].Id, otherContactList[0]);
        
        TW_Contact_FillComplementaryFields jobExecutionWorker = new TW_Contact_FillComplementaryFields();
        jobExecutionWorker = new TW_Contact_FillComplementaryFields();
        
        jobExecutionWorker.execute(contactList, oldContactMap);
    }
}