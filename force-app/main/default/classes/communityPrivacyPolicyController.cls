/**
* @description   Apex controller of the lwc communityPrivacyPolicy
* @testClass     communityPrivacyPolicyController
* Modification Log 
* ------------------------------------------------------------------------------------  
* Developer                       Date                Description 
* Carolina Resende             22/09/2021           Created Class
* António Santos               28/09/2021           Improvements
* ------------------------------------------------------------------------------------ 
*/
public with sharing class communityPrivacyPolicyController {
    private static final String DEFAULT_COUNTRY_CODE = 'EN';    // English

    private static final String DEFAULT_TIMEZONE_KEY = 'DEFAULT';

    static Map<String,String> timeZoneCountryMap;
    static Map<String,PrivacyPolicyCountry__mdt> privacyPolicyCountryMap;

    public class BodyText {
        @AuraEnabled
        public String key { get; set; }

        @AuraEnabled
        public String text { get; set; }
    }

    public class PrivacyPolicy {
        @AuraEnabled
        public String title { get; set; }

/*
        @AuraEnabled
        public List<BodyText> bodyTextList { get; set; }
*/
        @AuraEnabled
        public String bodyText { get; set; }
    }

    public class PrivacyPolicyResult {
        @AuraEnabled
        public PrivacyPolicy countryPrivacyPolicy { get; set; }

        @AuraEnabled
        public PrivacyPolicy globalPrivacyPolicy { get; set; }
    }

    @AuraEnabled (cacheable=false)
    public static PrivacyPolicyResult getPrivacyPolicy(String browserTimeZone) {
        Id userId = UserInfo.getUserId();
        // International Scope is for countries outside of OMV domain of countries
        // In that case, the Privacy Policy will be the Austrian one translated to english
        // as setup in the Custom Metadata Type PrivacyPolicyCountries__mdt where TimeZone__c is NULL
        Boolean isInternationalScope = false;
        String userCountryCode;
        String identifiedCountryCode;
        String countryCode;

        initPrivacyPolicyCountryMaps();

        userCountryCode = getPortalUserCountryCode(userId);


        if (String.isNotBlank(browserTimeZone)) {
            String timeZoneKey = timeZoneCountryMap.containsKey(browserTimeZone) ? browserTimeZone : DEFAULT_TIMEZONE_KEY;

            identifiedCountryCode = timeZoneCountryMap.get(timeZoneKey);
        }

        if (String.isBlank(userCountryCode) && String.isBlank(identifiedCountryCode)) {
            // Site Guest User or User without Country Code
            // and
            // Could not identify country code from browser timezone
            isInternationalScope = true;
            countryCode = DEFAULT_COUNTRY_CODE;

        } else {
            if (String.isNotBlank(userCountryCode) && !privacyPolicyCountryMap.containsKey(userCountryCode)) {
                // User has country but is an unknown country for privacy policy
                isInternationalScope = true;
                countryCode = DEFAULT_COUNTRY_CODE;

            } else if (String.isNotBlank(userCountryCode) && privacyPolicyCountryMap.containsKey(userCountryCode)) {
                // User has country and it's a known country for privacy policy
                isInternationalScope = false;
                countryCode = userCountryCode;

            } else if (String.isNotBlank(identifiedCountryCode) && privacyPolicyCountryMap.containsKey(identifiedCountryCode)) {
                // User doesnt have a country but has been identified country by time zone and its a known country for privacy policy
                // e.g: user without country code or site guest user in an identified timezone
                isInternationalScope = false;
                countryCode = identifiedCountryCode;

            } else if (String.isNotBlank(identifiedCountryCode) && !privacyPolicyCountryMap.containsKey(identifiedCountryCode)) {
                // User doesnt have a country but has been identified country by time zone and its a non-known country code for privacy policy
                isInternationalScope = false;
                countryCode = DEFAULT_COUNTRY_CODE;

            }
        }

        return getPrivacyPolicyFor(countryCode);
    }

    public static PrivacyPolicyResult getPrivacyPolicyFor(String countryCode) {
        PrivacyPolicyResult result = new PrivacyPolicyResult();

        result.countryPrivacyPolicy = getPrivacyPolicyOfCountry(countryCode);
        result.globalPrivacyPolicy = getGlobalPrivacyPolicyOfCountry(countryCode);

        return result;
    }

    public static PrivacyPolicy getPrivacyPolicyOfCountry(String countryCode) {
        PrivacyPolicy result;

        if (String.isNotBlank(privacyPolicyCountryMap.get(countryCode).Title__c)) {
            result = new PrivacyPolicy();
            
            result.title = privacyPolicyCountryMap.get(countryCode).Title__c;
            result.bodyText = privacyPolicyCountryMap.get(countryCode).Body__c;
        }

        return result;
    }

    public static PrivacyPolicy getGlobalPrivacyPolicyOfCountry(String countryCode) {
        PrivacyPolicy result;

        if (String.isNotBlank(privacyPolicyCountryMap.get(countryCode).Title_English__c)) {
            result = new PrivacyPolicy();

            result.title = privacyPolicyCountryMap.get(countryCode).Title_English__c;
            result.bodyText = privacyPolicyCountryMap.get(countryCode).Body_English__c;
        }

        return result;
    }

    public static void initPrivacyPolicyCountryMaps() {
        Boolean isInit = false;

        if (privacyPolicyCountryMap == null) {
            privacyPolicyCountryMap = new Map<String,PrivacyPolicyCountry__mdt>();
            isInit = true;
        }

        if (timeZoneCountryMap == null) {
            timeZoneCountryMap = new Map<String,String>();
            isInit = true;
        }

        if (isInit) {
            REP_PrivacyPolicyCountry privacyPolicyCountryRepository = new REP_PrivacyPolicyCountry();

            timeZoneCountryMap = new Map<String,String>();

            for (PrivacyPolicyCountry__mdt privacyPolicyCountry : privacyPolicyCountryRepository.getPrivacyPolicyCountries()) {
                String timeZoneKey = privacyPolicyCountry.TimeZone__c != null ? privacyPolicyCountry.TimeZone__c : DEFAULT_TIMEZONE_KEY;

                timeZoneCountryMap.put(timeZoneKey, privacyPolicyCountry.CountryIsoCode__c);
                privacyPolicyCountryMap.put(privacyPolicyCountry.CountryIsoCode__c, privacyPolicyCountry);
            }
        }
    }

    public static String getPortalUserCountryCode(Id portalUserId) {
        REP_User userRepository = new REP_User();
        List<User> userList = userRepository.getPortalUserAndCompanyCode(new Set<Id> { portalUserId });
        String countryCode;

        if (!userList.isEmpty()) {
            countryCode = userList[0]?.Contact?.Account?.CompanyCodeCountry__c;
        }

        return countryCode;
    }    
}