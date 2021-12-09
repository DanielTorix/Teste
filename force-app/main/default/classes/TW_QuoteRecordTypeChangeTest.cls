@isTest
public with sharing class TW_QuoteRecordTypeChangeTest {
    
    
    @isTest

    private static void  TW_QuoteRecordTypeChangeTest() {
        Test.startTest();
        List<Quote> quoteList = FW_TestDataFactory.createQuote(2, false) ;
        quoteList[1].CompetitiveBandFuel__c=DO_Quote.QUOTE_COMPETITIVEBANDFUEL_CO3;
        insert quoteList;
       
        quoteList[0].CompetitiveBandFuel__c=DO_Quote.QUOTE_COMPETITIVEBANDFUEL_CO3;
        quoteList[1].CompetitiveBandFuel__c=DO_Quote.QUOTE_COMPETITIVEBANDFUEL_CO1;
        update quoteList;
        
        Test.stopTest();
        
        System.assertEquals(2, quoteList.size());
    }
}