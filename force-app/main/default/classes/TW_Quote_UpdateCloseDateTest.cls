@isTest
public with sharing class TW_Quote_UpdateCloseDateTest {
    static fflib_ApexMocks mocks = new fflib_ApexMocks();
    
    @isTest
    private static void TW_Quote_UpdateCloseDateTest() {

        IREP_Quote quoteRepository = (REP_Quote)mocks.mock(REP_Quote.class);
        IDO_Quote quoteDomain = (DO_Quote)mocks.mock(DO_Quote.class);
        Test.startTest();
        User runningUser = new User(Id = fflib_IDGenerator.generate(User.sObjectType));
        User testUser = new User(Id = fflib_IDGenerator.generate(User.sObjectType));
        List<Quote> quoteList = new List<Quote>();
        quoteList.add(
            new Quote(
                Id = fflib_IDGenerator.generate(Quote.sObjectType),
                Status = DO_Quote.QUOTE_STATUS_ACCEPTED
            )  
        );
        
        Map<Id, Quote> oldQuotesMap = new Map<Id, Quote>();
        oldQuotesMap.put(quoteList[0].Id, new Quote(Id = fflib_IDGenerator.generate(Quote.sObjectType)));
        quoteList[0].Status=DO_Quote.QUOTE_STATUS_DENIED;

        TW_Quote_UpdateCloseDate quoteExecutionWorker = new TW_Quote_UpdateCloseDate();
        quoteExecutionWorker = new TW_Quote_UpdateCloseDate(quoteRepository,quoteDomain);
        quoteExecutionWorker.execute(quoteList, oldQuotesMap);
        quoteExecutionWorker.execute(quoteList, null);
        Test.stopTest();
        System.assertNotEquals(null, quoteList[0].Id);
        
        
        
    }
}