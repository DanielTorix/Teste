/**
    * @description   Utility class to create records for tests
    * @testClass     N/A
    * Modification Log 
	* ------------------------------------------------------------------------------------  
	* Developer                       Date                Description  
    * João Alencar                    03/11/2021          changed the method createUsers to avoid a recurring error
    * ------------------------------------------------------------------------------------ 
*/
@isTest
public without sharing class FW_TestDataFactory{

    public static List<Batch_Definition__c> createBatchDefinition(Integer numberOfRecords, Boolean doInsert) {
        List<Batch_Definition__c> objList = new List<Batch_Definition__c>();
        
        for(Integer i = 0; i < numberOfRecords; i++) {
            objList.add(new Batch_Definition__c(
                Batch_Name__c = 'Test ' + i,
                Class_Name__c = 'Test ' + i,
                SObject_API_Name__c = 'Batch_Definition__c'
            ));
        }

        if(doInsert && !objList.isEmpty()) {
            insert objList;
        }
        return objList;
    }

    public static void createDisableErrorLogging() {
        insert new FW_DisableErrorLogging__c(
            All__c = true,
            CalloutException__c = true,
            DMLException__c = true,
            QueryException__c = true
        );
    }

    public static List<Error_Log__c> createErrorLog(Integer numberOfRecords, Boolean doInsert) {
        List<Error_Log__c> objList = new List<Error_Log__c>();
        
        for(Integer i = 0; i < numberOfRecords; i++){
            objList.add(new Error_Log__c());
        }

        if(doInsert && !objList.isEmpty()) {
            insert objList;
        }
        return objList;
    }

    public static List<Job_Execution__c> createJobExecution(Integer numberOfRecords, Boolean doInsert, String objRecordTypeName, Id batchDefinitionId) {
        Id rTypeId = getRecordTypeIdByDevName('Job_Execution__c', objRecordTypeName);
        
        List<Job_Execution__c> objList = new List<Job_Execution__c>();
        
        for(Integer i = 0; i < numberOfRecords; i++) {
            objList.add(new Job_Execution__c(
              Run_With_Defaults__c = true,
              RecordTypeId = rTypeId,
              Batch_Definition__c = batchDefinitionId
            ));
        }

        if(doInsert && !objList.isEmpty()) {
            insert objList;
        }
        return objList;
    }

    public static List<Parameters__c> createParameter(Integer numberOfRecords, Boolean doInsert) {
        List<Parameters__c> objList = new List<Parameters__c>();
        
        for(Integer i = 0; i < numberOfRecords; i++) {
            objList.add(new Parameters__c());
        }

        if(doInsert && !objList.isEmpty()) {
            insert objList;
        }
        return objList;
    }

     public static List<User> createUsers(Integer numberOfRecords, Boolean doInsert, String userProfileName, Id contactId) {
        Id userProfileId = [SELECT Id FROM Profile WHERE Name = :userProfileName LIMIT 1].Id;
        List<User> objList = new List<User>();
        
        for(Integer i = 0; i < numberOfRecords; i++) {
            objList.add(new User(
                LastName            = 'Test Last Name ' + i,
                Alias               = string.valueof(Math.abs(Crypto.getRandomLong())).substring(0, 6),
                Username            = 'Test' + string.valueof(Math.abs(Crypto.getRandomLong())).substring(0, 6) + i + '@omvtest.com',
                CommunityNickname   = 'Test' + string.valueof(Math.abs(Crypto.getRandomLong())).substring(0, 6) + i,
                ProfileId           = userProfileId,
                Email               = 'testemail' + i + '@test.com',
                TimeZoneSidKey      = 'Europe/Paris',
                LocaleSidKey        = 'fr_BE', 
                EmailEncodingKey    = 'ISO-8859-1',
                LanguageLocaleKey   = 'en_US',
                ContactId           = contactId
            ));
        }

        if(doInsert && !objList.isEmpty()) {
            insert objList;
        }

        return objList;
    }

    public static FW_TriggerHandlerSettings__c createTriggerHandlerSettingInactive(Boolean doAll, Boolean doInsert) {

        FW_TriggerHandlerSettings__c triggerHandlerSettings = new FW_TriggerHandlerSettings__c();
        SObjectType accountType = Schema.getGlobalDescribe().get('FW_TriggerHandlerSettings__c');
        Map<String,Schema.SObjectField> mfields = accountType.getDescribe().fields.getMap();
        
        for(Schema.SObjectField sfield : mfields.Values()) {
            schema.describefieldresult dfield = sfield.getDescribe();
            string namefield = dfield.getname();
            if(namefield.endsWith('__c')) {
                triggerHandlerSettings.put(namefield, false);
            }        
        }
        triggerHandlerSettings.put('All__c', doAll);

        if(doInsert) {
            insert triggerHandlerSettings;
        }
        return triggerHandlerSettings;
    }

    public static List<CleanErrorLogBatchSettings__c> createCleanErrorLogBatchSettings(Integer numberOfRecords, Boolean doInsert) {
        List<CleanErrorLogBatchSettings__c> objList = new List<CleanErrorLogBatchSettings__c>();
        
        for(Integer i = 0; i < numberOfRecords; i++) {
            objList.add(new CleanErrorLogBatchSettings__c(
              Name = 'Default',
              NumberOfDays__c = 2
            ));
        }

        if(doInsert && !objList.isEmpty()) {
            insert objList;
        }
        return objList;
    }

    private static Id getRecordTypeIdByDevName(String sObjType, String devName){

        Id recTypeId = null;

        try {
            final Map<String, Schema.SObjectType> sObjectTypeMap = Schema.getGlobalDescribe();
            if (sObjectTypeMap.containsKey(sObjType)) {
                final Map<String, Schema.RecordTypeInfo> recordTypeInfoMap = sObjectTypeMap.get(sObjType).getDescribe().getRecordTypeInfosByDeveloperName();
                if (recordTypeInfoMap.containsKey(devName)) {
                    recTypeId = recordTypeInfoMap.get(devName).getRecordTypeId();
                }
            }
        } catch (Exception e) {
            System.debug( e.getLineNumber() + ' ' + e.getMessage());
        }

        return recTypeId;
    }
    
    public static void createCepConfiguration(){
        CEP_Configuration__c setting = new CEP_Configuration__c();
        setting.OMVEmailDomains__c = 'omv.com,petrom.com,borealisgroup.com,external.petrom.com,external.omv.com';
        insert setting;
    }
    
    public static List<Case> createCase(Integer numberOfRecords, Boolean doInsert) {
        if (CEP_Configuration__c.getOrgDefaults().OMVEmailDomains__c == null) {
            createCepConfiguration();
        }        
        
        List<Case> objList = new List<Case>();
        
        for(Integer i = 0; i < numberOfRecords; i++) {
            objList.add(new Case(
                Origin = 'Customer Representative',
                Channel__c = 'Email',
                CategoryT1__c = 'Spam',
                Source__c = 'Other' 
            ));
        }

        if(doInsert && !objList.isEmpty() && objList != null) {
            insert objList;
        }
        return objList;
    }
    
    public static List<Opportunity> createOpportunity(Integer numberOfRecords, Boolean doInsert) {
        List<Opportunity> objListOpportunity = new List<Opportunity>();
        List<Account> objListAccount = new List<Account>();

        
        objListAccount.add(new Account(
                Name = 'test',
                ExternalId__c='1234'
            ));
        
        for(Integer i = 0; i < numberOfRecords; i++) {
            objListOpportunity.add(new Opportunity(
                Name = 'test',
                AccountId=objListAccount[0].Id,
                CloseDate=System.today().addMonths(1),
                StageName='Qualification',
                OpportunityCategory__c=Do_opportunity.OPPORTUNITY_CATEGORY_CARDS
            ));
        }

        if(doInsert && !objListOpportunity.isEmpty()) {
            insert objListOpportunity;
        }
        return objListOpportunity;
    }
    public static List<Account> createAccount(Integer numberOfRecords, Boolean doInsert) {
        List<Account> objListAccount = new List<Account>();

        for(Integer i = 0; i < numberOfRecords; i++) {
            objListAccount.add(new Account(
                Name = 'test',
                ExternalId__c='1234'+i
            ));
        }

        if(doInsert && !objListAccount.isEmpty()) {
            insert objListAccount;
        }
        return objListAccount;
    }
    public static List<Invoice__c> createInvoice(Account accountInvoice, Integer numberOfRecords, Boolean doInsert) {
        List<Invoice__c> objListinvoice = new List<Invoice__c>();

        for(Integer i = 0; i < numberOfRecords; i++) {
            objListinvoice.add(new Invoice__c(
                account__c = accountInvoice.Id,
                DownloadLink__c = 'www.teste.com'
            ));
        }

        if(doInsert && !objListinvoice.isEmpty()) {
            insert objListinvoice;
        }
        return objListinvoice;
    }
    
    public static List<Quote> createQuote(Integer numberOfRecords, Boolean doInsert) {
        List<Opportunity> objListOpportunity = new List<Opportunity>();
        List<Account> objListAccount = new List<Account>();
        List<Quote> objListQuote = new List<Quote>();
        
        objListAccount.add(new Account(
                Name = 'test',
                ExternalId__c='1234'
            ));

            objListOpportunity.add(new Opportunity(
                Name = 'test',
                AccountId=objListAccount[0].Id,
                CloseDate=System.today().addMonths(1),
                StageName='Qualification',
                OpportunityCategory__c=Do_Opportunity.OPPORTUNITY_CATEGORY_CARDS
            ));
            if(!objListOpportunity.isEmpty()) {
                insert objListOpportunity;
            }
        
        for(Integer i = 0; i < numberOfRecords; i++) {
            objListQuote.add(new Quote(
                Name = 'test',
                OpportunityID =objListOpportunity[0].Id
            ));
        }

        if(doInsert && !objListQuote.isEmpty()) {
            insert objListQuote;
        }
        return objListQuote;
    }

    public static List<Lead> createLead(Integer numberOfRecords, Boolean doInsert) {
        List<Lead> objLeadList = new List<Lead>();
        
        for(Integer i = 0; i < numberOfRecords; i++) {
            objLeadList.add(new Lead(
               LastName='test',
               Company ='test',
                Lead_Category__c= Do_Lead.LEAD_CATEGORY_CARDS,
                Potential_Diesel_volume_kL_y__c =1,
                Potential_Gasoline_volume_kL_y__c=2,
                VAT_Tax_Number__c = 'teste'+i
                
            ));
        }

        if(doInsert && !objLeadList.isEmpty()) {
            insert objLeadList;
        }
        return objLeadList;
    }

    public static List<EmailMessage> createEmailMessage(Integer numberOfRecords, Boolean doInsert) {
        List<EmailMessage> objEmailMessageList = new List<EmailMessage>();

        for(Integer i = 0; i < numberOfRecords; i++) {
            objEmailMessageList.add(new EmailMessage());
        }

        if(doInsert && !objEmailMessageList.isEmpty()) {
            insert objEmailMessageList;
        }
        return objEmailMessageList;
    }

    public static List<Product2> createProduct(Integer numberOfRecords, Boolean doInsert) {
        List<Product2> objProductList = new List<Product2>();

        for(Integer i = 0; i < numberOfRecords; i++) {
            objProductList.add(new Product2(
                Name = 'test product '+i
            ));
        }

        if(doInsert && !objProductList.isEmpty()) {
            insert objProductList;
        }
        return objProductList;
    }

    public static List<Group> createGroup(Integer numberOfRecords, Boolean doInsert) {
        List<Group> objGroupList = new List<Group>();

        for(Integer i = 0; i < numberOfRecords; i++) {
            objGroupList.add(new Group(
                Name = 'test product '+i,
                DeveloperName = 'testproduct'+i
            ));
        }

        if(doInsert && !objGroupList.isEmpty()) {
            insert objGroupList;
        }
        return objGroupList;
    }

    public static List<UserRole> createUserRole(Integer numberOfRecords, Boolean doInsert) {
        List<UserRole> objUserRoleList = new List<UserRole>();

        for(Integer i = 0; i < numberOfRecords; i++) {
            objUserRoleList.add(new UserRole(
                Name = 'test product '+i,
                DeveloperName = 'testproduct'+i
            ));
        }

        if(doInsert && !objUserRoleList.isEmpty()) {
            insert objUserRoleList;
        }
        return objUserRoleList;
    }

    public static List<GroupMember> createGroupMember(Integer numberOfRecords, Boolean doInsert, ID groupID , ID userID) {
        List<GroupMember> objGroupMemberList = new List<GroupMember>();

        for(Integer i = 0; i < numberOfRecords; i++) {
            objGroupMemberList.add(new GroupMember(
                GroupID = groupID,
                UserOrGroupId = userID
            ));
        }

        if(doInsert && !objGroupMemberList.isEmpty()) {
            insert objGroupMemberList;
        }
        return objGroupMemberList;
    }

    public static List<PricebookEntry> createPricebookEntry(Integer numberOfRecords, Boolean doInsert, Id pricebook, Id product) {
        List<PricebookEntry> objPricebookEntryList = new List<PricebookEntry>();

        for(Integer i = 0; i < numberOfRecords; i++) {
            objPricebookEntryList.add(new PricebookEntry(
                UnitPrice = 1,
                Pricebook2Id = pricebook,
                Product2Id = product,
                isActive = true
            ));
        }

        if(doInsert && !objPricebookEntryList.isEmpty()) {
            insert objPricebookEntryList;
        }
        return objPricebookEntryList;
    }

    public static List<ProductDiscount__c> createProductDiscount(Integer numberOfRecords, Boolean doInsert){
        List<ProductDiscount__c> objProductDiscountList = new List<ProductDiscount__c>();

        for(Integer i = 0; i < numberOfRecords; i++) {
            objProductDiscountList.add(new ProductDiscount__c(
                IsActive__c = true
            ));
        }

        if(doInsert && !objProductDiscountList.isEmpty()) {
            insert objProductDiscountList;
        }
        return objProductDiscountList;
    }

    public static List<QuoteLineItem> createQuoteLineItem(Integer numberOfRecords, Boolean doInsert, Quote quote, PricebookEntry pricebookEntry){
        List<QuoteLineItem> objQuoteLineItemList = new List<QuoteLineItem>();

        for(Integer i = 0; i < numberOfRecords; i++) {
            objQuoteLineItemList.add(new QuoteLineItem(
                QuoteId = quote.Id,
                PricebookEntryId = pricebookEntry.Id,
                Quantity = 1,
                UnitPrice = 1
            ));
        }
        
        if(doInsert && !objQuoteLineItemList.isEmpty()) {
            insert objQuoteLineItemList;
        }
        return objQuoteLineItemList;
    }

    public static List<ProductDiscountCriteria__c> createProductDiscountCriteria(Integer numberOfRecords, Boolean doInsert, ProductDiscount__c productDiscount, String fieldAPI, String fieldValue){
        List<ProductDiscountCriteria__c> objProductDiscountCriteriaList = new List<ProductDiscountCriteria__c>();

        for(Integer i = 0; i < numberOfRecords; i++) {
            objProductDiscountCriteriaList.add(new ProductDiscountCriteria__c(
                Name = fieldAPI,
                FieldValue__c = fieldValue,
                ProductDiscount__c = productDiscount.Id
            ));
        }

        if(doInsert && !objProductDiscountCriteriaList.isEmpty()) {
            insert objProductDiscountCriteriaList;
        }
        return objProductDiscountCriteriaList;
    }

    public static List<CompanyCode__c> createCompanyCode(Integer numberOfRecords, Boolean doInsert){
        List<CompanyCode__c> objCompanyCodeList = new List<CompanyCode__c>();

        for(Integer i = 0; i < numberOfRecords; i++) {
            objCompanyCodeList.add(new CompanyCode__c(
                Name = 'teste',
                Language__c = 'EN'
            ));
        }

        if(doInsert && !objCompanyCodeList.isEmpty()) {
            insert objCompanyCodeList;
        }
        return objCompanyCodeList;
    }

    public static List<Contact> createContacts(Integer numberOfRecords, Boolean doInsert) {
        List<Account> objListAccount = new List<Account>();

        
        objListAccount.add(new Account(
                Name = 'test',
                ExternalId__c='1234'
            ));
        List<Contact> objList = new List<Contact>();
        
        for(Integer i = 0; i < numberOfRecords; i++) {
            objList.add(new Contact(
                LastName            = 'Test Last Name ' + i,
                Title = 'Test Tittle',
                AccountId=objListAccount[0].id
            ));
        }

        if(doInsert && !objList.isEmpty()) {
            insert objList;
        }

        return objList;
    }
    public static PermissionSetGroup createPermissionSetGroupWithComponent(){
        
        PermissionSetGroup permGroup = new PermissionSetGroup( DeveloperName = 'test', MasterLabel = 'Test' );
        insert permGroup;

        // permissionSet permSet = new PermissionSet(name='testFactoryGroup',Label='testFactoryGroup');
        // insert permSet;
        
        // PermissionSetGroupComponent permGroupComponent = new PermissionSetGroupComponent( PermissionSetGroupId = permGroup.Id, PermissionSetId = permSet.Id );
        // insert permGroupComponent;

        
        return permGroup;
    }
    public static PermissionSetAssignment createAndAssignPermissionSetToUser(Id userId){
        permissionSet permSet = new PermissionSet(name='testFactory',Label='testFactory');
        insert permSet;

        PermissionSetAssignment permGroupAssignment = new PermissionSetAssignment( PermissionSetId = permSet.Id, AssigneeId = userId );
        insert permGroupAssignment;

        return permGroupAssignment;
    }

    public static List<Contact> createContact(Integer numberOfRecords, Boolean doInsert){
        List<Account> accountList = createAccount(numberOfRecords, true);
        List<Contact> objContactList = new List<Contact>();

        for(Integer i = 0; i < numberOfRecords; i++) {
            objContactList.add(new Contact(
                LastName = 'teste'+i,
                AccountId = accountList[i].Id,
                Title = 'teste'+i
            ));
        }

        if(doInsert && !objContactList.isEmpty()) {
            insert objContactList;
        }
        return objContactList;
    }

    public static List<EncryptedDataGDPR__c> createEncryptedData(Integer numberOfRecords, Boolean doInsert){
        List<EncryptedDataGDPR__c> objEncryptedDataList = new List<EncryptedDataGDPR__c>();

        for(Integer i = 0; i < numberOfRecords; i++) {
            objEncryptedDataList.add(new EncryptedDataGDPR__c(
                MobilePhoneEncrypted__c = 'teste'+i,
                BusinessPhoneEncrypted__c = 'teste'+i,
                EmailEncrypted__c = 'teste'+i
            ));
        }

        if(doInsert && !objEncryptedDataList.isEmpty()) {
            insert objEncryptedDataList;
        }
        return objEncryptedDataList;
    }

    public static List<ContentVersion> createDocument(Integer numberOfRecords, Boolean doInsert){
        List<ContentVersion> objDocList = new List<ContentVersion>();

        for(Integer i = 0; i < numberOfRecords; i++) {
            objDocList.add(new ContentVersion( 
                Title = 'teste'+i,
                PathOnClient = 'teste'+i,
                VersionData = Blob.valueOf('teste'+i)
            ));
        }

        if(doInsert && !objDocList.isEmpty()) {
            insert objDocList;
        }
        return objDocList;
    }

    public static List<ContentDocumentLink> createDocumentLink(Integer numberOfRecords, Boolean doInsert, Id linkId){
        List<ContentVersion> contentVersion = createDocument(1, true);

        Id documentId = [SELECT ContentDocumentId FROM ContentVersion WHERE Id = :contentVersion[0].Id].ContentDocumentId;

        List<ContentDocumentLink> objDocLinkList = new List<ContentDocumentLink>();

        for(Integer i = 0; i < numberOfRecords; i++) {
            objDocLinkList.add(new ContentDocumentLink(
                LinkedEntityId = linkId,
                ContentDocumentId = documentId
            ));
        }

        if(doInsert && !objDocLinkList.isEmpty()) {
            insert objDocLinkList;
        }
        return objDocLinkList;
    }
}