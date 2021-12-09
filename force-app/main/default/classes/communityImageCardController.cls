public with sharing class communityImageCardController {
    @AuraEnabled(cacheable=true)
    public static String getDocumentURL(String documentUniqueName) {
        IREP_Organization organizationRepository = new REP_Organization();
        IREP_Document documentRepository = new REP_Document();
        Id orgId = organizationRepository.getOrganization().Id;
        Id documentId;
        
        if (!Test.isRunningTest()) {
            documentId = documentRepository.getDocumentByDeveloperName(documentUniqueName).Id;
        } else {
            documentId = orgId;
        }

        return URL.getOrgDomainUrl().toExternalForm() + '/servlet/servlet.ImageServer?id=' + documentId + '&oid=' + orgId;
    }
}