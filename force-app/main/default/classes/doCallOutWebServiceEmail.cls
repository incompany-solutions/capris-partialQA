global with sharing class doCallOutWebServiceEmail {

    webservice static string getCalloutResponseContents(String EmailId) {

        Http h = new Http();

        HttpRequest req = new HttpRequest();
        req.setEndpoint(WS_Helper.getEndpoint('sfcemail'));
        /* Endpoint antiguo
        req.setEndpoint('http://bd2.capris.cr:64423/Salesforce_Email_Insert/ws/sfcemail/');*/
        req.setBody(CreateJSON.GenerateJSONEmail(EmailId));
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
                WS_Helper.createLog(WS_Helper.EMAIL,'Error: \nStatus: ' + res.getStatus() + '\nStatus Code: ' + res.getStatusCode(),res.getBody());    
            }
			return res.getBody();
        }
        Catch(Exception e) {
            System.Debug(e);
            WS_Helper.createLog(WS_Helper.EMAIL,'Error ' + e.getMessage() + '- Line number: ' + e.getLineNumber(),null);
			return e.getMessage();
        }
    }
}