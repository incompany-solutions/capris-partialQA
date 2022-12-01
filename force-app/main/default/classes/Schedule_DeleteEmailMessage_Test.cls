/**
 * @description       : 
 * @author            : esteban@incompany.cr
 * @group             : 
 * @last modified on  : 28-11-2022
 * @last modified by  : esteban@incompany.cr
**/
@isTest
public class Schedule_DeleteEmailMessage_Test {
    @TestSetup
    static void setup(){
        EmailMessage emailToDelete1 = TestData.createEmailMessage(true);
        EmailMessage emailToDelete2 = TestData.createEmailMessage(true);
        EmailMessage emailNoDelete = TestData.createEmailMessage(true);
        
        Test.setCreatedDate(emailToDelete1.Id,Date.newInstance(2020,1,1));
        Test.setCreatedDate(emailToDelete2.Id,Date.newInstance(2020,1,1));
        Test.setCreatedDate(emailNoDelete.Id,Date.newInstance(2022,1,1));
    }
    
    // Dummy CRON expression: midnight on March 15.
    // Because this is a test, job executes
    // immediately after Test.stopTest().
    public static String CRON_EXP = '0 0 0 15 3 ? 2023';
    @isTest
    static void ScheduleTest() {
        Test.startTest();
        // Schedule the test job
        String jobId = System.schedule('Schedule_DeleteEmailMessage',
            CRON_EXP,
            new Schedule_DeleteEmailMessage());
        // Stopping the test will run the job synchronously
        Test.stopTest();


    }
}
