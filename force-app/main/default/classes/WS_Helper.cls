public with sharing class WS_Helper {
    
    public static final String CREDENTIALS = generateCredenciales();
    public static final String MUELLE = 'Muelle';
    public static final String PTO_FACT = 'Punto Facturacion';
    public static final String USUARIO_PTO_FAC = 'Usuario Punto Facturacion';
    public static final String ENCABEZADOS_COMBOS = 'Encabezados Combos';
    public static final String DETALLE_COMBOS = 'Detalle Combos';
    public static final String COMBOS_PUNTO_FACTURACION = 'Combos Punto Facturacion';
    public static final String ARTICULOS = 'Articulos';
    public static final String EXISTENCIAS = 'Existencias';
    public static final String ARTICULOS_EN_GARANTIA = 'Articulos en Garantia';
    public static final String DETALLE_MOVIMIENTOS = 'Detalle Movimientos';
    public static final String CONTACTOS = 'Contactos';
    public static final String EMAIL = 'Email';
    public static final String TELEFONOS = 'Telefonos';
    public static final String CLIENTES = 'Clientes';

    public static String generateCredenciales()
    {
        Credenciales_Endpoint__mdt mdt_credenciales = Credenciales_Endpoint__mdt.getInstance('credenciales');
        String pkey = mdt_credenciales.Llave__c;
        String porg = mdt_credenciales.Organization__c;
        JSONGenerator gen = JSON.createGenerator(true);
		gen.writeStartObject();
        gen.writeStringField('pkey', pkey);
        gen.writeStringField('porg', porg);
        gen.writeEndObject();        
        String CREDENCIALES = gen.getAsString();
        System.debug(CREDENCIALES);
        return CREDENCIALES;
    }

    public static void createLog(String obj, String errorMessage, String payload){
        Log__c log = new Log__c();
        log.Payload__c = payload;
        log.Objeto__c = obj;

        if(errorMessage.length() > 255){
            log.Error_Message2__c = errorMessage;
        }else{
            log.Error_Message__c = errorMessage;
        }
        insert log;
    }

    public static String getEndpoint(String cmtEndpointName){
        Catalogo_Endpoints__mdt catalogo = Catalogo_Endpoints__mdt.getInstance(cmtEndpointName);
        String endpoint = catalogo.URL__c;
        return endpoint;
    }
}