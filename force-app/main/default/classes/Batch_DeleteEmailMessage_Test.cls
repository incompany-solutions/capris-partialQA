/**
 * @description       : 
 * @author            : esteban@incompany.cr
 * @group             : 
 * @last modified on  : 28-11-2022
 * @last modified by  : esteban@incompany.cr
**/
@isTest
public class Batch_DeleteEmailMessage_Test {
    @TestSetup
    static void setup(){
        EmailMessage emailToDelete1 = TestData.createEmailMessage(true);
        EmailMessage emailToDelete2 = TestData.createEmailMessage(true);
        EmailMessage emailNoDelete = TestData.createEmailMessage(true);
        
        Test.setCreatedDate(emailToDelete1.Id,Date.newInstance(2020,1,1));
        Test.setCreatedDate(emailToDelete2.Id,Date.newInstance(2020,1,1));
        Test.setCreatedDate(emailNoDelete.Id,Date.newInstance(2022,1,1));
    }

    @isTest
    static void test(){
        List<EmailMessage> lstEmailMessages = [SELECT Id, TextBody, Subject, FromName, FromAddress, ToAddress FROM EmailMessage];
        System.assertEquals(3,lstEmailMessages.size());

        Test.startTest();
        Batch_DeleteEmailMessage uca = new Batch_DeleteEmailMessage();
        Id batchId = Database.executeBatch(uca);
        Test.stopTest();
        // after the testing stops, assert records were updated properly 
        lstEmailMessages = [SELECT Id, TextBody, Subject, FromName, FromAddress, ToAddress FROM EmailMessage];
        System.assertEquals(1,lstEmailMessages.size());
       
    }
}
