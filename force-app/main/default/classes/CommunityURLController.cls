public class CommunityURLController {
    public String communityPrefix {get; set;}

    public String getCommunityLink(){
        Site site = [SELECT Id FROM Site WHERE UrlPathPrefix =: communityPrefix LIMIT 1];
        return [SELECT SecureURL FROM SiteDetail WHERE DurableId =: site.Id].SecureUrl;
    }
}