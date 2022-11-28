/**
 * @description       : 
 * @author            : esteban@incompany.cr
 * @group             : 
 * @last modified on  : 28-11-2022
 * @last modified by  : esteban@incompany.cr
**/
@isTest
public class Schedule_DeleteWebServiceLog_Test {
    @TestSetup
    static void setup(){
        List<WebServiceLog__c> lstWebService = new List<WebServiceLog__c>();
        for(Integer i = 0;i<102;i++)
        {
            WebServiceLog__c webServiceToDelete = new WebServiceLog__c();
            webServiceToDelete.Web_Services__c = 'Web Service a borrar '+i;
            
            lstWebService.add(webServiceToDelete);
        }

        insert lstWebService;
    }

    // Dummy CRON expression: midnight on March 15.
    // Because this is a test, job executes
    // immediately after Test.stopTest().
    public static String CRON_EXP = '0 0 0 15 3 ? 2023';
    @isTest
    static void ScheduleTest() {
        Test.startTest();
        // Schedule the test job
        String jobId = System.schedule('Schedule_DeleteWebServiceLog',
            CRON_EXP,
            new Schedule_DeleteWebServiceLog());
        // Stopping the test will run the job synchronously
        Test.stopTest();
    }
}
