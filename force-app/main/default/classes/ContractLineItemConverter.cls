/**
 * Created by mateuszbednarek on 20/01/2021.
 * Edit by Joana Neto (Capgemini) on 01/06/2021 with custom object API name change
 */

public with sharing class ContractLineItemConverter {

    static List<ServiceContract> lineItemsToUpsert = new List<ServiceContract>();
    static Schema.sObjectField externalIdField = ServiceContract.Line_Item_Unique_Identifier__c.getDescribe().getSObjectField();
    static List<Schema.FieldSetMember>  lineItemFields = Util.readFieldSet('Contract_Line_Item',
            'FPS_Bor_Temporary_Storage__c');
    static Set<Schema.FieldSetMember>  fieldToConvertToNumber = new Set<Schema.FieldSetMember>(Util.readFieldSet
            ('Number_type_fields',
                    'FPS_Bor_Temporary_Storage__c'));

    static List<FPS_Bor_Temporary_Storage__c> contractsList;
    static Map<String, ServiceContract> extIdToContract = getContracts();
    public static void convert(List<FPS_Bor_Temporary_Storage__c> lineItems) {
        contractsList = lineItems;
        createLineItems();

        Util.upsertRecords(lineItemsToUpsert, externalIdField, ContractLineItemConverter.class,'convert');
    }

    private static void createLineItems() {
        for (FPS_Bor_Temporary_Storage__c contract : contractsList) {
            if(serviceContractExists(contract)){
                lineItemsToUpsert.add(createLineItem(contract));
            }

        }
    }

    private static ServiceContract createLineItem(FPS_Bor_Temporary_Storage__c temp){
        ServiceContract lineItem =  new ServiceContract(
                ParentServiceContract = getServiceContract(temp.CM_Master_Number__c),
                Line_Item_Unique_Identifier__c = temp.CM_Master_Number__c + '_' + temp.Posting_Period__c,
                Name = temp.CM_Master_Number__c + '_' + temp.Posting_Period__c,
                Description = temp.CM_Master_Description__c,
                Posting_Period__c = temp.Posting_Period_Date__c,
                OwnerId = getOwnerId(temp.CM_Master_Number__c),
                Customer_Name__c = getCustomerName(temp.CM_Master_Number__c),
                StartDate = temp.Valid_From_Date__c,
                EndDate = temp.Valid_To_Date__c
        );


        for(Schema.FieldSetMember field: lineItemFields){
            String fieldPath = field.getFieldPath();
            Object fieldValue = temp.get(fieldPath);
            Boolean onlyPositive = fieldPath != 'Adjusted_Quantity__c' && fieldPath != 'Open_Quantity__c' ;
            if(fieldShouldBeConvertedToNumber(fieldPath)){
                fieldValue = convertFieldToNumericValue(fieldValue,onlyPositive);
            }
            lineItem.put(fieldPath, fieldValue);
        }

        return lineItem;
    }
    private static Boolean fieldShouldBeConvertedToNumber(String pathName){
        for(Schema.FieldSetMember field: fieldToConvertToNumber){
            if(field.getFieldPath() == pathName) return true;
        }
        return false;
    }
    private static Object convertFieldToNumericValue(Object textValue, Boolean onlyPositive){
        if(textValue == null){
            return null;
        }
        Decimal value = Decimal.valueOf(String.valueOf(textValue).replaceAll(' ','').replaceAll(',','' +
                '.'));
        return value < 0 && onlyPositive ? value * -1 : value;
    }

    private static ServiceContract getServiceContract(String extId) {
        return new ServiceContract(CM_Master_Number__c = extId);
    }
    private static Id getOwnerId(String extId) {
        if(extIdToContract.containsKey(extId)){
            return extIdToContract.get(extId).OwnerId;
        }
        return null;
    }

    private static String getCustomerName(String extId) {
        if(extIdToContract.containsKey(extId)){
            return extIdToContract.get(extId).Customer_Name__c;
        }
        return null;
    }

    private static Map<String, ServiceContract> getContracts(){
        if(extIdToContract == null){
            extIdToContract = new Map<String, ServiceContract>();
            for(ServiceContract ctr: [SELECT Id, CM_Master_Number__c,OwnerId, Customer_Name__c FROM ServiceContract
            WHERE
                    Is_Master_Contract__c = TRUE]){
                extIdToContract.put(ctr.CM_Master_Number__c, ctr);
            }

        }
        return extIdToContract;
    }

    private static Boolean serviceContractExists(FPS_Bor_Temporary_Storage__c contract){
        return extIdToContract.containsKey(contract.CM_Master_Number__c);
    }
}