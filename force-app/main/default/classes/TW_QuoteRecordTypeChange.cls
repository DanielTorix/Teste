/**
* @description   worker class to change RecordType on Quote depending on Competitive Fuel Band
* @testClass     TW_QuoteRecordTypeChangeTest
* Modification Log 
* ------------------------------------------------------------------------------------  
* Developer                       Date                Description 
* Hugo Rodrigues               10/08/2021          Created Quote Worker
* ------------------------------------------------------------------------------------ 
*/
public with sharing class TW_QuoteRecordTypeChange {
   
     //method execute
     public void execute(List<Quote> quoteList, Map<ID,Quote> quoteOldMap){
       
        //store ID of recordType
        ID quoteWithApprovalID  =DO_Quote.QUOTE_CARDS_WITH_APPROVAL_RECORDTYPE_ID;
        ID quoteWithoutApprovalID =DO_Quote.QUOTE_CARDS_RECORDTYPE_ID;

        
        //check the quotes
        for(Quote quoteRecord: quoteList){
           //Check if the competitive band fuel of the quote requires approval or not and checks if the current record type is correct according to that, if not then changes to the correct record type.
            if( quoteOldMap == null || quoteOldMap.get(quoteRecord.Id).CompetitiveBandFuel__c != quoteRecord.CompetitiveBandFuel__c || quoteOldMap.get(quoteRecord.Id).NonFuelCompetitivePackage__c != quoteRecord.NonFuelCompetitivePackage__c ){
               if( ( DO_Quote.QUOTE_NON_FUEL_PACKAGE_WITH_APPROVAL.contains( quoteRecord.NonFuelCompetitivePackage__c ) || DO_Quote.QUOTE_COMPETITIVE_BAND_FUELS_WITH_APPROVAL.contains( quoteRecord.CompetitiveBandFuel__c ))&& quoteRecord.RecordTypeID != quoteWithApprovalID ){
                    quoteRecord.RecordTypeID = quoteWithApprovalID;
                }else if( DO_Quote.QUOTE_COMPETITIVE_BAND_FUELS_WITHOUT_APPROVAL.contains( quoteRecord.CompetitiveBandFuel__c )  && (DO_Quote.QUOTE_NON_FUEL_PACKAGE_WITHOUT_APPROVAL.contains( quoteRecord.NonFuelCompetitivePackage__c ) || quoteRecord.NonFuelCompetitivePackage__c ==null ) && quoteRecord.RecordTypeID != quoteWithoutApprovalID ){
                    quoteRecord.RecordTypeID = quoteWithoutApprovalID;
                }
            }            
        }
     }
}