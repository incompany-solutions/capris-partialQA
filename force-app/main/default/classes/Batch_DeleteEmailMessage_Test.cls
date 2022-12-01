/**
 * @description       : 
 * @author            : esteban@incompany.cr
 * @group             : 
 * @last modified on  : 29-11-2022
 * @last modified by  : esteban@incompany.cr
**/
@isTest
public class Batch_DeleteEmailMessage_Test {
    @TestSetup
    static void setup(){
        EmailMessage emailToDelete1 = TestData.createEmailMessage(true);
        EmailMessage emailToDelete2 = TestData.createEmailMessage(true);
        EmailMessage emailToDelete3 = TestData.createEmailMessage(true);
        EmailMessage emailToDelete4 = TestData.createEmailMessage(true);
        EmailMessage emailToDelete5 = TestData.createEmailMessage(true);
        EmailMessage emailToDelete6 = TestData.createEmailMessage(true);
        EmailMessage emailNoDelete = TestData.createEmailMessage(true);
        
        Test.setCreatedDate(emailToDelete1.Id,Date.newInstance(2020,1,1));
        Test.setCreatedDate(emailToDelete2.Id,Date.newInstance(2020,1,1));
        Test.setCreatedDate(emailToDelete3.Id,Date.newInstance(2020,2,1));
        Test.setCreatedDate(emailToDelete4.Id,Date.newInstance(2018,3,2));
        Test.setCreatedDate(emailToDelete5.Id,Date.newInstance(2019,2,4));
        Test.setCreatedDate(emailToDelete6.Id,Date.newInstance(2020,1,3));
        Test.setCreatedDate(emailNoDelete.Id,Date.newInstance(2022,1,1));
    }

    @isTest
    static void test(){
        List<EmailMessage> lstEmailMessages = [SELECT Id, TextBody, Subject, FromName, FromAddress, ToAddress FROM EmailMessage];
        System.assertEquals(7,lstEmailMessages.size());

        Test.startTest();
        Batch_DeleteEmailMessage uca = new Batch_DeleteEmailMessage();
        Id batchId = Database.executeBatch(uca);
        Test.stopTest();
        // after the testing stops, assert records were updated properly 
        lstEmailMessages = [SELECT Id, TextBody, Subject, FromName, FromAddress, ToAddress FROM EmailMessage];
        //Tomar en cuenta que cuando se elimina la informacion se envia un correo, por lo que quedaria un email, mas el email que se envia
        System.assertEquals(2,lstEmailMessages.size());
       
    }
}
