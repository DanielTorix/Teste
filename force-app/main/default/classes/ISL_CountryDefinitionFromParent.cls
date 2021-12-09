/**
* @description   Intervace class to define the country field from accounts
* Modification Log 
* ------------------------------------------------------------------------------------  
* Developer                       Date                Description 
* Guilherme Charro                02/09/2021          Created class
* ------------------------------------------------------------------------------------ 
*/
public interface ISL_CountryDefinitionFromParent {
    void setCountryField(List<SObject> sobjectList, String countryAPIname, String accountLookupAPIname);
}