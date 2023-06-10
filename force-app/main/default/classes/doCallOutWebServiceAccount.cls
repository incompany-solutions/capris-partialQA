global with sharing class doCallOutWebServiceAccount {

	webservice static string getCalloutResponseContents(String AccId) {

		Http h = new Http();

		HttpRequest req = new HttpRequest();
		req.setEndpoint('http://bd2.capris.cr:64423/Salesforce_Cliente_Insert/ws/sfcclientes/');
		req.setBody(CreateJSON.GenerateJSONAccount(AccId));
		req.setHeader('Content-Type', 'application/json');
		req.setMethod('POST');

		Try {
			HttpResponse res = h.send(req);
			System.debug(res);
			System.debug(res.getBody());
			String jsonStr = res.getBody();
			//myProcessClass.myMethod(jsonStr);
			return res.getBody();
		}
		Catch(Exception e) {
			System.Debug(e);
			return e.getMessage();
		}
	}
}