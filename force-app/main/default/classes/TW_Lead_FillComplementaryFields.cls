/**
@description    worker class to automatically fill needed fields
@testClass      TW_Lead_FillComplementaryFieldsTest
* Modification Log 
* ------------------------------------------------------------------------------------  
* Developer                       Date                Description  
* Guilherme Charro                08/09/2021          Created the class
* Hugo Rodrigues                  20/10/2021         updated to meet US39484 description
* ------------------------------------------------------------------------------------        
*/
public with sharing class TW_Lead_FillComplementaryFields {
    private IREP_CompanyCode companyCodeRepository;
    private IREP_OMVEntityEmployee oMVEntityRepository;

    public TW_Lead_FillComplementaryFields(){
        this.companyCodeRepository = new REP_CompanyCode();
        this.oMVEntityRepository = new REP_OMVEntityEmployee();
        
    }
    
    @TestVisible
    private TW_Lead_FillComplementaryFields(IREP_CompanyCode companyCodeRepository,IREP_OMVEntityEmployee oMVEntityRepository){
        this.companyCodeRepository = companyCodeRepository;
        this.oMVEntityRepository = oMVEntityRepository;
    }

    public void execute(List<Lead> leadList, Map<Id,Lead> oldLeadMap) {
        Set<Id> companyCodeIdsSet = new Set<Id>();
        Set<Id> userIdsSet = new Set<Id>();
        for (Lead leadInserted : leadList) {
            if(leadInserted.OwnerID.getsobjecttype()==User.sobjecttype && (oldLeadMap==null|| (oldLeadMap!=null && leadInserted.OwnerID != oldLeadMap.get(leadInserted.Id).OwnerID))){
                userIdsSet.add(leadInserted.OwnerID);
                companyCodeIdsSet.add(leadInserted.CompanyCode__c);
            }
            else if (leadInserted.OwnerID.getsobjecttype()!=User.sobjecttype) {
                leadInserted.CompanyCodeCountry__c = null;
                leadInserted.CompanyCode__c = null;
            }
        }

        List<OMVEntityEmployee__c> oMVEntityEmployeeList =new List<OMVEntityEmployee__c>();
        Map<String,OMVEntityEmployee__c> oMVEntityEmployeeMap = new Map<String,OMVEntityEmployee__c>();

        if(!userIdsSet.isEmpty()){
           
            oMVEntityEmployeeList= oMVEntityRepository.getCompanyCodeByUserID(userIdsSet);
        }
        
        for(OMVEntityEmployee__c omvEntity : oMVEntityEmployeeList){
            oMVEntityEmployeeMap.put(omvEntity.EmployeeUser__c,omvEntity);
        }

        Map<Id,CompanyCode__c> companyCodeMap = new Map<Id,CompanyCode__c>();

        if (!companyCodeIdsSet.isEmpty()) {
            companyCodeMap = new Map<Id,CompanyCode__c>(companyCodeRepository.getCompanyCodeInfo(companyCodeIdsSet));
        }        

        for (Lead leadInserted : leadList) {
            if(oMVEntityEmployeeMap.containsKey(leadInserted.OwnerID)){
                leadInserted.CompanyCode__c = oMVEntityEmployeeMap.get(leadInserted.OwnerID).OMVEntity__c;
            }
            if (companyCodeMap.containsKey(leadInserted.CompanyCode__c) && DO_Lead.LEAD_RECORDTYPE_CARDSLIST.contains(leadInserted.RecordTypeId) && !String.isBlank(leadInserted.CompanyCode__c) 
            && (oldLeadMap == null || (oldLeadMap != null && leadInserted.CompanyCode__c != oldLeadMap.get(leadInserted.Id).CompanyCode__c))) {
                leadInserted.CompanyCodeCountry__c = companyCodeMap.get(leadInserted.CompanyCode__c).Country__c;
            }
            else if (!oMVEntityEmployeeMap.containsKey(leadInserted.OwnerID) &&(oldLeadMap==null || (leadInserted.OwnerID != oldLeadMap.get(leadInserted.Id).OwnerID))){
                leadInserted.CompanyCode__c =null;
            }           
        }        
    }
}