Public class CreateJSON {

    public static JSONGenerator writeCredentials(JSONGenerator gen){
        Credenciales_Endpoint__mdt mdt_credenciales = Credenciales_Endpoint__mdt.getInstance('credenciales');
        gen.writeStringField('pkey',mdt_credenciales.Llave__c);
        gen.writeStringField('porg',mdt_credenciales.Organization__c);
        return gen;
    }

    public static string GenerateJSONAccount(String AccId) {
        
        List<Account> accLst = [Select Id,
                                org_id__c, num_cliente__c, razon_social__c, zonaCanton__c, cedula__c, tipo_cliente__c,
                                observaciones__c, Website, provincia__c, forma_pago__c, LastModifiedBy.Usuario_Base_de_Datos__c, LastModifiedDate,
                                mcl_hor_entr__c, mcl_obs_entr__c, mcl_roc_entr__c, ruta__c, limit_credit__c, dias_tramit_cob__c,
                                cod_cobrador__c, CreatedDate, plazo_credito__c, mcl_nombre1__c, mcl_nombre2__c, mcl_apellido1__c,
                                mcl_apellido2__c, CreatedBy.Usuario_Base_de_Datos__c, mcl_env_email__c, mcl_env_sms__c, mcl_fec_nac__c, mcl_id_puesto__c,
                                mcl_plazo_tec__c, mcl_cob_tec__c, zona_cliente__c, Direccion_Comercial__c, mcl_origen__c, mcl_excep_trans__c,
                                mcl_ind_mixto__c, abcDelCliente__c, baja__c From Account Where Id = :AccId Limit 1];
        System.Debug(accLst);

        JSONGenerator gen = JSON.createGenerator(false);
        
        Try {
            For (Account acc : accLst) {

                DateTime fyhNacimiento = acc.mcl_fec_nac__c;
                Long fyhNacimientoLong = acc.mcl_fec_nac__c != null ? fyhNacimiento.getTime() : 0;

                gen.writeStartObject();
                writeCredentials(gen);
                gen.writeFieldName('ClienteMainList');
                gen.writeStartArray();
                gen.writeStartObject();
                gen.writeStringField('org', 'CAP'); //ValidateNull.doValidation(acc.org_id__c));
                gen.writeStringField('codCliente', acc.num_cliente__c != null ? acc.num_cliente__c : '0');
                gen.writeStringField('nombreFantasia', acc.razon_social__c != null ? acc.razon_social__c : ValidateNull.doValidation(acc.mcl_nombre1__c) + ' ' + ValidateNull.doValidation(acc.mcl_nombre2__c) + ' ' + ValidateNull.doValidation(acc.mcl_apellido1__c) + ' ' + ValidateNull.doValidation(acc.mcl_apellido2__c));
                gen.writeNullField('direccion');
                gen.writeStringField('estado', ValidateNull.doValidation(acc.baja__c));
                gen.writeStringField('razonSocial', acc.razon_social__c != null ? acc.razon_social__c : ValidateNull.doValidation(acc.mcl_nombre1__c) + ' ' + ValidateNull.doValidation(acc.mcl_nombre2__c) + ' ' + ValidateNull.doValidation(acc.mcl_apellido1__c) + ' ' + ValidateNull.doValidation(acc.mcl_apellido2__c));
                if (acc.zonaCanton__c != null)
                gen.writeStringField('canton', ValidateNull.doValidation(acc.zonaCanton__c.left(3)));
                gen.writeStringField('cedula', ValidateNull.doValidation(acc.cedula__c));
                //gen.writeStringField('tipocli', ValidateNull.doValidation(acc.tipo_cliente__c));
                gen.writeStringField('reqOc', 'N');
                gen.writeStringField('observaciones', ValidateNull.doValidation(acc.observaciones__c));
                gen.writeStringField('sitioWeb', ValidateNull.doValidation(acc.Website));
                gen.writeStringField('provincia', ValidateNull.doValidation(acc.provincia__c));
                gen.writeStringField('usuModifica', ValidateNull.doValidation(acc.LastModifiedBy.Usuario_Base_de_Datos__c));
                gen.writeStringField('fyhModifica', FormatDate.getFromDateTime(acc.LastModifiedDate));
                gen.writeStringField('horaEntrega', ValidateNull.doValidation(acc.mcl_hor_entr__c));
                gen.writeStringField('obsEntrega', ValidateNull.doValidation(acc.mcl_obs_entr__c));
                gen.writeStringField('reqOcEntrega', ValidateNull.doValidation(acc.mcl_roc_entr__c));
                gen.writeNullField('reqFacEntrega');
                gen.writeStringField('rutaCobro', ValidateNull.doValidation(acc.ruta__c));
                gen.writeNumberField('limiteCredito', ValidateNull.doValidationNumber(Double.valueOf(acc.limit_credit__c)));
                gen.writeStringField('diaTramite', ValidateNull.doValidation(acc.dias_tramit_cob__c));
                gen.writeStringField('cobradorCxc', ValidateNull.doValidation(acc.cod_cobrador__c));
                gen.writeStringField('fyhIngreso', FormatDate.getFromDateTime(acc.CreatedDate));
                gen.writeStringField('plazoCxc', ValidateNull.doValidation(acc.plazo_credito__c));
                gen.writeStringField('nombre1', ValidateNull.doValidation(acc.mcl_nombre1__c));
                gen.writeStringField('nombre2', ValidateNull.doValidation(acc.mcl_nombre2__c));
                gen.writeStringField('apellido1', ValidateNull.doValidation(acc.mcl_apellido1__c));
                gen.writeStringField('apellido2', ValidateNull.doValidation(acc.mcl_apellido2__c));
                gen.writeStringField('usuIngreso',ValidateNull.doValidation(acc.CreatedBy.Usuario_Base_de_Datos__c));
                gen.writeStringField('envEmail', ValidateNull.doValidationBoolean(acc.mcl_env_email__c));
                gen.writeStringField('envSms', ValidateNull.doValidationBoolean(acc.mcl_env_sms__c));
                gen.writeStringField('fyhNacimiento', acc.mcl_fec_nac__c != null ? FormatDate.getFromDateTime(acc.mcl_fec_nac__c) : '');
                gen.writeStringField('idPuesto', ValidateNull.doValidation(acc.mcl_id_puesto__c));
                gen.writeStringField('plazoTec', ValidateNull.doValidation(acc.mcl_plazo_tec__c));
                gen.writeStringField('cobradorTec', ValidateNull.doValidation(acc.mcl_cob_tec__c));
                gen.writeNullField('region');
                gen.writeStringField('zona', ValidateNull.doValidation(acc.zonaCanton__c.left(3)));
                gen.writeStringField('dirComercial', acc.Direccion_Comercial__c != null ? acc.Direccion_Comercial__c :'');
                gen.writeStringField('origen', ValidateNull.doValidation(acc.mcl_origen__c));
                gen.writeStringField('excepTrans', ValidateNull.doValidationBoolean(acc.mcl_excep_trans__c));
                gen.writeStringField('indMixto', ValidateNull.doValidationBoolean(acc.mcl_ind_mixto__c));
                gen.writeNullField('fyhVenLetc');
                gen.writeStringField('claCli', ValidateNull.doValidation(acc.abcDelCliente__c));
                gen.writeStringField('idSaleforce', acc.Id);



                gen.writeEndObject();
                gen.writeEndArray();
                gen.writeEndObject();
            }

        }
        Catch(Exception e) {
            System.Debug('Error on GenerateJSONAccount ' + e.getMessage() + ' on ' + e.getStackTraceString());

        }
        String Body = gen.getAsString();
        String Result = JSON.serializePretty(Body);
        System.Debug('JSON Enviado ' + Body);
        System.Debug('Result Enviado ' + Result);
        Return Body;
    }

    public static String GenerateJSONContact(String ContId) {

        List<Contact> contLst = [SELECT Id, IsDeleted, MasterRecordId, AccountId, LastName,
                                 FirstName, Salutation, Name, RecordTypeId, MailingStreet, MailingCity,
                                 MailingState, MailingPostalCode, MailingCountry,
                                 //MailingStateCode, MailingCountryCode,
                                 MailingLatitude, MailingLongitude, MailingGeocodeAccuracy, MailingAddress, Phone,
                                 Fax, MobilePhone, ReportsToId, Email, Title, Department, CurrencyIsoCode, OwnerId,
                                 CreatedDate, CreatedById, LastModifiedDate, LastModifiedById,
                                 LastReferencedDate, EmailBouncedReason, EmailBouncedDate, IsEmailBounced,
                                 PhotoUrl, Jigsaw, JigsawContactId, Consecutivo_de_Contactos__c, ExportaActualiza__c,
                                 ExportaInsert__c, Exportar__c, ID_Salesforce_Cuenta__c, Id_Capris__c, Minutes_Since_Created__c,
                                 Minutes_Since_Modified__c, SF_Creado_por__c, SF_Fecha_de_creaci_n__c,
                                 SF_Fecha_de_ltima_modificaci_n__c, SF_Usuario_ltima_modificaci_n__c, Verificar_Lapso_Creado__c,
                                 Verificar_Lapso_Modificado__c, idcontacto__c, mcc_cedula__c, mcc_cod_org__c, mcc_env_email__c,
                                 mcc_env_sms__c, mcc_estado__c, mcc_fec_nac__c, mcc_fyh_inserta__c, mcc_fyh_modifica__c,
                                 mcc_id_actividad__c, mcc_id_contacto__c, mcc_id_puesto__c, mcc_ind_credito__c, mcc_ind_encuesta__c,
                                 mcc_ind_estcta__c, mcc_ind_fiador__c, mcc_ind_gerente__c, mcc_num_cliente__c, mcc_obs__c,
                                 mcc_usu_inserta__c, mcc_usu_modifica__c, Data_Quality_Description__c, Data_Quality_Score__c,
                                 Movil__c, CreatedBy.Name, LastModifiedBy.Name, Account.num_cliente__c FROM Contact Where Id = :ContId];

        JSONGenerator gen = JSON.createGenerator(false);


        Try {
            For (Contact con : contLst) {

                gen.writeStartObject();
                writeCredentials(gen);
                gen.writeFieldName('ContactosMainList');
                gen.writeStartArray();
                gen.writeStartObject();
                gen.writeStringField('org', 'CAP'); //ValidateNull.doValidation(con.mcc_cod_org__c));
                gen.writeStringField('codcli', ValidateNull.doValidation(con.Account.num_cliente__c));
                gen.writeStringField('idContacto', con.idcontacto__c != null ? con.idcontacto__c : '0');
                gen.writeStringField('cedula', ValidateNull.doValidation(con.mcc_cedula__c));
                gen.writeStringField('nombre1', ValidateNull.doValidation(con.FirstName));
                gen.writeNullField('nombre2');
                gen.writeStringField('apellidos', ValidateNull.doValidation(con.LastName));
                gen.writeStringField('fyhNacimiento', con.mcc_fec_nac__c != null ? FormatDate.getFromDateTime(con.mcc_fec_nac__c) : '');
                gen.writeStringField('envEmail',ValidateNull.doValidationBoolean(con.mcc_env_email__c));
                gen.writeStringField('estado', 'A');//ValidateNull.doValidation(con.mcc_estado__c));
                gen.writeStringField('envSms',ValidateNull.doValidationBoolean(con.mcc_env_sms__c));
                gen.writeNullField('idPuesto');
                gen.writeStringField('observaciones', ValidateNull.doValidation(con.mcc_obs__c));
                gen.writeStringField('usuInserta', ValidateNull.doValidation(con.CreatedBy.Name));
                gen.writeStringField('fyhInserta', con.CreatedDate != null ? FormatDate.getFromDateTime(con.CreatedDate) : '');
                gen.writeStringField('usuModifica', con.LastModifiedBy.Name);
                gen.writeStringField('fyhModifica', con.LastModifiedDate != null ? FormatDate.getFromDateTime(con.LastModifiedDate) : '');
                gen.writeStringField('indCredito', ValidateNull.doValidationBoolean(con.mcc_ind_credito__c));
                gen.writeStringField('indEncuesta', ValidateNull.doValidationBoolean(con.mcc_ind_encuesta__c));
                gen.writeStringField('indEstcta', ValidateNull.doValidationBoolean(con.mcc_ind_estcta__c));
                gen.writeStringField('indFiador', ValidateNull.doValidationBoolean(con.mcc_ind_fiador__c));
                gen.writeStringField('indGerente', ValidateNull.doValidationBoolean(con.mcc_ind_gerente__c));
                gen.writeStringField('idSaleforce', con.Id);
                gen.writeEndObject();
                gen.writeEndArray();
                gen.writeEndObject();
            }

        } Catch(Exception e) {
            System.Debug(e.getStackTraceString());

        }
        String Body = gen.getAsString();
        String Result = JSON.serializePretty(Body);
        System.Debug('JSON Enviado ' + Body);
        Return Body;
    }

    public static String GenerateJSONEmail(String EmailId) {

        List<Correo_Electronico__c> contLst = [SELECT Id, OwnerId, IsDeleted, Name, CurrencyIsoCode, RecordTypeId,
                                               CreatedDate, CreatedById, LastModifiedDate, LastModifiedById, LastActivityDate,
                                               LastViewedDate, LastReferencedDate, ExportaActualiza__c, ExportaInsert__c, Exportar__c,
                                               Id_Capris__c, Minutes_Since_Created__c, Minutes_Since_Modified__c, Nombre_del_Cliente__c,
                                               Nombre_del_Contacto__c, SF_Creado_por__c, SF_Fecha_de_creaci_n__c, SF_Fecha_de_ltima_modificaci_n__c,
                                               SF_Usuario_ltima_modificaci_n__c, Verificar_Lapso_Creado__c, Verificar_Lapso_Modificado__c,
                                               mce_cod_org__c, mce_estado__c, mce_estctatarj__c, mce_fyh_inserta__c, mce_fyh_modifica__c,
                                               mce_id_contacto__c, mce_num_cliente__c, mce_otros__c, mce_usu_inserta__c,Nombre_del_Contacto__r.Id_Capris__c,
                                               mce_usu_modifica__c, CreatedBy.Name, LastModifiedBy.Name FROM Correo_Electronico__c Where Id = :EmailId];

        JSONGenerator gen = JSON.createGenerator(false);


        Try {
            For (Correo_Electronico__c obj : contLst) {

                gen.writeStartObject();
                writeCredentials(gen);
                gen.writeFieldName('EmailMainList');
                gen.writeStartArray();
                gen.writeStartObject();
                gen.writeStringField('org', 'CAP'); //ValidateNull.doValidation(obj.mce_cod_org__c));
                gen.writeStringField('codcli', ValidateNull.doValidation(obj.mce_num_cliente__c));
				if(obj.Nombre_del_Contacto__c != null){
                gen.writeStringField('idContacto', obj.Nombre_del_Contacto__r.Id_Capris__c != null ? obj.Nombre_del_Contacto__r.Id_Capris__c.substringAfter('-') : '');
				}
				else{
				gen.writeStringField('idContacto', '');
				}
                gen.writeStringField('email', obj.Name);
                gen.writeStringField('otros', ValidateNull.doValidation(obj.mce_otros__c));
                gen.writeStringField('usuInserta', ValidateNull.doValidation(obj.CreatedBy.Name));
                gen.writeStringField('fyhInserta', FormatDate.getFromDateTime(obj.CreatedDate));
                gen.writeStringField('usuModifica', obj.LastModifiedBy.Name);
                gen.writeStringField('fyhModifica', FormatDate.getFromDateTime(obj.LastModifiedDate));
                gen.writeStringField('estado', ValidateNull.doValidation(obj.mce_estado__c));
                gen.writeStringField('estctatarj', ValidateNull.doValidationBoolean(obj.mce_estctatarj__c));
                gen.writeNullField('estfe');
                gen.writeStringField('idSaleforce', obj.Id);
                gen.writeEndObject();
                gen.writeEndArray();
                gen.writeEndObject();
            }

        } Catch(Exception e) {
            System.Debug(e);

        }
        String Body = gen.getAsString();
        String Result = JSON.serializePretty(Body);
        System.Debug('JSON Enviado ' + Body);
        Return Body;
    }


    public static String GenerateJSONPhone(String PhoneId) {

        List<Telefonos__c> contLst = [SELECT Id, OwnerId, IsDeleted, Name, CurrencyIsoCode, RecordTypeId,
                                      CreatedDate, CreatedById, LastModifiedDate, LastModifiedById, LastActivityDate, LastViewedDate,
                                      LastReferencedDate, ExportaActualiza__c, ExportaInsert__c, Id_Capris__c, Minutes_Since_Created__c,
                                      Minutes_Since_Modified__c, Nombre_del_Cliente__c, Nombre_del_Contacto__c, SF_Creado_por__c,
                                      SF_Fecha_de_creaci_n__c, SF_Fecha_de_ltima_modificaci_n__c, SF_Usuario_ltima_modificaci_n__c,
                                      Verificar_Lapso_Creado__c, Verificar_Lapso_Modificado__c, telc_asignacion__c, telc_cod_org__c,
                                      telc_estado__c, telc_extension__c, telc_fyh_inserta__c, telc_fyh_modifica__c, telc_id_contacto__c,
                                      telc_num_cliente__c, telc_tipo__c, telc_ubicacion__c, telc_usu_inserta__c, telc_usu_modifica__c,
									  Nombre_del_Contacto__r.Id_Capris__c,
                                      telc_visible__c, CreatedBy.Name, LastModifiedBy.Name, Nombre_del_Cliente__r.num_cliente__c FROM Telefonos__c Where Id = :PhoneId];

        JSONGenerator gen = JSON.createGenerator(false);


        Try {
            For (Telefonos__c obj : contLst) {

                gen.writeStartObject();
                writeCredentials(gen);
                gen.writeFieldName('TelefonosMainList');
                gen.writeStartArray();
                gen.writeStartObject();
                gen.writeStringField('org', 'CAP'); //)ValidateNull.doValidation(obj.telc_cod_org__c));
                gen.writeStringField('codcli', ValidateNull.doValidation(obj.Nombre_del_Cliente__r.num_cliente__c));
                gen.writeStringField('tipo', ValidateNull.doValidation(obj.telc_tipo__c));
                gen.writeStringField('numero', obj.Name);
                gen.writeStringField('ubicacion', ValidateNull.doValidation(obj.telc_ubicacion__c));
                gen.writeStringField('asignacion', ValidateNull.doValidation(obj.telc_asignacion__c));
                gen.writeStringField('usuModifica', obj.LastModifiedBy.Name);
                gen.writeStringField('fyhModifica', FormatDate.getFromDateTime(obj.LastModifiedDate));
                gen.writeStringField('extension', ValidateNull.doValidation(obj.telc_extension__c));
                gen.writeStringField('usuInserta', ValidateNull.doValidation(obj.CreatedBy.Name));
                gen.writeStringField('fyhInserta', FormatDate.getFromDateTime(obj.CreatedDate));
                if(obj.Nombre_del_Contacto__c != null){
                gen.writeStringField('idContacto', obj.Nombre_del_Contacto__r.Id_Capris__c != null ? obj.Nombre_del_Contacto__r.Id_Capris__c.substringAfter('-') : '');
				}
				else{
				gen.writeStringField('idContacto', '');
				}
                gen.writeStringField('estado', ValidateNull.doValidation(obj.telc_estado__c));
                gen.writeStringField('idSaleforce', obj.Id);
                gen.writeEndObject();
                gen.writeEndArray();
                gen.writeEndObject();
            }

        } Catch(Exception e) {
            System.Debug(e);

        }
        String Body = gen.getAsString();
        String Result = JSON.serializePretty(Body);
        System.Debug('JSON Enviado ' + Body);
        Return Body;
    }
}