/**
* @description   Batch created to notify the owner of the account of the target closure date
* @Parameters    DaysBeforeClosure optional parameter to add to the batch definition to change the amount of days before creating the notification
* @testClass     Async_OppTargetDateNotificationTest
* @ScheduleClass Async_OppTargetDateNotifSchedule
* Modification Log 
* ------------------------------------------------------------------------------------  
* Developer                       Date                Description 
* João Lopes                    28/06/2021            Class created
* ------------------------------------------------------------------------------------ 
*/

global class Async_OppTargetDateNotification extends FW_AsyncHandler implements Database.Batchable<sObject>, Database.stateful{

    private IREP_Opportunity opportunityRepository;
    private ISL_ChatterNotifications opportunityChatterNotifications;
    global Async_OppTargetDateNotification(){
        
        opportunityRepository = new REP_Opportunity();
        opportunityChatterNotifications = new SL_ChatterNotifications();
    }

    @testVisible
    private Async_OppTargetDateNotification(IREP_Opportunity opportunityRep,FW_IREP_JobExecution jobExecutionRep, FW_IREP_Parameters parameterRep, ISL_ChatterNotifications chatterNotifications){
       
        this.opportunityRepository = opportunityRep;
        this.jobExecutionRep = jobExecutionRep;
        this.parameterRep = parameterRep;
        this.opportunityChatterNotifications = chatterNotifications;
    }

    global Database.QueryLocator start(Database.BatchableContext bc) {

        setAsyncApexJobId(bc.getJobId());

        FW_QueryBuilder query = new FW_QueryBuilder(Opportunity.SObjectType)
        .selectFields(REP_Opportunity.OPPORTUNITY_FIELDS)
        .SetWhere('IsClosed = false AND TargetDateofClosure__c = ' + string.valueOf( Date.today().addDays( this.getParameterValue('DaysBeforeClosure') != null ? Integer.valueOf( this.getParameterValue('DaysBeforeClosure') ) : 7 ) ));

        return executeQuery(query);
    }

    global void execute(Database.BatchableContext bc, List<Opportunity> oppList) {
        
        List<Opportunity> opportunityList = new  List<Opportunity>(opportunityRepository.getOpportunityByID(new Map<ID,Opportunity>(oppList).keySet()));
        
        for(Opportunity opportunityRecord : opportunityList){
            
            SL_ChatterNotifications opportunityChatterNotificationPost = new SL_ChatterNotifications.chatterBuilder()
                .setPreText( System.Label.OpportunityClosureDateMessage.substringBeforeLast('@owner') +' ')
                .setPosText(' ' + System.Label.OpportunityClosureDateMessage.substringAfterLast('@owner') )
                .setMentionIds(new List<String>{opportunityRecord.OwnerId})
                .setSubjectId(opportunityRecord.Id)
                .build();

            opportunityChatterNotifications.addFeedItemInputList( opportunityChatterNotificationPost.getFeedItemInputList() ) ;

        }
        opportunityChatterNotifications.persistChatterPosts();
    }

    global void finish(Database.BatchableContext bc) {
        finishBatch(bc.getJobId());
    }
}