/**
 * @File Name          : VolunteerMatchApiService.cls
 * @Description        : Class for retreving data from VolunteerMatch API
 * @Author             : Abhimanyu Tanwar
 * @Group              :
 * @Last Modified By   : Abhimanyu Tanwar
 * @Last Modified On   : 3/29/2019, 10:50:54 AM
 * @Modification Log   :
 *==============================================================================
 * Ver         Date                     Author      		      Modification
 *==============================================================================
 * 1.0    3/27/2019, 4:23:09 PM   Abhimanyu Tanwar     Initial Version
**/
public with sharing class VolunteerMatchApiService {
    
    private static String key = '';
    private static String usrId = '';
    private static String apiUrl = '';

    private WSSECredentials wsse = null;
    private static final String DATETIME_FORMAT =  'yyyy-MM-dd\'T\'HH:mm:ssZ';
    private static final String CHARSET = 'UTF-8';

    public VolunteerMatchApiService() {
        
        String devCredName = runningInASandbox() ? 'VolunteerMatchAPIStage' : 'VolunteerMatchAPIProd';

        //get URL, UserName and password from Custom Metadata
        for(Volunteer_Match_Credential__mdt cred :[ SELECT Id,DeveloperName,MasterLabel,URL__c,Username__c,Key__c
                                                        FROM Volunteer_Match_Credential__mdt
                                                        WHERE DeveloperName =: devCredName
                                                        LIMIT 1]){
            usrId = cred.Username__c;
            key = cred.Key__c;
            apiUrl = cred.URL__c+'/api/call';
            
            wsse = buildWSSECredentials(usrId, key);
        }
    }

    /**
    * Method to identify current org prod or sandbox
    * @return Boolean
    */
    private static Boolean runningInASandbox() {
      return [SELECT IsSandbox FROM Organization LIMIT 1].IsSandbox;
    }

    /**
    * Generate a random nonce.
    * @return Blob
    */
    private Blob generateNonce() {
        return Crypto.generateAesKey(128);
    }

    /**
    * Generates a SHA-256 hash of a payload message.
    * @param payload
    * @return
    */
    private Blob sha256(Blob payload) {
        return Crypto.generateDigest('SHA-256', payload);
    }

    /**
    * Given a name and a password, build a WSSECredentials object.
    * @param accountName
    * @param password
    * @return WSSECredentials
    */
    private WSSECredentials buildWSSECredentials(String accountName, String password) {
        WSSECredentials wsse= new WSSECredentials();
        wsse.userName = accountName;
        Blob nonce = generateNonce();
        if (nonce == null) {
            system.debug('Failed to generate nonce');
            return null;
        }

        wsse.nonce = EncodingUtil.base64Encode(nonce);
        wsse.timestamp = System.now().format(DATETIME_FORMAT);

        String digestInput = wsse.nonce + wsse.timestamp + password;
        wsse.passwordDigest = EncodingUtil.base64Encode(sha256(Blob.valueOf(digestInput)));

        return wsse;
    }

    /**
    * Builds an HTTP connection based on some WSSE credentials, a JSON query and some API key information and retreive Response.
    * @param wsse
    * @param query
    * @param httpMethod
    * @param accountName
    * @return HttpResponse
    */
    private HttpResponse buildConnection(WSSECredentials wsse, String query, String httpMethod, String accountName) {
        HttpResponse res;
        try {
            // Instantiate a new http object
            Http h = new Http();

            // Instantiate a new HTTP request, specify the method (GET) as well as the endpoint
            HttpRequest req = new HttpRequest();
            req.setEndpoint(apiUrl + '?' + query);
            req.setMethod(httpMethod);

            req.setHeader('Accept-Charset', CHARSET);
            req.setHeader('Content-Type', 'application/json');
            req.setHeader('Authorization', 'WSSE profile="UsernameToken"');

            String credentials= '';
            credentials+= 'UsernameToken Username="'+accountName+'", ';
            credentials+= 'PasswordDigest="'+wsse.passwordDigest+'", ';
            credentials+= 'Nonce="'+wsse.nonce+'", ';
            credentials+= 'Created="'+wsse.timestamp+'", ';
            req.setHeader('X-WSSE', credentials);

            // Send the request, and return a response
            res = h.send(req);
            //return res;
        } catch (Exception e) {
          system.debug('Failed to build connection to API'+ e.getMessage());
          throw e;
        }
        return res;
    }

    /** Call the VolunteerMatch API for the specified method
    *
    * @param apiMethod
    * @param query
    * @param httpMethod
    * @param accName
    * @param password
    * @return
    */
    public String callAPIReAuth(String apiMethod, String query, String httpMethod) {
        wsse = buildWSSECredentials(usrId, key);
        return callAPI(apiMethod, query, httpMethod);
    }

    /** Call the VolunteerMatch API for the specified method
    * If calling this method directly from your application you must use the constructor with credentials
    * and be aware that the credentials will time out after some set time. The advantage is better performance
    * since we don't need to rebuild the security header so if you know you will be doing multiple back to back
    * API calls you may consider using this method.
    *
    * @param url
    * @param apiMethod
    * @param query
    * @param httpMethod
    * @return
    */
    public String callAPI(String apiMethod, String query, String httpMethod) {
        String q = '';
        if(wsse == null) {
            system.debug('Error no credentials, this method should only be called directly if the constructor with credentials was used.');
            return null;
        }
        try {
            q +='action='+EncodingUtil.urlEncode(apiMethod, CHARSET);
            q +='&query='+EncodingUtil.urlEncode(query, CHARSET);

            HttpResponse respone = buildConnection(wsse, q, httpMethod, wsse.userName);
            if(respone.getStatusCode() == 200){
                return respone.getBody();
            }
            else {
                return '{"error":"'+respone.getBody()+'" ,"status":"'+respone.getStatus()+'","statusCode":"'+respone.getStatusCode()+'"}';
            }
        } catch (Exception e) {
            return '{"error":"'+e.getMessage()+'"}';
        }
    }

    /**
    * Structure representing a set of WSSE credentials.
    */
    public class WSSECredentials {
        public String userName= '';
        public String passwordDigest= '';
        public String nonce= '';
        public String timestamp= '';
    }
    
}