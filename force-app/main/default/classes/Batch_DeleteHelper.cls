/**
 * @description       : 
 * @author            : esteban@incompany.cr
 * @group             : 
 * @last modified on  : 15-11-2022
 * @last modified by  : esteban@incompany.cr
**/
public with sharing class Batch_DeleteHelper {
    public static void sendEmail(String emailSubject,String successTitle,String errorTitle,Blob successResults, Blob errorResults){
        
        Messaging.EmailFileAttachment SuccessfullyDeleteAttach = new Messaging.EmailFileAttachment();
        SuccessfullyDeleteAttach.setFileName(successTitle);
        SuccessfullyDeleteAttach.setBody(successResults);

        Messaging.EmailFileAttachment ErrorDeleteAttach = new Messaging.EmailFileAttachment(); 
        ErrorDeleteAttach.setFileName(errorTitle);
        ErrorDeleteAttach.setBody(errorResults);
        
        Messaging.SingleEmailMessage email =new Messaging.SingleEmailMessage();
        List<EmailsNotificacion__mdt> lstEmailsConfigurados = [SELECT Email__c FROM EmailsNotificacion__mdt WHERE isActivo__c = true];
        List<String> lstEmailsToAddress = new List<String>();
        for(EmailsNotificacion__mdt registro : lstEmailsConfigurados)
        {
            lstEmailsToAddress.add(registro.Email__c);
        }
        String[] toAddresses = lstEmailsToAddress;
        String subject =emailSubject;
        email.setSubject(subject);
        email.setToAddresses( toAddresses );
        email.setPlainTextBody('A continuacion se adjuntan los '+emailSubject);
        email.setFileAttachments(new Messaging.EmailFileAttachment[]{SuccessfullyDeleteAttach,ErrorDeleteAttach});
        Messaging.SendEmailResult [] r = Messaging.sendEmail(new Messaging.SingleEmailMessage[] {email});
    }
}
