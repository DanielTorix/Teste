/**
 * Created by mateuszbednarek on 20/01/2021.
 * Edit by Joana Neto (Capgemini) on 01/06/2021 with custom object API name change
*/

public with sharing class ServiceContractConverter {

    static List<ServiceContract> contractsToUpsert = new List<ServiceContract>();
    static Schema.sObjectField externalIdField = ServiceContract.CM_Master_Number__c.getDescribe().getSObjectField();
    static Id standardPricebookId = getPricebookId();
    static List<FPS_Bor_Temporary_Storage__c> contractsList;
    static List<Schema.FieldSetMember>  lineItemFields = Util.readFieldSet('Contract_Line_Item',
            'FPS_Bor_Temporary_Storage__c');
    static Set<Schema.FieldSetMember>  fieldToConvertToNumber = new Set<Schema.FieldSetMember>(Util.readFieldSet
            ('Number_type_fields',
                    'FPS_Bor_Temporary_Storage__c'));
    static Map<String, User> externalIdToInternalUser = getInternalUsersMap();
    static Map<String, User> accountExternalIdToExternalUser = getExternalUsersMap();
    static Map<String, Account> externalIdToAccount = getAccountsMap();

    public static void convert(List<FPS_Bor_Temporary_Storage__c> contracts) {
        contractsList = contracts;
        createServiceContracts();

        Util.upsertRecords(contractsToUpsert,externalIdField, ServiceContractConverter.class,'convert');
    }

    private static void createServiceContracts() {
        for (FPS_Bor_Temporary_Storage__c contract : contractsList) {
            if(customerExists(contract)){
                contractsToUpsert.add(createContract(contract));
            }

        }
    }

    private static ServiceContract createContract(FPS_Bor_Temporary_Storage__c temp){
        validateCustomer(temp);
        ServiceContract contract =  new ServiceContract(
                Is_Master_Contract__c = true,
                Account = getAccount(temp.Customer__c),
                CM_Master_Number__c = temp.CM_Master_Number__c,
                Pricebook2Id = standardPricebookId,
                OwnerId = getUser(temp),
                Customer_Name__c = getAccountName(temp.Customer__c),
                Name = temp.Customer__c+'_'+temp.Product_Group__c,
                Plus_Tolerance__c = temp.Plus_tolerance_in__c == null ? 0 : Decimal.valueOf(String.valueOf(temp
                        .Plus_tolerance_in__c).replaceAll(' ','').replaceAll(',','.')),
                Minus_Tolerance__c = temp.Minus_tolerance_in__c == null ? 0 : Decimal.valueOf(String.valueOf(temp
                        .Minus_tolerance_in__c).replaceAll(' ','')
                        .replaceAll(',','.')),
                Description = temp.CM_Master_Description__c,
                StartDate = temp.Valid_From_Date__c,
                EndDate = temp.Valid_To_Date__c,
                Plant__c = temp.Plant__c
        );

        for(Schema.FieldSetMember field: lineItemFields){
            String fieldPath = field.getFieldPath();
            Object fieldValue = temp.get(fieldPath);
            if(fieldShouldBeConvertedToNumber(fieldPath)){
                fieldValue = convertFieldToNumericValue(fieldValue);
            }
            contract.put(fieldPath, fieldValue);
        }

        return contract;
    }

    //Items related to 3058619 Customer should be actually linked to 123418
    private static void validateCustomer(FPS_Bor_Temporary_Storage__c tmp){
        if(tmp.Customer__c == '3058619'){
            tmp.Customer__c = '123418';
        }
    }

    private static Boolean fieldShouldBeConvertedToNumber(String pathName){
        for(Schema.FieldSetMember field: fieldToConvertToNumber){
            if(field.getFieldPath() == pathName) return true;
        }
        return false;
    }

    private static Object convertFieldToNumericValue(Object textValue){
        if(textValue == null){
            return null;
        }
        Decimal value = Decimal.valueOf(String.valueOf(textValue).replaceAll(' ','').replaceAll(',','' +
                '.'));
        return value < 0 ? value * -1 : value;
    }

    private static Account getAccount(String extId) {
        return new Account(ExternalId__c = extId);
    }
    private static String getAccountName(String extId){
        if(externalIdToAccount.containsKey(extId)){
            return externalIdToAccount.get(extId).Name;
        }else{
            return null;
        }

    }
    private static Id getUser(FPS_Bor_Temporary_Storage__c contract){
        if(isActiveContract(contract)){
            if(accountExternalIdToExternalUser.containsKey(contract.Customer__c)){
                return accountExternalIdToExternalUser.get(contract.Customer__c).Id;
            }
        }else{
            if(externalIdToInternalUser.containsKey(contract.Sales_Representative__c)){
                return externalIdToInternalUser.get(contract.Sales_Representative__c).Id;
            }
        }
        return externalIdToInternalUser.get('DUMMY').Id;
    }
    private static Boolean isActiveContract(FPS_Bor_Temporary_Storage__c contract){
        return Date.today().year() - contract.Valid_To_Date__c.year() <= 1;
    }
    private static Id getPricebookId(){
        if(Test.isRunningTest()){
            return Test.getStandardPricebookId();
        }
        if(standardPricebookId == null){
            return[SELECT Id FROM Pricebook2 WHERE IsStandard = true].Id;
        }else{
            return standardPricebookId;
        }
    }
    private static Map<String, Account> getAccountsMap(){
        if(externalIdToAccount == null){
            externalIdToAccount = new Map<String, Account>();
            for(Account acc: [SELECT Id, Name,ExternalId__c FROM Account WHERE ExternalId__c != null]){
                externalIdToAccount.put(acc.ExternalId__c, acc);
            }
        }
        return externalIdToAccount;
    }
    private static Map<String, User> getInternalUsersMap(){
        if(externalIdToInternalUser == null){
            externalIdToInternalUser = new Map<String, User>();
            for(User usr: [SELECT Id, Sales_Representative__c FROM User WHERE Sales_Representative__c != null]){
                externalIdToInternalUser.put(usr.Sales_Representative__c, usr);
            }

        }
        return externalIdToInternalUser;
    }

    private static Map<String, User> getExternalUsersMap(){
        if(accountExternalIdToExternalUser == null){
            accountExternalIdToExternalUser = new Map<String, User>();
            for(User usr: [SELECT Account.ExternalId__c,Account.Name,Account.Id,Id,Username,Email,UserRole.Name,
                    UserRole.PortalRole,UserRole.PortalType FROM User WHERE UserRole.Name LIKE '%Customer User' AND Account.ExternalId__c != null]){
                accountExternalIdToExternalUser.put(usr.Account.ExternalId__c, usr);
            }
        }
        return accountExternalIdToExternalUser;
    }

    private static Boolean customerExists(FPS_Bor_Temporary_Storage__c contract){
        return externalIdToAccount.containsKey(contract.Customer__c);
    }
}