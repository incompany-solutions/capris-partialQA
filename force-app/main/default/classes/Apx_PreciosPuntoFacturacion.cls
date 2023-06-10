public class Apx_PreciosPuntoFacturacion {
	public Opportunity cOpportunity { get; set; }
	public List<Map<String, String>> XMLElements { get; set; }

	//variables otras
	public static Map<String, string> mapcolRows { get; set; }
	public String idOP { set; get; }
	public String codcliente { set; get; }
	public String ptoFact { set; get; }
	public static List<String> subChildElementsList { get; set; }
	public String codigoCliente { get; set; }
	public String codigoCompania { get; set; }
	public static String ptoFac { get; set; }
	public Boolean muestraActualizar{get;set;}
	static String responseBody;
	public static List<Map<String, String>> rowValues { get; set; }
	public static List<Precio> listPrecioArt { get; set; }
	static Precio precioA;
	//constructor
	public Apx_PreciosPuntoFacturacion()
	{
		muestraActualizar = false;
		codigoCompania = ApexPages.currentPage().getParameters().get('codcompania');
		codigoCliente = ApexPages.currentPage().getParameters().get('codcliente');
		ptoFact = ApexPages.currentPage().getParameters().get('ptoFact');
		String[] ptoF = ptoFact.split('-');
		ptoFact = ptoF[0]; //
		idOP = ApexPages.currentPage().getParameters().get('idOP');
		List<Opportunity> oportunidadesList = [select name, id,PuntoFactRelacionado__c,EMV_NUM_CLIENTE__c,EMV_COD_ORG__c,HasOpportunityLineItem from Opportunity where Id = :idOP];
		if (!oportunidadesList.isEmpty()){
			cOpportunity = oportunidadesList[0];
			InitValidaciones();
		} 
	}

	public PageReference InitValidaciones(){
		
		if(cOpportunity.PuntoFactRelacionado__c==null){
			ApexPages.addmessage(new ApexPages.message(ApexPages.severity.Warning, 'Debe indicar el punto de facturación.  Presione el botón Regresar para indicarlo.'));
			muestraActualizar = true;
			
		} 
		
		if(cOpportunity.EMV_NUM_CLIENTE__c==null) {
			ApexPages.addmessage(new ApexPages.message(ApexPages.severity.Warning, 'Debe indicar el cliente.  Presione el botón Regresar para indicarlo.'));
			muestraActualizar = true;
		}
		
		if(cOpportunity.EMV_COD_ORG__c==null) {
			ApexPages.addmessage(new ApexPages.message(ApexPages.severity.Warning, 'Debe indicar la compañía.  Presione el botón Regresar para indicarla.'));
			muestraActualizar = true;
		}
		
		if(!cOpportunity.HasOpportunityLineItem){
			ApexPages.addmessage(new ApexPages.message(ApexPages.severity.Warning, 'Debe agregar artículos a la oportunidad.  Presione el botón Regresar para agregarlos.'));
			muestraActualizar = true;
		}	
		
		return null;	
	}
	public String procesarSolicitud(String Url) {
		HttpRequest request = requestWS(Url);
		Http h = new Http();
		HttpResponse responses = reponseWS(h, request);
		String res = responses.getBody();
		return res;
	}

	Public Pagereference ActualizaOPLI() {

		//*************************************************************///
		try {
			List<OpportunityLineItem> opLI = new List<OpportunityLineItem> ();
			List<OpportunityLineItem> opLIActualiza = new List<OpportunityLineItem> ();
			List<Product2> prod2Actualiza = new List<Product2> ();
			OpportunityLineItem opLIItemA;
			Product2 prod2;
			opLI = [Select Id, OpportunityId, PricebookEntryId, Product2Id, DMV_COD_OFERTA__c, DMV_COD_PRODUCTO__c, Precio_especial_c__c, Quantity, UnitPrice, Discount, Description, TotalPrice FROM OpportunityLineItem where OpportunityId = :idOP and DMV_COD_ORG__c = :codigoCompania and DMV_COD_OFERTA__c = null];
			system.debug('opLI ' + opLI);
			if (opLI.size() > 0) {
				system.debug('más de una línea de producto oportunidad');
				Precio itemP;
				for (OpportunityLineItem itemOLI : opLI) {
					opLIItemA = new OpportunityLineItem();
					opLIItemA = itemOLI;
					itemP = new Precio();
					prod2 = new Product2();
					// itemP=ParserReponseWS(itemOLI.DMV_COD_PRODUCTO__c,String.valueOf(itemOLI.Quantity.round(System.RoundingMode.CEILING)));
					String codArticulo = itemOLI.DMV_COD_PRODUCTO__c;
					String cantidad = String.valueOf(itemOLI.Quantity.round(System.RoundingMode.CEILING));
					// String cliente=itemOLI.ARTICULO_MIXTO__c
					System.debug('******** codigoCompania+codArticulo++cantidad+codigoCliente+ptoFact ' + codigoCompania + '*' + codArticulo + '*' + cantidad + '*' + codigoCliente + '*' + ptoFact);

					String Url = 'http://bd2.capris.cr:64423/Salesforce_Precios/webresources/app.entities.precios/' + codigoCompania + '/' + codArticulo + '/' + cantidad + '/' + codigoCliente + '/' + ptoFact + '/';
					String parsear = procesarSolicitud(Url);
					System.debug('***** parsear ****** ' + parsear);
					itemP = ParserReponseWS(parsear);
					//Actualizar solo precios
					System.debug('***** PARSEADO ****** ' + itemP);
					opLIItemA.ParserPrecios__c =  'Fecha/Hora consumo: ' + String.valueOf(System.now()) +' | '+ parsear;
					opLIItemA.Precio_especial_c__c = itemP.PrecioEspecial == 0 ? null : itemP.PrecioEspecial;
					opLIItemA.UnitPrice = itemP.PrecioNormal;
					opLIItemA.Discount = itemP.PorcentajeDescuento == 0 ? null : itemP.PorcentajeDescuento;

					opLIActualiza.add(opLIItemA);
					system.debug('Articulo ' + opLIItemA);
					system.debug('opLIActualiza ' + opLIActualiza);
				}
				//Actualizamos precio de productos del pedido
				TriggerHandler.bypass('OpportunityLineItemTriggerHandler');
				Upsert opLIActualiza;
				TriggerHandler.clearBypass('OpportunityLineItemTriggerHandler');
			}
		} catch(Exception e) {
			ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR, 'Error al actualizar artículo de oportunidad.'));
		}

		//*************************************************************/// 

		System.debug('cOpportunity ' + cOpportunity);

		if (cOpportunity!=null) {
			PageReference opportunity = new PageReference('/' + cOpportunity.id);
			opportunity.setRedirect(true);
			return opportunity;
		}
		return null;
	}

	public static HttpResponse reponseWS(Http http, HttpRequest req) {
		HttpResponse res = http.send(req);
		return res;
	}

	//call-in de servicio web de capris de consulta de boletas
	public static HttpRequest requestWS(String Url) {
		HttpRequest req = new HttpRequest();

		try {

			req.setEndpoint(Url);
			req.setMethod('GET');

			//xmlContent=res.getBody();
			//system.debug('xmlContent '+xmlContent);

		} catch(Exception e) {
			ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR, 'Error en comunicacion con servicio web de tramites.Intente de nuevo la consulta.'));
			system.debug('Error recibiendo respuesta de WS Tramites.' + 'Descripcion de Error: ' + e.getMessage());
		}

		return req;
	}



	//Manejo de parseo de xml enviado por el servicio web
	//public Precio ParserReponseWS(String codArticulo,String cantidad)
	public static Precio ParserReponseWS(String response)
	{
		System.debug('****** respuesta ws: ****** ' + response);

		String elementValues;
		Integer i;
		Integer lastcount = 0;
		//String childElementName;        
		List<String> elementValuesList = new List<String> ();
		List<Dom.XmlNode> childlist = new List<Dom.XmlNode> ();
		// Set<String> childelementslist = new Set<String>();
		mapcolRows = new map<String, String> ();
		String subChildElementName;
		subChildElementsList = new List<String> ();
		rowValues = new List<Map<String, String>> ();
		// Map<String, string> mapvalues = new Map<String, string>();

		Integer childElementCount = 0;
		Integer subChildElementsCount = 0;
		//String Url='http://bd2.capris.cr:64423/Salesforce_Precios/webresources/app.entities.precios/'+codigoCompania+'/'+codArticulo+'/'+cantidad+'/'+codigoCliente+'/'+ptoFact+'/';        
		try {

			responsebody = response; //Call webservices


			//parser XML
			Dom.Document doc = new Dom.Document();
			List<Dom.XmlNode> childelements;
			doc.load(responsebody);
			Dom.XMLNode rootElement = doc.getRootElement();
			String rootElementName = rootElement.getName();

			for (Dom.XmlNode childelement : rootElement.getChildElements())
			{
				childlist.add(childelement);
				childElementCount++;

			}

			for (Dom.XmlNode subchildelement : childlist[0].getChildElements())
			{
				subChildElementName = subchildelement.getName();
				subChildElementsList.add(subChildElementName);
				elementValues = subchildelement.getText();
				elementValuesList.add(elementValues);
				//mapvalues.put(subChildElementName,elementValues);
			}

			for (Dom.XmlNode childelement : rootElement.getChildElements())
			{
				mapcolRows = new map<String, String> ();
				for (Dom.XmlNode subchildelement : childelement.getChildElements())
				{

					mapcolRows.put(subchildelement.getName(), subchildelement.getText());
					//rowValues.add(mapcolRows);  //Remove rowValuds list from here
				}
				rowValues.add(mapcolRows); //Add rowValuds list to here             
			}

			String codCli = '';
			String codArt = '';
			String cant = '';
			String puntoFactura = '';
			String precioNormal = '0';
			String precioEspecial = '0';
			String porcentajeDescuento = '0';

			listPrecioArt = new List<Precio> ();
			//Obtener precio actualizado
			for (Integer e = 0; e<rowValues.size(); e++) {

				precioA = new Precio();

				Map<String, String> myMap = rowValues.get(e);

				for (String key : myMap.keySet()) {

					if (key == 'CodCliente') {
						codCli = myMap.get(key);
						//system.debug('precioA '+precioA);
					}

					if (Key == 'CodArticulo') {
						codArt = myMap.get(key);
						//system.debug('CodArticulo '+codArt);
					}
					if (Key == 'Cantidad') {
						cant = myMap.get(key);
						//system.debug('Cantidad '+Cantidad);
					}

					if (Key == 'PuntoFacturacion') {
						puntoFactura = myMap.get(key);
						//system.debug('PuntoFacturacion '+puntoFactura);
					}
					if (Key == 'PrecioNormal') {
						precioNormal = myMap.get(key);
						// system.debug('PrecioNormal '+PrecioNormal);
					}
					if (Key == 'PrecioEspecial') {
						precioEspecial = myMap.get(key);
						//system.debug('PrecioEspecial '+PrecioEspecial);
					}
					if (Key == 'PorcentajeDescuento') {
						porcentajeDescuento = myMap.get(key);
						//system.debug('PorcentajeDescuento '+PorcentajeDescuento);
					}

				}
				precioA.CodCliente = (codCli == 'null') ? ' ' : codCli;
				precioA.CodArticulo = (codArt == 'null') ? ' ' : codArt;
				system.debug('Cantidad ' + cant);
				precioA.Cantidad = Integer.valueOf((cant == 'null') ? ' ' : cant);
				precioA.PuntoFacturacion = (puntoFactura == 'null') ? ' ' : puntoFactura;
				precioA.PrecioNormal = Decimal.valueOf((precioNormal == 'null') ? ' ' : precioNormal);
				precioA.PrecioEspecial = Decimal.valueOf((precioEspecial == 'null') ? ' ' : precioEspecial);
				precioA.PorcentajeDescuento = Decimal.valueOf((porcentajeDescuento == 'null') ? ' ' : porcentajeDescuento);
				system.debug('precioA item ' + precioA);

			}
		} catch(Exception e) {
			ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR, 'Error al actualizar artículo de oportunidad.'));
		}
		return precioA;
	}

	public PageReference backOpp() {
		PageReference opportunity = new PageReference('/' + cOpportunity.id);
		opportunity.setRedirect(true);
		return opportunity;
	}

	///Entidad de objeto Precio
	public class Precio {
		public String CodCliente { get; set; }
		public String CodArticulo { get; set; }
		public Integer Cantidad { get; set; }
		public String PuntoFacturacion { get; set; }
		public Decimal PrecioNormal { get; set; }
		public Decimal PrecioEspecial { get; set; }
		public Decimal PorcentajeDescuento { get; set; }


		public Precio() {
			CodCliente = '';
			CodArticulo = '';
			Cantidad = 0;
			PuntoFacturacion = '';
			PrecioNormal = 0;
			PrecioEspecial = 0;
			PorcentajeDescuento = 0;

		}

	}


}