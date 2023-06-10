global with sharing class doCallOutWebServiceContact {

    webservice static string getCalloutResponseContents(String ContId) {

        Http h = new Http();

        HttpRequest req = new HttpRequest();
        req.setEndpoint('http://bd2.capris.cr:64423/Salesforce_Contactos_Insert/ws/sfccontactos/');
        req.setBody(CreateJSON.GenerateJSONContact(ContId));
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