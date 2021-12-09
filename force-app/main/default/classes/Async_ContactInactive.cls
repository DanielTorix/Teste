/**
* @description   BactJob to send notification and delete contacts with prospect accounts not updated for 3 years
* @testClass     Async_ContactInactiveTest
* @ScheduleClass Async_ContactInactiveSchedule
* Modification Log 
* ------------------------------------------------------------------------------------  
* Developer                       Date                Description 
* Guilherme charro              01/10/2021          Created batchjob
* Guilherme charro              09/11/2021          edited to check all related records
* ------------------------------------------------------------------------------------ 
*/
global without sharing class Async_ContactInactive extends FW_AsyncHandler implements Database.Batchable<sObject>, Database.stateful{
    private IREP_Contact contactRepository;
    private ISL_ChatterNotifications contactChatterNotifications;
    private IDO_Contact contactDomain;
    private IREP_CEPSkipValidationRules cepSkipValidationRulesRepository;
    private IREP_TriggerHandlerSettings triggerHandlerSettingsRepository;

    private static final String YEARS = 'Years';
    private static final String DAYS = 'Days';

    global Async_ContactInactive(){
        contactRepository = new REP_Contact();
        contactChatterNotifications = new SL_ChatterNotifications();
        contactDomain = new DO_Contact();
        cepSkipValidationRulesRepository = new REP_CEPSkipValidationRules();
        triggerHandlerSettingsRepository = new REP_TriggerHandlerSettings();
    }

    @testVisible
    private Async_ContactInactive(IREP_Contact contactRepository,FW_IREP_JobExecution jobExecutionRep, FW_IREP_Parameters parameterRep, ISL_ChatterNotifications contactChatterNotifications, IDO_Contact contactDomain, IREP_CEPSkipValidationRules cepSkipValidationRulesRepository, IREP_TriggerHandlerSettings triggerHandlerSettingsRepository){
        this.contactRepository = contactRepository;
        this.jobExecutionRep = jobExecutionRep;
        this.parameterRep = parameterRep;
        this.contactChatterNotifications = contactChatterNotifications;  
        this.contactDomain = contactDomain;  
        this.cepSkipValidationRulesRepository = cepSkipValidationRulesRepository;
        this.triggerHandlerSettingsRepository = triggerHandlerSettingsRepository;
    }

    private static String yearsDate;
    private static String daysDate;

    global Database.QueryLocator start(Database.BatchableContext bc) {
        setAsyncApexJobId(bc.getJobId());

        Integer days = Integer.valueOf(getParameterValue(DAYS));
        Integer years = Integer.valueOf(getParameterValue(YEARS));

        Date yearsAgo = DATE.TODAY().addYears(years);

        daysDate = String.valueOf(yearsAgo.addDays(days));

        FW_QueryBuilder query = new FW_QueryBuilder(Contact.SObjectType)
        .selectFields(REP_Contact.CONTACT_FIELDS)
        .selectParentFields(Contact.AccountId, REP_Account.ACCOUNT_FIELDS)
        .SetWhere('Account.Type = \''+DO_Account.ACCOUNT_TYPE_PROSPECT+'\' AND RelatedActivityDate__c <= '+daysDate+' AND ContactAnonimyzed__c = false');
        
        return executeQuery(query);
    }

    global void execute(Database.BatchableContext bc, List<Contact> contactList) {
        Integer days = Integer.valueOf(getParameterValue(DAYS));
        Integer years = Integer.valueOf(getParameterValue(YEARS));

        Date yearsAgo = DATE.TODAY().addYears(years);

        yearsDate = String.valueOf(yearsAgo);
        daysDate = String.valueOf(yearsAgo.addDays(days));   

        List<Contact> contactToUpdateList = new List<Contact>();
        for (Contact contactToCheck : contactList) {
            if (contactToCheck.RelatedActivityDate__c.isSameDay(date.valueOf(daysDate).addDays(-1))) {
                SL_ChatterNotifications contactChatterNotificationPost = new SL_ChatterNotifications.chatterBuilder()
                        .setPreText(System.Label.ChatterContactProspectMessage + ' ')
                        .setPosText(' '+System.Label.ChatterContactProspectMessage1)
                        .setMentionIds(new List<String>{contactToCheck.Account.OwnerId})
                        .setSubjectId(contactToCheck.Id)
                        .build();
    
                contactChatterNotifications.addFeedItemInputList( contactChatterNotificationPost.getFeedItemInputList() );
            }else if (contactToCheck.RelatedActivityDate__c <= date.valueOf(yearsDate)) {
                Contact contactToUpdate = contactDomain.createContact(contactToCheck.Id);
                contactToUpdate.ContactAnonimyzed__c = true;
                contactToUpdateList.add(contactToUpdate);
            }
        }

        contactChatterNotifications.persistChatterPosts();

        if (!contactToUpdateList.isEmpty()) {
            CEPSkipValidationRules__c skipValidation = CEPSkipValidationRules__c.getOrgDefaults();
            skipValidation.Contact__c = true;
            cepSkipValidationRulesRepository.updateSObjects(new List<CEPSkipValidationRules__c>{skipValidation});

            FW_TriggerHandlerSettings__c skipTrigger = FW_TriggerHandlerSettings__c.getOrgDefaults();
            skipTrigger.Contact__c = true;
            triggerHandlerSettingsRepository.updateSObjects(new List<FW_TriggerHandlerSettings__c>{skipTrigger});

            contactRepository.updateSObjects(contactToUpdateList);         
            
            skipValidation.Contact__c = false;
            cepSkipValidationRulesRepository.updateSObjects(new List<CEPSkipValidationRules__c>{skipValidation});

            skipTrigger.Contact__c = false;
            triggerHandlerSettingsRepository.updateSObjects(new List<FW_TriggerHandlerSettings__c>{skipTrigger});
        }
    }

    global void finish(Database.BatchableContext bc) {
        finishBatch(bc.getJobId());
    }
}