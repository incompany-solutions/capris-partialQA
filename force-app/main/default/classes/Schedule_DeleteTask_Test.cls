/**
 * @description       : 
 * @author            : esteban@incompany.cr
 * @group             : 
 * @last modified on  : 28-11-2022
 * @last modified by  : esteban@incompany.cr
**/
@isTest
public with sharing class Schedule_DeleteTask_Test {
    @TestSetup
    static void setup(){
        Task deleteTask1 = TestData.createTask(true);
        Task deleteTask2 = TestData.createTask(true);
        Task deleteNoTask = TestData.createTask(true);

        Test.setCreatedDate(deleteTask1.Id,Date.newInstance(2020,1,1));
        Test.setCreatedDate(deleteTask2.Id,Date.newInstance(2020,1,1));
        Test.setCreatedDate(deleteNoTask.Id,Date.newInstance(2022,1,1));
    }

    // Dummy CRON expression: midnight on March 15.
    // Because this is a test, job executes
    // immediately after Test.stopTest().
    public static String CRON_EXP = '0 0 0 15 3 ? 2023';
    @isTest
    static void ScheduleTest() {
        Test.startTest();
        // Schedule the test job
        String jobId = System.schedule('Schedule_DeleteTask',
            CRON_EXP,
            new Schedule_DeleteTask());
        // Stopping the test will run the job synchronously
        Test.stopTest();
    }
}
