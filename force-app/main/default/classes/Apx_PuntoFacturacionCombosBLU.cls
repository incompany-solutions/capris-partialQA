public class Apx_PuntoFacturacionCombosBLU {
/*
	

	//Usuarios Puntos de facturacion WS Call
	@future(callout = true)
	public static void ProcesarUsuarioPtoFacturacionBLU() {
		HttpResponse res = new HttpResponse();
		res = CallWSUsuarioPtoFacturacionBLU();
		List<Usuario_Facturaci_n__c> usrptoFac;
		if (res != null && res.getBody() != null && res.getBody() != '') {
			usrptoFac = ParserUsuariosPtoFacturacion(res.getBody()); //Obtenemos datos de WS encabezados.
			if (!usrptoFac.isEmpty()) {
				insertaractualizarUsuariosPtoFacturacion(usrptoFac); //Insertamos o actualizamos encabezados segun sea el caso del resgistro enviado.
			}

		}
	}
	public static HttpResponse CallWSUsuarioPtoFacturacionBLU() {
		HttpResponse res = new HttpResponse();
		try {
			HttpRequest req = new HttpRequest();
			req.setEndpoint('http://bd2.capris.cr:64423/Salesforce_UsuFact/webresources/app.entities.usuariosfact/BLU');
			req.setMethod('GET');
			req.setTimeout(120000);
			Http h = new Http();
			res = h.send(req);
		} catch(Exception e) {
			system.debug('Error ' + e.getMessage() + '- Line number: ' + e.getLineNumber());
		}
		return res;
	}

	//Parseo de datos obtenidos del response del WS 
	public static List<Usuario_Facturaci_n__c> ParserUsuariosPtoFacturacion(String xmlfile) {

		List<Usuario_Facturaci_n__c> listusrptos = new List<Usuario_Facturaci_n__c> ();
		Usuario_Facturaci_n__c usrptoFactItem;
		System.Debug('**** xmlfile ParserUsuariosPtoFacturacion BLU **** '+xmlfile);
		DOM.Document xmlDOC = new DOM.Document();
		xmlDOC.load(xmlfile);
		if (!xmlDOC.getRootElement().getChildElements().isEmpty()) {
			for (DOM.XMLNode ObjChild : xmlDOC.getRootElement().getChildElements()) {
				usrptoFactItem = new Usuario_Facturaci_n__c();
				for (DOM.XMLNode xmlNodeObjChild : ObjChild.getChildren())
				{
					if (xmlNodeObjChild.getName() == 'codUsu' && xmlNodeObjChild.getText() != 'null')
					usrptoFactItem.Codigo_de_Usuario__c = xmlNodeObjChild.getText();
					if (xmlNodeObjChild.getName() == 'descripcion' && xmlNodeObjChild.getText() != 'null')
					usrptoFactItem.Descripcion__c = xmlNodeObjChild.getText();
					if (xmlNodeObjChild.getName() == 'tipUsuario' && xmlNodeObjChild.getText() != 'null')
					usrptoFactItem.Tipo_de_Usuario__c = xmlNodeObjChild.getText();
					if (xmlNodeObjChild.getName() == 'usuarioBd' && xmlNodeObjChild.getText() != 'null')
					usrptoFactItem.Usuario_Base_de_Datos__c = xmlNodeObjChild.getText();

					usrptoFactItem.Cod_Compania__c = 'BLU';
					usrptoFactItem.Id_Usuario_Punto_Facturacion__c =usrptoFactItem.Cod_Compania__c+usrptoFactItem.Codigo_de_Usuario__c+usrptoFactItem.Usuario_Base_de_Datos__c;
				}
				System.Debug(usrptoFactItem);
				listusrptos.add(usrptoFactItem); //lista de encabezado  
			}
		}

		System.Debug('$$$$$$$ listaaa ' + listusrptos);
		return listusrptos;
	}

	//Realizacion de upsert de datos enviados 
	public static void insertaractualizarUsuariosPtoFacturacion(List<Usuario_Facturaci_n__c> listausrptoFac) {

		try {

			upsert listausrptoFac Usuario_Facturaci_n__c.Id_Usuario_Punto_Facturacion__c;
		} catch(DmlException e) {
			System.debug('Error cause: ' + e.getCause() + '-Line number:' + e.getLineNumber() + ' - Message:' + e.getMessage());
		}
	}


	//Puntos de facturacion WS Call
	@future(callout = true)
	public static void ProcesarPtoFacturacionBLU() {
		HttpResponse res = new HttpResponse();
		res = CallWSPtoFacturacionBLU();
		List<GES_PTO_FAC__c> ptoFac;
		if (res != null && res.getBody() != null && res.getBody() != '') {
			ptoFac = ParserPtoFacturacion(res.getBody()); //Obtenemos datos de WS encabezados.
			if (!ptoFac.isEmpty()) {
				insertaractualizarPtoFacturacion(ptoFac); //Insertamos o actualizamos encabezados segun sea el caso del resgistro enviado.
			}

		}

	}
	public static HttpResponse CallWSPtoFacturacionBLU() {
		HttpResponse res = new HttpResponse();
		try {
			HttpRequest req = new HttpRequest();
			req.setEndpoint('http://bd2.capris.cr:64423/Salesforce_UsuPtoFact/webresources/app.entities.usuariosptofact/BLU');
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
	public static List<GES_PTO_FAC__c> ParserPtoFacturacion(String xmlfile) {

		List<GES_PTO_FAC__c> listptos = new List<GES_PTO_FAC__c> ();
		GES_PTO_FAC__c ptoFactItem;
		System.Debug('**** xmlfile ParserPtoFacturacion BLU **** '+xmlfile);
		DOM.Document xmlDOC = new DOM.Document();
		xmlDOC.load(xmlfile);
		if (!xmlDOC.getRootElement().getChildElements().isEmpty()) {
			for (DOM.XMLNode ObjChild : xmlDOC.getRootElement().getChildElements()) {
				ptoFactItem = new GES_PTO_FAC__c();

				for (DOM.XMLNode xmlNodeObjChild : ObjChild.getChildren()){
					if (xmlNodeObjChild.getName() == 'codUsu' && xmlNodeObjChild.getText() != 'null')
					ptoFactItem.PTO_COD_USU__c = xmlNodeObjChild.getText();
					if (xmlNodeObjChild.getName() == 'descripcion' && xmlNodeObjChild.getText() != 'null')
					ptoFactItem.PTO_DESCRIPCION__c = xmlNodeObjChild.getText();
					if (xmlNodeObjChild.getName() == 'fecFin' && xmlNodeObjChild.getText() != 'null')
					ptoFactItem.PTO_FEC_FIN__c = xmlNodeObjChild.getText(); //Datime.valueOf();
					if (xmlNodeObjChild.getName() == 'ptoFact' && xmlNodeObjChild.getText() != 'null')
					ptoFactItem.PTO_COD_PTO__c = xmlNodeObjChild.getText();
					ptoFactItem.PTO_COD_ORG__c = 'BLU';
					ptoFactItem.IDPtoFact__c = ptoFactItem.PTO_COD_ORG__c+ptoFactItem.PTO_COD_USU__c+ptoFactItem.PTO_COD_PTO__c;
				}
				listptos.add(ptoFactItem); //lista de encabezado  
			}
			Integer i = 0;
			for (GES_PTO_FAC__c item : listptos) {
				system.debug('Item de lista ' + i + ' punto facturacion ' + item);
				i++;
			}
		}

		System.Debug('$$$$$$$ listaaa ' + listptos);
		return listptos;
	}

	//Realizacion de upsert de datos enviados 
	public static void insertaractualizarPtoFacturacion(List<GES_PTO_FAC__c> listaptoFac) {
		Set<String> puntos = new Set<String>();
		Set<String> companias = new Set<String>();
		Map<String,String> mapMuelles = new Map<String,String>();
		List<GES_PTO_FAC__c> listaFinalPtoFacturacion = new List<GES_PTO_FAC__c>();

		try {
			if(!listaptoFac.isEmpty()){
				for(GES_PTO_FAC__c pfact:listaptoFac){
					puntos.add(pfact.PTO_COD_PTO__c);
					companias.add(pfact.PTO_COD_ORG__c);
				}

				for(GES_MUELLES__c m:[select id,GES_MUE_PTO__c,GES_MUE_COM__c from GES_MUELLES__c where GES_MUE_PTO__c in:puntos and GES_MUE_COM__c in:companias]){
					mapMuelles.put(m.GES_MUE_PTO__c+m.GES_MUE_COM__c,m.id);
				}

				for(GES_PTO_FAC__c pfact:listaptoFac){
					if(mapMuelles.containsKey(pfact.PTO_COD_PTO__c+pfact.PTO_COD_ORG__c)){
						pfact.Muelle_del__c = mapMuelles.get(pfact.PTO_COD_PTO__c+pfact.PTO_COD_ORG__c);
						listaFinalPtoFacturacion.add(pfact);
					}
				}

				if(!listaFinalPtoFacturacion.isEmpty()){
					upsert listaFinalPtoFacturacion GES_PTO_FAC__c.IDPtoFact__c;
				}

			}


		} catch(DmlException e) {
			System.debug('Error cause: ' + e.getCause() + '-Line number:' + e.getLineNumber() + ' - Message:' + e.getMessage());
		}
	}

	//Muelles WS Call
	@future(callout = true)
	public static void ProcesarMuellesBLU() {
		HttpResponse res = new HttpResponse();
		res = CallWSMuellesBLU();

		List<GES_MUELLES__c> ptoMuelle;
		if (res != null && res.getBody() != null && res.getBody() != '') {
			ptoMuelle = ParserMuelles(res.getBody()); //Obtenemos datos de WS encabezados.
			if (!ptoMuelle.isEmpty()) {
				insertaractualizarMuelles(ptoMuelle); //Insertamos o actualizamos encabezados segun sea el caso del resgistro enviado.
			}
		}


	}
	public static HttpResponse CallWSMuellesBLU() {
		HttpResponse res = new HttpResponse();
		try {
			HttpRequest req = new HttpRequest();
			req.setEndpoint('http://bd2.capris.cr:64423/Salesforce_MuellesPtoFact/webresources/app.entities.muellesptofact/BLU');
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
	public static List<GES_MUELLES__c> ParserMuelles(String xmlfile) {

		List<GES_MUELLES__c> listmuelle = new List<GES_MUELLES__c> ();
		GES_MUELLES__c muelleItem;
		System.Debug('**** xmlfile ParserMuelles BLU **** '+xmlfile);
		DOM.Document xmlDOC = new DOM.Document();
		xmlDOC.load(xmlfile);
		if (!xmlDOC.getRootElement().getChildElements().isEmpty()) {
			for (DOM.XMLNode ObjChild : xmlDOC.getRootElement().getChildElements()) {

				muelleItem = new GES_MUELLES__c();

				for (DOM.XMLNode xmlNodeObjChild : ObjChild.getChildren()){
					if (xmlNodeObjChild.getName() == 'codMuelle' && xmlNodeObjChild.getText() != 'null')
					muelleItem.GES_MUE_COD__c = xmlNodeObjChild.getText();
					if (xmlNodeObjChild.getName() == 'descripcion' && xmlNodeObjChild.getText() != 'null')
					muelleItem.GES_MUE_DES__c = xmlNodeObjChild.getText();
					if (xmlNodeObjChild.getName() == 'ptoFact' && xmlNodeObjChild.getText() != 'null')
					muelleItem.GES_MUE_PTO__c = xmlNodeObjChild.getText(); //Datime.valueOf();

					muelleItem.GES_MUE_COM__c = 'BLU';
					muelleItem.IDMuelle__c = muelleItem.GES_MUE_COM__c+muelleItem.GES_MUE_COD__c+muelleItem.GES_MUE_PTO__c;

				}
				listmuelle.add(muelleItem); //lista de encabezado  
			}

		}

		return listmuelle;
	}

	//Realizacion de upsert de datos enviados 
	public static void insertaractualizarMuelles(List<GES_MUELLES__c> listamuelle) {

		try {

			upsert listamuelle GES_MUELLES__c.IDMuelle__c;
		} catch(DmlException e) {
			System.debug('Error cause: ' + e.getCause() + '-Line number:' + e.getLineNumber() + ' - Message:' + e.getMessage());
		}
	}


	//Combos WS Call
	@future(callout = true)
	public static void ProcesarCombosPtosBLU() {
		HttpResponse res = new HttpResponse();
		res = CallWSCombosPtosBLU();
		List<Combo_Punto_Facturacion__c> ptoCombos;
		if (res != null && res.getBody() != null && res.getBody() != '') {
			ptoCombos = ParserCombos(res.getBody()); //Obtenemos datos de WS encabezados.
			if (!ptoCombos.isEmpty()) {
				insertaractualizarCombos(ptoCombos); //Insertamos o actualizamos encabezados segun sea el caso del resgistro enviado.
			}

		}

	}
	public static HttpResponse CallWSCombosPtosBLU() {
		HttpResponse res = new HttpResponse();
		try {
			HttpRequest req = new HttpRequest();

			req.setEndpoint('http://bd2.capris.cr:64423/Salesforce_CombosPtoFact/webresources/app.entities.combosptofact/BLU');
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
	public static List<Combo_Punto_Facturacion__c> ParserCombos(String xmlfile) {

		List<Combo_Punto_Facturacion__c> listCombos = new List<Combo_Punto_Facturacion__c> ();
		Combo_Punto_Facturacion__c comboItem;
		System.Debug('**** xmlfile ParserCombos BLU **** ' + xmlfile);
		DOM.Document xmlDOC = new DOM.Document();
		xmlDOC.load(xmlfile);
		if (!xmlDOC.getRootElement().getChildElements().isEmpty()) {
			for (DOM.XMLNode ObjChild : xmlDOC.getRootElement().getChildElements()) {
				comboItem = new Combo_Punto_Facturacion__c();
				for (DOM.XMLNode xmlNodeObjChild : ObjChild.getChildren()){
					if (xmlNodeObjChild.getName() == 'codOferta' && xmlNodeObjChild.getText() != 'null')
					comboItem.Codigo_Oferta__c = xmlNodeObjChild.getText();
					if (xmlNodeObjChild.getName() == 'ptoFact' && xmlNodeObjChild.getText() != 'null')
					comboItem.Punto_Fact__c = xmlNodeObjChild.getText();
					comboItem.Codigo_Compania__c = 'BLU';
					comboItem.Id_Externo__c = comboItem.Codigo_Compania__c+comboItem.Codigo_Oferta__c+comboItem.Punto_Fact__c;
				}
				System.Debug(comboItem);
				listCombos.add(comboItem); //lista de encabezado  
			}
			Integer i = 0;
			for (Combo_Punto_Facturacion__c item : listCombos) {
				system.debug('Item de lista ' + i + ' encabezado ' + item);
				i++;
			}
		}

		System.Debug('$$$$$$$ listaaa ' + listCombos);
		return listCombos;
	}

	//Realizacion de upsert de datos enviados 
	public static void insertaractualizarcombos(List<Combo_Punto_Facturacion__c> listacombos) {

		try {

			upsert listacombos Combo_Punto_Facturacion__c.Id_Externo__c;
		} catch(DmlException e) {
			System.debug('Error cause: ' + e.getCause() + '-Line number:' + e.getLineNumber() + ' - Message:' + e.getMessage());
		}
	}


	//Combos WS Call
	@future(callout = true)
	public static void ProcesarCombosEncabezadosBLU() {
		HttpResponse res = new HttpResponse();
		res = CallWSCombosEncabezadosBLU();
		List<GES_COMBOS__c> ptoCombos;
		if (res != null && res.getBody() != null && res.getBody() != '') {
			ptoCombos = ParserCombosEnc(res.getBody()); //Obtenemos datos de WS encabezados.
			if (!ptoCombos.isEmpty()) {
				insertaractualizarEnc(ptoCombos); //Insertamos o actualizamos encabezados segun sea el caso del resgistro enviado.
			}

		}
	}
	public static HttpResponse CallWSCombosEncabezadosBLU() {
		HttpResponse res = new HttpResponse();
		try {
			HttpRequest req = new HttpRequest();

			req.setEndpoint('http://bd2.capris.cr:64423/Salesforce_EncCombos/webresources/app.entities.enccombos/BLU');
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
	public static List<GES_COMBOS__c> ParserCombosEnc(String xmlfile) {

		List<GES_COMBOS__c> listCombosEnc = new List<GES_COMBOS__c> ();
		GES_COMBOS__c comboencItem;
		System.Debug('$$$$ xmlfile existencia ' + xmlfile);
		DOM.Document xmlDOC = new DOM.Document();
		xmlDOC.load(xmlfile);
		if (!xmlDOC.getRootElement().getChildElements().isEmpty()) {
			for (DOM.XMLNode ObjChild : xmlDOC.getRootElement().getChildElements()) {
				comboencItem = new GES_COMBOS__c();

				for (DOM.XMLNode xmlNodeObjChild : ObjChild.getChildren()){
					if (xmlNodeObjChild.getName() == 'codOferta' && xmlNodeObjChild.getText() != 'null')
					comboencItem.COM_COD_OFERTA__c = xmlNodeObjChild.getText();
					if (xmlNodeObjChild.getName() == 'codart' && xmlNodeObjChild.getText() != 'null')
					comboencItem.COM_COD_PROD__c = xmlNodeObjChild.getText();
					if (xmlNodeObjChild.getName() == 'descripcion' && xmlNodeObjChild.getText() != 'null')
					comboencItem.COM_DESCRIPCION__c = xmlNodeObjChild.getText();
					if (xmlNodeObjChild.getName() == 'facComp' && xmlNodeObjChild.getText() != 'null')
					comboencItem.COM_FAC_COM__c = xmlNodeObjChild.getText();


					comboencItem.COM_COD_ORG__c = 'BLU';
					comboencItem.IDCombo__c = comboencItem.COM_COD_ORG__c +comboencItem.COM_COD_OFERTA__c+ comboencItem.COM_COD_PROD__c;
				}
				System.Debug(comboencItem);
				listCombosEnc.add(comboencItem); //lista de encabezado  
			}
			Integer i = 0;
			for (GES_COMBOS__c item : listCombosEnc) {
				system.debug('Item de lista ' + i + ' encabezado ' + item);
				i++;
			}
		}

		System.Debug('$$$$$$$ listaaa ' + listCombosEnc);
		return listCombosEnc;
	}

	//Realizacion de upsert de datos enviados 
	public static void insertaractualizarEnc(List<GES_COMBOS__c> listacombos) {

		try {

			upsert listacombos GES_COMBOS__c.IDCombo__c;
		} catch(DmlException e) {
			System.debug('Error cause: ' + e.getCause() + '-Line number:' + e.getLineNumber() + ' - Message:' + e.getMessage());
		}
	}

	//Combos WS Call
	@future(callout = true)
	public static void ProcesarCombosDetallesBLU() {
		HttpResponse res = new HttpResponse();
		res = CallWSCombosDetallesBLU();
		List<GES_DET_COMBOS__c> ptoCombosDet;
		if (res != null && res.getBody() != null && res.getBody() != '') {
			ptoCombosDet = ParserCombosDet(res.getBody()); //Obtenemos datos de WS encabezados.
			if (!ptoCombosDet.isEmpty()) {
				insertaractualizarDet(ptoCombosDet); //Insertamos o actualizamos encabezados segun sea el caso del resgistro enviado.
			}
		}



	}
	public static HttpResponse CallWSCombosDetallesBLU() {
		HttpResponse res = new HttpResponse();
		try {
			HttpRequest req = new HttpRequest();

			req.setEndpoint('http://bd2.capris.cr:64423/Salesforce_DetCombos/webresources/app.entities.detcombos/BLU');
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
	public static List<GES_DET_COMBOS__c> ParserCombosDet(String xmlfile) {

		List<GES_DET_COMBOS__c> listCombosDet = new List<GES_DET_COMBOS__c> ();
		GES_DET_COMBOS__c combodetItem;
		System.Debug('$$$$ xmlfile existencia ' + xmlfile);
		DOM.Document xmlDOC = new DOM.Document();
		xmlDOC.load(xmlfile);
		if (!xmlDOC.getRootElement().getChildElements().isEmpty()) {
			for (DOM.XMLNode ObjChild : xmlDOC.getRootElement().getChildElements()) {
				combodetItem = new GES_DET_COMBOS__c();

				for (DOM.XMLNode xmlNodeObjChild : ObjChild.getChildren()){


					if (xmlNodeObjChild.getName() == 'cantidad' && xmlNodeObjChild.getText() != 'null')
					combodetItem.GDC_CANTIDAD__c = Decimal.valueOf(xmlNodeObjChild.getText());
					if (xmlNodeObjChild.getName() == 'codOferta' && xmlNodeObjChild.getText() != 'null')
					combodetItem.GDC_COD_OFERTA__c = xmlNodeObjChild.getText();
					if (xmlNodeObjChild.getName() == 'codigo' && xmlNodeObjChild.getText() != 'null')
					combodetItem.GDC_COD_PROD__c = xmlNodeObjChild.getText();
					if (xmlNodeObjChild.getName() == 'precio' && xmlNodeObjChild.getText() != 'null')
					combodetItem.GDC_PRECIO__c = Decimal.valueOf(xmlNodeObjChild.getText());


					combodetItem.GDC_COD_ORG__c = 'BLU';
					combodetItem.IDDetComb__c = combodetItem.GDC_COD_ORG__c+combodetItem.GDC_COD_OFERTA__c+combodetItem.GDC_COD_PROD__c;
				}
				System.Debug(combodetItem);
				listCombosDet.add(combodetItem); //lista de encabezado  
			}
			Integer i = 0;
			for (GES_DET_COMBOS__c item : listCombosDet) {
				system.debug('Item de lista ' + i + ' detalle ' + item);
				i++;
			}
		}

		System.Debug('$$$$$$$ listaaa ' + listCombosDet);
		return listCombosDet;
	}

	//Realizacion de upsert de datos enviados 
	public static void insertaractualizarDet(List<GES_DET_COMBOS__c> listacombosdet) {

		try {

			upsert listacombosdet GES_DET_COMBOS__c.IDDetComb__c;
		} catch(DmlException e) {
			System.debug('Error cause: ' + e.getCause() + '-Line number:' + e.getLineNumber() + ' - Message:' + e.getMessage());
		}
	}
	*/
}