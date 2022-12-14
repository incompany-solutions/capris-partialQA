/**
 * @description       : 
 * @author            : esteban@incompany.cr
 * @group             : 
 * @last modified on  : 29-11-2022
 * @last modified by  : esteban@incompany.cr
**/
@isTest
public with sharing class TestData {
    private static Account createAccount(Boolean insertAccount)
    {
        Account acc = new Account();
        acc.Name = 'Cuenta1';
        if(insertAccount)
        {
            insert acc;
        }

        return acc;
    }

    private static Encabezado__c createEncabezado(Boolean insertEncabezado,Date fechaMovimiento)
    {
        Account acc = createAccount(true);

        Encabezado__c encabezado = new Encabezado__c();
        encabezado.Cliente__c = acc.Id;
        encabezado.EMV_FEC_MOVIMIENTO__c = fechaMovimiento;
        if(insertEncabezado)
        {
            insert encabezado;
        }

        return encabezado;
    }

    public static Detalle_de_Movimiento__c createDetalleMovimiento(Boolean insertDetalleMovimiento,Date fechaMovimiento)
    {
        Encabezado__c encabezado =  createEncabezado(true,fechaMovimiento);

        Detalle_de_Movimiento__c detalleDelete1 = new Detalle_de_Movimiento__c();
        detalleDelete1.DMV_COD_ORG_3__c = 'DMV';
        detalleDelete1.DMV_TIPO_MOV__c = 'DMV_TIPO';
        detalleDelete1.DMV_COD_PUNTO_FACT__c = 'DM';
        detalleDelete1.DMV_NUM_DOCUMENTO_3__c = 'DOCUMENTO';
        detalleDelete1.DMV_NUM_LINEA_3__c = 'DMV';
        detalleDelete1.Name = 'Test 1';
        detalleDelete1.DMV_COD_PRODUCTO_3__c = 'DMVCOD';
        detalleDelete1.DMV_CAN_MOVIMIENTO_3__c = 5;
        detalleDelete1.DMV_PRECIO_NORMAL_3__c = 2;
        detalleDelete1.DMV_PRECIO_ESPECIAL_3__c = 2;
        detalleDelete1.DMV_DESC_ESP_3__c = 1;
        detalleDelete1.Monto_I_V_NUMBER__c = 2;
        detalleDelete1.DMV_FYH_MODIFICA_3__c = Date.today();
        detalleDelete1.DMV_USU_MODIFICA_3__c = 'dmvUsuModifica';//dmvUsuModifica
        detalleDelete1.DMV_COD_OFERTA_3__c = 'dmvCodOferta';
        detalleDelete1.Encabezado__c = encabezado.Id;
        if(insertDetalleMovimiento)
        {
            insert detalleDelete1;
        }

        return detalleDelete1;
    }

    public static EmailMessage createEmailMessage(Boolean insertEmailMessage)
    {
        EmailMessage emailToDelete1 = new EmailMessage();
        emailToDelete1.TextBody='Message'; 
        emailToDelete1.Subject='Message';
        emailToDelete1.FromName='Esteban Segura Benavides';
        emailToDelete1.FromAddress='esteban@incompany.cr';
        emailToDelete1.ToAddress='admin@incompany.cr';
        if(insertEmailMessage)
        {
            insert emailToDelete1;
        }

        return emailToDelete1;
    }

    public static EventoEncabezado__c createEventoEncabezado(Boolean insertEventoEncabezado,Date fechaEvento)
    {
        Encabezado__c encabezado =  createEncabezado(true,fechaEvento);

        EventoEncabezado__c eventoToDelete1 = new EventoEncabezado__c();
        eventoToDelete1.Encabezado__c = encabezado.Id;
        eventoToDelete1.Fecha_de_evento__c = fechaEvento;
        if(insertEventoEncabezado)
        {
            insert eventoToDelete1;
        }

        return eventoToDelete1;

    }

    private static Lead createLead(Boolean insertLead){
        Lead lead1 = new Lead();
        lead1.FirstName = 'Lead';
        lead1.LastName = 'Test';
        lead1.Company = 'Incompany';
        if(insertLead)
        {
            insert lead1;
        }

        return lead1;
    }

    public static Task createTask(Boolean insertTask){
        Lead lead1 = createLead(true);

        Task deleteTask1 = new Task();
        deleteTask1.WhoId = lead1.Id;
        deleteTask1.Description = 'Test Task to Delete';
        if(insertTask)
        {
            insert deleteTask1;
        }

        return deleteTask1;
    }

    public static List<WebServiceLog__c> createWebService(Boolean insertWebService){
        List<WebServiceLog__c> lstWebService = new List<WebServiceLog__c>();
        for(Integer i = 0;i<102;i++)
        {
            WebServiceLog__c webServiceToDelete = new WebServiceLog__c();
            webServiceToDelete.Web_Services__c = 'Clientes';
            
            lstWebService.add(webServiceToDelete);
        }
        if(insertWebService)
        {
            insert lstWebService;
        }

        return lstWebService;
    }
}
