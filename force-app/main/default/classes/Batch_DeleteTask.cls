/**
 * @description       : 
 * @author            : esteban@incompany.cr
 * @group             : 
 * @last modified on  : 01-12-2022
 * @last modified by  : esteban@incompany.cr
**/
public with sharing class Batch_DeleteTask implements Database.Batchable<sObject>, Database.Stateful{
    public List<Task> lstTotalTaskToDelete = new List<Task>();
    public List<Batch_ObjectStatusDMLHandler> successTaskDML = new List<Batch_ObjectStatusDMLHandler>();
    public List<Batch_ObjectStatusDMLHandler> errorTaskDML = new List<Batch_ObjectStatusDMLHandler>();

    public Database.QueryLocator start(Database.BatchableContext bc) {
        Datetime now = Datetime.now();
        Datetime oneLessYear = Datetime.newInstance(now.Year()-1, now.Month(), now.Day(), now.hour()+6, now.minute(), now.second());
        String strOneLessYear = String.valueOf(oneLessYear).replace(' ','T');
        System.debug('SELECT Id,,CreatedDate FROM Task WHERE CreatedDate < '+strOneLessYear+' ORDER BY CreatedDate DESC');
        return DataBase.getQueryLocator(
            'SELECT Id,CreatedDate FROM Task WHERE CreatedDate < '+strOneLessYear+'Z ORDER BY CreatedDate DESC'
        );
    }
    public void execute(Database.BatchableContext bc, List<Task> records){
        Map<Id,Task> mapTaskToDelete = new map<Id,Task>();

        // process each batch of records
        for(Task taskToDelete : records)
        {
            lstTotalTaskToDelete.add(taskToDelete);
            mapTaskToDelete.put(taskToDelete.Id,taskToDelete);
        }
        
        Database.DeleteResult[] deleteResults = Database.delete(mapTaskToDelete.values(),false);
        Integer i=0;
        for(Database.DeleteResult databaseResult : deleteResults) {
            Batch_ObjectStatusDMLHandler statusObject = new Batch_ObjectStatusDMLHandler();
            if (databaseResult.isSuccess()) {
                // Operation was successful, so get the ID of the record that was processed
                System.debug('Successfully deleted account with ID: ' + databaseResult.getId());
                statusObject.objectSelected = (Task) mapTaskToDelete.get(databaseResult.getId());
                statusObject.status = 'SUCCESS';
                successTaskDML.add(statusObject);
            }
            else {
                // Operation failed, so get all errors  
                String strError = '';
                for(Database.Error err : databaseResult.getErrors()) {
                    strError += 'The following error has occurred: '+err.getStatusCode() + ': ' + err.getMessage()+':'+ err.getFields();
                }
                statusObject.objectSelected = (Task) mapTaskToDelete.values()[i];
                statusObject.status = 'FAIL';
                statusObject.errorMessage = strError;

                errorTaskDML.add(statusObject);
            }
            i++;
        }
    }
    public void finish(Database.BatchableContext bc){

        Date today = Date.today();
        System.debug('Send Message');
        Blob successCVS = generateCSV(successTaskDML);
        Blob errorCVS = generateCSV(errorTaskDML);
        String strToday = today.Day()+'_'+today.Month()+'_'+today.Year();
        String csvSuccessName= 'TaskSucess_'+strToday+'.csv';  
        String csvErrorName= 'TaskFail_'+strToday+'.csv'; 
        String emailSubject = 'Resultados Tareas '+strToday;
        Batch_DeleteHelper.sendEmail(emailSubject,csvSuccessName,csvErrorName,successCVS,errorCVS);
        
    }
    @TestVisible
    private static Blob generateCSV(List<Batch_ObjectStatusDMLHandler> successTaskDML)
    {
        String header = 'ID, CREATEDDATE, STATUS, MESSAGE \n';
        String finalstr = header;
        for(Batch_ObjectStatusDMLHandler objectRecieved: successTaskDML)
        {
            Task actuakTask = (Task) objectRecieved.objectSelected;
            String recordString = actuakTask.Id+','+actuakTask.CreatedDate+','+objectRecieved.status+','+objectRecieved.errorMessage+'\n';

            finalstr = finalstr +recordString;

        }

        blob csvBlob = Blob.valueOf(finalstr);
        return csvBlob;
    }
}
