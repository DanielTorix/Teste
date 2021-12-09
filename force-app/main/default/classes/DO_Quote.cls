/**
* @description   Quote domain object class
* @testClass     DO_QuoteTest
* Modification Log 
* ------------------------------------------------------------------------------------  
* Developer                       Date                Description 
* Hugo Rodrigues                06/056/2021          Created Quote domain
* Carolina Resende              27/08/2021           Create Volume Fueld Band Picklist Values
* Hugo Rodrigues                27/08/2021          Created NON-Fuel PAckage
* João Alencar                  23/09/2021          added the quote type E-Mobility to fix bug 38918 on US35933
* ------------------------------------------------------------------------------------ 
*/
public class DO_Quote implements IDO_Quote{

    public final static String QUOTE_STATUS_ACCEPTED='Accepted';
    public final static String QUOTE_STATUS_DENIED ='Denied';
    public final static String QUOTE_STATUS_DRAFT ='Draft';
    public final static String QUOTE_STATUS_PRESENTED='Presented';
    public final static String QUOTE_STATUS_APPROVED='Approved';
    public final static String QUOTE_CARDS_RECORDTYPE_NAME = 'CEP_CARDS_QUOTES';
    public final static String QUOTE_CARDS_WITH_APPROVAL_RECORDTYPE_NAME = 'CEP_CARDS_QUOTE_WITH_APPROVAL';
    public final static String QUOTE_COMPETITIVEBANDFUEL_CO1 ='CO1';
    public final static String QUOTE_COMPETITIVEBANDFUEL_CO2 ='CO2';
    public final static String QUOTE_COMPETITIVEBANDFUEL_CO3 ='CO3';
    public final static String QUOTE_COMPETITIVEBANDFUEL_CO4 ='CO4';
    public final static String QUOTE_COMPETITIVEBANDFUEL_CO5 ='CO5';
    public final static String QUOTE_COMPETITIVEBANDFUEL_CO6 ='CO6';
    public final static String QUOTE_NON_FUEL_PACKAGE_NF1 ='Non Fuel Package - NF1';
    public final static String QUOTE_NON_FUEL_PACKAGE_NF2 ='Non Fuel Package - NF2';
    public final static String QUOTE_NON_FUEL_PACKAGE_NF3 ='Non Fuel Package - NF3';
    public final static String QUOTE_VOLUMEFUELBAND_V10 ='V10';
    public final static String QUOTE_VOLUMEFUELBAND_V30 ='V30';
    public final static String QUOTE_VOLUMEFUELBAND_V60 ='V60';
    public final static String QUOTE_VOLUMEFUELBAND_V100 ='V100';
    public final static String QUOTE_VOLUMEFUELBAND_V150 ='V150';
    public final static String QUOTE_VOLUMEFUELBAND_V250 ='V250';
    public final static String QUOTE_VOLUMEFUELBAND_V500 ='V500';
    public final static String QUOTE_VOLUMEFUELBAND_V750 ='V750';
    public final static String QUOTE_VOLUMEFUELBAND_V1000 ='V1000';
    public final static String QUOTE_VOLUMEFUELBAND_VM ='VM';
    public final static String QUOTE_APPROVAL_STARTED='Started';
    public final static String QUOTE_NAME_FOR_TEST = 'Test';
    public final static String QUOTE_APPROVAL_STATUS_COMPLETED='Completed';
    public final static String QUOTE_TYPE_EMOBILITY ='E-Mobility';
    public final static String QUOTE_TYPE_FLEET_PP ='Fleet PP';
    public final static String QUOTE_TYPE_FLEET_LP ='Fleet LP';

    public final static Set<ID> QUOTE_QUOTELINEITEMID = new Set<ID>();
    public final static Id QUOTE_CARDS_RECORDTYPE_ID = Schema.SObjectType.Quote.getRecordTypeInfosByDeveloperName().get(QUOTE_CARDS_RECORDTYPE_NAME).getRecordTypeId();
    public final static Id QUOTE_CARDS_WITH_APPROVAL_RECORDTYPE_ID = Schema.SObjectType.Quote.getRecordTypeInfosByDeveloperName().get(QUOTE_CARDS_WITH_APPROVAL_RECORDTYPE_NAME).getRecordTypeId();
    public final static Set<String> QUOTE_COMPETITIVE_BAND_FUELS_WITH_APPROVAL = new Set<String>{ QUOTE_COMPETITIVEBANDFUEL_CO3, QUOTE_COMPETITIVEBANDFUEL_CO4, QUOTE_COMPETITIVEBANDFUEL_CO5, QUOTE_COMPETITIVEBANDFUEL_CO6 };
    public final static Set<String> QUOTE_COMPETITIVE_BAND_FUELS_WITHOUT_APPROVAL = new Set<String>{ QUOTE_COMPETITIVEBANDFUEL_CO1, QUOTE_COMPETITIVEBANDFUEL_CO2 };
    public final static Set<String> QUOTE_NON_FUEL_PACKAGE_WITHOUT_APPROVAL = new Set<String>{ QUOTE_NON_FUEL_PACKAGE_NF1};
    public final static Set<String> QUOTE_NON_FUEL_PACKAGE_WITH_APPROVAL = new Set<String>{ QUOTE_NON_FUEL_PACKAGE_NF3, QUOTE_NON_FUEL_PACKAGE_NF2 };   
}