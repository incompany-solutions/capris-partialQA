public with sharing class CredentialHelper {
   
    public static final string CREDENTIALS = generateCredenciales();

    public static String generateCredenciales()
    {
        Credenciales_Endpoint__mdt mdt_credenciales = Credenciales_Endpoint__mdt.getInstance('credenciales');
        String pkey = mdt_credenciales.Llave__c;
        String porg = mdt_credenciales.Organization__c;
        String CREDENCIALES = '{"pkey":"'+pkey+'","porg":"'+porg+'"}';
        return CREDENCIALES;
    }

    public static void createLog(String object, String errorMessage, String payload){
        Log__c log = new Log__c();
        log.Payload__c = payload;
        log.Objeto__c = object;

        if(errorMessage.length() > 255){
            log.Error_Message2__c = errorMessage;
        }else{
            log.Error_Message__c = errorMessage;
        }
        insert log;
    }

}