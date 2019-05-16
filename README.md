# Volunteer-Match-API-Salesforce
## VolunteerMatch API Integration in Salesforce


1. Add VolunteerMatch API Credentials in Custom Metadata
	1. Go to Quick Find/Search.
	2. Type Custom Metadata and click on Custom Metadata Types.
	3. Click on "Manage Records" for "Volunteer Match Credential".
	4. For Stage Click New, enter following values and save.

| Field Name | Values |
| --- | --- |
| Label | VolunteerMatchAPIStage |
| Name | VolunteerMatchAPIStage  |
| URL | https://www.stage.volunteermatch.org 
| Username | Username for Volunteermatch |
| Key | Enter Key for Volunteermatch |

	5. For Production Click New, enter following values and save.

| Field Name | Values |
| --- | --- |
| Label | VolunteerMatchAPI 
| Name | VolunteerMatchAPI |
| URL | https://www.volunteermatch.org |
| Username | Username for Volunteermatch |
| Key | Enter Key for Volunteermatch |

			
To Test, try running the following command in Execute Anonymous Window in Developer Console
```
System.debug(
	new SearchOpportunitiesExample().searchOpportunity('{ "location": "san francisco, ca",'+
		 '"opportunityTypes": ["public"],'+
		 '"sortOrder": "asc",'+
		 '"sortCriteria": "orgname",'+
		 '"pageNumber": 1,'+
		 '"numberOfResults": 10,'+
		 '"fieldsToDisplay": ["id", "title", "location"]'+
		'}')
	);
```
