/**
* @description   BactJob to send notification for Quote for 7 days before ExpirationDate
* @testClass     Async_QuoteExpirationNotificationTest
* @ScheduleClass Async_QuoteChatterNotificationSchedule
* Modification Log 
* ------------------------------------------------------------------------------------  
* Developer                       Date                Description 
* Hugo Rodrigues                25/06/2021         BactJob to send notification for Quote for 7 days before ExpirationDate
* ------------------------------------------------------------------------------------ 
*/
global class Async_QuoteExpirationDateNotification extends FW_AsyncHandler implements Database.Batchable<sObject>, Database.stateful{
    
    private IREP_Quote quoteRepository;
    private ISL_ChatterNotifications quoteChatterNotifications;
    
    global Async_QuoteExpirationDateNotification() {

        quoteRepository = new REP_Quote();
        quoteChatterNotifications = new SL_ChatterNotifications();

    }

    @testVisible
    private Async_QuoteExpirationDateNotification(IREP_Quote quoteRep,FW_IREP_JobExecution jobExecutionRep, FW_IREP_Parameters parameterRep, ISL_ChatterNotifications chatterNotifications) {

        this.quoteRepository = quoteRep;
        this.jobExecutionRep = jobExecutionRep;
        this.parameterRep = parameterRep;
        this.quoteChatterNotifications = chatterNotifications;
    }

    global Database.QueryLocator start(Database.BatchableContext bc) {

        setAsyncApexJobId(bc.getJobId());

        FW_QueryBuilder query = new FW_QueryBuilder(Quote.SObjectType)
        .selectFields(REP_Quote.QUOTE_FIELDS)
        .SetWhere('Status != \'  Accepted \' AND Status  !=\' Denied \' AND ValidityDate__c = ' + string.valueOf( Date.today().addDays( this.getParameterValue('daysBeforeCloseQuote') != null ? +Integer.valueOf( this.getParameterValue('daysBeforeCloseQuote') ) : 7 ) ));
        system.debug(query.getQuery());
        return executeQuery(query);
    }
    global void execute(Database.BatchableContext bc, List<Quote> quoteList) {
        
        List<Quote> quotesList = new  List<Quote>(quoteRepository.getQuoteByID(new Map<ID,Quote>(quoteList).keySet()));
        
        for(Quote quoteRecord : quotesList){
            
            SL_ChatterNotifications quoteChatterNotificationPost = new SL_ChatterNotifications.chatterBuilder()
                .setPreText(System.Label.ChatterOpportunityMessage1 +' ')
                .setPosText(' ' + System.Label.ChatterQuoteNotification + ' ' + quoteRecord.Name  + ' ' + System.Label.ChatterQuoteNotification2 )
                .setMentionIds(new List<String>{quoteRecord.OwnerId})
                .setSubjectId(quoteRecord.Id)
                .build();

                quoteChatterNotifications.addFeedItemInputList( quoteChatterNotificationPost.getFeedItemInputList() ) ;
                

        }
        quoteChatterNotifications.persistChatterPosts();
       
    }

    global void finish(Database.BatchableContext bc) {
        finishBatch(bc.getJobId());
    }
}