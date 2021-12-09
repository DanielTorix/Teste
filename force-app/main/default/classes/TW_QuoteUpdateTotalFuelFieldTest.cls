/**
@author Hugo Rodrigues
@date   23/07/2021
@description Test class for TW_QuoteUpdateTotalFuelField
@TestClass         
Modification Log:
----------------------------------------------------------------------------------------------------
Developer                Date                Description                                    Coverage
----------------------------------------------------------------------------------------------------
Hugo Rodrigues           23/07/2021         Original Version                                    100
Hugo Rodrigues           23/09/2021   added RecordType and 2 updates because validation rule    100
Hugo Rodrigues           08/10/2021      updated to work with the framework                     100
*/
@isTest
public with sharing class TW_QuoteUpdateTotalFuelFieldTest {
    static fflib_ApexMocks mocks = new fflib_ApexMocks();
    
    @isTest

    private static void  TW_QuoteUpdateTotalFuelFieldTest() {
        
        IREP_Quote quoteRepository = (REP_Quote)mocks.mock(REP_Quote.class);        
        IREP_Opportunity oppRepository = (REP_Opportunity)mocks.mock(REP_Opportunity.class);

        User runningUser = new User(Id = fflib_IDGenerator.generate(User.sObjectType));
        User testUser = new User(Id = fflib_IDGenerator.generate(User.sObjectType));
        List<Quote> quoteList = new List<Quote>();
        List<Account> objListAccount = new List<Account>();
        List<Opportunity> objListOpportunity = new List<Opportunity>();
        
        objListAccount.add(
            new Account(
                Id = fflib_IDGenerator.generate(Account.sObjectType),
                Name = Do_Account.ACCOUNT_NAME_FOR_TEST,
                ExternalId__c=Do_Account.ACCOUNT_EXT_CUSTOMER_ID_FOR_TEST
            ));

        objListOpportunity.add(
            new Opportunity(
                Id = fflib_IDGenerator.generate(Opportunity.sObjectType),
                Name = Do_Opportunity.OPPORTUNITY_NAME_FOR_TEST,
                AccountId=objListAccount[0].Id,
                CloseDate=System.today().addMonths(1),
                StageName=Do_Opportunity.OPPORTUNITY_STAGENAME_QUALIFICATION,
                OpportunityCategory__c=Do_Opportunity.OPPORTUNITY_CATEGORY_BULK,
                PotentialDieselvolumekLy__c =2,
                PotentialGasolinevolumekLy__c=3

            ));
        quoteList.add(
            new Quote(
                Id = fflib_IDGenerator.generate(Quote.sObjectType),
                Name=DO_Quote.QUOTE_NAME_FOR_TEST,
                Status = DO_Quote.QUOTE_STATUS_ACCEPTED,
                OpportunityID = objListOpportunity[0].Id,
                RecordTypeID=DO_Quote.QUOTE_CARDS_RECORDTYPE_ID

            )  
        );
        
        mocks.startStubbing();
        mocks.when(quoteRepository.getQuoteByID((Set<Id>) fflib_match.anyObject())).thenReturn(quoteList);
        mocks.when(oppRepository.getOpportunityByID((Set<Id>) fflib_match.anyObject())).thenReturn(objListOpportunity);
        mocks.stopStubbing();
        TW_QuoteUpdateTotalFuelField quoteExecutionWorker = new TW_QuoteUpdateTotalFuelField();
        quoteExecutionWorker = new TW_QuoteUpdateTotalFuelField(oppRepository,quoteRepository);
        quoteExecutionWorker.execute(quoteList);
        
        
        
    }
}