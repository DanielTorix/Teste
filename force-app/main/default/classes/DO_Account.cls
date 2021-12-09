/**
* @description   Account domain object class
* @testClass     DO_AccountTest
* Modification Log 
* ------------------------------------------------------------------------------------  
* Developer                       Date                Description 
* Hugo Rodrigues                25/08/2021          Created Account domain
* ------------------------------------------------------------------------------------ 
*/
public class DO_Account implements IDO_Account{
    public final static String ACCOUNT_TYPE_PROSPECT ='Prospect';
    public final static String ACCOUNT_RECORDTYPE_CEPCARDS = 'CEPCardsAccount';
    public final static String ACCOUNT_NAME_FOR_TEST = 'Test';
    public final static String ACCOUNT_EXT_CUSTOMER_ID_FOR_TEST = '1234';
    public final static Id ACCOUNT_RECORDTYPEID_CEPCARDS = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get(ACCOUNT_RECORDTYPE_CEPCARDS).getRecordTypeId();
}