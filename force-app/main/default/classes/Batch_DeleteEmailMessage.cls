/**
 * @description       : 
 * @author            : esteban@incompany.cr
 * @group             : 
 * @last modified on  : 19-12-2022
 * @last modified by  : esteban@incompany.cr
**/
public with sharing class Batch_DeleteEmailMessage implements Database.Batchable<sObject>, Database.Stateful  {
    public List<EmailMessage> emailsMessageToDelete = new List<EmailMessage>();
    public List<Batch_ObjectStatusDMLHandler> successEmailsMessageDML = new List<Batch_ObjectStatusDMLHandler>();
    public List<Batch_ObjectStatusDMLHandler> errorEmailsMessageDML = new List<Batch_ObjectStatusDMLHandler>();
    Integer i = 0;
    public Database.QueryLocator start(Database.BatchableContext bc) {
        Datetime now = Datetime.now();
        Datetime twoLessYear = Datetime.newInstance(now.Year()-2, now.Month(), now.Day(), now.hour()+6, now.minute(), now.second());
        String strTwoLessYear = String.valueOf(twoLessYear).replace(' ','T');
        System.debug('SELECT Id,CreatedDate FROM EmailMessage WHERE CreatedDate < '+strTwoLessYear+' ORDER BY CreatedDate DESC');
        return DataBase.getQueryLocator(
            'SELECT Id,CreatedDate FROM EmailMessage WHERE CreatedDate < '+strTwoLessYear+'Z ORDER BY CreatedDate DESC'
        );
    }
    public void execute(Database.BatchableContext bc, List<EmailMessage> records){
        Map<Id,EmailMessage> mapEmailsMessageToDelete = new map<Id,EmailMessage>();

        // process each batch of records
        for(EmailMessage emailToDelete : records)
        {
            emailsMessageToDelete.add(emailToDelete);
            mapEmailsMessageToDelete.put(emailToDelete.Id,emailToDelete);
        }
        
        Database.DeleteResult[] deleteResults = Database.delete(mapEmailsMessageToDelete.values(),false);
        for(Database.DeleteResult databaseResult : deleteResults) {
            Batch_ObjectStatusDMLHandler statusObject = new Batch_ObjectStatusDMLHandler();
            if (databaseResult.isSuccess()) {
                // Operation was successful, so get the ID of the record that was processed
                System.debug('Successfully deleted account with ID: ' + databaseResult.getId());
                statusObject.objectSelected = (EmailMessage) mapEmailsMessageToDelete.get(databaseResult.getId());
                statusObject.status = 'SUCCESS';
                successEmailsMessageDML.add(statusObject);
            }
            else {
                // Operation failed, so get all errors  
                String strError = '';
                for(Database.Error err : databaseResult.getErrors()) {
                    strError += 'The following error has occurred: '+err.getStatusCode() + ': ' + err.getMessage()+':'+ err.getFields()+'\n';
                }
                statusObject.objectSelected = (EmailMessage) emailsMessageToDelete[i];
                statusObject.status = 'FAIL';
                statusObject.errorMessage = strError;

                errorEmailsMessageDML.add(statusObject);
            }
            i++;
        }
    }
    public void finish(Database.BatchableContext bc){

        Date today = Date.today();
        System.debug('Send Message');
        Blob successCVS = generateCSV(successEmailsMessageDML);
        Blob errorCVS = generateCSV(errorEmailsMessageDML);
        String strToday = today.Day()+'_'+today.Month()+'_'+today.Year();
        String csvSuccessName= 'EmailMessageSucess_'+strToday+'.csv';  
        String csvErrorName= 'EmailMessageFail_'+strToday+'.csv'; 
        String emailSubject = 'Resultados EmailMessage '+strToday;
        Batch_DeleteHelper.sendEmail(emailSubject,csvSuccessName,csvErrorName,successCVS,errorCVS);
        
    }
    @TestVisible
    private static Blob generateCSV(List<Batch_ObjectStatusDMLHandler> successEmailsMessageDML)
    {
        String header = 'ID, CREATEDDATE, STATUS, MESSAGE \n';
        String finalstr = header ;
        for(Batch_ObjectStatusDMLHandler objectRecieved: successEmailsMessageDML)
        {
            EmailMessage actualEmailMessage = (EmailMessage) objectRecieved.objectSelected;
            String recordString = actualEmailMessage.Id+','+actualEmailMessage.CreatedDate+','+objectRecieved.status+','+objectRecieved.errorMessage+'\n';

            finalstr = finalstr +recordString;

        }

        blob csvBlob = Blob.valueOf(finalstr);
        return csvBlob;
    }
}
