@isTest
public with sharing class TW_Opportunity_FillPricebookTest {
    static fflib_ApexMocks mocks = new fflib_ApexMocks();
    
    @testSetup
    private static void makeData(){
        Pricebook2 pricebook = new Pricebook2();
        pricebook.Name = 'CARDS TESTE';
        insert pricebook;

        CEP_Configuration__c setting = new CEP_Configuration__c();
        setting.CardsPricebookId__c = pricebook.Id;
        insert setting;
    }
    
    @isTest
    private static void TW_Opportunity_FillPricebookTest() {
        Test.startTest();

        List<Opportunity> listOpportunity = new List<Opportunity>();
        listOpportunity.add(
            new Opportunity(
                Id = fflib_IDGenerator.generate(Opportunity.sObjectType),
                RecordTypeId = DO_Opportunity.OPPORTUNITY_CARDS_RECORDTYPE_ID
            )  
        );

        mocks.startStubbing();
        mocks.stopStubbing();

        TW_Opportunity_FillPricebook jobExecutionWorker = new TW_Opportunity_FillPricebook();
        jobExecutionWorker = new TW_Opportunity_FillPricebook();
        
        jobExecutionWorker.execute(listOpportunity);

        Test.stopTest();
    }
}