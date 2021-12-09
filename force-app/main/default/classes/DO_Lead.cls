/**
* @description   Lead domain object class
* @testClass     DO_LeadTest
* Modification Log 
* ------------------------------------------------------------------------------------  
* Developer                       Date                Description 
* Guilherme Charro                25/08/2021          Created Lead domain
* Hugo Rodrigues                  04/11/2021          added LEAD_STATUS_NEW,LEAD_STATUS_WORKING,LEAD_OPENSTATUSES
* ------------------------------------------------------------------------------------ 
*/
public class DO_Lead implements IDO_Lead{
    private final static String LEAD_RECORDTYPE_CEPCARDS = 'CEP_Cards_Lead';
    private final static String LEAD_RECORDTYPE_CEPCARDSDATABASE = 'CEP_Cards_Database_Lead';
    public final static Id LEAD_RECORDTYPEID_CEPCARDS = Schema.SObjectType.Lead.getRecordTypeInfosByDeveloperName().get(LEAD_RECORDTYPE_CEPCARDS).getRecordTypeId();
    public final static Id LEAD_RECORDTYPEID_CEPCARDSDATABASE = Schema.SObjectType.Lead.getRecordTypeInfosByDeveloperName().get(LEAD_RECORDTYPE_CEPCARDSDATABASE).getRecordTypeId();
    public final static List<Id> LEAD_RECORDTYPE_CARDSLIST = new List<Id>{LEAD_RECORDTYPEID_CEPCARDS, LEAD_RECORDTYPEID_CEPCARDSDATABASE};
    public final static String LEAD_GDPR_NO = 'No';
    public final static String LEAD_GDPR_YES = 'Yes';
    public final static String LEAD_CATEGORY_BULK = 'Bulk';
    public final static String LEAD_CATEGORY_CARDS = 'Cards';
    public final static String LEAD_COMPANY_TEST = 'test';
    public final static String LEAD_CONTACT_LAST_NAME_TEST = 'test';
    public final static String LEAD_TRADE_REGISTRATION_NUMBER_TEST = '12345665234523445';
    public final static String LEAD_VAX_NUMBER_TEST = '12345665234523445';
    public final static String LEAD_STATUS_NEW = 'New';
    public final static String LEAD_STATUS_WORKING = 'Working';
    public final static Set<String> LEAD_OPENSTATUSES = new Set<String>{DO_Lead.LEAD_STATUS_NEW,DO_Lead.LEAD_STATUS_WORKING}; 
}