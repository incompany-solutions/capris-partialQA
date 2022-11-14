/**
 * @description       : 
 * @author            : ???
 * @group             : 
 * @last modified on  : 21-10-2022
 * @last modified by  : esteban@incompany.cr
**/
public class DeserializeJSONAccount {

	public class DeserializeJSON {
		public List<AccountMainList> AccountMainList;
	}

	public class AccountMainList {
		public String codCliente;
		public String org;
		public String nombreFantasia;
		public String direccion{
            get {
                if (this.direccion == 'null') {
                    return null;
                }
                else {

                    return this.direccion;
                }
            }
            set;
        }
		public String estado;
		public String razonSocial;
		public String canton{
            get {
                if (this.canton == 'null') {
                    return null;
                }
                else {

                    return this.canton;
                }
            }
            set;
        }
		public String cedula;
		public String tipocli;
		public String reqOc;
		public String observaciones;
		public String sitioWeb{
            get {
                if (this.nombre1 == 'null') {
                    return null;
                }
                else {

                    return this.nombre1;
                }
            }
            set;
        }
		public String provincia;
		public String porcExoIva {
			get {
				if (this.porcExoIva == 'null') {
					return '0';
				}
				else {

					return this.porcExoIva;
				}
			}
			set;
		}
		public String usuModifica;
		public String fyhModifica;
		public String horaEntrega;
		public String obsEntrega;
		public String reqOcEntrega{
            get {
                if (this.reqOcEntrega == 'null') {
                    return null;
                }
                else {

                    return this.reqOcEntrega;
                }
            }
            set;
        }
		public String reqFacEntrega;
		public String rutaCobro{
            get {
                if (this.rutaCobro == 'null') {
                    return null;
                }
                else {

                    return this.rutaCobro;
                }
            }
            set;
        }
		public String limiteCredito{
            get {
                if (this.limiteCredito == 'null') {
                    return '0';
                }
                else {

                    return this.limiteCredito;
                }
            }
            set;
        }
		public String diaTramite;
		public String cobradorCxc;
		public String fyhIngreso;
		public String plazoCxc;
		public String nombre1{
            get {
                if (this.nombre1 == 'null') {
                    return null;
                }
                else {

                    return this.nombre1;
                }
            }
            set;
        }
		public String nombre2{
            get {
                if (this.nombre2 == 'null') {
                    return null;
                }
                else {

                    return this.nombre2;
                }
            }
            set;
        }
		public String apellido1{
            get {
                if (this.apellido1 == 'null') {
                    return null;
                }
                else {

                    return this.apellido1;
                }
            }
            set;
        }
		public String apellido2
        {
            get {
                if (this.apellido2 == 'null') {
                    return null;
                }
                else {

                    return this.apellido2;
                }
            }
            set;
        }
		public String usuIngreso;
		public String envEmail;
		public String envSms;
		public String fyhNacimiento;
		public String idPuesto{
            get {
                if (this.zona == 'null') {
                    return null;
                }
                else {

                    return this.zona;
                }
            }
            set;
        }
		public String plazoTec;
		public String cobradorTec;
		public String region;
		public String zona{
            get {
                if (this.zona == 'null') {
                    return null;
                }
                else {

                    return this.zona;
                }
            }
            set;
        }
		public String dirComercial{
            get {
                if (this.dirComercial == 'null') {
                    return null;
                }
                else {

                    return this.dirComercial;
                }
            }
            set;
        }
		public String origen{
            get {
                if (this.origen == 'null') {
                    return null;
                }
                else {

                    return this.origen;
                }
            }
            set;
        }
		public String excepTrans;
		public String indMixto;
		public String fyhVenLetc;
        public String vendedor;
		public String claCli{
            get {
                if (this.claCli == 'null') {
                    return null;
                }
                else {

                    return this.claCli;
                }
            }
            set;
        }
        public String codigoPrincipal;
        public String descripcionCIIU;
        public String SEM;
	}

	public static DeserializeJSON parse(String json) {
		return(DeserializeJSON) System.JSON.deserialize(json, DeserializeJSON.class);
	}
}