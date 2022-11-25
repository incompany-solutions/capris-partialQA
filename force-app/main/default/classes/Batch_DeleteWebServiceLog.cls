/**
 * @description       : 
 * @author            : esteban@incompany.cr
 * @group             : 
 * @last modified on  : 24-11-2022
 * @last modified by  : esteban@incompany.cr
**/
public with sharing class Batch_DeleteWebServiceLog implements Database.Batchable<sObject>, Database.Stateful  {
    public List<WebServiceLog__c> logsToDelete = new List<WebServiceLog__c>();
    public List<Batch_ObjectStatusDMLHandler> successLogsDML = new List<Batch_ObjectStatusDMLHandler>();
    public List<Batch_ObjectStatusDMLHandler> errorLogsDML = new List<Batch_ObjectStatusDMLHandler>();
    Integer i = 0;
    public Database.QueryLocator start(Database.BatchableContext bc) {
        return DataBase.getQueryLocator(
            '[SELECT Id FROM WebServiceLog__c LIMIT 200000 ORDER BY CreatedDate ASC]'
        );
    }
    public void execute(Database.BatchableContext bc, List<WebServiceLog__c> records){
        Map<Id,WebServiceLog__c > mapWebServiceLogToDelete = new map<Id,WebServiceLog__c >();

        // process each batch of records
        for(WebServiceLog__c logToDelete : records)
        {
            logsToDelete.add(logToDelete);
            mapWebServiceLogToDelete.put(logToDelete.Id,logToDelete);
        }
        
        Database.DeleteResult[] deleteResults = Database.delete(logsToDelete,false);
        for(Database.DeleteResult databaseResult : deleteResults) {
            Batch_ObjectStatusDMLHandler statusObject = new Batch_ObjectStatusDMLHandler();
            if (databaseResult.isSuccess()) {
                // Operation was successful, so get the ID of the record that was processed
                System.debug('Successfully deleted account with ID: ' + databaseResult.getId());
                statusObject.objectSelected = (WebServiceLog__c) mapWebServiceLogToDelete.get(databaseResult.getId());
                statusObject.status = 'SUCCESS';
                successLogsDML.add(statusObject);
            }
            else {
                // Operation failed, so get all errors  
                String strError = '';
                for(Database.Error err : databaseResult.getErrors()) {
                    strError += 'The following error has occurred: '+err.getStatusCode() + ': ' + err.getMessage()+':'+ err.getFields()+'\n';
                }
                statusObject.objectSelected = (WebServiceLog__c) logsToDelete[i];
                statusObject.status = 'FAIL';
                statusObject.errorMessage = strError;

                errorLogsDML.add(statusObject);
            }
            i++;
        }
    }
    public void finish(Database.BatchableContext bc){

        Date today = Date.today();
        System.debug('Send Message');
        Blob successCVS = generateCSV(successLogsDML);
        Blob errorCVS = generateCSV(errorLogsDML);
        String strToday = today.Day()+'_'+today.Month()+'_'+today.Year();
        String csvSuccessName= 'WebServiceLogSucess_'+strToday+'.csv';  
        String csvErrorName= 'WebServiceLogFail_'+strToday+'.csv'; 
        String emailSubject = 'Resultados WebServiceLog '+strToday;
        Batch_DeleteHelper.sendEmail(emailSubject,csvSuccessName,csvErrorName,successCVS,errorCVS);
        
    }
    @TestVisible
    private static Blob generateCSV(List<Batch_ObjectStatusDMLHandler> successLogsDML)
    {
        String header = 'ID, CREATEDDATE, STATUS, MESSAGE \n';
        String finalstr = header ;
        for(Batch_ObjectStatusDMLHandler objectRecieved: successLogsDML)
        {
            WebServiceLog__c actualWebServiceLog = (WebServiceLog__c) objectRecieved.objectSelected;
            String recordString = actualWebServiceLog.Id+','+actualWebServiceLog.CreatedDate+','+objectRecieved.status+','+objectRecieved.errorMessage+'\n';

            finalstr = finalstr +recordString;

        }

        blob csvBlob = Blob.valueOf(finalstr);
        return csvBlob;
    }
}
