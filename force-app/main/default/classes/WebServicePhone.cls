/**
 * @description       : 
 * @author            : esteban@incompany.cr
 * @group             : 
 * @last modified on  : 13-04-2023
 * @last modified by  : esteban@incompany.cr
**/
@RestResource(urlMapping = '/WebServicePhone/')
global with sharing class WebServicePhone {

    @HttpPOST
    global static void getResponsePOST() {

        RestRequest req = RestContext.request;
        RestResponse res = RestContext.response;
        String jsonStr = RestContext.request.requestBody.toString();
        System.debug('JSON Recieved '+jsonStr);

        Try {
            String Response = UpsertPhone.doUpsert(jsonStr);
            RestContext.response.statusCode = 200;
            RestContext.response.addHeader('Content-Type', 'application/json');
            res.responseBody = Blob.ValueOf(Response);
            
            // WebServiceLog__c log = new WebServiceLog__c();
            // log.UpsertedRecords__c = 0;
            // log.RecordWithErrors__c = 0;
            // log.TotalRecords__c = 0;
            // log.WebServiceMethod__c = 'WebServicePhone';
            // log.Web_Services__c='Telefonos';
            // Insert log;

            // Attachment attachmentJSON = new Attachment();
            // attachmentJSON.Body = Blob.valueOf(jsonStr);
            // attachmentJSON.Name = String.valueOf('JSON Recibido.txt');
            // attachmentJSON.ParentId = log.Id;
            // insert attachmentJSON;

            // Attachment attachmentJSON2 = new Attachment();
            // attachmentJSON2.Body = Blob.valueOf(Response);
            // attachmentJSON2.Name = String.valueOf('JSON Respuesta.txt');
            // attachmentJSON2.ParentId = log.Id;
            // insert attachmentJSON2;
        }
        Catch(Exception e) {
            System.debug('Error on WebServicePhone ' + e.getMessage() + ' on line ' + e.getStackTraceString());
            RestContext.response.statusCode = 200;
            RestContext.response.addHeader('Content-Type', 'application/json');
            res.responseBody = Blob.ValueOf('{"ResponseMainList":[{"codigo":"Error al procesar el registro","Status":"CAP"}]}');
        }
    }

}