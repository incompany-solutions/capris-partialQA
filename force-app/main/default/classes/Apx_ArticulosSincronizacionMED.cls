public class Apx_ArticulosSincronizacionMED {

	/*public Apx_ArticulosSincronizacionMED() { }

	//************************* WSArticulos MED *****************************************
	@future(callout = true)
	public static void ProcesarArticulosMED() {
		//Parsear xml
		//system.debug('XML response articulos '+res.getBody());
		HttpResponse res = CallWSArticulosMED();
		List<Product2> listartc;
		if (res != null && res.getBody() != null && res.getBody() != '') {
			listartc = ParserArticulos(res.getBody()); //Obtenemos datos de WS articulos. 
			System.debug('listartc ProcesarArticulosMED ' + listartc);
			if (!listartc.isEmpty()) {
				insertaractualizarArticulos(listartc); //Insertamos o actualizamos articulos.
			}
		}



	}
	//Invocacion del servicio web de Capris

	public static HttpResponse CallWSArticulosMED() {
		HttpResponse res = new HttpResponse();
		try {
			HttpRequest req = new HttpRequest();
			string fecha = system.now().format();
			fecha = fecha.replace('/', '.');
			fecha = fecha.substring(0, fecha.length() - 3);
			req.setEndpoint('http://bd2.capris.cr:64423/Salesforce_Articulos/webresources/app.entities.articulos/MED-' + fecha + '-H');
			req.setMethod('GET');
			req.setTimeout(60000);
			Http h = new Http();
			res = h.send(req);

			//Parsear xml
			system.debug('XML response articulos ' + res.getBody());
			// String xmlArtc=res.getBody();


		} catch(Exception e) {
			system.debug('Error ' + e.getMessage() + '-Line number ' + e.getLineNumber());
		}
		return res;
	}

	//Realizacion de upsert de datos enviados 
	public static void insertaractualizarArticulos(List<Product2> listaartic) {

		try {
			upsert listaartic Product2.idExternoArticulo__c;
		} catch(DmlException e) {
			System.debug('Error cause: ' + e.getCause() + '-Line number:' + e.getLineNumber() + ' - Message:' + e.getMessage());
		}
	}

	//Parseo de datos obtenidos del response del WS 
	public static List<Product2> ParserArticulos(String xmlfile) {

		List<Product2> listArticulos = new List<Product2> ();
		Product2 articuloItem;
		System.Debug('**** xmlfile ParserArticulos MED **** ' + xmlfile);
		DOM.Document xmlDOC = new DOM.Document();
		xmlDOC.load(xmlfile);
		if (!xmlDOC.getRootElement().getChildElements().isEmpty()) {
			for (DOM.XMLNode ObjChild : xmlDOC.getRootElement().getChildElements()) {
				articuloItem = new Product2();

				for (DOM.XMLNode xmlNodeObjChild : ObjChild.getChildren())
				{

					if (xmlNodeObjChild.getName() == 'codigo' && xmlNodeObjChild.getText() != 'null') {
						articuloItem.CODIGO__c = xmlNodeObjChild.getText();
						articuloItem.ProductCode = xmlNodeObjChild.getText();
						articuloItem.ORG__c = 'MED';
						articuloItem.idExternoArticulo__c = articuloItem.CODIGO__c + articuloItem.ORG__c;

						if (xmlNodeObjChild.getName() == 'descripcion' && xmlNodeObjChild.getText() != 'null')
						articuloItem.DESCRIPCION__c = xmlNodeObjChild.getText();
						if (xmlNodeObjChild.getName() == 'estado' && xmlNodeObjChild.getText() != 'null')
						articuloItem.ESTADO__c = xmlNodeObjChild.getText();
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
					}



				}
				System.Debug(articuloItem);
				listArticulos.add(articuloItem); //lista de encabezado  
			}
			Integer i = 0;
			for (Product2 item : listArticulos) {
				system.debug('Item de lista ' + i + ' articulo ' + item);
				i++;
			}
		} //if(!xmlDOC.getRootElement().getChildElements().isEmpty())

		System.Debug('$$$$$$$ listaaa articulo' + listArticulos);
		return listarticulos;
	}

	//************************* WSExistencias *****************************************
	@future(callout = true)
	public static void ProcesarExistenciasMED() {
		//Parsear xml
		//system.debug('XML response articulos '+res.getBody());
		HttpResponse res = CallWSExistenciasMED();
		List<Existencias__c> listexist;
		if (res != null && res.getBody() != null && res.getBody() != '') {
			listexist = ParserExistencias(res.getBody()); //Obtenemos datos de WS encabezados.
			System.debug('listexist ProcesarExistenciasMED ' + listexist);
			if (!listexist.isEmpty()) {
				insertaractualizarExistencias(listexist); //Insertamos o actualizamos encabezados segun sea el caso del resgistro enviado.
			}
		}

	}
	//Invocacion del servicio web de Capris
	//@future(callout=true)
	public static HttpResponse CallWSExistenciasMED() {
		String response;
		HttpResponse res = new HttpResponse();
		try {
			HttpRequest req = new HttpRequest();
			string fecha = system.now().format();
			fecha = fecha.replace('/', '.');
			fecha = fecha.substring(0, fecha.length() - 3);

			req.setEndpoint('http://bd2.capris.cr:64423/Salesforce_ExistenciaArticulo/webresources/app.entities.existencias/MED-' + fecha + '-H');
			req.setMethod('GET');
			req.setTimeout(60000);
			Http h = new Http();
			res = h.send(req);

			//Parsear xml
			system.debug('XML response ' + res.getBody());
			//response=res.getBody();
		} catch(Exception e) {
			system.debug('Error ' + e.getMessage() + '-Line number ' + e.getLineNumber());
		}
		return res;
	}

	//Realizacion de upsert de datos enviados 
	public static void insertaractualizarExistencias(List<Existencias__c> listaexist) {

		try {
			upsert listaexist Existencias__c.IDEX__c;
		} catch(DmlException e) {
			System.debug('Error cause: ' + e.getCause() + '-Line number:' + e.getLineNumber() + ' - Message:' + e.getMessage());
		}
	}

	//Parseo de datos obtenidos del response del WS 
	public static List<Existencias__c> ParserExistencias(String xmlfile) {

		List<Existencias__c> listExist = new List<Existencias__c> ();
		Existencias__c existItem;
		System.Debug('**** xmlfile existencia ParserExistencias MED **** ' + xmlfile);
		DOM.Document xmlDOC = new DOM.Document();
		xmlDOC.load(xmlfile);
		if (!xmlDOC.getRootElement().getChildElements().isEmpty()) {
			for (DOM.XMLNode ObjChild : xmlDOC.getRootElement().getChildElements()) {

				existItem = new Existencias__c();

				for (DOM.XMLNode xmlNodeObjChild : ObjChild.getChildren()){

					if (xmlNodeObjChild.getName() == 'codigo' && xmlNodeObjChild.getText() != 'null')
					existItem.C_digo_de_art_culo__c = xmlNodeObjChild.getText();
					if (xmlNodeObjChild.getName() == 'exist' && xmlNodeObjChild.getText() != 'null') {
						existItem.Existencia__c = Decimal.valueOf(xmlNodeObjChild.getText());
						existItem.Name = xmlNodeObjChild.getText();
					}

					existItem.C_digo__c = 'MED';
					existItem.IDEX__c = existItem.C_digo__c + existItem.C_digo_de_art_culo__c;

				}
				System.Debug(existItem);
				listExist.add(existItem); //lista de encabezado  
			}
			Integer i = 0;
			for (Existencias__c item : listExist) {
				system.debug('Item de lista ' + i + ' encabezado ' + item);
				i++;
			}
		} //if(!xmlDOC.getRootElement().getChildElements().isEmpty())

		System.Debug('$$$$$$$ listaaa ' + listExist);
		return listExist;
	}

	//************************* WSGarantias *****************************************
	@future(callout = true)
	public static void ProcesarGarantiasMED() {
		//Parsear xml
		//system.debug('XML response articulos '+res.getBody());
		HttpResponse res = CallWSGarantiasMED();
		List<Garantia__c> listgarant;
		System.debug('res ProcesarGarantiasMED ' + res);
		System.debug('res.getBody() ProcesarGarantiasMED ' + res.getBody());
		if (res != null && res.getBody() != null && res.getBody() != '') {
			listgarant = ParserGarantias(res.getBody()); //Obtenemos datos de WS encabezados.
			System.debug('listgarant ProcesarGarantiasMED ' + listgarant);
			if (!listgarant.isEmpty()) {
				insertaractualizarGarantias(listgarant); //Insertamos o actualizamos encabezados segun sea el caso del resgistro enviado.
			}
		}

	}
	//Invocacion del servicio web de Capris

	public static HttpResponse CallWSGarantiasMED() {
		String response;
		HttpResponse res = new HttpResponse();
		try {
			HttpRequest req = new HttpRequest();
			string fecha = system.now().format();
			fecha = fecha.replace('/', '.');
			fecha = fecha.substring(0, fecha.length() - 3);

			req.setEndpoint('http://bd2.capris.cr:64423/Salesforce_ArticulosGarantia/webresources/app.entities.articulosgaran/MED-' + fecha + '-H');
			req.setMethod('GET');
			req.setTimeout(60000);
			Http h = new Http();
			res = h.send(req);

			//Parsear xml
			system.debug('XML response garantias' + res.getBody());

		} catch(Exception e) {
			system.debug('Error ' + e.getMessage() + '-Line number ' + e.getLineNumber());
		}
		return res;
	}

	//Realizacion de upsert de datos enviados 
	public static void insertaractualizarGarantias(List<Garantia__c> listagarnt) {

		try {
			upsert listagarnt Garantia__c.IDG__c;
		} catch(DmlException e) {
			System.debug('Error cause: ' + e.getCause() + '-Line number:' + e.getLineNumber() + ' - Message:' + e.getMessage());
		}
	}

	//Parseo de datos obtenidos del response del WS 
	public static List<Garantia__c> ParserGarantias(String xmlfile) {

		List<Garantia__c> listGarant = new List<Garantia__c> ();
		Garantia__c garantItem;
		System.Debug('**** xmlfile ParserGarantias MED **** ' + xmlfile);
		DOM.Document xmlDOC = new DOM.Document();
		xmlDOC.load(xmlfile);

		if (!xmlDOC.getRootElement().getChildElements().isEmpty()) {

			for (DOM.XMLNode ObjChild : xmlDOC.getRootElement().getChildElements()) {

				garantItem = new Garantia__c();

				for (DOM.XMLNode xmlNodeObjChild : ObjChild.getChildren())
				{

					if (xmlNodeObjChild.getName() == 'codigo' && xmlNodeObjChild.getText() != 'null')
					garantItem.CODIGO__c = xmlNodeObjChild.getText();
					if (xmlNodeObjChild.getName() == 'garantia' && xmlNodeObjChild.getText() != 'null')
					garantItem.DETALLE_GARANTIA__c = xmlNodeObjChild.getText();

					garantItem.Codigo_Compania__c = 'MED';
					garantItem.IDG__c = garantItem.Codigo_Compania__c + garantItem.CODIGO__c;

				}
				System.Debug(garantItem);
				listGarant.add(garantItem); //lista de encabezado  
			}
			Integer i = 0;
			for (Garantia__c item : listGarant) {
				system.debug('Item de lista ' + i + ' garantia ' + item);
				i++;
			}
		} //if(!xmlDOC.getRootElement().getChildElements().isEmpty())

		System.Debug('$$$$$$$ listaaa garantia ' + listGarant);
		return listGarant;
	}*/
}