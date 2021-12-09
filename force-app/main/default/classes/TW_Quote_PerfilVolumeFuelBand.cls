/**
* @description   Based on the value of the field "Total Potential Fuel Volume" define the value of the field "Fuel Volume Band" 
* @testClass     TW_Quote_PerfilVolumeFuelBandTest
* Modification Log 
* ------------------------------------------------------------------------------------  
* Developer                     Date                Description 
* Carolina Resende              27/08/2021          Created Perfil Volume Fuel Band
* João Alencar                  23/09/2021          added validation on the quote type E-Mobility to fix bug 38918 on US35933
* ------------------------------------------------------------------------------------ 
*/

public class TW_Quote_PerfilVolumeFuelBand {
    
    public TW_Quote_PerfilVolumeFuelBand(){}
    
    public void execute(List<Quote> quoteList, Map<Id,Quote> quoteOldMap){ 
        //check all Quotes in the List
        for(Quote quoteToUpdate : quoteList){
            if( quoteOldMap == null || (quoteOldMap.get(quoteToUpdate.Id).TotalPotentialFuelVolume__c != quoteToUpdate.TotalPotentialFuelVolume__c) ){
                populateFuelVolumeBand(quoteToUpdate);                  
            }     
        }
    }
    
    private void populateFuelVolumeBand(Quote quoteToUpdate){
        if(quoteToUpdate.QuoteType__c == DO_Quote.QUOTE_TYPE_EMOBILITY || string.isBlank(String.valueOf(quoteToUpdate.TotalPotentialFuelVolume__c))){
            quoteToUpdate.FuelVolumeBand__c = null;
        }
        else if(quoteToUpdate.TotalPotentialFuelVolume__c <= 10){
            quoteToUpdate.FuelVolumeBand__c = DO_Quote.QUOTE_VOLUMEFUELBAND_V10;
        }
        else if(quoteToUpdate.TotalPotentialFuelVolume__c > 10 && quoteToUpdate.TotalPotentialFuelVolume__c <=30){
            quoteToUpdate.FuelVolumeBand__c = DO_Quote.QUOTE_VOLUMEFUELBAND_V30;
        }
        else if(quoteToUpdate.TotalPotentialFuelVolume__c >30 && quoteToUpdate.TotalPotentialFuelVolume__c <=60){
            quoteToUpdate.FuelVolumeBand__c = DO_Quote.QUOTE_VOLUMEFUELBAND_V60;
        }
        else if(quoteToUpdate.TotalPotentialFuelVolume__c >60 && quoteToUpdate.TotalPotentialFuelVolume__c <=100){
            quoteToUpdate.FuelVolumeBand__c = DO_Quote.QUOTE_VOLUMEFUELBAND_V100;
        } 
        else if(quoteToUpdate.TotalPotentialFuelVolume__c >100 && quoteToUpdate.TotalPotentialFuelVolume__c <=150){
            quoteToUpdate.FuelVolumeBand__c = DO_Quote.QUOTE_VOLUMEFUELBAND_V150;
        }
        else if(quoteToUpdate.TotalPotentialFuelVolume__c >150 && quoteToUpdate.TotalPotentialFuelVolume__c <=250){
            quoteToUpdate.FuelVolumeBand__c = DO_Quote.QUOTE_VOLUMEFUELBAND_V250;
        }
        else if(quoteToUpdate.TotalPotentialFuelVolume__c >250 && quoteToUpdate.TotalPotentialFuelVolume__c <=500){
            quoteToUpdate.FuelVolumeBand__c = DO_Quote.QUOTE_VOLUMEFUELBAND_V500;
        }
        else if(quoteToUpdate.TotalPotentialFuelVolume__c >500 && quoteToUpdate.TotalPotentialFuelVolume__c <=750){
            quoteToUpdate.FuelVolumeBand__c = DO_Quote.QUOTE_VOLUMEFUELBAND_V750;
        }
        else if(quoteToUpdate.TotalPotentialFuelVolume__c >750 && quoteToUpdate.TotalPotentialFuelVolume__c <=1000){
            quoteToUpdate.FuelVolumeBand__c = DO_Quote.QUOTE_VOLUMEFUELBAND_V1000;
        }
        else{
            quoteToUpdate.FuelVolumeBand__c = DO_Quote.QUOTE_VOLUMEFUELBAND_VM;
        }
    }
}