//97% coverage
@isTest
public with sharing class TW_EmailMessage_CheckCaseEmailsTest {
    static fflib_ApexMocks mocks = new fflib_ApexMocks();
    
    @isTest
    private static void TW_EmailMessage_CheckCaseEmailsTest() {
        IREP_Case caseRepository = (REP_Case)mocks.mock(REP_Case.class);
        IREP_EmailMessage emailMessageRepository = (REP_EmailMessage)mocks.mock(REP_EmailMessage.class);
        ISL_ChatterNotifications emailMessageChatterNotification = (SL_ChatterNotifications)mocks.mock(SL_ChatterNotifications.class);

        List<Case> listCase = new List<Case>{
            new Case(
                Id = fflib_IDGenerator.generate(Case.sObjectType),
                Status = DO_Case.CASE_STATUS_CLOSED,
                Source__c = DO_Case.CASE_SOURCE_OTHER
            ),
            new Case(
                Id = fflib_IDGenerator.generate(Case.sObjectType),
                Status = DO_Case.CASE_STATUS_RESOLUTIONCUSTOMER,
                Source__c = DO_Case.CASE_SOURCE_OTHER
            ),
            new Case(
                Id = fflib_IDGenerator.generate(Case.sObjectType),
                Source__c = DO_Case.CASE_SOURCE_OTHER
            ),
            new Case(
                Id = fflib_IDGenerator.generate(Case.sObjectType),
                Status = DO_Case.CASE_STATUS_NEW,
                AccountId = null
            ) 
        };
        
        listCase[0] = (Case)fflib_ApexMocksUtils.setReadOnlyFields(
                listCase[0],
                Case.class,
                new Map<SObjectField, Object> {Case.IsClosed => true}
        );

        List<EmailMessage> listEmailMessage = new List<EmailMessage>{
            new EmailMessage(
                Id = fflib_IDGenerator.generate(EmailMessage.sObjectType),
                RelatedToId = listCase[0].Id,
                Incoming = true
            ),
            new EmailMessage(
                Id = fflib_IDGenerator.generate(EmailMessage.sObjectType),
                RelatedToId = listCase[1].Id,
                Incoming = true
            ),
            new EmailMessage(
                Id = fflib_IDGenerator.generate(EmailMessage.sObjectType),
                RelatedToId = listCase[2].Id,
                Incoming = true
            ),
            new EmailMessage(
                Id = fflib_IDGenerator.generate(EmailMessage.sObjectType),
                RelatedToId = listCase[3].Id,
                Incoming = true,
                ToAddress = 'info.poukazky@omv.com'
            ),
            new EmailMessage(
                Id = fflib_IDGenerator.generate(EmailMessage.sObjectType),
                RelatedToId = listCase[2].Id,
                Incoming = false
            )
        };
        
        
        mocks.startStubbing();
        mocks.when(caseRepository.getCasesById((Set<Id>) fflib_match.anyObject())).thenReturn(listCase);
        ((ISL_ChatterNotifications) mocks.doAnswer( new VoidAnswer(),emailMessageChatterNotification)).persistChatterPosts();
        mocks.when(caseRepository.updateSObjects((List<Case>) fflib_match.anyList())).thenReturn(new List<Database.SaveResult>());
        
        mocks.stopStubbing();
        
        TW_EmailMessage_CheckCaseEmails jobExecutionWorker = new TW_EmailMessage_CheckCaseEmails();
        jobExecutionWorker = new TW_EmailMessage_CheckCaseEmails(emailMessageChatterNotification, caseRepository, emailMessageRepository);
        
        jobExecutionWorker.execute(listEmailMessage);
        
        Test.startTest();
        Test.stopTest();
        
        ((IREP_Case)mocks.verify(caseRepository, 1)).getCasesById((Set<Id>) fflib_match.anyObject());
        ((IREP_Case)mocks.verify(caseRepository, 1)).updateSObjects((List<Case>) fflib_match.anyList());
    }

    class VoidAnswer implements fflib_Answer {
        public Object answer (fflib_InvocationOnMock invocation) {
            return null;
        }
    }
}