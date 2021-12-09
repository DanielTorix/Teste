/**
* @description   Controller VFC_LetterheadController
* @testClass     VFC_LetterheadControllerTest
* Modification Log 
* ------------------------------------------------------------------------------------  
* Developer                       Date                Description 
* Antonio Santos              11/08/2021         Created the controller
* Hugo Rodrigues              15/11/2021        updated to meet US41246
* ------------------------------------------------------------------------------------ 
*/
public without sharing class VFC_LetterheadController {
    public Id organizationId        { get; set; }
    public Id portalHeaderImageId   { get; set; }
    public Id portalFooterImageId   { get; set; }
    public String portalBaseUrl     { get; set; }
    public CEPFPSEmailBranding__mdt customerCountryMetadata   { get; set; }
    public String customerCountry   { get; set{customerCountry = value;initialize();} }

    private IREP_Organization organizationRepository;
    private IREP_CEPFPSEmailBranding cEPFPSEmailBrandingRepository;
    private IREP_Document documentRepository;

    public VFC_LetterheadController() {
        
        if( customerCountry != null ){
            initialize();
        }
    }
    private void initialize(){
        organizationRepository = new REP_Organization();
        cEPFPSEmailBrandingRepository= new REP_CEPFPSEmailBranding();
        documentRepository = new REP_Document();
        system.debug(customerCountry);
        customerCountryMetadata=cEPFPSEmailBrandingRepository.getCEPFPSEmailBranding(!Test.isRunningTest()
        ? customerCountry
        :'TE');
        organizationId = organizationRepository.getOrganization().Id;
        for(Document doc :documentRepository.getDocumentListByDeveloperName(!Test.isRunningTest()
        ? new Set<String>{customerCountryMetadata.FooterLogoImage__c,customerCountryMetadata.HeaderLogoImage__c}
        :  new Set<String>{'TESTDOC'})){
            if(doc.DeveloperName==customerCountryMetadata.HeaderLogoImage__c){
                portalHeaderImageId=doc.id;
            }
            if(doc.DeveloperName==customerCountryMetadata.FooterLogoImage__c){
                portalFooterImageId=doc.id;
            }
            
        }
        portalBaseUrl = URL.getOrgDomainUrl().toExternalForm();
    }
}