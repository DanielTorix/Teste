/**
* @description   REP class to get fetch the Static Resources
* @testClass     REP_StaticResourceTest
* Modification Log 
* ------------------------------------------------------------------------------------
* Developer                    Date                Description 
* António Santos               02/12/2021          Initial Release of REP Class.
* ------------------------------------------------------------------------------------ 
*/
public with sharing class REP_StaticResource extends FW_SobjectRep implements IREP_StaticResource {
    public Map<String,String> getStaticResourceBySet(Set<String> staticResourceNameSet) {
        Map<String,String> resultMap = new Map<String,String>();

        for (
            StaticResource staticResource : [
                SELECT
                    Id, SystemModStamp, Name
                FROM
                    StaticResource
                WHERE
                    Name IN :staticResourceNameSet
            ]
        ) {
            String url = '/resource/' + String.valueOf(
                                            (
                                                (DateTime) staticResource.SystemModStamp
                                            ).getTime()
                                        ) +
                    '/' + staticResource.Name;

            resultMap.put(staticResource.Name, url);
        }

        return resultMap;
    }
}