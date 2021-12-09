public with sharing class oMVPortalMainMenuControler {

    public class OmvUserLayout {
        @AuraEnabled
        public User userInfo { get; set; }

        @AuraEnabled
        public OMVPortalLayoutConfiguration__c layoutConfiguration { get; set; }

        @AuraEnabled
        public String imageUrlString { get; set; }
    }

    @AuraEnabled(cacheable=true)
    //public static sObject getOMVPortalLayout() {
    public static OmvUserLayout getOMVPortalLayout() {
        REP_User userRepository = new REP_User();
        REP_StaticResource stacticResourceRepository = new REP_StaticResource();
        User userRecord = new User();
        String userCountry;
        REP_OMVPortalLayoutConfiguration portalRepository = new REP_OMVPortalLayoutConfiguration();
        OMVPortalLayoutConfiguration__c portalObject= new  OMVPortalLayoutConfiguration__c();
        OmvUserLayout userLayout = new OmvUserLayout();
        Set<String> imageSet = new Set<String>();
        userRecord=userRepository.getPortalUserAndCompanyCode(new Set<Id>{UserInfo.getUserId()}).get(0);

        if(userRecord!=null){
            userCountry=userRecord.Contact.Account.CompanyCodeCountry__c;
        }

        if (String.isBlank(userCountry)) {
            userCountry = 'AT';
        }

        if(userCountry !=null){
            portalObject = portalRepository.getOMVPortalLayoutbyCountry(userCountry);
        }
        imageSet.add(portalObject.HeaderLogo__c);
        userLayout.userInfo = userRecord;
        userLayout.layoutConfiguration = portalObject;
        
        Map<String,String> iconUrlMap = stacticResourceRepository.getStaticResourceBySet(imageSet);
        userLayout.imageUrlString=iconUrlMap.get(portalObject.HeaderLogo__c);
        return userLayout;
        
    }
}