/**
* @description   IREP Interface to get fetch the Static Resources
* Modification Log 
* ------------------------------------------------------------------------------------
* Developer                    Date                Description 
* António Santos               02/12/2021          Initial Release of IREP Interface.
* ------------------------------------------------------------------------------------ 
*/
public interface IREP_StaticResource extends FW_ISObjectRep {
    Map<String,String> getStaticResourceBySet(Set<String> staticResourceNameSet);
}