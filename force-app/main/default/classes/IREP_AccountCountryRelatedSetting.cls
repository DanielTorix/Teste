/**
* @description   interface for the AccountCountryRelatedSetting Repository
* Modification Log 
* ------------------------------------------------------------------------------------  
* Developer                       Date                Description 
* Guilherme Charro               02/09/2021           interface for the AccountCountryRelatedSetting Repository
* ------------------------------------------------------------------------------------ 
*/
public interface IREP_AccountCountryRelatedSetting extends FW_ISObjectRep{
    List<AccountCountryRelatedSetting__mdt> getAllAccountCountryRelated();
}