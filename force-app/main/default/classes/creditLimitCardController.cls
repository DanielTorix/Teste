public with sharing class creditLimitCardController {
    public static final String CREDIT_LIMIT_HEADER = 'Credit Limit Information';
    public static final String CREDIT_LIMIT_LABEL = 'Credit Limit';
    public static final String REMAINING_CREDIT_LIMIT_LABEL = 'Remaining Credit Limit';
    public static final String OPEN_ITEMS_LABEL = 'Open Items';
    public static final String VALID_UNTIL_LABEL = 'Valid Until';
    public static final String LAST_UPDATE_DATE_LABEL = 'Last Update Date';

    public static final String CREDIT_LIMIT_ICON = 'creditlimiticon1';
    public static final String REMAINING_CREDIT_LIMIT_ICON = 'creditlimiticon2';
    public static final String OPEN_ITEMS_ICON = 'creditlimiticon3';
    public static final String VALID_UNTIL_ICON = 'creditlimiticon4';
    public static final String LAST_UPDATE_DATE_ICON = 'creditlimiticon5';

    public class CreditLimitItem {
        @AuraEnabled
        public String iconUrl { get; set; }

        @AuraEnabled
        public String label { get; set; }

        @AuraEnabled
        public Decimal value { get; set; }

        @AuraEnabled
        public Datetime dateValue { get; set; }

        @AuraEnabled
        public Integer position { get; set; }

        @AuraEnabled
        public String formatValue {
            get {
                if (dateValue != null) {
                    return dateValue.format('dd.MM.yyyy');
                } else {
                    return String.format(
                        value.format(),
                        new String[] {
                            '0', 'number', '###,###,##0.00'
                        }
                    ) + ' €';
                }
            }
        }

        public CreditLimitItem(String iconUrl, String label, Decimal value, Datetime dateValue, Integer position) {
            this.iconUrl = iconUrl;
            this.label = label;
            this.value = value;
            this.dateValue = dateValue;
            this.position = position;
        }
    }

    public class CreditLimitResult {
        @AuraEnabled
        public String header { get; set; }

        @AuraEnabled
        public List<CreditLimitItem> creditLimitItemList { get; set; }

        public CreditLimitResult() {
            creditLimitItemList = new List<CreditLimitItem>();
        }
    }

    @AuraEnabled
    public static CreditLimitResult getCreditLimitDetails() {
        REP_User repUser = new REP_User();
        List<User> userList = repUser.getPortalUserAndCompanyCode(new Set<Id> { UserInfo.getUserId() });
        Id accountId;
        Integer position = 0;

        if (userList != null && !userList.isEmpty()) {
            accountId = userList[0].Contact.AccountId;
        }

        Account account = [
            SELECT
                Id,
                CreditLimit__c,
                RemainingCreditLimit__c,
                OpenItems__c,
                ValidUntil__c,
                LastUpdateDate__c
            FROM
                Account
            WHERE
                Id = :accountId
        ];

        CreditLimitResult result = new CreditLimitResult();

        REP_StaticResource repStaticResource = new REP_StaticResource();
        Map<String,String> iconUrlMap = repStaticResource.getStaticResourceBySet(
            new Set<String> {
                CREDIT_LIMIT_ICON,
                REMAINING_CREDIT_LIMIT_ICON,
                OPEN_ITEMS_ICON,
                VALID_UNTIL_ICON,
                LAST_UPDATE_DATE_ICON
            }
        );
        
        result.header = CREDIT_LIMIT_HEADER;

        result.creditLimitItemList.add(
            new CreditLimitItem(
                iconUrlMap.get(CREDIT_LIMIT_ICON),
                CREDIT_LIMIT_LABEL,
                account.CreditLimit__c,
                null,
                ++position
            )
        );

        result.creditLimitItemList.add(
            new CreditLimitItem(
                iconUrlMap.get(REMAINING_CREDIT_LIMIT_ICON),
                REMAINING_CREDIT_LIMIT_LABEL,
                account.RemainingCreditLimit__c,
                null,
                ++position
            )
        );

        result.creditLimitItemList.add(
            new CreditLimitItem(
                iconUrlMap.get(OPEN_ITEMS_ICON),
                OPEN_ITEMS_LABEL,
                account.OpenItems__c,
                null,
                ++position
            )
        );

        result.creditLimitItemList.add(
            new CreditLimitItem(
                iconUrlMap.get(VALID_UNTIL_ICON),
                VALID_UNTIL_LABEL,
                null,
                account.ValidUntil__c,
                ++position
            )
        );

        result.creditLimitItemList.add(
            new CreditLimitItem(
                iconUrlMap.get(LAST_UPDATE_DATE_ICON),
                LAST_UPDATE_DATE_LABEL,
                null,
                account.LastUpdateDate__c,
                ++position
            )
        );

        return result;
    }
}