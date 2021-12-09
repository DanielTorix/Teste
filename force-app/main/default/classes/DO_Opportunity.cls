/**
* @description   Opportunity domain object class
* @testClass     DO_OpportunityTest
* Modification Log 
* ------------------------------------------------------------------------------------  
* Developer                       Date                Description 
* Guilherme Charro                21/07/2021          Created Opportunity Repository
* ------------------------------------------------------------------------------------ 
*/
public with sharing class DO_Opportunity implements IDO_Opportunity{
    public final static String OPPORTUNITY_CARDS_RECORDTYPE_NAME = 'CEPOpportunity';
    public final static String OPPORTUNITY_NAME_FOR_TEST = 'Test';
    public final static String OPPORTUNITY_STAGENAME_QUALIFICATION = 'Qualification';
    public final static String OPPORTUNITY_CATEGORY_BULK = 'Bulk';
    public final static String OPPORTUNITY_CATEGORY_CARDS = 'Cards';
    public final static Id OPPORTUNITY_CARDS_RECORDTYPE_ID = Schema.SObjectType.Opportunity.getRecordTypeInfosByDeveloperName().get(OPPORTUNITY_CARDS_RECORDTYPE_NAME).getRecordTypeId();
}