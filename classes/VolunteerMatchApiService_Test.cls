/**
 * @File Name          : VolunteerMatchApiService_Test.cls
 * @Description        : Test Class for VolunteerMatchApiService.cls
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
@isTest
private class VolunteerMatchApiService_Test {

    /**
    * @description This class is used for mock response
    * @author Abhimanyu Tanwar | 5/9/2019
    */
    private class postTestMock implements HttpCalloutMock {
        public HttpResponse respond(HTTPRequest req) {
            String json = '{"status":{"description":"Success","code":"0"}}';
            HttpResponse res = new HttpResponse();
            res.setHeader('Content-Type', 'text/json');
            res.setBody(json);
            res.setStatusCode(200);
            return res;
        }
    }
    
    /**
    * @description This function is a test function for TEK_MembershipController.loadFinancialAccountTreeViewData(String recordId)
    * @author Tushar Gandhi | 5/9/2019
    * @return void
    */
    @isTest 
    private static void testVolunteerMatchApiService() {
        String SEARCH_OPPORTUNITIES = 'searchOpportunities';
        Test.setMock(HttpCalloutMock.class, new postTestMock());
        Test.startTest();
             VolunteerMatchApiService vmApiService = new VolunteerMatchApiService();
             vmApiService.callAPIReAuth(SEARCH_OPPORTUNITIES,
                                        '{ "location": "san francisco, ca",'+
                                         '"opportunityTypes": ["public"],'+
                                         '"sortOrder": "asc",'+
                                         '"sortCriteria": "orgname",'+
                                        ' "pageNumber": 1,'+
                                         '"numberOfResults": 10,'+
                                         '"fieldsToDisplay": ["id", "title", "location"]'+
                                        '}'
                                        , 'GET');
        Test.stopTest();
    }
    
    /**
    * @description This function is a test function for TEK_MembershipController.loadFinancialAccountTreeViewData(String recordId)
    * @author Tushar Gandhi | 5/9/2019
    * @return void
    */
    @isTest 
    private static void testSearchOpportunity() {
        Test.setMock(HttpCalloutMock.class, new postTestMock());
        Test.startTest();
            new SearchOpportunitiesExample().searchOpportunity( '{ "location": "san francisco, ca",'+
                                                                '"opportunityTypes": ["public"],'+
                                                                '"sortOrder": "asc",'+
                                                                '"sortCriteria": "orgname",'+
                                                                '"pageNumber": 1,'+
                                                                '"numberOfResults": 10,'+
                                                                '"fieldsToDisplay": ["id", "title", "location"]'+
                                                                '}');
        Test.stopTest();
    }
}