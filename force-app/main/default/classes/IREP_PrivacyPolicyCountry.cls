/**
* @description   Privacy Policy Country Interface
* @testClass     IREP_PrivacyPolicyCountry
* Modification Log 
* ------------------------------------------------------------------------------------  
* Developer                       Date                Description 
* António Santos               28/09/2021           Created Privacy Policy Country Repository Interface
* ------------------------------------------------------------------------------------ 
*/
public interface IREP_PrivacyPolicyCountry extends FW_ISObjectRep {
    List<PrivacyPolicyCountry__mdt> getPrivacyPolicyCountries();
}