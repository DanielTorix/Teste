/**
@description    worker class to notify when a closed case receives an email
@testClass      TW_EmailMessage_CheckCaseEmailsTest
* Modification Log 
* ------------------------------------------------------------------------------------  
* Developer                       Date                Description  
* Guilherme Charro                07/07/2021          Created the class
* Guilherme Charro                22/09/2021          added logic to update Case Language according to the inbox (US 32695)
* ------------------------------------------------------------------------------------        
*/
public with sharing class TW_EmailMessage_CheckCaseEmails {
    private IREP_Case caseRepository;
    private ISL_ChatterNotifications emailMessageChatterNotifications;
    private IREP_EmailMessage emailMessageRepository;
    
    public TW_EmailMessage_CheckCaseEmails(){
        this.emailMessageChatterNotifications = new SL_ChatterNotifications();
        this.caseRepository = new REP_Case();
        this.emailMessageRepository = new REP_EmailMessage();
    }
    
    @TestVisible
    private TW_EmailMessage_CheckCaseEmails(ISL_ChatterNotifications emailMessageChatterNotifications, IREP_Case caseRepository, IREP_EmailMessage emailMessageRepository){
        this.emailMessageChatterNotifications = emailMessageChatterNotifications;
        this.caseRepository = caseRepository;
        this.emailMessageRepository = emailMessageRepository;
    }

    public void execute(List<EmailMessage> emailMessageList) {
        
        Set<Id> caseIds = new Set<Id>();
        List<Id> emailMessagesIdList = new List<Id>();
        for (EmailMessage emailReceived : emailMessageList) {
            if (emailReceived.Incoming && !String.isBlank(emailReceived.RelatedToId) && Schema.Case.SObjectType == emailReceived.RelatedToId.getSobjectType()){
                caseIds.add(emailReceived.RelatedToId);
                emailMessagesIdList.add( emailReceived.Id );
            }else if (!String.isBlank(emailReceived.RelatedToId) && Schema.Case.SObjectType == emailReceived.RelatedToId.getSobjectType()) {
                emailMessagesIdList.add( emailReceived.Id );
            }
        }
        List<Case> casesInfoList = new List<Case>();
        List<Case> casesToUpdate = new List<Case>();

        if (!caseIds.isEmpty()) {
            casesInfoList = caseRepository.getCasesById(caseIds);
        }

        Map<String, InboxLanguage__mdt> inboxLanguagesMap = new Map<String, InboxLanguage__mdt>();
        for( InboxLanguage__mdt mdtLanguage : InboxLanguage__mdt.getAll().values() ){
            inboxLanguagesMap.put(mdtLanguage.InboxAddress__c, mdtLanguage);
        }

        for (Case caseInfo : casesInfoList) {
            if (caseInfo.IsClosed) {
                SL_ChatterNotifications emailMessageChatterNotificationPost = new SL_ChatterNotifications.chatterBuilder()
                .setPosText(' '+System.Label.EmailMessageCaseClosedTrigger1+' '+caseInfo.CaseNumber+'. '+System.Label.EmailMessageCaseClosedTrigger2)
                .setMentionIds(new List<String>{caseInfo.OwnerId})
                .setSubjectId(caseInfo.Id)
                .build();

                emailMessageChatterNotifications.addFeedItemInputList( emailMessageChatterNotificationPost.getFeedItemInputList() );
            }else if (caseInfo.Status == DO_Case.CASE_STATUS_RESOLUTIONCUSTOMER) {
                if (!String.isBlank(caseInfo.Source__c)) {
                    caseInfo.Status = DO_Case.CASE_STATUS_CUSTOMERFEEDBACK;
                    casesToUpdate.add(caseInfo);
                }

                SL_ChatterNotifications emailMessageChatterNotificationPost = new SL_ChatterNotifications.chatterBuilder()
                .setPosText(' '+System.Label.EmailMessageCaseClosedTrigger1+' '+caseInfo.CaseNumber+'. '+System.Label.EmailMessageCaseTrigger3)
                .setMentionIds(new List<String>{caseInfo.OwnerId})
                .setSubjectId(caseInfo.Id)
                .build();

                emailMessageChatterNotifications.addFeedItemInputList( emailMessageChatterNotificationPost.getFeedItemInputList() );
            }else if(caseInfo.Status != DO_Case.CASE_STATUS_NEW){
                if (!String.isBlank(caseInfo.Source__c)) {
                    caseInfo.Status = DO_Case.CASE_STATUS_INFORMATIONRECEIVED;
                    casesToUpdate.add(caseInfo);
                }

                SL_ChatterNotifications emailMessageChatterNotificationPost = new SL_ChatterNotifications.chatterBuilder()
                .setPosText(' '+System.Label.EmailMessageCaseClosedTrigger1+' '+caseInfo.CaseNumber+'. '+System.Label.EmailMessageCaseTrigger4)
                .setMentionIds(new List<String>{caseInfo.OwnerId})
                .setSubjectId(caseInfo.Id)
                .build();

                emailMessageChatterNotifications.addFeedItemInputList( emailMessageChatterNotificationPost.getFeedItemInputList() );
            }else if (caseInfo.Status == DO_Case.CASE_STATUS_NEW && (String.isBlank(caseInfo.AccountId) || caseInfo.AccountId == null)) {
                for (EmailMessage emailReceived : emailMessageList) {
                    if (emailReceived.RelatedToId == caseInfo.Id) {
                    	if (inboxLanguagesMap.containsKey( emailReceived.ToAddress )) {
                        	caseInfo.Case_Language__c = inboxLanguagesMap.get( emailReceived.ToAddress ).LanguageCode__c;
                            casesToUpdate.add(caseInfo);
                            break;
                        }    
                    }
                }
            }
        }

        if (!emailMessagesIdList.isEmpty()) {
            // emailMessageRepository.updateSObjects(emailsToUpdateList);
            async_updateEmailMessage( emailMessagesIdList );
            emailMessageChatterNotifications.persistChatterPosts();  
        }

        if (!casesToUpdate.isEmpty()) {
            caseRepository.updateSObjects(casesToUpdate);
        }
    }

    @testVisible
    @future
    private static void async_updateEmailMessage(List<Id> emailMessagesIdList){

        IREP_EmailMessage emailMessageRepository = new REP_EmailMessage();
        List<EmailMessage> emailMessagesToUpdateList = emailMessageRepository.getEmailMessagesById( emailMessagesIdList );
        for( EmailMessage emailRecord : emailMessagesToUpdateList ){

            emailRecord.parentCase__c = emailRecord.relatedToId;
            
        }

        if( !emailMessagesToUpdateList.isEmpty() ){
            emailMessageRepository.updateSObjects(emailMessagesToUpdateList);
        }
    }
}