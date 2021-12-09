/**
* @description   Framework Api Method Wrapper
* @testClass     
* Modification Log 
* ------------------------------------------------------------------------------------  
* Developer                       Date                Description 
* Antonio Santos                23/08/2021          Created Framework Api Method Wrapper.
* ------------------------------------------------------------------------------------ 
*/
public class FW_ApiMethod {
	public String namedCredential;
	public String path;
	public String subPath;
	public String httpMethod;
	public String contentType;
	public String inputTemplate;
    public String mockOutput;
	public String outputClass;
	public Map<String,List<String>> httpHeaderMap;

    public Integer timeout; // seconds

	public FW_ApiMethod(CEP_ApiCredential__mdt credential, CEP_ApiPath__mdt path, CEP_ApiMethod__mdt method, List<CEP_ApiHttpHeader__mdt> headerList) {
		this.httpHeaderMap = new Map<String,List<String>>();

        this.namedCredential = credential.NamedCredential__c;
        this.path = path.Path__c;

        this.subPath = method.SubPath__c;
        this.httpMethod = method.HttpMethod__c;
        this.contentType = method.ContentType__c;
        this.inputTemplate = method.Input__c;
        this.mockOutput = method.MockOutput__c;
        this.outputClass = method.OutputDeserializeClassName__c;

        if (method.TimeoutOverride__c != null) {
            this.timeout = Integer.valueOf(method.TimeoutOverride__c);
        }

        if (headerList != null) {
            for (CEP_ApiHttpHeader__mdt httpHeader : headerList) {
                if (!this.httpHeaderMap.containsKey(httpHeader.HeaderName__c)) {
                    this.httpHeaderMap.put(httpHeader.HeaderName__c, new List<String>());
                }

                this.httpHeaderMap.get(httpHeader.HeaderName__c).add(httpHeader.HeaderValue__c);
            }
        }
	}
}