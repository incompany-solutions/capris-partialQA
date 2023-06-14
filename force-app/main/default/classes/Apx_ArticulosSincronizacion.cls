public class Apx_ArticulosSincronizacion {

	//************************* WSArticulos *****************************************
	@future(callout = true)
	public static void procesarArticulos(String compania) {
		//Parsear xml
		HttpResponse res = CallWSArticulos(compania);
		System.debug('Respuesta recibida ' + res);
		List<Product2> listartc;
		if (res != null && res.getBody() != null && res.getBody() != '') {
			listartc = ParserArticulos(res.getBody(), compania); //Obtenemos datos de WS articulos. 
			System.debug('listartc procesarArticulos ' + listartc);
			if (!listartc.isEmpty()) {
				insertaractualizarArticulos(listartc, compania); //Insertamos o actualizamos articulos.
			}
		}
	}
	//Invocacion del servicio web de Capris

	public static HttpResponse CallWSArticulos(String compania) {
		HttpRequest req = new HttpRequest();
		HttpResponse res = new HttpResponse();
		try {
			Integer dia = system.now().day();
			Integer mes = system.now().month();
			Integer anno = system.now().year();
			Integer hora = system.now().hour()-1;
			system.debug('fecha 0 *** ' +dia+'.'+mes+'.'+anno+' '+ hora);
			string fecha = dia+'.'+mes+'.'+anno+' '+ hora+':00-H';
			req.setEndpoint('http://bd2.capris.cr:64423/Salesforce_Articulos/webresources/app.entities.articulos/' + compania +'-'+ fecha);
			req.setBody(CredentialHelper.CREDENTIALS);
			req.setMethod('GET');
			req.setTimeout(120000);
			Http h = new Http();
			res = h.send(req);
		} catch(Exception e) {
			system.debug('Error ' + e.getMessage() + '-Line number ' + e.getLineNumber());
		}
		return res;
	}

	//Parseo de datos obtenidos del response del WS 
	public static List<Product2> ParserArticulos(String xmlfile,String compania) {

		List<Product2> listArticulos = new List<Product2> ();
		Product2 articuloItem;
		System.Debug('****  xmlfile ParserArticulos **** ' + xmlfile);
		DOM.Document xmlDOC = new DOM.Document();
		xmlDOC.load(xmlfile);
		Set<string> articulosUnicos = new Set<String>();
		if (!xmlDOC.getRootElement().getChildElements().isEmpty()) {
			for (DOM.XMLNode ObjChild : xmlDOC.getRootElement().getChildElements()) {
				articuloItem = new Product2();
				Boolean bandera = false;
				for (DOM.XMLNode xmlNodeObjChild : ObjChild.getChildren()) {

					if (xmlNodeObjChild.getName() == 'codigo' && xmlNodeObjChild.getText() != 'null') {
						articuloItem.CODIGO__c = xmlNodeObjChild.getText();
						articuloItem.ProductCode = xmlNodeObjChild.getText();
					}
					
					if (xmlNodeObjChild.getName() == 'descripcion' && xmlNodeObjChild.getText() != 'null'){
						articuloItem.DESCRIPCION__c = xmlNodeObjChild.getText();
						articuloItem.Description = xmlNodeObjChild.getText();
						articuloItem.Name = xmlNodeObjChild.getText();
					}

					if (xmlNodeObjChild.getName() == 'estado' && xmlNodeObjChild.getText() != 'null'){
						articuloItem.ESTADO__c = xmlNodeObjChild.getText();
						articuloItem.IsActive = articuloItem.ESTADO__c=='DESCO'||articuloItem.ESTADO__c=='INACT'||articuloItem.ESTADO__c=='LIQUI'?false:true;
					}

					if (xmlNodeObjChild.getName() == 'estrellas' && xmlNodeObjChild.getText() != 'null')
					articuloItem.ESTRELLAS__c = decimal.valueOf(xmlNodeObjChild.getText());

					if (xmlNodeObjChild.getName() == 'fecVenReg' && xmlNodeObjChild.getText() != 'null')
					articuloItem.FECVENCREG__c = xmlNodeObjChild.getText();

					if (xmlNodeObjChild.getName() == 'fechaLlegada' && xmlNodeObjChild.getText() != 'null')
					articuloItem.FECHA_LLEGADA__c = xmlNodeObjChild.getText();

					if (xmlNodeObjChild.getName() == 'indMixto' && xmlNodeObjChild.getText() != 'null')
					articuloItem.IND_MIXTO__c = xmlNodeObjChild.getText();

					if (xmlNodeObjChild.getName() == 'marca' && xmlNodeObjChild.getText() != 'null')
					articuloItem.MARCA__c = xmlNodeObjChild.getText();

					if (xmlNodeObjChild.getName() == 'modelo' && xmlNodeObjChild.getText() != 'null')
					articuloItem.MODELO__c = xmlNodeObjChild.getText();	
					
					if(compania!=null&&articuloItem.CODIGO__c!=null&&!articulosUnicos.contains(compania+articuloItem.CODIGO__c)){
						articuloItem.ORG__c = compania;
						articuloItem.idExternoArticulo__c = compania + articuloItem.CODIGO__c;
						bandera = true;		
						articulosUnicos.add(compania+articuloItem.CODIGO__c);		
					}				
				}
				if(bandera){
					listArticulos.add(articuloItem); //lista de encabezado
				}  
			}//for (DOM.XMLNode ObjChild : xmlDOC.getRootElement().getChildElements())
		} //if (!rootElement.getChildElements().isEmpty())

		System.Debug('listArticulos articulos sincronizacion **** ' + listArticulos);
		return listarticulos;
	}

	//Realizacion de upsert de datos enviados 
	public static void insertaractualizarArticulos(List<Product2> listaartic, String compania) {
		String LPStardard = '';
		Set<String> ProdSet = new Set<String> ();
		Set<String> ProductosStandard = new Set<String> ();
		map<String,Product2> mapaProductos= new map<String,Product2>();
		List<PricebookEntry> entradasStandard = new List<PricebookEntry> ();
		map<String, PricebookEntry> mapaEntradas = new map<String, PricebookEntry> ();
        List<PricebookEntry> entradas = new List<PricebookEntry>();

		try {
			System.debug('insertaractualizarArticulos '+ listaartic);

			upsert listaartic Product2.idExternoArticulo__c;

			system.debug('compania insertaractualizarArticulos ' + compania);
			
			Pricebook2 LP = [select id from Pricebook2 where Compania__c = :compania];
			if(!test.isRunningTest()) LPStardard = [select id from priceBook2 where isActive = true and isStandard = true limit 1].id;
			
			if (Test.isRunningTest())  LPStardard=Test.getStandardPricebookId();

			
			for(Product2 temp :[select id, ProductCode, Name from Product2 where ORG__c=:compania]){
				mapaProductos.put(temp.ProductCode,temp);
				ProdSet.add(temp.id);
			}

			for (PricebookEntry temp :[select id, Product2.ProductCode, PriceBook2Id from PricebookEntry where Product2Id = :ProdSet and PriceBook2Id = :LPStardard]) {
				ProductosStandard.add(temp.Product2.ProductCode);
			}
			for (PricebookEntry temp :[select id, Product2Id, PriceBook2Id from PricebookEntry where Product2Id = :ProdSet and PriceBook2Id = :LP.Id]) {
				mapaEntradas.put((temp.Product2Id + '' + temp.PriceBook2Id + ''), temp);
			}

			for (Product2 temp : listaartic) {
				if (!ProductosStandard.contains(temp.ProductCode)) {
					entradasStandard.add(new PricebookEntry(Product2Id = mapaProductos.get(temp.ProductCode).id, Pricebook2Id = LPStardard, UnitPrice = 0, isActive = true));
				}
				if (mapaEntradas.KeySet().contains(mapaProductos.get(temp.ProductCode + '').id + '' + LP.id)) {
					entradas.add(mapaEntradas.get(mapaProductos.get(temp.ProductCode + '').id + '' + LP.id));
				} else {
					entradas.add(new PricebookEntry(Product2Id = mapaProductos.get(temp.ProductCode).Id, Pricebook2Id = LP.Id, UnitPrice = 0, isActive = true));
				}
			}
			System.debug('entradasStandard '+ entradasStandard);
			System.debug('entradas '+ entradas);
			if(!entradasStandard.isEmpty()){
        		insert entradasStandard;			
			}

    		if(!entradas.isEmpty()){
       			upsert entradas;			
			}
		} catch(DmlException e) {
			System.debug('Error cause: ' + e.getCause() + '-Line number:' + e.getLineNumber() + ' - Message:' + e.getMessage());
		}
	}

	//************************* WSExkistencias *****************************************
	@future(callout = true)
	public static void ProcesarExistencias(String compania) {
		HttpResponse res = new HttpResponse();
		//Parsear xml
		res = CallWSExistencias(compania);
		List<Existencias> listexist;
		

		if (res != null && res.getBody() != null && res.getBody() != '') {
			listexist = ParserExistencias(res.getBody(),compania); //Obtenemos datos de WS encabezados.
			System.debug('listexist ProcesarExistencias ' + listexist);
			if (!listexist.isEmpty()) {
				insertaractualizarExistencias(listexist); //Insertamos o actualizamos encabezados segun sea el caso del resgistro enviado.
			}

		}
	}
	//Invocacion del servicio web de Capris

	public static HttpResponse CallWSExistencias(String compania) {
		String response;
		HttpResponse res;
		try {
			HttpRequest req = new HttpRequest();
			Integer dia = system.now().day();
			Integer mes = system.now().month();
			Integer anno = system.now().year();
			Integer hora = system.now().hour()-1;
			system.debug('fecha 0 *** ' +dia+'.'+mes+'.'+anno+' '+hora);
			string fecha = dia+'.'+mes+'.'+anno+' '+ hora+':00-H';

			req.setEndpoint('http://bd2.capris.cr:64423/Salesforce_ExistenciaArticulo/webresources/app.entities.existencias/'+compania+'-'+ fecha);
			req.setBody(CredentialHelper.CREDENTIALS);
			req.setMethod('GET');
			req.setTimeout(120000);
			Http h = new Http();
			res = h.send(req);
			System.debug(' res en CallWSExistencias ' + res);

		} catch(Exception e) {
			system.debug('Error ' + e.getMessage() + '-Line number ' + e.getLineNumber());
		}
		return res;
	}

	public class Existencias{
		public String codigoArticulo{get;set;}
		public Decimal existenciaArticulo{get;set;}
		public String companiaArticulo{get;set;}
		public String idArticulo{get;set;}
	}

	//Parseo de datos obtenidos del response del WS 
	public static List<Existencias> ParserExistencias(String xmlfile,String compania) {

		List<Existencias> listExist = new List<Existencias> ();
		Existencias existItem;
		System.Debug('**** xmlfile ParserExistencias **** ' + xmlfile);
		DOM.Document xmlDOC = new DOM.Document();
		xmlDOC.load(xmlfile);

		if (!xmlDOC.getRootElement().getChildElements().isEmpty()) {
			for (DOM.XMLNode ObjChild : xmlDOC.getRootElement().getChildElements()) {
				existItem = new Existencias();
				for (DOM.XMLNode xmlNodeObjChild : ObjChild.getChildren()){
					if (xmlNodeObjChild.getName() == 'codigo' && xmlNodeObjChild.getText() != 'null')
						existItem.codigoArticulo = xmlNodeObjChild.getText();
					if (xmlNodeObjChild.getName() == 'exist' && xmlNodeObjChild.getText() != 'null') {
						existItem.existenciaArticulo = Decimal.valueOf(xmlNodeObjChild.getText());
					}
					existItem.companiaArticulo = compania;
					existItem.idArticulo = compania + existItem.codigoArticulo;

				}
				System.Debug('existItem ' + existItem);
				listExist.add(existItem); //lista de encabezado  
			}
		} //if (!rootElement.getChildElements().isEmpty())


		System.Debug('$$$$$$$ listaaa ' + listExist);
		return listExist;
	}

	//Realizacion de upsert de datos enviados 
	public static void insertaractualizarExistencias(List<Existencias> listaexist) {
	List<Product2> listProductosExistencias = new List<Product2>();
	List<Product2> listProductosNuevos = new List<Product2>();
	Map<String,Decimal> mapExistencias = new Map<String,Decimal>();
	//Map<String,Existencias> mapExistenciasCompleto = new Map<String,Existencias>();
	Set<String> setProductosExistentes = new Set<String>();

		try {
			for(Existencias exi:listaexist){
				mapExistencias.put(exi.idArticulo,exi.existenciaArticulo);
				//mapExistenciasCompleto.put(exi.idArticulo,exi);
			}

			for(Product2 pro:[select id,idExternoArticulo__c,ExistenciasArticulo__c from Product2 where idExternoArticulo__c in:mapExistencias.keySet()]){
				pro.ExistenciasArticulo__c = mapExistencias.get(pro.idExternoArticulo__c);
				setProductosExistentes.add(pro.idExternoArticulo__c);
				listProductosExistencias.add(pro);
			}

			System.debug('Productos actualizados con existencias: ' + listProductosExistencias.size());

			/*if(mapExistenciasCompleto.keySet().size()!=setProductosExistentes.size()){
				for(String elemento:mapExistenciasCompleto.keySet()){
					if(!setProductosExistentes.contains(elemento)){
						Existencias newExistencia = mapExistenciasCompleto.get(elemento);
						Product2 newProducto = new Product2(
							Name = newExistencia.codigoArticulo,
							CODIGO__c = newExistencia.codigoArticulo,
							ProductCode = newExistencia.codigoArticulo,
							IsActive = true,
							ORG__c = newExistencia.companiaArticulo,
							idExternoArticulo__c = newExistencia.idArticulo,
							ExistenciasArticulo__c = newExistencia.existenciaArticulo,
							PorExistencia__c = true
						);
						listProductosNuevos.add(newProducto);
					}
				}
			}*/

			if(!listProductosExistencias.isEmpty()){
				upsert listProductosExistencias Product2.idExternoArticulo__c;
			}

			/*if(!listProductosNuevos.isEmpty()){
				System.debug('Productos nuevos con existencias: ' + listProductosNuevos.size());
				upsert listProductosNuevos Product2.idExternoArticulo__c;
			}*/
			
		} catch(DmlException e) {
			System.debug('Error cause: ' + e.getCause() + '-Line number:' + e.getLineNumber() + ' - Message:' + e.getMessage());
		}
	}



	//************************* WSGarantias *****************************************
	@future(callout = true)
	public static void ProcesarGarantias(String compania) {
		//Parsear xml
		HttpResponse res = CallWSGarantias(compania);
		List<Garantias> listgarant;
		if (res != null && res.getBody() != null && res.getBody() != '') {
			listgarant = ParserGarantias(res.getBody(),compania); //Obtenemos datos de WS encabezados.
			System.debug('listgarant ProcesarGarantias ' + listgarant);
			if (!listgarant.isEmpty()) {
				insertaractualizarGarantias(listgarant); //Insertamos o actualizamos encabezados segun sea el caso del resgistro enviado.
			}

		}
	}

	//Invocacion del servicio web de Capris
	public static HttpResponse CallWSGarantias(String compania) {
		String response;
		HttpResponse res = new HttpResponse();

		try {
			HttpRequest req = new HttpRequest();
			Integer dia = system.now().day();
			Integer mes = system.now().month();
			Integer anno = system.now().year();
			Integer hora = system.now().hour()-1;
			system.debug('fecha 0 *** ' +dia+'.'+mes+'.'+anno+' '+ hora);
			string fecha = dia+'.'+mes+'.'+anno+' '+ hora+':00-H';
			req.setEndpoint('http://bd2.capris.cr:64423/Salesforce_ArticulosGarantia/webresources/app.entities.articulosgaran/'+compania+'-'+ fecha);
			req.setBody(CredentialHelper.CREDENTIALS);
			req.setMethod('GET');
			req.setTimeout(120000);
			Http h = new Http();
			res = h.send(req);


		} catch(Exception e) {
			system.debug('Error ' + e.getMessage() + '-Line number ' + e.getLineNumber());
		}
		return res;
	}
	
	public class Garantias{
		public String codigoArticulo{get;set;}
		public String garantiaArticulo{get;set;}
		public String companiaArticulo{get;set;}
		public String idArticulo{get;set;}
	}

	//Parseo de datos obtenidos del response del WS 
	public static List<Garantias> ParserGarantias(String xmlfile,String compania) {

		List<Garantias> listGarant = new List<Garantias> ();
		Garantias garantItem;
		System.Debug('****  xmlfile ParserGarantias **** ' + xmlfile);
		DOM.Document xmlDOC = new DOM.Document();
		xmlDOC.load(xmlfile);
		if (!xmlDOC.getRootElement().getChildElements().isEmpty()) {

			for (DOM.XMLNode ObjChild : xmlDOC.getRootElement().getChildElements()) {

				garantItem = new Garantias();

				for (DOM.XMLNode xmlNodeObjChild : ObjChild.getChildren()){
					if (xmlNodeObjChild.getName() == 'codigo' && xmlNodeObjChild.getText() != 'null')
						garantItem.codigoArticulo = xmlNodeObjChild.getText();
					if (xmlNodeObjChild.getName() == 'garantia' && xmlNodeObjChild.getText() != 'null')
						garantItem.garantiaArticulo = xmlNodeObjChild.getText();

					garantItem.companiaArticulo = compania;
					garantItem.idArticulo = compania + garantItem.codigoArticulo;
				}
				System.Debug('garantItem ' + garantItem);
				listGarant.add(garantItem); //lista de encabezado  
			}
		} //if (!rootElement.getChildElements().isEmpty())

		System.Debug('$$$$$$$ listaaa garantia ' + listGarant);
		return listGarant;
	}
	
	//Realizacion de upsert de datos enviados 
	public static void insertaractualizarGarantias(List<Garantias> listagarnt) {
		List<Product2> listProductosGarantias = new List<Product2>();
		List<Product2> listProductosNuevos = new List<Product2>();
		Map<String,String> mapGarantias = new Map<String,String>();
		//Map<String,Garantias> mapGarantiasCompleto = new Map<String,Garantias>();
		Set<String> setProductosExistentes = new Set<String>();

		try {
			
			for(Garantias gar:listagarnt){
				mapGarantias.put(gar.idArticulo,gar.garantiaArticulo);
				//mapGarantiasCompleto.put(gar.idArticulo,gar);
			}

			for(Product2 pro:[select id,idExternoArticulo__c,GarantiaArticulo__c from Product2 where idExternoArticulo__c in:mapGarantias.keySet()]){
				pro.GarantiaArticulo__c = mapGarantias.get(pro.idExternoArticulo__c);
				setProductosExistentes.add(pro.idExternoArticulo__c);
				listProductosGarantias.add(pro);
			}

			System.debug('Productos actualizados con garantias: ' + listProductosGarantias.size());
			/*if(mapGarantiasCompleto.keySet().size()!=setProductosExistentes.size()){
				for(String elemento:mapGarantiasCompleto.keySet()){
					if(!setProductosExistentes.contains(elemento)){
						Garantias newGarantia = mapGarantiasCompleto.get(elemento);
						Product2 newProducto = new Product2(
							Name = newGarantia.codigoArticulo,
							CODIGO__c = newGarantia.codigoArticulo,
							ProductCode = newGarantia.codigoArticulo,
							IsActive = true,
							ORG__c = newGarantia.companiaArticulo,
							idExternoArticulo__c = newGarantia.idArticulo,
							GarantiaArticulo__c = newGarantia.garantiaArticulo,
							PorGarantia__c = true
						);
						listProductosNuevos.add(newProducto);
					}
				}
			}*/
			
			if(!listProductosGarantias.isEmpty()){
				upsert listProductosGarantias Product2.idExternoArticulo__c;
			}

			/*if(!listProductosNuevos.isEmpty()){
				System.debug('Productos nuevos con garantias: ' + listProductosNuevos.size());
				upsert listProductosNuevos Product2.idExternoArticulo__c;
			}*/

		} catch(DmlException e) {
			System.debug('Error cause: ' + e.getCause() + '-Line number:' + e.getLineNumber() + ' - Message:' + e.getMessage());
		}
	}


}