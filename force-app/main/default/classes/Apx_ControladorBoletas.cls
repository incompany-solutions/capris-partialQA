public with sharing class Apx_ControladorBoletas {

    public static Map<String, Boletas> mapEncabezadosBoletas { get; set; }
    public static Map<String, List<Boletas>> mapDetallesBoletas { get; set; }
    public static Account cAccount { get; set; }
    //public static List<Boletas> listBoletas{get;set;}
    Public Integer size{get;set;} 
    Public Integer noOfRecords{get; set;} 
    public Account cuenta { get; set; }
    

    public static String codigoCliente;
    public static String codigoCompania;

    public String nomcuenta { set; get; }
    public String codigo { get; set; }

    public Apx_ControladorBoletas(ApexPages.StandardController controller) {
        
        if (controller.getRecord().id != null) {
            System.debug('ID record cuenta: ' + controller.getRecord().id);
            List<Account> listCuentas = [
                                         select Id, Name, org_id__c, num_cliente__c from Account where Id = :controller.getRecord().id LIMIT 1
                                        ];
            System.debug('CUENTA 1 ' + listCuentas);
            if (!listCuentas.isEmpty()) {
                cAccount = listCuentas[0];
                cuenta = listCuentas[0];
                nomcuenta = cAccount.Name;
                codigoCompania = cAccount.org_id__c;
                codigoCliente = cAccount.num_cliente__c;
                codigo = cAccount.num_cliente__c;
            }
        }
         if(ApexPages.currentPage().getParameters().get('IdCliente')!=null) {
            List<Account> listCuentas = [
                                         select Id, Name, org_id__c, num_cliente__c from Account where Id = :ApexPages.currentPage().getParameters().get('IdCliente') LIMIT 1
                                        ];
            System.debug('CUENTA 2 ' + listCuentas);
            if (!listCuentas.isEmpty()) {
                cAccount = listCuentas[0];
                cuenta = listCuentas[0];
                nomcuenta = cAccount.Name;
                codigoCompania = cAccount.org_id__c;
                codigoCliente = cAccount.num_cliente__c;
                codigo = cAccount.num_cliente__c;
            }
        }
    }

    public Apx_ControladorBoletas() {
        nomcuenta = ApexPages.currentPage().getParameters().get('nomcuenta');
        size=10;
    }

    public PageReference verBoletas() {

        if (codigoCompania == null || codigoCliente == null) {
            codigoCompania = ApexPages.currentPage().getParameters().get('codCompania') != null ? ApexPages.currentPage().getParameters().get('codCompania') : cuenta.org_id__c;
            codigoCliente = ApexPages.currentPage().getParameters().get('codCliente') != null ? ApexPages.currentPage().getParameters().get('codCliente') : cuenta.num_cliente__c;
            codigo = ApexPages.currentPage().getParameters().get('codCliente') != null ? ApexPages.currentPage().getParameters().get('codCliente') : cuenta.num_cliente__c;
        }

        HttpResponse res = CallWSBoletas(codigoCompania, codigoCliente);
        System.debug('Respuesta recibida ' + res);
        List<Product2> listartc;
        if (res != null && res.getBody() != null && res.getBody() != '') {
            RetrieveArchivedRecords(res.getBody());
        }
        return null;
    }

    public static HttpResponse CallWSBoletas(String codigoCompania, string codigoCliente) {
        Http h = new Http();
        HttpRequest req = new HttpRequest();
        HttpResponse res = new HttpResponse();
        try {
            System.debug('codigoCompania ' + codigoCompania);
            System.debug('codigoCliente ' + codigoCliente);

            String endpoint = 'http://bd2.capris.cr:64423/Salesforce_Boletas/webresources/app.entities.boletas/getCliBol/' + codigoCompania + '-' + codigoCliente;
            system.debug('Endpoint:' + endpoint);
            req.setEndpoint(endpoint);
            req.setMethod('GET');
            req.setTimeout(120000);
            res = h.send(req);
        } catch(Exception e) {
            system.debug('Error ' + e.getMessage() + '-Line number ' + e.getLineNumber());
        }
        return res;

    }

    //Recorrero documento xml y cargar datos a objeto
    public static void RetrieveArchivedRecords(string xmlfile) {
        System.Debug('****  xmlfile RetrieveArchivedRecords **** ' + xmlfile);

        try {
            DOM.Document xmlDOC = new DOM.Document();
            xmlDOC.load(xmlfile);
            system.debug('xmlDOC ' + xmlDOC);
            Boletas detalleBoleta;
            Boletas encabezadoBoleta;
            mapEncabezadosBoletas = new Map<String, Boletas> ();
            mapDetallesBoletas = new Map<String, List<Boletas>> ();

            if (!xmlDOC.getRootElement().getChildElements().isEmpty()) {
                
				for (DOM.XMLNode ObjChild : xmlDOC.getRootElement().getChildElements()) {
					encabezadoBoleta = new Boletas();
                    for (DOM.XMLNode xmlNodeObjChild : ObjChild.getChildren()) {
                        if (xmlNodeObjChild.getText() != 'null' && xmlNodeObjChild.getText() != '') {
							
							if (xmlNodeObjChild.getName() == 'boleta') {
                                encabezadoBoleta.boletanum = xmlNodeObjChild.getText();
                                system.debug('boleta ' + encabezadoBoleta.boletanum);
                                mapDetallesBoletas.put(encabezadoBoleta.boletanum, new List<Boletas> ());
                            }

                            if (xmlNodeObjChild.getName() == 'codprod') {
                                encabezadoBoleta.producto = xmlNodeObjChild.getText();
                                system.debug('producto ' + encabezadoBoleta.producto);
                            }
							
							if (xmlNodeObjChild.getName() == 'desprod') {
                                encabezadoBoleta.descripcion = xmlNodeObjChild.getText();
                                system.debug('descripcion ' + encabezadoBoleta.descripcion);
                            }

							if (xmlNodeObjChild.getName() == 'serie') {
                                encabezadoBoleta.serie = xmlNodeObjChild.getText();
                                system.debug('serie ' + encabezadoBoleta.serie);
                            }

                            if (xmlNodeObjChild.getName() == 'ptoprof') {
                                encabezadoBoleta.ptoprof = xmlNodeObjChild.getText();
                                system.debug('ptoprof ' + encabezadoBoleta.ptoprof);
                            }                            
                            
                            if (xmlNodeObjChild.getName() == 'numprof') {
                                encabezadoBoleta.numprof = xmlNodeObjChild.getText();
                                system.debug('numprof ' + encabezadoBoleta.numprof);
                            }
							mapEncabezadosBoletas.put(encabezadoBoleta.boletanum, encabezadoBoleta);
                        }
                    }
                }

                for (DOM.XMLNode ObjChild : xmlDOC.getRootElement().getChildElements()) {
                    detalleBoleta = new Boletas();
                    for (DOM.XMLNode xmlNodeObjChild : ObjChild.getChildren()) {

                        if (xmlNodeObjChild.getText() != 'null' && xmlNodeObjChild.getText() != '') {

                            //Detalles
                            if (xmlNodeObjChild.getName() == 'boleta') {
                                detalleBoleta.boletanum = xmlNodeObjChild.getText();
                                system.debug('boleta ' + detalleBoleta.boletanum);
                            }
							
							if (xmlNodeObjChild.getName() == 'estado') {
                                detalleBoleta.estado = xmlNodeObjChild.getText();
                                system.debug('estado ' + detalleBoleta.estado);
                            }
                            if (xmlNodeObjChild.getName() == 'fecha') {
                                detalleBoleta.fecha = xmlNodeObjChild.getText();
                                system.debug('fecha ' + detalleBoleta.fecha);
                            }

                            if (xmlNodeObjChild.getName() == 'obs') {
                                detalleBoleta.observaciones = xmlNodeObjChild.getText();
                                system.debug('observaciones ' + detalleBoleta.observaciones);
                            }
                        }
                    }

                    if (mapDetallesBoletas.containsKey(detalleBoleta.boletanum)) {
                        mapDetallesBoletas.get(detalleBoleta.boletanum).add(detalleBoleta);
                    }
				}
            }

            System.debug('mapEncabezadosBoletas *** ' + mapEncabezadosBoletas.size());
            System.debug('mapDetallesBoletas *** ' + mapDetallesBoletas.size());
			if(mapEncabezadosBoletas.size()==0){
				ApexPages.addMessage(new ApexPages.message(ApexPages.severity.INFO, 'El cliente no posee boletas para mostrar.'));
			}

        }catch(Exception ex) {
            ApexPages.addMessage(new ApexPages.message(ApexPages.severity.INFO, 'El cliente no posee boletas para mostrar.'));
            system.debug('Error boletas:' + ex.getMessage());
        }

    }
    /*
    public ApexPages.StandardSetController setCon {
        get {
            if(setCon == null) { 
                setCon = new ApexPages.StandardSetController(listBoletas);
                setCon.setPageSize(size);  
                noOfRecords = setCon.getResultSize();
            }            
            return setCon;
        }
        set;
    }

    public List<Boletas> getBoletasDetalles() {
         return (List<Boletas>) setCon.getRecords();
    }*/
    
    public PageReference backAcc() {
        PageReference cuenta = new PageReference('/' + cuenta.Id);
        cuenta.setRedirect(true);
        return cuenta;
    }

    public class Boletas {
        public String boletanum { get; set; }
        public String producto { get; set; }
        public String descripcion { get; set; }
        public String estado { get; set; }
        public String fecha { get; set; }
        public String numprof { get; set; }
        public String observaciones { get; set; }
        public String ptoprof { get; set; }
        public String serie { get; set; }

        public Boletas() {
            boletanum = '';
            producto = '';
            descripcion = '';
            estado = '';
            fecha = '';
            numprof = '';
            observaciones = '';
            ptoprof = '';
            serie = '';
        }

    }
}