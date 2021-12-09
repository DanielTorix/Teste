@isTest
public class REP_QuoteTest {
    @isTest
    static void QuoteTest() {
        
            User runningUser = FW_TestDataFactory.createUsers(1, true, 'System Administrator', null).get(0);
            System.runAs(runningUser){  
                List<Quote> listQuote = FW_TestDataFactory.createQuote(1, true);
                List<Opportunity> listOpportunity = FW_TestDataFactory.createOpportunity(1, true);

                test.startTest();
                    REP_Quote quoteRepository = new REP_Quote();
                    List<Quote> quotesReturned = quoteRepository.getQuoteByID(new Set<ID> {listQuote[0].Id});
                    List<Quote> quotesReturnedThird = quoteRepository.getQuoteWithItemsById(new Set<ID> {listQuote[0].Id});
                    List<Quote> quotesByOpportunityReturned = quoteRepository.getQuoteByOpportunityID(new Set<ID> {listOpportunity[0].Id});
                    List<Quote> CardsQuotesReturned = quoteRepository.getCardsQuotes(new Set<ID> {listQuote[0].Id});
                test.stopTest();
                System.assertEquals(1, quotesReturned.size());
                System.assertEquals(1, quotesReturnedThird.size());
                System.assertEquals(1, CardsQuotesReturned.size());
            }

    }
}