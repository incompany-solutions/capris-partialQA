/**
 * @description       : 
 * @author            : esteban@incompany.cr
 * @group             : 
 * @last modified on  : 29-11-2022
 * @last modified by  : esteban@incompany.cr
**/
@isTest
public class Batch_DeleteWebServiceLog_Test {
    @TestSetup
    static void setup(){
        List<WebServiceLog__c> lstWebService = TestData.createWebService(true);
    }

    @isTest
    static void test(){
        List<WebServiceLog__c> lstWebService = [SELECT Id FROM WebServiceLog__c];
        System.assertEquals(102,lstWebService.size());

        Test.startTest();
        Batch_DeleteWebServiceLog uca = new Batch_DeleteWebServiceLog();
        Id batchId = Database.executeBatch(uca);
        Test.stopTest();

        lstWebService = [SELECT Id FROM WebServiceLog__c];
        System.assertEquals(0,lstWebService.size());
    }
}
