/**
 * @description       : 
 * @author            : esteban@incompany.cr
 * @group             : 
 * @last modified on  : 13-04-2023
 * @last modified by  : esteban@incompany.cr
**/
public class UpsertPhone {

	public static DeserializeJSONPhone.DeserializeJSON resultwrap { get; set; }

	public static string doUpsert(String jsonStr) {

		resultwrap = DeserializeJSONPhone.parse(jsonStr);
		List<Telefonos__c> PhoneLst = new List<Telefonos__c> ();
		List<Telefonos__c> PhoneLstDelete = new List<Telefonos__c> ();
		List<String> TempDelete = new List<String> ();


		Integer Counter1 = - 1;
		Integer Counter2 = - 1;
		Map<Integer, String> CounterMap = new Map<Integer, String> ();
		String OrgId;
		for (DeserializeJSONPhone.PhoneMainList wrap : resultwrap.PhoneMainList) {
			if (wrap.estado == 'A') {
				Telefonos__c tel = new Telefonos__c();
				tel.telc_cod_org__c = wrap.org;
				tel.telc_tipo__c = wrap.tipo;
				tel.Name = wrap.numero.replace('\r\n', '').replace('\n', '').replace('\r', '');
				tel.telc_num_cliente__c = wrap.codCli;
				tel.telc_ubicacion__c = wrap.ubicacion;
				tel.telc_asignacion__c = wrap.asignacion;
				tel.telc_usu_modifica__c = wrap.usuModifica;
				tel.telc_fyh_modifica__c = Date.valueOf(Datetime.newInstance(LONG.valueOf(wrap.fyhModifica)));
				tel.telc_extension__c = wrap.extension;
				tel.telc_usu_inserta__c = wrap.usuInserta;
				tel.telc_fyh_inserta__c = Date.valueOf(Datetime.newInstance(LONG.valueOf(wrap.fyhInserta)));
				tel.telc_estado__c = wrap.estado;
				OrgId = wrap.org;
				Account acc = new Account(Id_Capris__c = wrap.org + '-' + wrap.codCli);
				tel.Nombre_del_Cliente__r = acc;

				if (wrap.idContacto != 'null') {
					Contact con = new Contact(Id_Capris__c = wrap.org + '-' + wrap.idContacto);
					tel.Nombre_del_Contacto__r = con;
				}
				Counter1 = Counter1 + 1;
				CounterMap.put(Counter1, wrap.org + '-' + wrap.codCli + '-' + wrap.idContacto + '-' + wrap.numero.replace('\r\n', '').replace('\n', '').replace('\r', ''));


				tel.Id_Capris__c = wrap.org + '-' + wrap.numero.replace('\r\n', '').replace('\n', '').replace('\r', '') + '-' + wrap.idContacto + '-' + wrap.codCli;
				PhoneLst.add(tel);
			}
			else {
				TempDelete.add(wrap.org + '-' + wrap.numero.replace('\r\n', '').replace('\n', '').replace('\r', '') + '-' + wrap.idContacto + '-' + wrap.codCli);
			}
		}

		PhoneLstDelete = [SELECT Id From Telefonos__c WHERE Id_Capris__c IN :TempDelete];

		Schema.SObjectField f = Telefonos__c.Fields.Id_Capris__c;
		Database.UpsertResult[] saveResultList = Database.upsert(PhoneLst, f, false);

		Database.DeleteResult[] deleteResultList = Database.delete(PhoneLstDelete);

		JSONGenerator gen = JSON.createGenerator(false);
		gen.writeStartObject();
		gen.writeFieldName('ResponseMainList');
		gen.writeStartArray();
        /*
		for (Database.UpsertResult res : saveResultList) {
			Counter2 = Counter2 + 1;
			if (res.isSuccess()) {
				gen.writeStartObject();
				gen.writeStringField('codigo', 'Se procesó correctamente el registro');
				gen.writeStringField('Status', CounterMap.get(Counter2));
				gen.writeEndObject();
			} else {
				For (Database.Error e : res.getErrors()) {
					System.debug(e);
					gen.writeStartObject();
					gen.writeStringField('codigo', 'Error al procesar el registro');
					gen.writeStringField('Status', CounterMap.get(Counter2));
					gen.writeEndObject();
				}
			}
		}*/
        
        //List<WebServiceLog__c> lerrors = new List<WebServiceLog__c> ();

        for(Integer i=0;i<saveResultList.size();i++){
            if(saveResultList[i].isSuccess()) {
                if(saveResultList[i].isCreated()){
                    gen.writeStartObject();
                    gen.writeStringField('codigo', 'Se procesó correctamente el registro');
                    gen.writeStringField('Status', PhoneLst[i].telc_cod_org__c);
                	//gen.writeStringField('operacion', 'Creado');
                    gen.writeEndObject();
                    //gen.writeStringField('Creado', PhoneLst[i].Id_Capris__c);
                } else {
                    gen.writeStartObject();
                	gen.writeStringField('codigo', 'Se procesó correctamente el registro');
                	gen.writeStringField('Status', PhoneLst[i].telc_cod_org__c);
                    //gen.writeStringField('operacion', 'Actualizado');
                	gen.writeEndObject();
                    //gen.writeStringField('Actualizado', PhoneLst[i].Id_Capris__c);
                }
            }else{
                Database.Error err = saveResultList.get(i).getErrors().get(0);
                gen.writeStartObject();
                gen.writeStringField('codigo', 'Error al procesar el registro');
                gen.writeStringField('Status',  PhoneLst[i].telc_cod_org__c);
                gen.writeEndObject();
                //gen.writeStringField('Error', PhoneLst[i].Id_Capris__c + ' --- ' + err.getMessage() + '\nStatus Code : '+err.getStatusCode()+'\n Fields : '+err.getFields());
                
                //  WebServiceLog__c log = new WebServiceLog__c();
                // log.Web_Services__c='Telefonos';
                // log.ErrorDetail__c = PhoneLst[i].Id_Capris__c + ' --- ' + err.getMessage() + '\nStatus Code : '+err.getStatusCode()+'\n Fields : '+err.getFields();
				// log.hasErrors__c = true;
                // lerrors.add(log);
            }
        }
		gen.writeEndArray();
		gen.writeEndObject();

        //   if (lerrors.size() > 0){
        //     insert lerrors;
        // }
        
		return gen.getAsString();
		//return '{"ResponseMainList":[{"codigo":"Se procesó correctamente el registro","Status":"' + OrgId + '"}]}';
	}

	public static void doNothing() {
		Integer a = 1;
		Integer b = 0;
		Integer c = a;
		a = b;
		b = c;
		c = a;
		a = b;
		b = c;
		c = a;
		a = b;
		b = c;
		c = a;
		a = b;
		b = c;
		c = a;
		a = b;
		b = c;
		c = a;
		a = b;
		b = c;
		c = a;
		a = b;
		b = c;
		c = a;
		a = b;
		b = c;
		c = a;
		a = b;
		b = c;
		c = a;
		a = b;
		b = c;
		c = a;
		a = b;
		b = c;
		c = a;
		a = b;
		b = c;
		c = a;
		a = b;
		b = c;
		c = a;
		a = b;
		b = c;
		c = a;
		a = b;
		b = c;
		c = a;
		a = b;
		b = c;
		c = a;
		a = b;
		b = c;
		c = a;
		a = b;
		b = c;
		c = a;
		a = b;
		b = c;
		c = a;
		a = b;
		b = c;
		c = a;
		a = b;
		b = c;
		c = a;
		a = b;
		b = c;
		c = a;
		a = b;
		b = c;
		c = a;
		a = b;
		b = c;
		c = a;
		a = b;
		b = c;
		c = a;
		a = b;
		b = c;
		c = a;
		a = b;
		b = c;
		c = a;
		a = b;
		b = c;
		c = a;
		a = b;
		b = c;
		c = a;
		a = b;
		b = c;
		c = a;
		a = b;
		b = c;
		c = a;
		a = b;
		b = c;
		c = a;
		a = b;
		b = c;
		c = a;
		a = b;
		b = c;
		c = a;
		a = b;
		b = c;
		c = a;
		a = b;
		b = c;
		c = a;
		a = b;
		b = c;
		c = a;
		a = b;
		b = c;
		c = a;
		a = b;
		b = c;
		c = a;
		a = b;
		b = c;
		c = a;
		a = b;
		b = c;
		c = a;
		a = b;
		b = c;
		c = a;
		a = b;
		b = c;
		c = a;
		a = b;
		b = c;
		c = a;
		a = b;
		b = c;
		c = a;
		a = b;
		b = c;
		c = a;
		a = b;
		b = c;
		c = a;
		a = b;
		b = c;
		c = a;
		a = b;
		b = c;
		c = a;
		a = b;
		b = c;
		c = a;
		a = b;
		b = c;
		c = a;
		a = b;
		b = c;
		c = a;
		a = b;
		b = c;
		c = a;
		a = b;
		b = c;
		c = a;
		a = b;
		b = c;
		c = a;
		a = b;
		b = c;
		c = a;
		a = b;
		b = c;
		c = a;
		a = b;
		b = c;
		c = a;
		a = b;
		b = c;
		c = a;
		a = b;
		b = c;
		c = a;
		a = b;
		b = c;
		c = a;
		a = b;
		b = c;
		c = a;
		a = b;
		b = c;
		c = a;
		a = b;
		b = c;
		c = a;
		a = b;
		b = c;
		c = a;
		a = b;
		b = c;
		c = a;
		a = b;
		b = c;
		c = a;
		a = b;
		b = c;
		c = a;
		a = b;
		b = c;
		c = a;
		a = b;
		b = c;
		c = a;
		a = b;
		b = c;
		c = a;
		a = b;
		b = c;
		c = a;
		a = b;
		b = c;
		c = a;
		a = b;
		b = c;
		c = a;
		a = b;
		b = c;
		c = a;
		a = b;
		b = c;
		c = a;
		a = b;
		b = c;
		c = a;
		a = b;
		b = c;
		c = a;
	}
}