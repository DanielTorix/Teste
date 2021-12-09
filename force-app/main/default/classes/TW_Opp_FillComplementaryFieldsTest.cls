@isTest
public with sharing class TW_Opp_FillComplementaryFieldsTest {
    static fflib_ApexMocks mocks = new fflib_ApexMocks();
    
    @isTest
    private static void TW_Opp_FillComplementaryFieldsTest() {
        ISL_CountryDefinitionFromParent countryDefinition = (SL_CountryDefinitionFromParent)mocks.mock(SL_CountryDefinitionFromParent.class);

        List<Account> listAccount = new List<Account>{
            new Account(
                Id = fflib_IDGenerator.generate(Account.sObjectType)
            ),
            new Account(
                Id = fflib_IDGenerator.generate(Account.sObjectType)
            )
        };

        List<Opportunity> listOpportunity = new List<Opportunity>{
            new Opportunity(
                Id = fflib_IDGenerator.generate(Opportunity.sObjectType),
                AccountId = listAccount[0].Id
            ),
            new Opportunity(
                Id = fflib_IDGenerator.generate(Opportunity.sObjectType),
                AccountId = listAccount[1].Id
            )  
        };

        listOpportunity[0] = (Opportunity)fflib_ApexMocksUtils.setReadOnlyFields(
            listOpportunity[0],
            Opportunity.class,
            new Map<SObjectField, Object> {Opportunity.RecordTypeId => DO_Opportunity.OPPORTUNITY_CARDS_RECORDTYPE_ID}
        );
        
        Map<Id,Opportunity> oldOppMap = new Map<Id,Opportunity>();
        oldOppMap.put(listOpportunity[0].Id, listOpportunity[1]);

        mocks.startStubbing();
        mocks.stopStubbing();

        TW_Opp_FillComplementaryFields jobExecutionWorker = new TW_Opp_FillComplementaryFields();
        jobExecutionWorker = new TW_Opp_FillComplementaryFields(countryDefinition);
        
        jobExecutionWorker.execute(listOpportunity, null);
        jobExecutionWorker.execute(listOpportunity, oldOppMap);
    }
}