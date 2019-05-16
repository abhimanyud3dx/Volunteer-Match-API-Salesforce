public class SearchOpportunitiesExample {
    
    private static final String SEARCH_OPPORTUNITIES = 'searchOpportunities';
    
    public string searchOpportunity(String query){
        VolunteerMatchApiService vmApiService = new VolunteerMatchApiService();
        return vmApiService.callAPIReAuth(SEARCH_OPPORTUNITIES, query, 'GET');
    }

}