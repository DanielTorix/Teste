/**
* @description   Interface for the CEPFPSEmailBranding Repository
* @testClass     N/A
* Modification Log 
* ------------------------------------------------------------------------------------  
* Developer                       Date                Description 
*Hugo Rodrigues               15/11/2021         Interface for the  CEPFPSEmailBranding Repository
* ------------------------------------------------------------------------------------ 
*/
public interface IREP_CEPFPSEmailBranding extends FW_ISObjectRep{
    CEPFPSEmailBranding__mdt getCEPFPSEmailBranding(String CustomerCountry);
}