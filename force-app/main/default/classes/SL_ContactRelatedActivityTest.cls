/**
@author Guilherme Charro
@date    12/11/2021
@description Test class for SL_ContactRelatedActivity
@TestClass         
Modification Log:
----------------------------------------------------------------------------------------------------
Developer                       Date                Description                           Coverage
----------------------------------------------------------------------------------------------------
Guilherme Charro                12/11/2021         Original Version                         100
*/
@isTest
public class SL_ContactRelatedActivityTest {
    static fflib_ApexMocks mocks = new fflib_ApexMocks();

    @isTest
    static void SetContactRelatedActivityTest() {
        IREP_Contact contactRepository = (REP_Contact)mocks.mock(REP_Contact.class);
        IREP_CEPSkipValidationRules cepSkipValidationRulesRepository = (REP_CEPSkipValidationRules)mocks.mock(REP_CEPSkipValidationRules.class);
        IREP_TriggerHandlerSettings triggerHandlerSettingsRepository = (REP_TriggerHandlerSettings)mocks.mock(REP_TriggerHandlerSettings.class);

        List<Contact> contactList = new List<Contact>{
            new Contact(
                Id = fflib_IDGenerator.generate(Contact.sObjectType),
                LastName = 'test class contact',
                RecordTypeID = Do_Contact.CONTACT_RECORDTYPEID_CEPCARDS
            )
        };

        mocks.startStubbing();
        mocks.when(contactRepository.getContactById((Set<Id>)  fflib_match.anyObject())).thenReturn(contactList);
        mocks.when(contactRepository.updateSObjects((List<Contact>)  fflib_match.anyList())).thenReturn(new List<Database.SaveResult>());
        mocks.when(cepSkipValidationRulesRepository.updateSObjects((List<CEPSkipValidationRules__c>)  fflib_match.anyList())).thenReturn(new List<Database.SaveResult>());
        mocks.when(triggerHandlerSettingsRepository.updateSObjects((List<FW_TriggerHandlerSettings__c>)  fflib_match.anyList())).thenReturn(new List<Database.SaveResult>());
        mocks.stopStubbing();

        SL_ContactRelatedActivity jobExecutionWorker = new SL_ContactRelatedActivity();
        jobExecutionWorker = new SL_ContactRelatedActivity(contactRepository, cepSkipValidationRulesRepository, triggerHandlerSettingsRepository);

        jobExecutionWorker.setContactRelatedActivity(new Set<Id>{contactList[0].Id});

        ((IREP_Contact)mocks.verify(contactRepository, 1)).getContactById((Set<Id>)  fflib_match.anyObject());
        ((IREP_Contact)mocks.verify(contactRepository, 1)).updateSObjects((List<Contact>)  fflib_match.anyList());
        ((IREP_CEPSkipValidationRules)mocks.verify(cepSkipValidationRulesRepository, 2)).updateSObjects((List<CEPSkipValidationRules__c>) fflib_match.anyList());
        ((IREP_TriggerHandlerSettings)mocks.verify(triggerHandlerSettingsRepository, 2)).updateSObjects((List<FW_TriggerHandlerSettings__c>) fflib_match.anyList());
    }
}