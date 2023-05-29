/**
 * @description       : 
 * @author            : esteban@incompany.cr
 * @group             : 
 * @last modified on  : 29-05-2023
 * @last modified by  : esteban@incompany.cr
**/
public class Apx_PuntosFacturacionCombos {
    public static String generateCredenciales()
    {
        Credenciales_Endpoint__mdt mdt_credenciales = Credenciales_Endpoint__mdt.getInstance('credenciales');
        String pkey = mdt_credenciales.Llave__c;
        String porg = mdt_credenciales.Organization__c;
        String CREDENCIALES = '{"pkey":"'+pkey+'","porg":"'+porg+'"}';
        return CREDENCIALES;
    }
    /******************************** INICIA MUELLES********************************/
    //Muelles WS Call
    @future(callout = true)
    public static void ProcesarMuelle(String compania) {
        HttpResponse res = new HttpResponse();
        res = CallWSMuelles(compania);
        List<Muelle> ptoMuelle;
        if (res != null && res.getBody() != null && res.getBody() != '') {
            ptoMuelle = ParserMuelles(res.getBody(),compania); //Obtenemos datos de WS encabezados.
            System.debug('ptoMuelle ProcesarMuelle CAP ' + ptoMuelle);
            if (!ptoMuelle.isEmpty()) {
                insertaractualizarMuelles(ptoMuelle); //Insertamos o actualizamos encabezados segun sea el caso del resgistro enviado.
            }
        }
    }

    public static HttpResponse CallWSMuelles(String compania) 
    {
        String CREDENCIALES = generateCredenciales();
        Catalogo_Endpoints__mdt catalogo = Catalogo_Endpoints__mdt.getInstance('app_entities_muellesptofact');
        String endpoint = catalogo.URL__c;

        HttpResponse res = new HttpResponse();
        try 
        {
            HttpRequest req = new HttpRequest();
            req.setEndpoint(endpoint);
            req.setBody(CREDENCIALES);
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
    public static List<Muelle> ParserMuelles(String xmlfile,String compania) {
        System.Debug('****  xmlfile ParserMuelles CAP **** ' + xmlfile);
        //String compania = 'CAP';
        DOM.Document xmlDOC = new DOM.Document();
        xmlDOC.load(xmlfile);

        String codigoMuelle, descripcionMuelle, puntoFactMuelle;

        Set<String> setPuntosFact = new Set<String> ();
        Set<String> setMuelles = new Set<String> ();
        Set<String> setMuellesPuntos = new Set<String> ();
        set<String> puntosSet = new Set<String> ();

        list<Muelle> listMuelles = new list<Muelle> ();
        list<MuellePunto> listMuellesPuntos = new List<MuellePunto> ();
        List<Punto> listPuntosUnicos = new List<Punto> ();

        Map<String, list<string>> mapPuntosMuelle = new Map<String, list<string>> ();

        Muelle muelleItem;
        MuellePunto muellePuntoFact;
        Punto puntoUnico;

        if (!xmlDOC.getRootElement().getChildElements().isEmpty()) {
            codigoMuelle = '';
            descripcionMuelle = '';
            puntoFactMuelle = '';
            for (DOM.XMLNode ObjChild : xmlDOC.getRootElement().getChildElements()) {
                for (DOM.XMLNode xmlNodeObjChild : ObjChild.getChildren()) {
                    if (xmlNodeObjChild.getText() != 'null') {
                        if (xmlNodeObjChild.getName() == 'codMuelle') {
                            codigoMuelle = xmlNodeObjChild.getText();
							if (!mapPuntosMuelle.containsKey(codigoMuelle + compania)) {
                            mapPuntosMuelle.put(codigoMuelle + compania, new list<String> ());
							}
                        }
                        
                        if (xmlNodeObjChild.getName() == 'ptoFact') {
                            puntoFactMuelle = xmlNodeObjChild.getText();
							if (mapPuntosMuelle.containsKey(codigoMuelle + compania)) {
								mapPuntosMuelle.get(codigoMuelle + compania).add(puntoFactMuelle);
							}                        
						}

                    }
                }
            }
            System.debug('mapPuntosMuelle ' + mapPuntosMuelle);
            codigoMuelle = '';
            descripcionMuelle = '';

            for (DOM.XMLNode ObjChild : xmlDOC.getRootElement().getChildElements()) {
                for (DOM.XMLNode xmlNodeObjChild : ObjChild.getChildren()) {
                    if (xmlNodeObjChild.getText() != 'null') {
                        if (xmlNodeObjChild.getName() == 'codMuelle') {
                            codigoMuelle = xmlNodeObjChild.getText();
                        }
                        if (xmlNodeObjChild.getName() == 'descripcion') {
                            descripcionMuelle = xmlNodeObjChild.getText();
                        }
                        if (codigoMuelle != '' && descripcionMuelle != '' && !setMuelles.contains(compania + codigoMuelle)) {
                            muelleItem = new Muelle();
                            setMuelles.add(compania + codigoMuelle);
                            muelleItem.compania = compania;
                            muelleItem.codMuelle = codigoMuelle;
                            muelleItem.descripcion = descripcionMuelle;
                            muelleItem.idExternoMuelle = compania + codigoMuelle;
                            if (!mapPuntosMuelle.values().isEmpty() && mapPuntosMuelle.containsKey(codigoMuelle + compania)) {
                                list<String> puntosLista = mapPuntosMuelle.get(codigoMuelle + compania);
                                for (String pfact : puntosLista) {
                                    if (!puntosSet.contains(pfact)) {
                                        puntosSet.add(pfact);
                                    }
                                    muellePuntoFact = new MuellePunto();
                                    muellePuntoFact.codPuntoFact = pfact;
                                    muellePuntoFact.codMuelle = codigoMuelle;
                                    muellePuntoFact.compania = compania;
                                    muellePuntoFact.idExternoMuellePunto = compania + pfact + codigoMuelle;
                                    listMuellesPuntos.add(muellePuntoFact);
                                }
                                if (!listMuellesPuntos.isEmpty()) {
                                    muelleItem.muellesPuntos = listMuellesPuntos;
                                }
                                if (!puntosSet.isEmpty()) {
                                    for (String p : puntosSet) {
                                        puntoUnico = new Punto();
                                        puntoUnico.codPuntoFact = p;
                                        puntoUnico.compania = compania;
                                        puntoUnico.idExternoPunto = compania + p;
                                        listPuntosUnicos.add(puntoUnico);
                                    }
                                    if (!listPuntosUnicos.isEmpty()) {
                                        muelleItem.puntos = listPuntosUnicos;
                                    }
                                }
                            }
                            listMuelles.add(muelleItem);
                        }
                    }
                }
            }
        }
        System.debug('$$$$$$ ' + listMuelles);
        return listMuelles;
    }

    public static void insertaractualizarMuelles(List<Muelle> listamuelle) {
        Set<String> puntos = new Set<String> ();
        Set<String> puntosMuelles = new Set<String> ();

        List<GES_MUELLES__c> listmuelle = new List<GES_MUELLES__c> ();
        list<GES_PTO_FAC__c> listaPfact = new list<GES_PTO_FAC__c> ();
        List<MuellesPuntosFacturacion__c> listMuellesPuntos = new List<MuellesPuntosFacturacion__c> ();

        GES_MUELLES__c muelleItem;
        GES_PTO_FAC__c ptoFactItem;
        MuellesPuntosFacturacion__c muellePunto;
        System.debug('MUELLES A INSERTAR ' + listamuelle.size());
        try {
            if (!listamuelle.isEmpty()) {
                for (Muelle mItem : listamuelle) {
                    muelleItem = new GES_MUELLES__c();
					muelleItem.Name = mItem.descripcion;
                    muelleItem.GES_MUE_COD__c = mItem.codMuelle;
                    muelleItem.GES_MUE_DES__c = mItem.descripcion;
                    muelleItem.GES_MUE_COM__c = mItem.compania;
                    muelleItem.IDMuelle__c = mItem.idExternoMuelle;
                    if (!mItem.puntos.isEmpty()) {
                        for (Punto pUni : mItem.puntos) {
                            if (!puntos.contains(pUni.idExternoPunto)) {
                                puntos.add(pUni.idExternoPunto);
                                ptoFactItem = new GES_PTO_FAC__c();
								ptoFactItem.Name = pUni.codPuntoFact;
                                ptoFactItem.PTO_COD_ORG__c = pUni.compania;
                                ptoFactItem.PTO_COD_PTO__c = pUni.codPuntoFact;
                                ptoFactItem.IDPtoFact__c = pUni.idExternoPunto;
                                listaPfact.add(ptoFactItem);
                            }
                        }
                    }
                    if (!mItem.muellesPuntos.isEmpty()) {
                        for (MuellePunto mPunt : mItem.muellesPuntos) {
                            if (!puntosMuelles.contains(mPunt.idExternoMuellePunto)) {
                                puntosMuelles.add(mPunt.idExternoMuellePunto);
                                muellePunto = new MuellesPuntosFacturacion__c();
                                muellePunto.IdMuelle__c = mPunt.codMuelle;
                                muellePunto.IdPunto__c = mPunt.codPuntoFact;
                                muellePunto.Compania__c = mPunt.compania;
                                muellePunto.IdExterno__c = mPunt.idExternoMuellePunto;
                                listMuellesPuntos.add(muellePunto);
                            }
                        }
                    }
                    listmuelle.add(muelleItem);
                }
                if (!listmuelle.isEmpty()) {
                    upsert listmuelle GES_MUELLES__c.IDMuelle__c;
                }
                if (!listaPfact.isEmpty()) {
                    upsert listaPfact GES_PTO_FAC__c.IDPtoFact__c;
                }
                if (!listMuellesPuntos.isEmpty()) {
                    upsert listMuellesPuntos MuellesPuntosFacturacion__c.IdExterno__c;
                }
            }

        } catch(DmlException e) {
            System.debug('Error cause: ' + e.getCause() + '-Line number:' + e.getLineNumber() + ' - Message:' + e.getMessage());
        }
    }
    /******************************** FIN MUELLES********************************/

    /******************************** INICIA PUNTOS DE FACTURACION********************************/
    //Puntos de facturacion WS Call
    @future(callout = true)
    public static void ProcesarPtoFacturacion(String compania) {
        HttpResponse res = new HttpResponse();
        res = CallWSPtoFacturacion(compania);
        List<Punto> ptoFac;
        if (res != null && res.getBody() != null && res.getBody() != '') {
            ptoFac = ParserPtoFacturacion(res.getBody(),compania); //Obtenemos datos de WS encabezados.
            System.debug('ptoFac ProcesarPtoFacturacion CAP ' + ptoFac + ' cantidad ' + ptoFac.size());
            if (!ptoFac.isEmpty()) {
                insertaractualizarPtoFacturacion(ptoFac); //Insertamos o actualizamos encabezados segun sea el caso del resgistro enviado.
            }

        }
    }

    public static HttpResponse CallWSPtoFacturacion(String compania) {
        HttpResponse res = new HttpResponse();
        try {
            HttpRequest req = new HttpRequest();

            req.setEndpoint('http://bd2.capris.cr:64423/Salesforce_UsuPtoFact/webresources/app.entities.usuariosptofact/'+compania);
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
    public static List<Punto> ParserPtoFacturacion(String xmlfile,String compania) {
        System.Debug('****  xmlfile ParserMuelles CAP **** ' + xmlfile);

        DOM.Document xmlDOC = new DOM.Document();
        xmlDOC.load(xmlfile);

        //String compania = 'CAP';
        String codigoUsuario, puntoFacturacion;

        Set<String> setPuntos  = new Set<String>();
        Set<String> usuariosSet = new Set<String>();

        Map<String, list<string>> mapUsuariosPuntos = new Map<String, list<string>> ();

        List<Punto> listaPuntosFacturacion = new list<Punto> ();
        list<PuntoUsuario> listPuntosUsuarios = new List<PuntoUsuario>();
        List<Usuario> listUsuariosUnicos = new List<Usuario>();

        Punto punto;
        PuntoUsuario puntoUsuario;
        Usuario usuarioUnico;

        if (!xmlDOC.getRootElement().getChildElements().isEmpty()) {
            puntoFacturacion = '';
            codigoUsuario = '';
            for (DOM.XMLNode ObjChild : xmlDOC.getRootElement().getChildElements()) {
                for (DOM.XMLNode xmlNodeObjChild : ObjChild.getChildren()) {
                    if (xmlNodeObjChild.getText() != 'null') {
                        if (xmlNodeObjChild.getName() == 'ptoFact') {
                            puntoFacturacion = xmlNodeObjChild.getText();

                        }
						if (!mapUsuariosPuntos.containsKey(puntoFacturacion + compania)) {
							mapUsuariosPuntos.put(puntoFacturacion + compania, new list<String> ());
						}

                        if (xmlNodeObjChild.getName() == 'codUsu') {
                            codigoUsuario = xmlNodeObjChild.getText();
						}

                        if (mapUsuariosPuntos.containsKey(puntoFacturacion + compania)) {
                            mapUsuariosPuntos.get(puntoFacturacion + compania).add(codigoUsuario);
                        }

					}
                }
            }

            puntoFacturacion = '';
            codigoUsuario = '';
            String descripcion = '';
            String fecha = '';
            System.debug('USUARIOS RELACIONADOS: ' + mapUsuariosPuntos);

            for (DOM.XMLNode ObjChild : xmlDOC.getRootElement().getChildElements()) {
                for (DOM.XMLNode xmlNodeObjChild : ObjChild.getChildren()) {
                    if (xmlNodeObjChild.getText() != 'null') {

                        if (xmlNodeObjChild.getName() == 'descripcion') {
                            descripcion = xmlNodeObjChild.getText();
                        }

                        if (xmlNodeObjChild.getName() == 'fecFin') {
                            fecha = xmlNodeObjChild.getText();
                        }

                        if (xmlNodeObjChild.getName() == 'ptoFact') {
                            puntoFacturacion = xmlNodeObjChild.getText();
                        }

                        if (xmlNodeObjChild.getName() == 'codUsu') {
                            codigoUsuario = xmlNodeObjChild.getText();
                        }

                        System.debug('********* descripcion ' + descripcion + ' fecha ' + fecha + ' puntoFacturacion '  + puntoFacturacion + ' codigoUsuario ' + codigoUsuario + ' setPuntos ' + setPuntos);
                        if (descripcion != '' && fecha != '' && puntoFacturacion != '' && codigoUsuario != '' &&!setPuntos.contains(puntoFacturacion)) {
                            setPuntos.add(puntoFacturacion);
                            punto = new Punto();
                            punto.descripcion = descripcion;
                            punto.fechaFin = fecha;
                            punto.codPuntoFact = puntoFacturacion;
                            punto.compania = compania;
                            punto.idExternoPunto = compania+puntoFacturacion;

                            if (!mapUsuariosPuntos.values().isEmpty() && mapUsuariosPuntos.containsKey(puntoFacturacion + compania)) {
                                list<String> usuariosLista = mapUsuariosPuntos.get(puntoFacturacion + compania);
                                System.debug('usuariosLista ' + usuariosLista + ' ' + usuariosLista.size()+'puntoFacturacion + compania ' + puntoFacturacion + ' - ' + compania);
                                for(String u : usuariosLista){
                                    if (!usuariosSet.contains(u)) {
                                        usuariosSet.add(u);
                                    }
                                    puntoUsuario = new PuntoUsuario();
                                    puntoUsuario.codPuntoFact = puntoFacturacion;
                                    puntoUsuario.codUsuario = u;
                                    puntoUsuario.compania = compania;
                                    puntoUsuario.idExternoPuntoUsuario = compania + u +puntoFacturacion;
                                    listPuntosUsuarios.add(puntoUsuario);
                                }
                                if (!listPuntosUsuarios.isEmpty()) {
                                    punto.puntosUsuarios = listPuntosUsuarios;
                                }
                                if (!usuariosSet.isEmpty()) {
                                    for(String u:usuariosSet){
                                        usuarioUnico = new Usuario();
                                        usuarioUnico.codUsuario = u;
                                        usuarioUnico.compania = compania;
                                        usuarioUnico.idExternoUsuario = compania + u;
                                        listUsuariosUnicos.add(usuarioUnico);
                                    }
                                }
                                if (!listUsuariosUnicos.isEmpty()) {
                                    punto.usuarios = listUsuariosUnicos;
                                }
                            }
                            listaPuntosFacturacion.add(punto);

                        }
                    }
                }
            }
        }
        System.debug('lista puntos facturacion ' + listaPuntosFacturacion);
        return listaPuntosFacturacion;
    }

    //Realizacion de upsert de datos enviados 
    public static void insertaractualizarPtoFacturacion(List<Punto> listaptoFac) {
        try {
            if (!listaptoFac.isEmpty()) {
                Set<String> usuarios = new Set<String>();
                Set<String> puntosUsuarios = new Set<String>();
                List<GES_PTO_FAC__c> listPuntos = new List<GES_PTO_FAC__c>();
                List<Usuario_Facturaci_n__c> listUsuarios = new List<Usuario_Facturaci_n__c>();
                List<PuntoUsuarioFacturacion__c> listPuntosUsuarios = new List<PuntoUsuarioFacturacion__c>();

                GES_PTO_FAC__c puntoItem;
                Usuario_Facturaci_n__c usuarioFact;
                PuntoUsuarioFacturacion__c puntoUsuario;
                System.debug(' *************************** listaptoFac *************************** ' + listaptoFac);

                for(Punto p:listaptoFac){
                    puntoItem = new GES_PTO_FAC__c();
                    puntoItem.IDPtoFact__c = p.idExternoPunto;
                    puntoItem.PTO_DESCRIPCION__c = p.descripcion;
                    puntoItem.PTO_FEC_FIN__c = p.fechaFin;
                    puntoItem.PTO_COD_PTO__c = p.codPuntoFact;
                    puntoItem.PTO_COD_ORG__c = p.compania;
					puntoItem.Name = p.codPuntoFact;
                    if(!p.usuarios.isEmpty()){
                        for(Usuario uUni:p.usuarios){
                            if(!usuarios.contains(uUni.idExternoUsuario)){
                                usuarios.add(uUni.idExternoUsuario);
                                usuarioFact  = new Usuario_Facturaci_n__c();
								usuarioFact.Name = uUni.codUsuario;
                                usuarioFact.Codigo_de_Usuario__c = uUni.codUsuario;
                                usuarioFact.Cod_Compania__c = uUni.compania;
                                usuarioFact.Id_Usuario_Punto_Facturacion__c = uUni.compania + uUni.codUsuario;
                                listUsuarios.add(usuarioFact);
                            }
                        }
                    }

                    if(!p.puntosUsuarios.isEmpty()){
                        for(PuntoUsuario pUsu:p.puntosUsuarios){
                            if(!puntosUsuarios.contains(pUsu.idExternoPuntoUsuario)){
                                puntosUsuarios.add(pUsu.idExternoPuntoUsuario);
                                puntoUsuario = new PuntoUsuarioFacturacion__c();
                                puntoUsuario.IdPunto__c = pUsu.codPuntoFact;
                                puntoUsuario.IdUsuario__c = pUsu.codUsuario;
                                puntoUsuario.Compania__c = pUsu.compania;
                                puntoUsuario.IdExterno__c = pUsu.idExternoPuntoUsuario;
                                listPuntosUsuarios.add(puntoUsuario);
                            }
                        }
                    }
                    listPuntos.add(puntoItem);
                }
                if(!listPuntos.isEmpty()){
                    upsert listPuntos GES_PTO_FAC__c.IDPtoFact__c;
                }
                if(!listUsuarios.isEmpty()){
                    upsert listUsuarios Usuario_Facturaci_n__c.Id_Usuario_Punto_Facturacion__c; //trigger: ApxT_UsuarioFacturacionUsusariosSF
                }
                if(!listPuntosUsuarios.isEmpty()){
                    upsert listPuntosUsuarios PuntoUsuarioFacturacion__c.IdExterno__c; //HACER TRIGGER PARA LLENAR CAMPOS DE BÚSQUEDA PUNTO Y USUARIO
                }
            }
        } catch(DmlException e) {
            System.debug('Error cause: ' + e.getCause() + '-Line number:' + e.getLineNumber() + ' - Message:' + e.getMessage());
        }
    }

    /******************************** FIN PUNTOS DE FACTURACION********************************/

    /******************************** INICIA USUARIO PUNTOS DE FACTURACION********************************/
    //Puntos de facturacion WS Call
    @future(callout = true)
    public static void ProcesarUsuarioPtoFacturacion(String compania) {

        HttpResponse res = new HttpResponse();
        res = CallWSUsuarioPtoFacturacion(compania);
        List<Usuario> usrptoFac;
        if (res != null && res.getBody() != null && res.getBody() != '') {
            usrptoFac = ParserUsuariosPtoFacturacion(res.getBody(),compania); //Obtenemos datos de WS encabezados.
            System.debug('usrptoFac ProcesarUsuarioPtoFacturacion CAP ' + usrptoFac);

            if (!usrptoFac.isEmpty()) {
                insertaractualizarUsuariosPtoFacturacion(usrptoFac); //Insertamos o actualizamos encabezados segun sea el caso del resgistro enviado.
            }
        }
    }

    public static HttpResponse CallWSUsuarioPtoFacturacion(String compania) {
        HttpResponse res = new HttpResponse();
        try {
            HttpRequest req = new HttpRequest();

            req.setEndpoint('http://bd2.capris.cr:64423/Salesforce_UsuFact/webresources/app.entities.usuariosfact/'+compania);
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
    public static List<Usuario> ParserUsuariosPtoFacturacion(String xmlfile,String compania) {
        System.Debug('**** xmlfile ParserUsuariosPtoFacturacion CAP **** ' + xmlfile);

        DOM.Document xmlDOC = new DOM.Document();
        xmlDOC.load(xmlfile);

        Set<String> usuariosSet = new Set<String>();
        List<Usuario> listusrptos = new List<Usuario>();
        Usuario usuario;

        if (!xmlDOC.getRootElement().getChildElements().isEmpty()) {
            for (DOM.XMLNode ObjChild : xmlDOC.getRootElement().getChildElements()) {
                usuario = new Usuario();
                for (DOM.XMLNode xmlNodeObjChild : ObjChild.getChildren()) {
                    if (xmlNodeObjChild.getText() != 'null') {
                        
                        usuario.compania = compania;
	
						if(xmlNodeObjChild.getName() == 'codUsu'){
                            usuario.codUsuario = xmlNodeObjChild.getText();
							usuario.idExternoUsuario = compania+xmlNodeObjChild.getText();
                        }
                        if(xmlNodeObjChild.getName() == 'descripcion'){
                            usuario.descripcion = xmlNodeObjChild.getText();
                        }
                        if(xmlNodeObjChild.getName() == 'mayorista'){
                            usuario.mayorista = xmlNodeObjChild.getText();
                        }
                        if(xmlNodeObjChild.getName() == 'tipUsuario'){
                            usuario.tipoUser = xmlNodeObjChild.getText();
                        }
                        if(xmlNodeObjChild.getName() == 'usuarioBd'){
                            usuario.usuarioBD = xmlNodeObjChild.getText();
                        }
                        
						listusrptos.add(usuario);

                    }
                }
            }
        }
        
        System.Debug('$$$$$$$ listaaa ' + listusrptos);
        return listusrptos;
    }

    //Realizacion de upsert de datos enviados 
    public static void insertaractualizarUsuariosPtoFacturacion(List<Usuario> listausrptoFac) {
        
        Set<String> usuarios = new Set<String> ();
        System.debug('listausrptoFac ****** ' +listausrptoFac);
        List<Usuario_Facturaci_n__c> listausrptoFacFinal = new List<Usuario_Facturaci_n__c> ();
        Usuario_Facturaci_n__c usuario;
        try {
            if(!listausrptoFac.isEmpty()){
                for(Usuario u:listausrptoFac){
                    if(!usuarios.contains(u.idExternoUsuario)){
                        usuarios.add(u.idExternoUsuario);
                        usuario = new Usuario_Facturaci_n__c();
						usuario.Name = u.codUsuario;
                        usuario.Codigo_de_Usuario__c = u.codUsuario;
                        usuario.Cod_Compania__c = u.compania;
                        usuario.Descripcion__c = u.descripcion;
                        usuario.mayorista__c = u.mayorista;
                        usuario.Tipo_de_Usuario__c = u.tipoUser;
                        usuario.Usuario_Base_de_Datos__c  = u.usuarioBD;
                        usuario.Id_Usuario_Punto_Facturacion__c = u.idExternoUsuario;
                        listausrptoFacFinal.add(usuario);
                    }
                }
                System.debug(' ***listausrptoFacFinal*** ' + listausrptoFacFinal);
				if(!listausrptoFacFinal.isEmpty()){
                    upsert listausrptoFacFinal Usuario_Facturaci_n__c.Id_Usuario_Punto_Facturacion__c; 
                }
            }
        } catch(DmlException e) {
            System.debug('Error cause: ' + e.getCause() + '-Line number:' + e.getLineNumber() + ' - Message:' + e.getMessage());
        }
    }
    /******************************** FIN USUARIO PUNTOS DE FACTURACION********************************/

    /******************************** INICIA ENCABEZADO COMBOS********************************/
	//Combos WS Call
	@future(callout=true)
	public static void ProcesarCombosEncabezados(String compania) {
		HttpResponse res = new HttpResponse();
		res = CallWSCombosEncabezados(compania);
		List<GES_COMBOS__c> ptoCombos;
		if (res != null && res.getBody() != null && res.getBody() != '') {
			ptoCombos = ParserCombosEnc(res.getBody(),compania); //Obtenemos datos de WS encabezados.
			System.debug('ptoCombos ProcesarCombosEncabezados CAP ' + ptoCombos);
			if (!ptoCombos.isEmpty()) {
				insertaractualizarEnc(ptoCombos); //Insertamos o actualizamos encabezados segun sea el caso del resgistro enviado.
			}
		}
	}

	public static HttpResponse CallWSCombosEncabezados(String compania) {
		HttpResponse res = new HttpResponse();

		try {
			HttpRequest req = new HttpRequest();

			req.setEndpoint('http://bd2.capris.cr:64423/Salesforce_EncCombos/webresources/app.entities.enccombos/'+compania);
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
	public static List<GES_COMBOS__c> ParserCombosEnc(String xmlfile,String compania) {

		List<GES_COMBOS__c> listCombosEnc = new List<GES_COMBOS__c> ();
		GES_COMBOS__c comboencItem;
		System.Debug('**** xmlfile ParserCombosEnc CAP **** ' + xmlfile);
		DOM.Document xmlDOC = new DOM.Document();
		xmlDOC.load(xmlfile);
		set<string> combosEncUnicos = new set<string>();
		
		if (!xmlDOC.getRootElement().getChildElements().isEmpty()) {
			for (DOM.XMLNode ObjChild : xmlDOC.getRootElement().getChildElements()) {
				comboencItem = new GES_COMBOS__c();
				Boolean bandera = false;
				for (DOM.XMLNode xmlNodeObjChild : ObjChild.getChildren())
				{
					if (xmlNodeObjChild.getName() == 'codOferta' && xmlNodeObjChild.getText() != 'null')
					comboencItem.COM_COD_OFERTA__c = xmlNodeObjChild.getText();
					if (xmlNodeObjChild.getName() == 'codart' && xmlNodeObjChild.getText() != 'null')
					comboencItem.COM_COD_PROD__c = xmlNodeObjChild.getText();
					if (xmlNodeObjChild.getName() == 'descripcion' && xmlNodeObjChild.getText() != 'null')
					comboencItem.COM_DESCRIPCION__c = xmlNodeObjChild.getText();
					if (xmlNodeObjChild.getName() == 'facComp' && xmlNodeObjChild.getText() != 'null')
					comboencItem.COM_FAC_COM__c = xmlNodeObjChild.getText();
					
					if(compania!=null&&comboencItem.COM_COD_OFERTA__c!=null&&!combosEncUnicos.contains(compania+comboencItem.COM_COD_OFERTA__c)){
						comboencItem.COM_COD_ORG__c = compania;
						comboencItem.IDCombo__c = compania+comboencItem.COM_COD_OFERTA__c;
						comboencItem.Name=comboencItem.COM_COD_OFERTA__c;	
						bandera = true;	
						combosEncUnicos.add(compania+comboencItem.COM_COD_OFERTA__c);			
					}

				}
				if(bandera){
					listCombosEnc.add(comboencItem); //lista de encabezado
				}  
			}
		}

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

	/******************************** INICIA DETALLE COMBOS********************************/


	//Combos WS Call
	@future(callout = true)
	public static void ProcesarCombosDetalles(String compania) {

		HttpResponse res = new HttpResponse();
		res = CallWSCombosDetalles(compania);
		List<GES_DET_COMBOS__c> ptoCombosDet;
		if (res != null && res.getBody() != null && res.getBody() != '') {
			ptoCombosDet = ParserCombosDet(res.getBody(),compania); //Obtenemos datos de WS encabezados.
			System.debug('ptoCombosDet ProcesarCombosDetalles CAP ' + ptoCombosDet);
			if (!ptoCombosDet.isEmpty()) {
				insertaractualizarDet(ptoCombosDet); //Insertamos o actualizamos encabezados segun sea el caso del resgistro enviado.
			}

		}

	}
	//@future(callout=true)
	public static HttpResponse CallWSCombosDetalles(String compania) {
		HttpResponse res = new HttpResponse();
		try {
			HttpRequest req = new HttpRequest();

			req.setEndpoint('http://bd2.capris.cr:64423/Salesforce_DetCombos/webresources/app.entities.detcombos/'+compania);
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
	public static List<GES_DET_COMBOS__c> ParserCombosDet(String xmlfile,String compania) {

		List<GES_DET_COMBOS__c> listCombosDet = new List<GES_DET_COMBOS__c> ();
		GES_DET_COMBOS__c combodetItem;
		System.Debug('**** xmlfile ParserCombosDet CAP **** ' + xmlfile);
		DOM.Document xmlDOC = new DOM.Document();
		xmlDOC.load(xmlfile);
		Set<string> detalleCombosUnicos = new Set<string>();
		
		if (!xmlDOC.getRootElement().getChildElements().isEmpty()) {
			for (DOM.XMLNode ObjChild : xmlDOC.getRootElement().getChildElements()) {
				combodetItem = new GES_DET_COMBOS__c();
				Boolean bandera = false;
				for (DOM.XMLNode xmlNodeObjChild : ObjChild.getChildren())
				{
					if (xmlNodeObjChild.getName() == 'cantidad' && xmlNodeObjChild.getText() != 'null')
					combodetItem.GDC_CANTIDAD__c = Decimal.valueOf(xmlNodeObjChild.getText());
					if (xmlNodeObjChild.getName() == 'codOferta' && xmlNodeObjChild.getText() != 'null')
					combodetItem.GDC_COD_OFERTA__c = xmlNodeObjChild.getText();
					if (xmlNodeObjChild.getName() == 'codigo' && xmlNodeObjChild.getText() != 'null')
					combodetItem.GDC_COD_PROD__c = xmlNodeObjChild.getText();
					if (xmlNodeObjChild.getName() == 'precio' && xmlNodeObjChild.getText() != 'null')
					combodetItem.GDC_PRECIO__c = Decimal.valueOf(xmlNodeObjChild.getText());

					if(compania!=null&&combodetItem.GDC_COD_OFERTA__c!=null&&combodetItem.GDC_COD_PROD__c!=null&&!detalleCombosUnicos.contains(compania + combodetItem.GDC_COD_OFERTA__c + combodetItem.GDC_COD_PROD__c)){
						combodetItem.Name=combodetItem.GDC_COD_OFERTA__c;  
						combodetItem.GDC_COD_ORG__c = compania;
						combodetItem.IDDetComb__c = compania + combodetItem.GDC_COD_OFERTA__c + combodetItem.GDC_COD_PROD__c;
						bandera= true;
						detalleCombosUnicos.add(compania + combodetItem.GDC_COD_OFERTA__c + combodetItem.GDC_COD_PROD__c);					
					}
					
				}
				if(bandera){
					listCombosDet.add(combodetItem); //lista de encabezado
				}  
			}

		} //if (!xmlDOC.getRootElement().getChildElements().isEmpty()) 

		return listCombosDet;
	}

	//Realizacion de upsert de datos enviados 
	public static void insertaractualizarDet(List<GES_DET_COMBOS__c> listacombosdet) {

		try {
			Set<String>CombosSet=new Set<String>();
			Set<String>ProductosSet=new Set<String>();
			map<String,String>mapCombos= new map<String,String>();
			map<String,String>mapProductos= new map<String,String>();
			List<GES_DET_COMBOS__c> listacombosdetFinal = new List<GES_DET_COMBOS__c>();
			for(GES_DET_COMBOS__c detCo:listacombosdet){
				CombosSet.add(detCo.GDC_COD_ORG__c+detCo.GDC_COD_OFERTA__c);
				ProductosSet.add(detCo.GDC_COD_ORG__c+detCo.GDC_COD_PROD__c);
			}
			for(GES_COMBOS__c com:[select id,IDCombo__c from GES_COMBOS__c where IDCombo__c in:CombosSet]){
				mapCombos.put(com.IDCombo__c,com.Id);
			}
			for(Product2 pro:[select id,idExternoArticulo__c from Product2 where idExternoArticulo__c in: ProductosSet]){
				mapProductos.put(pro.idExternoArticulo__c,pro.Id);
			}
			System.debug('mapCombos *** ' + mapCombos.values());
			System.debug('mapProductos *** ' + mapProductos.values());

			for(GES_DET_COMBOS__c detCo:listacombosdet){
				if(!mapCombos.values().isEmpty()&&!mapProductos.values().isEmpty()&&mapCombos.containsKey(detCo.GDC_COD_ORG__c+detCo.GDC_COD_OFERTA__c)&&mapProductos.containsKey(detCo.GDC_COD_ORG__c+detCo.GDC_COD_PROD__c)){
					detCo.Combo__c = mapCombos.get(detCo.GDC_COD_ORG__c+detCo.GDC_COD_OFERTA__c);
					detCo.ProductoRelacionado__c = mapProductos.get(detCo.GDC_COD_ORG__c+detCo.GDC_COD_PROD__c);
					listacombosdetFinal.add(detCo);
				}
			}
			System.debug('listacombosdetFinal **** ' + listacombosdetFinal);
			if(!listacombosdetFinal.isEmpty()){
				upsert listacombosdetFinal GES_DET_COMBOS__c.IDDetComb__c;
			}
		} catch(DmlException e) {
			System.debug('Error cause: ' + e.getCause() + '-Line number:' + e.getLineNumber() + ' - Message:' + e.getMessage());
		}
	}
	
	
	
	
	/*********************************** COMBOS PUNTOS FACTURACIÓN *********************************************/
	//Combos WS Call
	@future(callout = true)
	public static void ProcesarCombosPtos(String compania) {

		HttpResponse res = new HttpResponse();
		res = CallWSCombosPtos(compania);
		List<Combo_Punto_Facturacion__c> ptoCombos;
		if (res != null && res.getBody() != null && res.getBody() != '') {
			ptoCombos = ParserCombos(res.getBody(),compania); //Obtenemos datos de WS encabezados.
			System.debug('ptoCombos ProcesarCombosPtos CAP ' + ptoCombos);
			if (!ptoCombos.isEmpty()) {
				insertaractualizarCombos(ptoCombos); //Insertamos o actualizamos encabezados segun sea el caso del resgistro enviado.
			}

		}


	}
	// @future(callout=true)
	public static HttpResponse CallWSCombosPtos(String compania) {
		HttpResponse res = new HttpResponse();
		try {
			HttpRequest req = new HttpRequest();
			req.setEndpoint('http://bd2.capris.cr:64423/Salesforce_CombosPtoFact/webresources/app.entities.combosptofact/'+compania);
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
	public static List<Combo_Punto_Facturacion__c> ParserCombos(String xmlfile,String compania) {

		List<Combo_Punto_Facturacion__c> listCombos = new List<Combo_Punto_Facturacion__c> ();
		Combo_Punto_Facturacion__c comboItem;
		System.Debug('**** xmlfile ParserCombos CAP **** '+ xmlfile);
		DOM.Document xmlDOC = new DOM.Document();
		xmlDOC.load(xmlfile);
		set<string> comboFactUnicos = new set<string>();
		
		if (!xmlDOC.getRootElement().getChildElements().isEmpty()) {
			for (DOM.XMLNode ObjChild : xmlDOC.getRootElement().getChildElements()) {
				comboItem = new Combo_Punto_Facturacion__c();
				Boolean bandera = false;
				for (DOM.XMLNode xmlNodeObjChild : ObjChild.getChildren()){

					if (xmlNodeObjChild.getName() == 'codOferta' && xmlNodeObjChild.getText() != 'null')
					comboItem.Codigo_Oferta__c = xmlNodeObjChild.getText();
					if (xmlNodeObjChild.getName() == 'ptoFact' && xmlNodeObjChild.getText() != 'null')
					comboItem.Punto_Fact__c = xmlNodeObjChild.getText();
					
					if(compania!=null&&comboItem.Codigo_Oferta__c!=null&&comboItem.Punto_Fact__c!=null&&!comboFactUnicos.contains(compania+comboItem.Codigo_Oferta__c+comboItem.Punto_Fact__c)){
						comboItem.Id_Externo__c = compania+comboItem.Codigo_Oferta__c+comboItem.Punto_Fact__c;
						comboItem.Codigo_Compania__c = compania;
						comboItem.Name = comboItem.Codigo_Oferta__c;
						bandera = true;
						comboFactUnicos.add(compania+comboItem.Codigo_Oferta__c+comboItem.Punto_Fact__c);						
					}	
				}
				if(bandera){
					listCombos.add(comboItem); //lista de encabezado
				}  
			}
		}

		return listCombos;
	}

	//Realizacion de upsert de datos enviados 
	public static void insertaractualizarcombos(List<Combo_Punto_Facturacion__c> listacombos) {

		try {
			Set<String>combosSet=new Set<String>();
			Set<String>puntosSet=new Set<String>();
			Map<String,String>mapCombos = new Map<String,String>();
			Map<String,String>mapPuntos = new Map<String,String>();
			List<Combo_Punto_Facturacion__c> listacombosFinal = new List<Combo_Punto_Facturacion__c>();
			for(Combo_Punto_Facturacion__c comPFact:listacombos){
				combosSet.add(comPFact.Codigo_Compania__c+comPFact.Codigo_Oferta__c);
				puntosSet.add(comPFact.Codigo_Compania__c+comPFact.Punto_Fact__c);
			}
			for(GES_COMBOS__c com:[select id,IDCombo__c from GES_COMBOS__c where IDCombo__c in:CombosSet]){
				mapCombos.put(com.IDCombo__c,com.Id);
			}
			for(GES_PTO_FAC__c pun:[select id,IDPtoFact__c from GES_PTO_FAC__c where IDPtoFact__c in:puntosSet]){
				mapPuntos.put(pun.IDPtoFact__c,pun.Id);
			}
			for(Combo_Punto_Facturacion__c comPFact:listacombos){
				if(!mapCombos.values().isEmpty()&&!mapPuntos.isEmpty()&&mapCombos.containsKey(comPFact.Codigo_Compania__c+comPFact.Codigo_Oferta__c)&&mapPuntos.containsKey(comPFact.Codigo_Compania__c+comPFact.Punto_Fact__c)){
					comPFact.Combo__c = mapCombos.get(comPFact.Codigo_Compania__c+comPFact.Codigo_Oferta__c);
					comPFact.FacturacionPto__c = mapPuntos.get(comPFact.Codigo_Compania__c+comPFact.Punto_Fact__c);
					listacombosFinal.add(comPFact);
				}
			}
			
			if(!listacombosFinal.isEmpty()){
				upsert listacombosFinal Combo_Punto_Facturacion__c.Id_Externo__c;
			}
		} catch(DmlException e) {
			System.debug('Error cause: ' + e.getCause() + '-Line number:' + e.getLineNumber() + ' - Message:' + e.getMessage());
		}
	}

    public class Muelle {
        public String compania { get; set; }
        public String codMuelle { get; set; }
        public String descripcion { get; set; }
        public String idExternoMuelle { get; set; }
        public List<Punto> puntos { get; set; } //para insertar en objeto Puntos de facturación
        public List<MuellePunto> muellesPuntos { get; set; } //para insertar en objeto Muelle x Punto de Facturación
    }

    public class Punto {
        public String codPuntoFact { get; set; }
        public String descripcion { get; set; }
        public String compania { get; set; }
        public string fechaFin { get; set; }
        public String idExternoPunto { get; set; }
        public List<Usuario> usuarios { get; set; } //para insertar en objeto Usuario Facturación
        public List<PuntoUsuario> puntosUsuarios { get; set; } // para insertar en objeto Puntos x Usuarios de Facturación (FALTA CREARLO)
    }

    public class Usuario {
        public string codUsuario { get; set; }
        public String compania {get;set;}
        public string descripcion { get; set; }
        public string mayorista { get; set; }
        public string tipoUser { get; set; }
        public string usuarioBD { get; set; }
        public string idExternoUsuario { get; set; }
    }

    public class MuellePunto {
        public String codMuelle { get; set; }
        public String codPuntoFact { get; set; }
        /*public String idMuelle { get; set; }
        public String idPuntoFact { get; set; }*/
        public String compania { get; set; }
        public string idExternoMuellePunto { get; set; }
    }

    public class PuntoUsuario {
        public String codPuntoFact { get; set; }
        public String codUsuario { get; set; }
        /*public String idPuntoFact { get; set; }
        public String idUsuario { get; set; }*/
        public String compania { get; set; }
        public string idExternoPuntoUsuario { get; set; }
    }

}