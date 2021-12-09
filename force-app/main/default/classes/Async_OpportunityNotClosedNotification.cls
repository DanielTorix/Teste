/**
* @description   BactJob to send notification for Opportunities not closed for 7 days or more
* @testClass     Async_OppNotClosedNotificationTest
* @ScheduleClass Async_OppChatterSchedule
* Modification Log 
* ------------------------------------------------------------------------------------  
* Developer                       Date                Description 
* Hugo Rodrigues                23/06/2021          BactJob to send notification for Opportunities not closed for 7 days or more
* ------------------------------------------------------------------------------------ 
*/

global class Async_OpportunityNotClosedNotification extends FW_AsyncHandler implements Database.Batchable<sObject>, Database.stateful{

    private IREP_Opportunity opportunityRepository;
    private ISL_ChatterNotifications opportunityChatterNotifications;

    global Async_OpportunityNotClosedNotification(){
        
        opportunityRepository = new REP_Opportunity();
        opportunityChatterNotifications = new SL_ChatterNotifications();
    }

    @testVisible
    private Async_OpportunityNotClosedNotification(IREP_Opportunity opportunityRep,FW_IREP_JobExecution jobExecutionRep, FW_IREP_Parameters parameterRep, ISL_ChatterNotifications chatterNotifications){
       
        this.opportunityRepository = opportunityRep;
        this.jobExecutionRep = jobExecutionRep;
        this.parameterRep = parameterRep;
        this.opportunityChatterNotifications = chatterNotifications;
        
    }

    global Database.QueryLocator start(Database.BatchableContext bc) {
     
        setAsyncApexJobId(bc.getJobId());

        FW_QueryBuilder query = new FW_QueryBuilder(Opportunity.SObjectType)
        .selectFields(REP_Opportunity.OPPORTUNITY_FIELDS)
        .SetWhere('IsClosed = false');
        
        return executeQuery(query);
    }

    global void execute(Database.BatchableContext bc, List<Opportunity> oppList) {
        
        List<Opportunity> opportunityList = new  List<Opportunity>(opportunityRepository.getQuoteByOpportunityID(new Map<ID,Opportunity>(oppList).keySet()));
        Integer numberDays = this.getParameterValue('daysInactiveOpportunity') != null ? Integer.valueOf( this.getParameterValue('daysInactiveOpportunity') ) : 7;
        
        Set<ID> opportunitySet = new Set<ID>(new Map<ID,Opportunity>(opportunityList).keySet());
        for(Opportunity opportunityRecord : opportunityList){
            if(opportunityRecord.Quotes.IsEmpty() ==false){
            for(Quote quoteRecord : opportunityRecord.Quotes){

                if(quoteRecord.Status != DO_Quote.QUOTE_STATUS_ACCEPTED && quoteRecord.Status != DO_Quote.QUOTE_STATUS_DENIED){
                    opportunitySet.remove(opportunityRecord.ID);
                }
                else if(quoteRecord.ClosedDate__c != date.Today() - numberDays ){
                    opportunitySet.remove(opportunityRecord.ID);
                }

            }
            
            }
            else if(opportunityRecord.Quotes.IsEmpty() ==true){
                opportunitySet.remove(opportunityRecord.ID);  
            }

        }
        List<Opportunity> opportunityFinalList = new  List<Opportunity>(opportunityRepository.getOpportunityByID(opportunitySet));

        
        for(Opportunity opportunityRecord : opportunityFinalList){
            Date daysDate = date.valueOf(opportunityRecord.CreatedDate);
            
            Integer daysDateInt = daysDate.daysBetween(date.today()) ;
            
            
            SL_ChatterNotifications opportunityChatterNotificationPost = new SL_ChatterNotifications.chatterBuilder()
                .setPreText(System.Label.ChatterOpportunityMessage1 +' ')
                .setPosText(' ' + System.Label.ChatterOpportunityMessage2 + ' ' + opportunityRecord.Name  + ' ' + System.Label.ChatterOpportunityMessage3 + ' ' + daysDateInt + ' ' + System.Label.ChatterOpportunityMessage3_5 + ' '+ opportunityRecord.CreatedDate + ' ' + System.Label.ChatterOpportunityMessage4 )
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