/**
* @Class     TW_Quote_PerfilVolumeFuelBand
* Modification Log 
* ------------------------------------------------------------------------------------  
* Developer                     Date                Coverage 
* Carolina Resende              27/08/2021          100%
* ------------------------------------------------------------------------------------ 
*/
@isTest
public with sharing class TW_Quote_PerfilVolumeFuelBandTest {
    static fflib_ApexMocks mocks = new fflib_ApexMocks();
    
    @isTest
    private static void TW_Quote_PerfilVolumeFuelBandTest() {
        
        List<Quote> quoteList = new List<Quote>{
            new Quote(
                Id = fflib_IDGenerator.generate(Quote.sObjectType),
                TotalPotentialFuelVolume__c = 0
            ),
            new Quote(
                Id = fflib_IDGenerator.generate(Quote.sObjectType),
                TotalPotentialFuelVolume__c = 20
            ) ,
            new Quote(
                Id = fflib_IDGenerator.generate(Quote.sObjectType),
                TotalPotentialFuelVolume__c = 50
            ) ,
            new Quote(
                Id = fflib_IDGenerator.generate(Quote.sObjectType),
                TotalPotentialFuelVolume__c = 100
            ) ,
            new Quote(
                Id = fflib_IDGenerator.generate(Quote.sObjectType),
                TotalPotentialFuelVolume__c = 150
            ) ,
            new Quote(
                Id = fflib_IDGenerator.generate(Quote.sObjectType),
                TotalPotentialFuelVolume__c = 250
            ) ,
            new Quote(
                Id = fflib_IDGenerator.generate(Quote.sObjectType),
                TotalPotentialFuelVolume__c = 500
            ) ,
            new Quote(
                Id = fflib_IDGenerator.generate(Quote.sObjectType),
                TotalPotentialFuelVolume__c = 750
            ),
            new Quote(
                Id = fflib_IDGenerator.generate(Quote.sObjectType),
                TotalPotentialFuelVolume__c = 1000
            ),
            new Quote(
                Id = fflib_IDGenerator.generate(Quote.sObjectType),
                TotalPotentialFuelVolume__c = 1500
            ),
            new Quote(
                Id = fflib_IDGenerator.generate(Quote.sObjectType),
                TotalPotentialFuelVolume__c = null
            )
        };
          
            
        List<Quote> quoteUpdateOldList = new List<Quote>{
            new Quote(
                Id = quoteList[0].Id,
                TotalPotentialFuelVolume__c = 1500
            ),
            new Quote(
                Id = quoteList[1].Id,
                TotalPotentialFuelVolume__c = 1000
            ) ,
            new Quote(
                Id = quoteList[2].Id,
                TotalPotentialFuelVolume__c = 750
            ) ,
            new Quote(
                Id = quoteList[3].Id,
                TotalPotentialFuelVolume__c = 500
            ) ,
            new Quote(
                Id = quoteList[4].Id,
                TotalPotentialFuelVolume__c = 250
            ) ,
            new Quote(
                Id = quoteList[5].Id,
                TotalPotentialFuelVolume__c = 150
            ) ,
            new Quote(
                Id = quoteList[6].Id,
                TotalPotentialFuelVolume__c = 100
            ) ,
            new Quote(
                Id = quoteList[7].Id,
                TotalPotentialFuelVolume__c = 50
            ),
            new Quote(
                Id = quoteList[8].Id,
                TotalPotentialFuelVolume__c = 10
            ),
            new Quote(
                Id = quoteList[9].Id,
                TotalPotentialFuelVolume__c = null
            ),
            new Quote(
                Id = quoteList[10].Id,
                TotalPotentialFuelVolume__c = 0
            ) 
        };

        Map<Id, Quote> oldQuotesMap = new Map<Id, Quote>(quoteUpdateOldList);

        Test.startTest();
        TW_Quote_PerfilVolumeFuelBand perfilVolumeFuelBandExecutionWorker = new TW_Quote_PerfilVolumeFuelBand();
        perfilVolumeFuelBandExecutionWorker.execute(quoteList, null); 
        perfilVolumeFuelBandExecutionWorker.execute(quoteList, oldQuotesMap); 
        Test.stopTest();
        System.assertEquals(DO_Quote.QUOTE_VOLUMEFUELBAND_V10, quoteList[0].FuelVolumeBand__c);
        System.assertEquals(DO_Quote.QUOTE_VOLUMEFUELBAND_V30, quoteList[1].FuelVolumeBand__c);
        System.assertEquals(DO_Quote.QUOTE_VOLUMEFUELBAND_V60, quoteList[2].FuelVolumeBand__c);
        System.assertEquals(DO_Quote.QUOTE_VOLUMEFUELBAND_V100, quoteList[3].FuelVolumeBand__c);
        System.assertEquals(DO_Quote.QUOTE_VOLUMEFUELBAND_V150, quoteList[4].FuelVolumeBand__c);
        System.assertEquals(DO_Quote.QUOTE_VOLUMEFUELBAND_V250, quoteList[5].FuelVolumeBand__c);
        System.assertEquals(DO_Quote.QUOTE_VOLUMEFUELBAND_V500, quoteList[6].FuelVolumeBand__c);
        System.assertEquals(DO_Quote.QUOTE_VOLUMEFUELBAND_V750, quoteList[7].FuelVolumeBand__c);
        System.assertEquals(DO_Quote.QUOTE_VOLUMEFUELBAND_V1000, quoteList[8].FuelVolumeBand__c);
        System.assertEquals(DO_Quote.QUOTE_VOLUMEFUELBAND_VM, quoteList[9].FuelVolumeBand__c);
        System.assertEquals(null, quoteList[10].FuelVolumeBand__c);
    }
}