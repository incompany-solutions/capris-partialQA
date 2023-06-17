global with sharing class doCallOutWebServiceAccount {

	webservice static string getCalloutResponseContents(String AccId) {

		Http h = new Http();

		HttpRequest req = ne HttpRequest();
		req.setEndpoint(WS_Helper.getEndpoint('sfcclientes'));
		/*	Endpoint Antiguo
		req.setEndpoint('http://bd2.capris.cr:64423/Salesforce_Cliente_Insert/ws/sfcclientes/');*/
		req.setBody(CreateJSON.GenerateJSONAccount(AccId));
		req.setHeader('Content-Type', 'application/json');
		req.setMethod('POST');

		Try {
			HttpResponse res = h.send(req);
			System.debug(res);
			System.debug(res.getBody());
			String jsonStr = res.getBody();
			//myProcessClass.myMethod(jsonStr);
			if(res.getStatusCode() == 200){

            }else{
                WS_Helper.createLog(WS_Helper.TELEFONOS,'Error: \nStatus: ' + res.getStatus() + '\nStatus Code: ' + res.getStatusCode(),res.getBody());    
            }
			return res.getBody();
		}
		Catch(Exception e) {
			System.Debug(e);
			WS_Helper.createLog(WS_Helper.TELEFONOS,'Error ' + e.getMessage() + '- Line number: ' + e.getLineNumber(),null);
			return e.getMessage();
		}
	}
}