 
/*------------------------------------------------------------------------
   File        : BPA_form
   Purpose     : 
   Syntax      : 
   Description : 
   Author(s)   : eshklyar
   Created     : Wed Dec 19 11:08:37 MSK 2018
   Notes       : 
 ----------------------------------------------------------------------*/

using Progress.Lang.*.
using Progress.Windows.Form.

block-level on error undo, throw.

class ibs.th.ref.bpa.BPA_form inherits Form: 
  { cmp/str-glbl.i   class}
  define private variable auth                as System.Windows.Forms.CheckBox    no-undo.
  define private variable auto_prifix_min     as System.Windows.Forms.Label       no-undo.
  define private variable auto_prifix_max     as System.Windows.Forms.Label       no-undo.
  define private variable auto_prifix         as System.Windows.Forms.Label       no-undo.
  define private variable auto_name_file      as System.Windows.Forms.Label       no-undo.
  define private variable auto_groupBox1      as System.Windows.Forms.GroupBox    no-undo.
  define private variable b_commis as System.Windows.Forms.Button no-undo.
  define private variable b_commis1 as System.Windows.Forms.Button no-undo.
  define private variable b_exit              as System.Windows.Forms.Button      no-undo.
  define private variable b_cancel            as System.Windows.Forms.Button      no-undo.
  define private variable bindingBPA          as Progress.Data.BindingSource      no-undo.
  define private variable bpa_type_commis     as System.Windows.Forms.Label       no-undo.
  define private variable bpa_sum             as System.Windows.Forms.Label       no-undo.
  define private variable bpa_prod_tel        as System.Windows.Forms.Label       no-undo.
  define private variable bpa_prod_name       as System.Windows.Forms.Label       no-undo.
  define private variable bpa_prod_inn        as System.Windows.Forms.Label       no-undo.
  define private variable bpa_prod            as System.Windows.Forms.GroupBox    no-undo.
  define private variable bpa_oper_tel        as System.Windows.Forms.Label       no-undo.
  define private variable bpa_oper_inn        as System.Windows.Forms.Label       no-undo.
  define private variable bpa_oper_adress     as System.Windows.Forms.Label       no-undo.
  define private variable bpa_oper            as System.Windows.Forms.GroupBox    no-undo.
  define private variable bpa_name_oper       as System.Windows.Forms.Label       no-undo.
  define private variable bpa_min_summ        as System.Windows.Forms.Label       no-undo.
  define private variable bpa_max_summ        as System.Windows.Forms.Label       no-undo.
  define private variable bpa_limit_sum       as System.Windows.Forms.Label       no-undo.
  define private variable bpa_groupBox3       as System.Windows.Forms.GroupBox    no-undo.
  define private variable bpa_flag_agent_ras  as System.Windows.Forms.Label       no-undo.
  define private variable bpa_falg_agent      as System.Windows.Forms.Label       no-undo.
  define private variable bpa_commis          as System.Windows.Forms.Label       no-undo.
  define private variable bpa_agent_teloper   as System.Windows.Forms.Label       no-undo.
  define private variable bpa_agent_tel       as System.Windows.Forms.Label       no-undo.
  define private variable bpa_agent_oper      as System.Windows.Forms.Label       no-undo.
  define private variable bpa_agent           as System.Windows.Forms.GroupBox    no-undo.
  define private variable c_bpa_AgentFlagRas  as System.Windows.Forms.ComboBox    no-undo.
  define private variable c_bpa_AgentFlag     as System.Windows.Forms.ComboBox    no-undo.
  define private variable commis              as System.Windows.Forms.TextBox     no-undo.
  define private variable commis_gds as System.Windows.Forms.TextBox no-undo.
  define private variable commis_gds1 as System.Windows.Forms.TextBox no-undo.
  define private variable components          as System.ComponentModel.IContainer no-undo.
  define private variable f_bpa_prod_tel      as System.Windows.Forms.TextBox     no-undo.
  define private variable f_bpa_prod_name     as System.Windows.Forms.TextBox     no-undo.
  define private variable f_bpa_prod_inn      as System.Windows.Forms.TextBox     no-undo.
  define private variable f_bpa_oper_tel      as System.Windows.Forms.TextBox     no-undo.
  define private variable f_bpa_oper_inn      as System.Windows.Forms.TextBox     no-undo.
  define private variable f_bpa_oper_adress   as System.Windows.Forms.TextBox     no-undo.
  define private variable f_bpa_name_oper     as System.Windows.Forms.TextBox     no-undo.
  define private variable f_bpa_agent_teloper as System.Windows.Forms.TextBox     no-undo.
  define private variable f_bpa_agent_tel     as System.Windows.Forms.TextBox     no-undo.
  define private variable f_bpa_agent_oper    as System.Windows.Forms.TextBox     no-undo.
  define private variable f_auto_prifix_min   as System.Windows.Forms.TextBox     no-undo.
  define private variable f_auto_prifix_max   as System.Windows.Forms.TextBox     no-undo.
  define private variable f_auto_name_file    as System.Windows.Forms.TextBox     no-undo.
  define private variable f_type_commis       as System.Windows.Forms.ComboBox    no-undo.
  define private variable f_min_sum           as System.Windows.Forms.TextBox     no-undo.
  define private variable f_max_sum           as System.Windows.Forms.TextBox     no-undo.
  define private variable f_limit_sum         as System.Windows.Forms.TextBox     no-undo.
  define private variable f_commis            as System.Windows.Forms.TextBox     no-undo.
  define private variable l_commis_gds as System.Windows.Forms.Label no-undo.
  define private variable l_name              as System.Windows.Forms.Label       no-undo.
  define private variable l_code              as System.Windows.Forms.Label       no-undo.
  define private variable f_name              as System.Windows.Forms.TextBox     no-undo.
  define private variable f_code              as System.Windows.Forms.TextBox     no-undo.
  define private variable l_slip_name         as System.Windows.Forms.Label       no-undo.
  define private variable label5 as System.Windows.Forms.Label no-undo.
  define private variable label9              as System.Windows.Forms.Label       no-undo.
  define private variable label8              as System.Windows.Forms.Label       no-undo.
  define private variable label7              as System.Windows.Forms.Label       no-undo.
  define private variable label6              as System.Windows.Forms.Label       no-undo.
  define private variable label4              as System.Windows.Forms.Label       no-undo.
  define private variable label3              as System.Windows.Forms.Label       no-undo.
  define private variable label2              as System.Windows.Forms.Label       no-undo.
  define private variable label12             as System.Windows.Forms.Label       no-undo.
  define private variable label11             as System.Windows.Forms.Label       no-undo.
  define private variable label10             as System.Windows.Forms.Label       no-undo.
  define private variable label1              as System.Windows.Forms.Label       no-undo.
  define private variable min_tel             as System.Windows.Forms.TextBox     no-undo.
  define private variable min_summ            as System.Windows.Forms.TextBox     no-undo.
  define private variable max_tel             as System.Windows.Forms.TextBox     no-undo.
  define private variable max_summ            as System.Windows.Forms.TextBox     no-undo.
  define private variable OCCgroup            as System.Windows.Forms.GroupBox    no-undo.
  define private variable oss_abbr            as System.Windows.Forms.TextBox     no-undo.
  define private variable pMode               as character                        no-undo .
  define private variable summ_atent          as System.Windows.Forms.TextBox     no-undo.
  define private variable slip_name           as System.Windows.Forms.TextBox     no-undo.
  define private variable slip                as System.Windows.Forms.CheckBox    no-undo.
  define private variable type                as System.Windows.Forms.Label       no-undo.
  define private variable type_commis         as System.Windows.Forms.ComboBox    no-undo.
  define private variable type_OperServ       as System.Windows.Forms.ComboBox    no-undo.
  define private variable type_OperServ1      as System.Windows.Forms.ComboBox    no-undo.
  define private variable type_OperServ2      as System.Windows.Forms.ComboBox    no-undo.
  define private variable type_ras            as System.Windows.Forms.ComboBox    no-undo.

  define buffer buf_OperServ for ub.OperServ .
  define temp-table tt-OperServ like ub.OperServ .
  
  define variable OsTypeRas        as character no-undo .
  define variable p-OsType         as character no-undo .
  define variable CommType         as character no-undo .
  define variable Commis_val       as decimal   no-undo .
  define variable p-AgentFlagRasch as character no-undo .
  define variable p-AgentFlag      as character no-undo .
  
  define property parparentproc as handle no-undo
  private get.
  set(input iH as handle):
    parparentproc = iH.
  end. 
           
  constructor public BPA_form (iChange as character, p-id as integer ):
    
    
    super().
    pMode = iChange .

    if pMode = {&add-def} then 
    do:
      create tt-OperServ .
      tt-OperServ.id = next-value (s-operserv-id) .
    end.
    else 
    do:
      find first buf_OperServ exclusive-lock where buf_OperServ.id = p-id no-error .
      buffer-copy buf_OperServ to tt-OperServ .
      Enable_Form () .      
    end. 

    InitializeComponent().
    if pMode <> {&add-def} then 
    do:
      assign
      this-object:type_ras:Text = OsTypeRas .
      this-object:type_OperServ:Text = p-OsType .
      this-object:type_OperServ1:Text = p-OsType .
      this-object:type_OperServ2:Text = p-OsType .
      this-object:type_commis:Text = CommType .
      this-object:Commis:Text = string(Commis_val) .
      this-object:f_type_commis:Text = CommType .
      this-object:f_commis:Text = string(Commis_val) .
      this-object:c_bpa_AgentFlag:Text = p-AgentFlag .
      this-object:c_bpa_AgentFlagRas:Text = p-AgentFlagRasch .
      .     
    end. 
     
    Visual_form_Type(OsTypeRas).
    Visual_form_mode(pMode).
    
    bindingBPA:Handle = buffer tt-OperServ:handle . 
        
    this-object:ComponentsCollection:ADD(this-object:components).
    catch e as Progress.Lang.Error:
      undo, throw e.
    end catch.

  end constructor.

  constructor public BPA_form ():
    InitializeComponent().
    
  end constructor.
  

	/*------------------------------------------------------------------------------
	 Purpose:
	 Notes:
	------------------------------------------------------------------------------*/
	@VisualDesigner.
	method private void auth_CheckedChanged( input sender as System.Object, input e as System.EventArgs ):
		
		return.

	end method.

	/*------------------------------------------------------------------------------
	 Purpose:
	 Notes:
	------------------------------------------------------------------------------*/
	@VisualDesigner.
	method private void choose_commis_gds( input sender as System.Object, input e as System.EventArgs ):
		add_goods().
		return.

	end method.

  /*------------------------------------------------------------------------------
   Purpose:
   Notes:
  ------------------------------------------------------------------------------*/
  @VisualDesigner.
  method private void add_goods():
    define variable v-GdsList as character no-undo .
    define variable ii        as integer   no-undo .
    define buffer buf_OperServ  for ub.OperServ .
    
    run str/gdslist.p ( input parparentproc
      , output v-GdsList).
    if v-GdsList <> "" then 
    do:
      v-GdsList = trim(v-GdsList,{&delim-cmd}) .
      for first ub.goods no-lock where ub.goods.gds-code = integer(entry(1, v-GdsList,{&delim-cmd})):
       if ub.goods.gds-type <> {&gds-office} then do:
         message "Товар должен быть услугой"
         view-as alert-box.
         return .
       end.     
       else do: 
       assign
       commis_gds:Text = string(entry(1, v-GdsList,{&delim-cmd}))
       commis_gds1:Text = string(entry(1, v-GdsList,{&delim-cmd})) 
       tt-OperServ.gds-code = integer(entry(1, v-GdsList,{&delim-cmd})).
       end.        
      end.
    end.  
    return.

  end method.

	/*------------------------------------------------------------------------------
	 Purpose:
	 Notes:
	------------------------------------------------------------------------------*/
	@VisualDesigner.
	method private void commis_gds1_TextChanged( input sender as System.Object, input e as System.EventArgs ):
		
		return.

	end method.

  method private void InitializeComponent(  ):
    
    /* NOTE: The following method is automatically generated.
    
    We strongly suggest that the contents of this method only be modified using the
    Visual Designer to avoid any incompatible modifications.
    
    Modifying the contents of this method using a code editor will invalidate any support for this file. */
      this-object:components = new System.ComponentModel.Container().
      @VisualDesigner.FormMember (NeedsInitialize="true").
      define variable tableDesc1 as Progress.Data.TableDesc no-undo.
      tableDesc1 = new Progress.Data.TableDesc("tt-OperServ").
      this-object:f_code = new System.Windows.Forms.TextBox().
      this-object:bindingBPA = new Progress.Data.BindingSource(this-object:components).
      this-object:l_code = new System.Windows.Forms.Label().
      this-object:f_name = new System.Windows.Forms.TextBox().
      this-object:l_name = new System.Windows.Forms.Label().
      this-object:bpa_oper = new System.Windows.Forms.GroupBox().
      this-object:f_bpa_oper_tel = new System.Windows.Forms.TextBox().
      this-object:bpa_oper_tel = new System.Windows.Forms.Label().
      this-object:f_bpa_name_oper = new System.Windows.Forms.TextBox().
      this-object:bpa_name_oper = new System.Windows.Forms.Label().
      this-object:f_bpa_oper_inn = new System.Windows.Forms.TextBox().
      this-object:f_bpa_oper_adress = new System.Windows.Forms.TextBox().
      this-object:bpa_oper_adress = new System.Windows.Forms.Label().
      this-object:bpa_oper_inn = new System.Windows.Forms.Label().
      this-object:OCCgroup = new System.Windows.Forms.GroupBox().
      this-object:b_commis = new System.Windows.Forms.Button().
      this-object:l_commis_gds = new System.Windows.Forms.Label().
      this-object:commis_gds = new System.Windows.Forms.TextBox().
      this-object:type_commis = new System.Windows.Forms.ComboBox().
      this-object:l_slip_name = new System.Windows.Forms.Label().
      this-object:label4 = new System.Windows.Forms.Label().
      this-object:slip_name = new System.Windows.Forms.TextBox().
      this-object:summ_atent = new System.Windows.Forms.TextBox().
      this-object:slip = new System.Windows.Forms.CheckBox().
      this-object:label3 = new System.Windows.Forms.Label().
      this-object:auth = new System.Windows.Forms.CheckBox().
      this-object:label7 = new System.Windows.Forms.Label().
      this-object:oss_abbr = new System.Windows.Forms.TextBox().
      this-object:label12 = new System.Windows.Forms.Label().
      this-object:label8 = new System.Windows.Forms.Label().
      this-object:label2 = new System.Windows.Forms.Label().
      this-object:label11 = new System.Windows.Forms.Label().
      this-object:label1 = new System.Windows.Forms.Label().
      this-object:label9 = new System.Windows.Forms.Label().
      this-object:max_summ = new System.Windows.Forms.TextBox().
      this-object:commis = new System.Windows.Forms.TextBox().
      this-object:max_tel = new System.Windows.Forms.TextBox().
      this-object:label10 = new System.Windows.Forms.Label().
      this-object:min_summ = new System.Windows.Forms.TextBox().
      this-object:min_tel = new System.Windows.Forms.TextBox().
      this-object:type_ras = new System.Windows.Forms.ComboBox().
      this-object:label6 = new System.Windows.Forms.Label().
      this-object:bpa_agent_tel = new System.Windows.Forms.Label().
      this-object:bpa_agent = new System.Windows.Forms.GroupBox().
      this-object:c_bpa_AgentFlagRas = new System.Windows.Forms.ComboBox().
      this-object:bpa_flag_agent_ras = new System.Windows.Forms.Label().
      this-object:c_bpa_AgentFlag = new System.Windows.Forms.ComboBox().
      this-object:bpa_falg_agent = new System.Windows.Forms.Label().
      this-object:f_bpa_agent_oper = new System.Windows.Forms.TextBox().
      this-object:bpa_agent_oper = new System.Windows.Forms.Label().
      this-object:f_bpa_agent_teloper = new System.Windows.Forms.TextBox().
      this-object:bpa_agent_teloper = new System.Windows.Forms.Label().
      this-object:f_bpa_agent_tel = new System.Windows.Forms.TextBox().
      this-object:bpa_prod = new System.Windows.Forms.GroupBox().
      this-object:f_bpa_prod_tel = new System.Windows.Forms.TextBox().
      this-object:bpa_prod_tel = new System.Windows.Forms.Label().
      this-object:f_bpa_prod_name = new System.Windows.Forms.TextBox().
      this-object:bpa_prod_name = new System.Windows.Forms.Label().
      this-object:f_bpa_prod_inn = new System.Windows.Forms.TextBox().
      this-object:bpa_prod_inn = new System.Windows.Forms.Label().
      this-object:bpa_groupBox3 = new System.Windows.Forms.GroupBox().
      this-object:b_commis1 = new System.Windows.Forms.Button().
      this-object:label5 = new System.Windows.Forms.Label().
      this-object:commis_gds1 = new System.Windows.Forms.TextBox().
      this-object:bpa_max_summ = new System.Windows.Forms.Label().
      this-object:f_type_commis = new System.Windows.Forms.ComboBox().
      this-object:bpa_min_summ = new System.Windows.Forms.Label().
      this-object:f_commis = new System.Windows.Forms.TextBox().
      this-object:f_max_sum = new System.Windows.Forms.TextBox().
      this-object:bpa_commis = new System.Windows.Forms.Label().
      this-object:f_min_sum = new System.Windows.Forms.TextBox().
      this-object:f_limit_sum = new System.Windows.Forms.TextBox().
      this-object:bpa_sum = new System.Windows.Forms.Label().
      this-object:bpa_limit_sum = new System.Windows.Forms.Label().
      this-object:bpa_type_commis = new System.Windows.Forms.Label().
      this-object:b_cancel = new System.Windows.Forms.Button().
      this-object:b_exit = new System.Windows.Forms.Button().
      this-object:type_OperServ = new System.Windows.Forms.ComboBox().
      this-object:type_OperServ1 = new System.Windows.Forms.ComboBox().
      this-object:type_OperServ2 = new System.Windows.Forms.ComboBox().
      this-object:type = new System.Windows.Forms.Label().
      this-object:auto_groupBox1 = new System.Windows.Forms.GroupBox().
      this-object:f_auto_name_file = new System.Windows.Forms.TextBox().
      this-object:auto_name_file = new System.Windows.Forms.Label().
      this-object:auto_prifix = new System.Windows.Forms.Label().
      this-object:f_auto_prifix_min = new System.Windows.Forms.TextBox().
      this-object:f_auto_prifix_max = new System.Windows.Forms.TextBox().
      this-object:auto_prifix_min = new System.Windows.Forms.Label().
      this-object:auto_prifix_max = new System.Windows.Forms.Label().
      cast(this-object:bindingBPA, System.ComponentModel.ISupportInitialize):BeginInit().
      this-object:bpa_oper:SuspendLayout().
      this-object:OCCgroup:SuspendLayout().
      this-object:bpa_agent:SuspendLayout().
      this-object:bpa_prod:SuspendLayout().
      this-object:bpa_groupBox3:SuspendLayout().
      this-object:auto_groupBox1:SuspendLayout().
      this-object:SuspendLayout().
      /*  */
      /* f_code */
      /*  */
      this-object:f_code:DataBindings:Add(new System.Windows.Forms.Binding("Text", this-object:bindingBPA, "id", true)).
      this-object:f_code:Font = new System.Drawing.Font("Microsoft Sans Serif", Progress.Util.CastUtil:ToSingle(8.25), System.Drawing.FontStyle:Regular, System.Drawing.GraphicsUnit:Point, System.Convert:ToByte(204)).
      this-object:f_code:Location = new System.Drawing.Point(123, 47).
      this-object:f_code:Name = "f_code".
      this-object:f_code:ReadOnly = true.
      this-object:f_code:Size = new System.Drawing.Size(137, 20).
      this-object:f_code:TabIndex = 0.
      this-object:f_code:WordWrap = false.
      /*  */
      /* bindingBPA */
      /*  */
      this-object:bindingBPA:MaxDataGuess = 0.
      this-object:bindingBPA:NoLOBs = false.
      this-object:bindingBPA:Position = 0.
      @VisualDesigner.FormMember (NeedsInitialize="false", InitializeArray="true").
      define variable arrayvar0 as "Progress.Data.TableDesc[]" no-undo.
      arrayvar0 = new "Progress.Data.TableDesc[]"(0).
      tableDesc1:ChildTables = arrayvar0.
      @VisualDesigner.FormMember (NeedsInitialize="false", InitializeArray="true").
      define variable arrayvar1 as Progress.Data.ColumnPropDesc extent 24 no-undo.
      arrayvar1[1] = new Progress.Data.ColumnPropDesc("AgentOpere", "опер.плат.агента", Progress.Data.DataType:CHARACTER).
      arrayvar1[2] = new Progress.Data.ColumnPropDesc("AgentTel", "тел. агента", Progress.Data.DataType:CHARACTER).
      arrayvar1[3] = new Progress.Data.ColumnPropDesc("ext-code", "ext-code", Progress.Data.DataType:CHARACTER).
      arrayvar1[4] = new Progress.Data.ColumnPropDesc("id", "id", Progress.Data.DataType:INT64).
      arrayvar1[5] = new Progress.Data.ColumnPropDesc("InnSupp", "ИНН", Progress.Data.DataType:CHARACTER).
      arrayvar1[6] = new Progress.Data.ColumnPropDesc("OperAddr", "адрес опер.", Progress.Data.DataType:CHARACTER).
      arrayvar1[7] = new Progress.Data.ColumnPropDesc("OperInn", "ИНН", Progress.Data.DataType:CHARACTER).
      arrayvar1[8] = new Progress.Data.ColumnPropDesc("OperName", "Наим. опер", Progress.Data.DataType:CHARACTER).
      arrayvar1[9] = new Progress.Data.ColumnPropDesc("OperTel", "тел. опер.", Progress.Data.DataType:CHARACTER).
      arrayvar1[10] = new Progress.Data.ColumnPropDesc("OperTelTran", "тел. опер", Progress.Data.DataType:CHARACTER).
      arrayvar1[11] = new Progress.Data.ColumnPropDesc("OSname", "Наим. опер.", Progress.Data.DataType:CHARACTER).
      arrayvar1[12] = new Progress.Data.ColumnPropDesc("OsNameAbbr", "Аббр. опер.", Progress.Data.DataType:CHARACTER).
      arrayvar1[13] = new Progress.Data.ColumnPropDesc("PreAAvt", "Необх.автор.", Progress.Data.DataType:LOGICAL).
      arrayvar1[14] = new Progress.Data.ColumnPropDesc("PreSlip", "Печ. слипа", Progress.Data.DataType:LOGICAL).
      arrayvar1[15] = new Progress.Data.ColumnPropDesc("QuantMax", "Макс.кол.цифр", Progress.Data.DataType:INTEGER).
      arrayvar1[16] = new Progress.Data.ColumnPropDesc("QuantMin", "Мин.кол.цифр", Progress.Data.DataType:INTEGER).
      arrayvar1[17] = new Progress.Data.ColumnPropDesc("SlipName", "Файла слипа", Progress.Data.DataType:CHARACTER).
      arrayvar1[18] = new Progress.Data.ColumnPropDesc("Status_", "Статус", Progress.Data.DataType:INTEGER).
      arrayvar1[19] = new Progress.Data.ColumnPropDesc("SummAtent", "Сумм.для предупр.", Progress.Data.DataType:DECIMAL).
      arrayvar1[20] = new Progress.Data.ColumnPropDesc("SummMax", "Макс.сумма", Progress.Data.DataType:DECIMAL).
      arrayvar1[21] = new Progress.Data.ColumnPropDesc("SummMin", "Мин.сумма", Progress.Data.DataType:DECIMAL).
      arrayvar1[22] = new Progress.Data.ColumnPropDesc("SuppName", "Наим. пост.", Progress.Data.DataType:CHARACTER).
      arrayvar1[23] = new Progress.Data.ColumnPropDesc("SuppTel", "тел. постав.", Progress.Data.DataType:CHARACTER).
      arrayvar1[24] = new Progress.Data.ColumnPropDesc("gds-code", "gds-code", Progress.Data.DataType:INTEGER).
      tableDesc1:Columns = arrayvar1.
      this-object:bindingBPA:TableSchema = tableDesc1.
      /*  */
      /* l_code */
      /*  */
      this-object:l_code:Font = new System.Drawing.Font("Microsoft Sans Serif", Progress.Util.CastUtil:ToSingle(9), System.Drawing.FontStyle:Bold, System.Drawing.GraphicsUnit:Point, System.Convert:ToByte(204)).
      this-object:l_code:Location = new System.Drawing.Point(12, 47).
      this-object:l_code:Name = "l_code".
      this-object:l_code:Size = new System.Drawing.Size(31, 23).
      this-object:l_code:TabIndex = 1.
      this-object:l_code:Text = "Код:".
      this-object:l_code:UseCompatibleTextRendering = true.
      /*  */
      /* f_name */
      /*  */
      this-object:f_name:DataBindings:Add(new System.Windows.Forms.Binding("Text", this-object:bindingBPA, "OSname", true)).
      this-object:f_name:Font = new System.Drawing.Font("Microsoft Sans Serif", Progress.Util.CastUtil:ToSingle(8.25), System.Drawing.FontStyle:Regular, System.Drawing.GraphicsUnit:Point, System.Convert:ToByte(204)).
      this-object:f_name:Location = new System.Drawing.Point(123, 78).
      this-object:f_name:Name = "f_name".
      this-object:f_name:Size = new System.Drawing.Size(232, 20).
      this-object:f_name:TabIndex = 2.
      /*  */
      /* l_name */
      /*  */
      this-object:l_name:Font = new System.Drawing.Font("Microsoft Sans Serif", Progress.Util.CastUtil:ToSingle(9), System.Drawing.FontStyle:Bold, System.Drawing.GraphicsUnit:Point, System.Convert:ToByte(204)).
      this-object:l_name:Location = new System.Drawing.Point(12, 78).
      this-object:l_name:Name = "l_name".
      this-object:l_name:Size = new System.Drawing.Size(102, 23).
      this-object:l_name:TabIndex = 3.
      this-object:l_name:Text = "Наименование:".
      this-object:l_name:UseCompatibleTextRendering = true.
      /*  */
      /* bpa_oper */
      /*  */
      this-object:bpa_oper:Controls:Add(this-object:f_bpa_oper_tel).
      this-object:bpa_oper:Controls:Add(this-object:bpa_oper_tel).
      this-object:bpa_oper:Controls:Add(this-object:f_bpa_name_oper).
      this-object:bpa_oper:Controls:Add(this-object:bpa_name_oper).
      this-object:bpa_oper:Controls:Add(this-object:f_bpa_oper_inn).
      this-object:bpa_oper:Controls:Add(this-object:f_bpa_oper_adress).
      this-object:bpa_oper:Controls:Add(this-object:bpa_oper_adress).
      this-object:bpa_oper:Controls:Add(this-object:bpa_oper_inn).
      this-object:bpa_oper:Font = new System.Drawing.Font("Microsoft Sans Serif", Progress.Util.CastUtil:ToSingle(9), System.Drawing.FontStyle:Bold, System.Drawing.GraphicsUnit:Point, System.Convert:ToByte(204)).
      this-object:bpa_oper:Location = new System.Drawing.Point(12, 115).
      this-object:bpa_oper:Name = "bpa_oper".
      this-object:bpa_oper:Size = new System.Drawing.Size(760, 111).
      this-object:bpa_oper:TabIndex = 6.
      this-object:bpa_oper:TabStop = false.
      this-object:bpa_oper:Text = "Оператор перевода".
      this-object:bpa_oper:UseCompatibleTextRendering = true.
      this-object:bpa_oper:Visible = false.
      /*  */
      /* f_bpa_oper_tel */
      /*  */
      this-object:f_bpa_oper_tel:DataBindings:Add(new System.Windows.Forms.Binding("Text", this-object:bindingBPA, "OperTelTran", true)).
      this-object:f_bpa_oper_tel:Font = new System.Drawing.Font("Microsoft Sans Serif", Progress.Util.CastUtil:ToSingle(9), System.Drawing.FontStyle:Italic, System.Drawing.GraphicsUnit:Point, System.Convert:ToByte(204)).
      this-object:f_bpa_oper_tel:Location = new System.Drawing.Point(111, 50).
      this-object:f_bpa_oper_tel:Multiline = true.
      this-object:f_bpa_oper_tel:Name = "f_bpa_oper_tel".
      this-object:f_bpa_oper_tel:Size = new System.Drawing.Size(234, 20).
      this-object:f_bpa_oper_tel:TabIndex = 16.
      this-object:f_bpa_oper_tel:TextChanged:Subscribe(this-object:f_oper_tel_TextChanged).
      /*  */
      /* bpa_oper_tel */
      /*  */
      this-object:bpa_oper_tel:Font = new System.Drawing.Font("Microsoft Sans Serif", Progress.Util.CastUtil:ToSingle(9), System.Drawing.FontStyle:Italic, System.Drawing.GraphicsUnit:Point, System.Convert:ToByte(204)).
      this-object:bpa_oper_tel:Location = new System.Drawing.Point(9, 50).
      this-object:bpa_oper_tel:Name = "bpa_oper_tel".
      this-object:bpa_oper_tel:Size = new System.Drawing.Size(96, 23).
      this-object:bpa_oper_tel:TabIndex = 11.
      this-object:bpa_oper_tel:Text = "Телефон:".
      this-object:bpa_oper_tel:UseCompatibleTextRendering = true.
      /*  */
      /* f_bpa_name_oper */
      /*  */
      this-object:f_bpa_name_oper:DataBindings:Add(new System.Windows.Forms.Binding("Text", this-object:bindingBPA, "OperName", true)).
      this-object:f_bpa_name_oper:Font = new System.Drawing.Font("Microsoft Sans Serif", Progress.Util.CastUtil:ToSingle(9), System.Drawing.FontStyle:Italic, System.Drawing.GraphicsUnit:Point, System.Convert:ToByte(204)).
      this-object:f_bpa_name_oper:Location = new System.Drawing.Point(111, 20).
      this-object:f_bpa_name_oper:Multiline = true.
      this-object:f_bpa_name_oper:Name = "f_bpa_name_oper".
      this-object:f_bpa_name_oper:Size = new System.Drawing.Size(643, 20).
      this-object:f_bpa_name_oper:TabIndex = 15.
      /*  */
      /* bpa_name_oper */
      /*  */
      this-object:bpa_name_oper:Font = new System.Drawing.Font("Microsoft Sans Serif", Progress.Util.CastUtil:ToSingle(9), System.Drawing.FontStyle:Italic, System.Drawing.GraphicsUnit:Point, System.Convert:ToByte(204)).
      this-object:bpa_name_oper:Location = new System.Drawing.Point(9, 20).
      this-object:bpa_name_oper:Name = "bpa_name_oper".
      this-object:bpa_name_oper:Size = new System.Drawing.Size(96, 23).
      this-object:bpa_name_oper:TabIndex = 9.
      this-object:bpa_name_oper:Text = "Наименование:".
      this-object:bpa_name_oper:UseCompatibleTextRendering = true.
      /*  */
      /* f_bpa_oper_inn */
      /*  */
      this-object:f_bpa_oper_inn:DataBindings:Add(new System.Windows.Forms.Binding("Text", this-object:bindingBPA, "OperInn", true)).
      this-object:f_bpa_oper_inn:Font = new System.Drawing.Font("Microsoft Sans Serif", Progress.Util.CastUtil:ToSingle(9), System.Drawing.FontStyle:Italic, System.Drawing.GraphicsUnit:Point, System.Convert:ToByte(204)).
      this-object:f_bpa_oper_inn:Location = new System.Drawing.Point(431, 50).
      this-object:f_bpa_oper_inn:Multiline = true.
      this-object:f_bpa_oper_inn:Name = "f_bpa_oper_inn".
      this-object:f_bpa_oper_inn:Size = new System.Drawing.Size(323, 20).
      this-object:f_bpa_oper_inn:TabIndex = 17.
      /*  */
      /* f_bpa_oper_adress */
      /*  */
      this-object:f_bpa_oper_adress:DataBindings:Add(new System.Windows.Forms.Binding("Text", this-object:bindingBPA, "OperAddr", true)).
      this-object:f_bpa_oper_adress:Font = new System.Drawing.Font("Microsoft Sans Serif", Progress.Util.CastUtil:ToSingle(9), System.Drawing.FontStyle:Italic, System.Drawing.GraphicsUnit:Point, System.Convert:ToByte(204)).
      this-object:f_bpa_oper_adress:Location = new System.Drawing.Point(111, 80).
      this-object:f_bpa_oper_adress:Multiline = true.
      this-object:f_bpa_oper_adress:Name = "f_bpa_oper_adress".
      this-object:f_bpa_oper_adress:Size = new System.Drawing.Size(643, 20).
      this-object:f_bpa_oper_adress:TabIndex = 18.
      /*  */
      /* bpa_oper_adress */
      /*  */
      this-object:bpa_oper_adress:Font = new System.Drawing.Font("Microsoft Sans Serif", Progress.Util.CastUtil:ToSingle(9), System.Drawing.FontStyle:Italic, System.Drawing.GraphicsUnit:Point, System.Convert:ToByte(204)).
      this-object:bpa_oper_adress:Location = new System.Drawing.Point(9, 80).
      this-object:bpa_oper_adress:Name = "bpa_oper_adress".
      this-object:bpa_oper_adress:Size = new System.Drawing.Size(44, 23).
      this-object:bpa_oper_adress:TabIndex = 5.
      this-object:bpa_oper_adress:Text = "Адрес:".
      this-object:bpa_oper_adress:UseCompatibleTextRendering = true.
      this-object:bpa_oper_adress:Click:Subscribe(this-object:label1_Click).
      /*  */
      /* bpa_oper_inn */
      /*  */
      this-object:bpa_oper_inn:Font = new System.Drawing.Font("Microsoft Sans Serif", Progress.Util.CastUtil:ToSingle(9), System.Drawing.FontStyle:Italic, System.Drawing.GraphicsUnit:Point, System.Convert:ToByte(204)).
      this-object:bpa_oper_inn:Location = new System.Drawing.Point(378, 50).
      this-object:bpa_oper_inn:Name = "bpa_oper_inn".
      this-object:bpa_oper_inn:Size = new System.Drawing.Size(47, 23).
      this-object:bpa_oper_inn:TabIndex = 7.
      this-object:bpa_oper_inn:Text = "ИНН:".
      this-object:bpa_oper_inn:UseCompatibleTextRendering = true.
      /*  */
      /* OCCgroup */
      /*  */
      this-object:OCCgroup:Controls:Add(this-object:b_commis).
      this-object:OCCgroup:Controls:Add(this-object:l_commis_gds).
      this-object:OCCgroup:Controls:Add(this-object:commis_gds).
      this-object:OCCgroup:Controls:Add(this-object:type_commis).
      this-object:OCCgroup:Controls:Add(this-object:l_slip_name).
      this-object:OCCgroup:Controls:Add(this-object:label4).
      this-object:OCCgroup:Controls:Add(this-object:slip_name).
      this-object:OCCgroup:Controls:Add(this-object:summ_atent).
      this-object:OCCgroup:Controls:Add(this-object:slip).
      this-object:OCCgroup:Controls:Add(this-object:label3).
      this-object:OCCgroup:Controls:Add(this-object:auth).
      this-object:OCCgroup:Controls:Add(this-object:label7).
      this-object:OCCgroup:Controls:Add(this-object:oss_abbr).
      this-object:OCCgroup:Controls:Add(this-object:label12).
      this-object:OCCgroup:Controls:Add(this-object:label8).
      this-object:OCCgroup:Controls:Add(this-object:label2).
      this-object:OCCgroup:Controls:Add(this-object:label11).
      this-object:OCCgroup:Controls:Add(this-object:label1).
      this-object:OCCgroup:Controls:Add(this-object:label9).
      this-object:OCCgroup:Controls:Add(this-object:max_summ).
      this-object:OCCgroup:Controls:Add(this-object:commis).
      this-object:OCCgroup:Controls:Add(this-object:max_tel).
      this-object:OCCgroup:Controls:Add(this-object:label10).
      this-object:OCCgroup:Controls:Add(this-object:min_summ).
      this-object:OCCgroup:Controls:Add(this-object:min_tel).
      this-object:OCCgroup:Location = new System.Drawing.Point(13, 104).
      this-object:OCCgroup:Name = "OCCgroup".
      this-object:OCCgroup:Size = new System.Drawing.Size(759, 183).
      this-object:OCCgroup:TabIndex = 7.
      this-object:OCCgroup:TabStop = false.
      this-object:OCCgroup:UseCompatibleTextRendering = true.
      this-object:OCCgroup:Visible = false.
      /*  */
      /* b_commis */
      /*  */
      this-object:b_commis:Location = new System.Drawing.Point(730, 115).
      this-object:b_commis:Name = "b_commis".
      this-object:b_commis:Size = new System.Drawing.Size(19, 20).
      this-object:b_commis:TabIndex = 61.
      this-object:b_commis:TextImageRelation = System.Windows.Forms.TextImageRelation:ImageBeforeText.
      this-object:b_commis:UseCompatibleTextRendering = true.
      this-object:b_commis:UseVisualStyleBackColor = true.
      this-object:b_commis:Click:Subscribe(this-object:choose_commis_gds).
      /*  */
      /* l_commis_gds */
      /*  */
      this-object:l_commis_gds:Font = new System.Drawing.Font("Microsoft Sans Serif", Progress.Util.CastUtil:ToSingle(9), System.Drawing.FontStyle:Italic, System.Drawing.GraphicsUnit:Point, System.Convert:ToByte(204)).
      this-object:l_commis_gds:Location = new System.Drawing.Point(361, 115).
      this-object:l_commis_gds:Name = "l_commis_gds".
      this-object:l_commis_gds:Size = new System.Drawing.Size(194, 23).
      this-object:l_commis_gds:TabIndex = 60.
      this-object:l_commis_gds:Text = "Комиссия-товар:".
      this-object:l_commis_gds:UseCompatibleTextRendering = true.
      this-object:l_commis_gds:Click:Subscribe(this-object:label5_Click_1).
      /*  */
      /* commis_gds */
      /*  */
      this-object:commis_gds:DataBindings:Add(new System.Windows.Forms.Binding("Text", this-object:bindingBPA, "gds-code", true)).
      this-object:commis_gds:Font = new System.Drawing.Font("Microsoft Sans Serif", Progress.Util.CastUtil:ToSingle(9), System.Drawing.FontStyle:Regular, System.Drawing.GraphicsUnit:Point, System.Convert:ToByte(204)).
      this-object:commis_gds:Location = new System.Drawing.Point(576, 115).
      this-object:commis_gds:Multiline = true.
      this-object:commis_gds:Name = "commis_gds".
      this-object:commis_gds:ReadOnly = true.
      this-object:commis_gds:Size = new System.Drawing.Size(148, 20).
      this-object:commis_gds:TabIndex = 59.
      /*  */
      /* type_commis */
      /*  */
      this-object:type_commis:DropDownStyle = System.Windows.Forms.ComboBoxStyle:DropDownList.
      this-object:type_commis:FormattingEnabled = true.
      @VisualDesigner.FormMember (NeedsInitialize="false", InitializeArray="true").
      define variable arrayvar2 as System.Object extent 2 no-undo.
      arrayvar2[1] = "Процент".
      arrayvar2[2] = "Сумма".
      this-object:type_commis:Items:AddRange(arrayvar2).
      this-object:type_commis:Location = new System.Drawing.Point(135, 82).
      this-object:type_commis:Name = "type_commis".
      this-object:type_commis:Size = new System.Drawing.Size(208, 21).
      this-object:type_commis:TabIndex = 11.
      this-object:type_commis:Leave:Subscribe(this-object:leave_type_commis).
      /*  */
      /* l_slip_name */
      /*  */
      this-object:l_slip_name:Font = new System.Drawing.Font("Microsoft Sans Serif", Progress.Util.CastUtil:ToSingle(9), System.Drawing.FontStyle:Italic, System.Drawing.GraphicsUnit:Point, System.Convert:ToByte(204)).
      this-object:l_slip_name:Location = new System.Drawing.Point(361, 148).
      this-object:l_slip_name:Name = "l_slip_name".
      this-object:l_slip_name:Size = new System.Drawing.Size(175, 23).
      this-object:l_slip_name:TabIndex = 39.
      this-object:l_slip_name:Text = "Имя файла конеч. слипа:".
      this-object:l_slip_name:UseCompatibleTextRendering = true.
      this-object:l_slip_name:Visible = false.
      /*  */
      /* label4 */
      /*  */
      this-object:label4:Font = new System.Drawing.Font("Microsoft Sans Serif", Progress.Util.CastUtil:ToSingle(9), System.Drawing.FontStyle:Italic, System.Drawing.GraphicsUnit:Point, System.Convert:ToByte(204)).
      this-object:label4:Location = new System.Drawing.Point(361, 82).
      this-object:label4:Name = "label4".
      this-object:label4:Size = new System.Drawing.Size(194, 23).
      this-object:label4:TabIndex = 35.
      this-object:label4:Text = "Комиссия:".
      this-object:label4:UseCompatibleTextRendering = true.
      /*  */
      /* slip_name */
      /*  */
      this-object:slip_name:DataBindings:Add(new System.Windows.Forms.Binding("Text", this-object:bindingBPA, "SlipName", true)).
      this-object:slip_name:Font = new System.Drawing.Font("Microsoft Sans Serif", Progress.Util.CastUtil:ToSingle(9), System.Drawing.FontStyle:Regular, System.Drawing.GraphicsUnit:Point, System.Convert:ToByte(204)).
      this-object:slip_name:Location = new System.Drawing.Point(551, 148).
      this-object:slip_name:Multiline = true.
      this-object:slip_name:Name = "slip_name".
      this-object:slip_name:Size = new System.Drawing.Size(199, 20).
      this-object:slip_name:TabIndex = 15.
      this-object:slip_name:Visible = false.
      /*  */
      /* summ_atent */
      /*  */
      this-object:summ_atent:DataBindings:Add(new System.Windows.Forms.Binding("Text", this-object:bindingBPA, "SummAtent", true)).
      this-object:summ_atent:Font = new System.Drawing.Font("Microsoft Sans Serif", Progress.Util.CastUtil:ToSingle(9), System.Drawing.FontStyle:Regular, System.Drawing.GraphicsUnit:Point, System.Convert:ToByte(204)).
      this-object:summ_atent:Location = new System.Drawing.Point(576, 52).
      this-object:summ_atent:Multiline = true.
      this-object:summ_atent:Name = "summ_atent".
      this-object:summ_atent:Size = new System.Drawing.Size(174, 20).
      this-object:summ_atent:TabIndex = 10.
      /*  */
      /* slip */
      /*  */
      this-object:slip:DataBindings:Add(new System.Windows.Forms.Binding("Checked", this-object:bindingBPA, "PreSlip", true)).
      this-object:slip:Location = new System.Drawing.Point(9, 148).
      this-object:slip:Name = "slip".
      this-object:slip:Size = new System.Drawing.Size(104, 24).
      this-object:slip:TabIndex = 14.
      this-object:slip:Text = "Печать слипа".
      this-object:slip:UseCompatibleTextRendering = true.
      this-object:slip:UseVisualStyleBackColor = true.
      this-object:slip:CheckedChanged:Subscribe(this-object:check_slip).
      /*  */
      /* label3 */
      /*  */
      this-object:label3:Font = new System.Drawing.Font("Microsoft Sans Serif", Progress.Util.CastUtil:ToSingle(9), System.Drawing.FontStyle:Italic, System.Drawing.GraphicsUnit:Point, System.Convert:ToByte(204)).
      this-object:label3:Location = new System.Drawing.Point(361, 52).
      this-object:label3:Name = "label3".
      this-object:label3:Size = new System.Drawing.Size(209, 23).
      this-object:label3:TabIndex = 27.
      this-object:label3:Text = "Порог сумм для предупреждений:".
      this-object:label3:UseCompatibleTextRendering = true.
      /*  */
      /* auth */
      /*  */
      this-object:auth:DataBindings:Add(new System.Windows.Forms.Binding("Checked", this-object:bindingBPA, "PreAAvt", true)).
      this-object:auth:Location = new System.Drawing.Point(9, 115).
      this-object:auth:Name = "auth".
      this-object:auth:Size = new System.Drawing.Size(104, 24).
      this-object:auth:TabIndex = 13.
      this-object:auth:Text = "Авторизация".
      this-object:auth:UseCompatibleTextRendering = true.
      this-object:auth:UseVisualStyleBackColor = true.
      this-object:auth:CheckedChanged:Subscribe(this-object:auth_CheckedChanged).
      /*  */
      /* label7 */
      /*  */
      this-object:label7:Font = new System.Drawing.Font("Microsoft Sans Serif", Progress.Util.CastUtil:ToSingle(9), System.Drawing.FontStyle:Italic, System.Drawing.GraphicsUnit:Point, System.Convert:ToByte(204)).
      this-object:label7:Location = new System.Drawing.Point(9, 52).
      this-object:label7:Name = "label7".
      this-object:label7:Size = new System.Drawing.Size(68, 23).
      this-object:label7:TabIndex = 46.
      this-object:label7:Text = "Сумма:".
      this-object:label7:UseCompatibleTextRendering = true.
      /*  */
      /* oss_abbr */
      /*  */
      this-object:oss_abbr:DataBindings:Add(new System.Windows.Forms.Binding("Text", this-object:bindingBPA, "OsNameAbbr", true)).
      this-object:oss_abbr:Font = new System.Drawing.Font("Microsoft Sans Serif", Progress.Util.CastUtil:ToSingle(9), System.Drawing.FontStyle:Regular, System.Drawing.GraphicsUnit:Point, System.Convert:ToByte(204)).
      this-object:oss_abbr:Location = new System.Drawing.Point(135, 19).
      this-object:oss_abbr:Multiline = true.
      this-object:oss_abbr:Name = "oss_abbr".
      this-object:oss_abbr:Size = new System.Drawing.Size(208, 20).
      this-object:oss_abbr:TabIndex = 5.
      /*  */
      /* label12 */
      /*  */
      this-object:label12:Font = new System.Drawing.Font("Microsoft Sans Serif", Progress.Util.CastUtil:ToSingle(9), System.Drawing.FontStyle:Italic, System.Drawing.GraphicsUnit:Point, System.Convert:ToByte(204)).
      this-object:label12:Location = new System.Drawing.Point(241, 52).
      this-object:label12:Name = "label12".
      this-object:label12:Size = new System.Drawing.Size(37, 23).
      this-object:label12:TabIndex = 58.
      this-object:label12:Text = "max:".
      this-object:label12:UseCompatibleTextRendering = true.
      /*  */
      /* label8 */
      /*  */
      this-object:label8:Font = new System.Drawing.Font("Microsoft Sans Serif", Progress.Util.CastUtil:ToSingle(9), System.Drawing.FontStyle:Italic, System.Drawing.GraphicsUnit:Point, System.Convert:ToByte(204)).
      this-object:label8:Location = new System.Drawing.Point(645, 19).
      this-object:label8:Name = "label8".
      this-object:label8:Size = new System.Drawing.Size(37, 23).
      this-object:label8:TabIndex = 44.
      this-object:label8:Text = "max:".
      this-object:label8:UseCompatibleTextRendering = true.
      /*  */
      /* label2 */
      /*  */
      this-object:label2:Font = new System.Drawing.Font("Microsoft Sans Serif", Progress.Util.CastUtil:ToSingle(9), System.Drawing.FontStyle:Italic, System.Drawing.GraphicsUnit:Point, System.Convert:ToByte(204)).
      this-object:label2:Location = new System.Drawing.Point(9, 19).
      this-object:label2:Name = "label2".
      this-object:label2:Size = new System.Drawing.Size(120, 23).
      this-object:label2:TabIndex = 21.
      this-object:label2:Text = "Аббр. оператора:".
      this-object:label2:UseCompatibleTextRendering = true.
      /*  */
      /* label11 */
      /*  */
      this-object:label11:Font = new System.Drawing.Font("Microsoft Sans Serif", Progress.Util.CastUtil:ToSingle(9), System.Drawing.FontStyle:Italic, System.Drawing.GraphicsUnit:Point, System.Convert:ToByte(204)).
      this-object:label11:Location = new System.Drawing.Point(135, 52).
      this-object:label11:Name = "label11".
      this-object:label11:Size = new System.Drawing.Size(30, 23).
      this-object:label11:TabIndex = 57.
      this-object:label11:Text = "min:".
      this-object:label11:UseCompatibleTextRendering = true.
      /*  */
      /* label1 */
      /*  */
      this-object:label1:Font = new System.Drawing.Font("Microsoft Sans Serif", Progress.Util.CastUtil:ToSingle(9), System.Drawing.FontStyle:Italic, System.Drawing.GraphicsUnit:Point, System.Convert:ToByte(204)).
      this-object:label1:Location = new System.Drawing.Point(9, 82).
      this-object:label1:Name = "label1".
      this-object:label1:Size = new System.Drawing.Size(133, 23).
      this-object:label1:TabIndex = 33.
      this-object:label1:Text = "Тип ввода комиссии:".
      this-object:label1:UseCompatibleTextRendering = true.
      /*  */
      /* label9 */
      /*  */
      this-object:label9:Font = new System.Drawing.Font("Microsoft Sans Serif", Progress.Util.CastUtil:ToSingle(9), System.Drawing.FontStyle:Italic, System.Drawing.GraphicsUnit:Point, System.Convert:ToByte(204)).
      this-object:label9:Location = new System.Drawing.Point(533, 19).
      this-object:label9:Name = "label9".
      this-object:label9:Size = new System.Drawing.Size(43, 23).
      this-object:label9:TabIndex = 43.
      this-object:label9:Text = "min:".
      this-object:label9:UseCompatibleTextRendering = true.
      /*  */
      /* max_summ */
      /*  */
      this-object:max_summ:DataBindings:Add(new System.Windows.Forms.Binding("Text", this-object:bindingBPA, "SummMax", true)).
      this-object:max_summ:Font = new System.Drawing.Font("Microsoft Sans Serif", Progress.Util.CastUtil:ToSingle(9), System.Drawing.FontStyle:Regular, System.Drawing.GraphicsUnit:Point, System.Convert:ToByte(204)).
      this-object:max_summ:Location = new System.Drawing.Point(281, 52).
      this-object:max_summ:Multiline = true.
      this-object:max_summ:Name = "max_summ".
      this-object:max_summ:Size = new System.Drawing.Size(62, 20).
      this-object:max_summ:TabIndex = 9.
      /*  */
      /* commis */
      /*  */
      this-object:commis:Font = new System.Drawing.Font("Microsoft Sans Serif", Progress.Util.CastUtil:ToSingle(9), System.Drawing.FontStyle:Regular, System.Drawing.GraphicsUnit:Point, System.Convert:ToByte(204)).
      this-object:commis:Location = new System.Drawing.Point(576, 82).
      this-object:commis:Multiline = true.
      this-object:commis:Name = "commis".
      this-object:commis:Size = new System.Drawing.Size(174, 20).
      this-object:commis:TabIndex = 12.
      this-object:commis:Leave:Subscribe(this-object:leave_summ_commis).
      /*  */
      /* max_tel */
      /*  */
      this-object:max_tel:DataBindings:Add(new System.Windows.Forms.Binding("Text", this-object:bindingBPA, "QuantMax", true)).
      this-object:max_tel:Font = new System.Drawing.Font("Microsoft Sans Serif", Progress.Util.CastUtil:ToSingle(9), System.Drawing.FontStyle:Regular, System.Drawing.GraphicsUnit:Point, System.Convert:ToByte(204)).
      this-object:max_tel:Location = new System.Drawing.Point(688, 19).
      this-object:max_tel:Multiline = true.
      this-object:max_tel:Name = "max_tel".
      this-object:max_tel:Size = new System.Drawing.Size(62, 20).
      this-object:max_tel:TabIndex = 7.
      this-object:max_tel:TextChanged:Subscribe(this-object:max_tel_TextChanged).
      /*  */
      /* label10 */
      /*  */
      this-object:label10:Font = new System.Drawing.Font("Microsoft Sans Serif", Progress.Util.CastUtil:ToSingle(9), System.Drawing.FontStyle:Italic, System.Drawing.GraphicsUnit:Point, System.Convert:ToByte(204)).
      this-object:label10:Location = new System.Drawing.Point(361, 19).
      this-object:label10:Name = "label10".
      this-object:label10:Size = new System.Drawing.Size(151, 23).
      this-object:label10:TabIndex = 23.
      this-object:label10:Text = "Кол-во цифр телефона:".
      this-object:label10:UseCompatibleTextRendering = true.
      /*  */
      /* min_summ */
      /*  */
      this-object:min_summ:AccessibleRole = System.Windows.Forms.AccessibleRole:None.
      this-object:min_summ:DataBindings:Add(new System.Windows.Forms.Binding("Text", this-object:bindingBPA, "SummMin", true)).
      this-object:min_summ:Font = new System.Drawing.Font("Microsoft Sans Serif", Progress.Util.CastUtil:ToSingle(9), System.Drawing.FontStyle:Regular, System.Drawing.GraphicsUnit:Point, System.Convert:ToByte(204)).
      this-object:min_summ:Location = new System.Drawing.Point(171, 52).
      this-object:min_summ:Multiline = true.
      this-object:min_summ:Name = "min_summ".
      this-object:min_summ:Size = new System.Drawing.Size(62, 20).
      this-object:min_summ:TabIndex = 8.
      /*  */
      /* min_tel */
      /*  */
      this-object:min_tel:DataBindings:Add(new System.Windows.Forms.Binding("Text", this-object:bindingBPA, "QuantMin", true)).
      this-object:min_tel:Font = new System.Drawing.Font("Microsoft Sans Serif", Progress.Util.CastUtil:ToSingle(9), System.Drawing.FontStyle:Regular, System.Drawing.GraphicsUnit:Point, System.Convert:ToByte(204)).
      this-object:min_tel:Location = new System.Drawing.Point(576, 19).
      this-object:min_tel:Multiline = true.
      this-object:min_tel:Name = "min_tel".
      this-object:min_tel:Size = new System.Drawing.Size(62, 20).
      this-object:min_tel:TabIndex = 6.
      /*  */
      /* type_ras */
      /*  */
      this-object:type_ras:DropDownStyle = System.Windows.Forms.ComboBoxStyle:DropDownList.
      this-object:type_ras:FormattingEnabled = true.
      @VisualDesigner.FormMember (NeedsInitialize="false", InitializeArray="true").
      define variable arrayvar3 as System.Object extent 3 no-undo.
      arrayvar3[1] = "Оплата Сотовой связи".
      arrayvar3[2] = "Начисление на карту".
      arrayvar3[3] = "Платежный агент".
      this-object:type_ras:Items:AddRange(arrayvar3).
      this-object:type_ras:Location = new System.Drawing.Point(497, 47).
      this-object:type_ras:Name = "type_ras".
      this-object:type_ras:Size = new System.Drawing.Size(274, 21).
      this-object:type_ras:TabIndex = 3.
      this-object:type_ras:SelectedIndexChanged:Subscribe(this-object:change_type_OperServRas).
      this-object:type_ras:TextChanged:Subscribe(this-object:change_type_OperServRas).
      this-object:type_ras:Leave:Subscribe(this-object:leave_CalcType).
      /*  */
      /* label6 */
      /*  */
      this-object:label6:Font = new System.Drawing.Font("Microsoft Sans Serif", Progress.Util.CastUtil:ToSingle(9), System.Drawing.FontStyle:Bold, System.Drawing.GraphicsUnit:Point, System.Convert:ToByte(204)).
      this-object:label6:Location = new System.Drawing.Point(394, 47).
      this-object:label6:Name = "label6".
      this-object:label6:Size = new System.Drawing.Size(86, 23).
      this-object:label6:TabIndex = 41.
      this-object:label6:Text = "Тип:".
      this-object:label6:UseCompatibleTextRendering = true.
      /*  */
      /* bpa_agent_tel */
      /*  */
      this-object:bpa_agent_tel:Font = new System.Drawing.Font("Microsoft Sans Serif", Progress.Util.CastUtil:ToSingle(9), System.Drawing.FontStyle:Italic, System.Drawing.GraphicsUnit:Point, System.Convert:ToByte(204)).
      this-object:bpa_agent_tel:Location = new System.Drawing.Point(9, 20).
      this-object:bpa_agent_tel:Name = "bpa_agent_tel".
      this-object:bpa_agent_tel:Size = new System.Drawing.Size(96, 23).
      this-object:bpa_agent_tel:TabIndex = 9.
      this-object:bpa_agent_tel:Text = "Телефон:".
      this-object:bpa_agent_tel:UseCompatibleTextRendering = true.
      this-object:bpa_agent_tel:Click:Subscribe(this-object:label5_Click).
      /*  */
      /* bpa_agent */
      /*  */
      this-object:bpa_agent:Controls:Add(this-object:c_bpa_AgentFlagRas).
      this-object:bpa_agent:Controls:Add(this-object:bpa_flag_agent_ras).
      this-object:bpa_agent:Controls:Add(this-object:c_bpa_AgentFlag).
      this-object:bpa_agent:Controls:Add(this-object:bpa_falg_agent).
      this-object:bpa_agent:Controls:Add(this-object:f_bpa_agent_oper).
      this-object:bpa_agent:Controls:Add(this-object:bpa_agent_oper).
      this-object:bpa_agent:Controls:Add(this-object:f_bpa_agent_teloper).
      this-object:bpa_agent:Controls:Add(this-object:bpa_agent_teloper).
      this-object:bpa_agent:Controls:Add(this-object:f_bpa_agent_tel).
      this-object:bpa_agent:Controls:Add(this-object:bpa_agent_tel).
      this-object:bpa_agent:Font = new System.Drawing.Font("Microsoft Sans Serif", Progress.Util.CastUtil:ToSingle(9), System.Drawing.FontStyle:Bold, System.Drawing.GraphicsUnit:Point, System.Convert:ToByte(204)).
      this-object:bpa_agent:Location = new System.Drawing.Point(12, 232).
      this-object:bpa_agent:Name = "bpa_agent".
      this-object:bpa_agent:Size = new System.Drawing.Size(760, 130).
      this-object:bpa_agent:TabIndex = 12.
      this-object:bpa_agent:TabStop = false.
      this-object:bpa_agent:Text = "Платежный агент".
      this-object:bpa_agent:UseCompatibleTextRendering = true.
      this-object:bpa_agent:Visible = false.
      /*  */
      /* c_bpa_AgentFlagRas */
      /*  */
      this-object:c_bpa_AgentFlagRas:DropDownStyle = System.Windows.Forms.ComboBoxStyle:DropDownList.
      this-object:c_bpa_AgentFlagRas:Font = new System.Drawing.Font("Microsoft Sans Serif", Progress.Util.CastUtil:ToSingle(9), System.Drawing.FontStyle:Regular, System.Drawing.GraphicsUnit:Point, System.Convert:ToByte(204)).
      this-object:c_bpa_AgentFlagRas:FormattingEnabled = true.
      @VisualDesigner.FormMember (NeedsInitialize="false", InitializeArray="true").
      define variable arrayvar4 as System.Object extent 7 no-undo.
      arrayvar4[1] = "Банковский платежный агент".
      arrayvar4[2] = "Банковский платежный субагент".
      arrayvar4[3] = "Платежный агент".
      arrayvar4[4] = "Платежный субагент".
      arrayvar4[5] = "Поверенный пользователь".
      arrayvar4[6] = "Комиссионер".
      arrayvar4[7] = "Агент, не явл. никем из перечисленных".
      this-object:c_bpa_AgentFlagRas:Items:AddRange(arrayvar4).
      this-object:c_bpa_AgentFlagRas:Location = new System.Drawing.Point(497, 49).
      this-object:c_bpa_AgentFlagRas:Name = "c_bpa_AgentFlagRas".
      this-object:c_bpa_AgentFlagRas:Size = new System.Drawing.Size(257, 23).
      this-object:c_bpa_AgentFlagRas:TabIndex = 22.
      this-object:c_bpa_AgentFlagRas:Leave:Subscribe(this-object:leave_AgentFlag_Ras).
      /*  */
      /* bpa_flag_agent_ras */
      /*  */
      this-object:bpa_flag_agent_ras:Font = new System.Drawing.Font("Microsoft Sans Serif", Progress.Util.CastUtil:ToSingle(9), System.Drawing.FontStyle:Italic, System.Drawing.GraphicsUnit:Point, System.Convert:ToByte(204)).
      this-object:bpa_flag_agent_ras:Location = new System.Drawing.Point(352, 46).
      this-object:bpa_flag_agent_ras:Name = "bpa_flag_agent_ras".
      this-object:bpa_flag_agent_ras:Size = new System.Drawing.Size(161, 35).
      this-object:bpa_flag_agent_ras:TabIndex = 21.
      this-object:bpa_flag_agent_ras:Text = "Агент по предмету расчета:".
      this-object:bpa_flag_agent_ras:UseCompatibleTextRendering = true.
      /*  */
      /* c_bpa_AgentFlag */
      /*  */
      this-object:c_bpa_AgentFlag:DropDownStyle = System.Windows.Forms.ComboBoxStyle:DropDownList.
      this-object:c_bpa_AgentFlag:Font = new System.Drawing.Font("Microsoft Sans Serif", Progress.Util.CastUtil:ToSingle(9), System.Drawing.FontStyle:Regular, System.Drawing.GraphicsUnit:Point, System.Convert:ToByte(204)).
      this-object:c_bpa_AgentFlag:FormattingEnabled = true.
      @VisualDesigner.FormMember (NeedsInitialize="false", InitializeArray="true").
      define variable arrayvar5 as System.Object extent 7 no-undo.
      arrayvar5[1] = "Банковский платежный агент".
      arrayvar5[2] = "Банковский платежный субагент".
      arrayvar5[3] = "Платежный агент".
      arrayvar5[4] = "Платежный субагент".
      arrayvar5[5] = "Поверенный пользователь".
      arrayvar5[6] = "Комиссионер".
      arrayvar5[7] = "Агент, не явл. никем из перечисленных".
      this-object:c_bpa_AgentFlag:Items:AddRange(arrayvar5).
      this-object:c_bpa_AgentFlag:Location = new System.Drawing.Point(111, 49).
      this-object:c_bpa_AgentFlag:Name = "c_bpa_AgentFlag".
      this-object:c_bpa_AgentFlag:Size = new System.Drawing.Size(234, 23).
      this-object:c_bpa_AgentFlag:TabIndex = 21.
      this-object:c_bpa_AgentFlag:Leave:Subscribe(this-object:leave_AgentFlag).
      /*  */
      /* bpa_falg_agent */
      /*  */
      this-object:bpa_falg_agent:Font = new System.Drawing.Font("Microsoft Sans Serif", Progress.Util.CastUtil:ToSingle(9), System.Drawing.FontStyle:Italic, System.Drawing.GraphicsUnit:Point, System.Convert:ToByte(204)).
      this-object:bpa_falg_agent:Location = new System.Drawing.Point(9, 49).
      this-object:bpa_falg_agent:Name = "bpa_falg_agent".
      this-object:bpa_falg_agent:Size = new System.Drawing.Size(101, 23).
      this-object:bpa_falg_agent:TabIndex = 19.
      this-object:bpa_falg_agent:Text = "Признак агента:".
      this-object:bpa_falg_agent:UseCompatibleTextRendering = true.
      this-object:bpa_falg_agent:Click:Subscribe(this-object:label1_Click_1).
      /*  */
      /* f_bpa_agent_oper */
      /*  */
      this-object:f_bpa_agent_oper:DataBindings:Add(new System.Windows.Forms.Binding("Text", this-object:bindingBPA, "AgentOpere", true)).
      this-object:f_bpa_agent_oper:Font = new System.Drawing.Font("Microsoft Sans Serif", Progress.Util.CastUtil:ToSingle(9), System.Drawing.FontStyle:Regular, System.Drawing.GraphicsUnit:Point, System.Convert:ToByte(204)).
      this-object:f_bpa_agent_oper:Location = new System.Drawing.Point(210, 91).
      this-object:f_bpa_agent_oper:Multiline = true.
      this-object:f_bpa_agent_oper:Name = "f_bpa_agent_oper".
      this-object:f_bpa_agent_oper:Size = new System.Drawing.Size(282, 20).
      this-object:f_bpa_agent_oper:TabIndex = 23.
      /*  */
      /* bpa_agent_oper */
      /*  */
      this-object:bpa_agent_oper:Font = new System.Drawing.Font("Microsoft Sans Serif", Progress.Util.CastUtil:ToSingle(9), System.Drawing.FontStyle:Italic, System.Drawing.GraphicsUnit:Point, System.Convert:ToByte(204)).
      this-object:bpa_agent_oper:Location = new System.Drawing.Point(9, 91).
      this-object:bpa_agent_oper:Name = "bpa_agent_oper".
      this-object:bpa_agent_oper:Size = new System.Drawing.Size(196, 23).
      this-object:bpa_agent_oper:TabIndex = 13.
      this-object:bpa_agent_oper:Text = "Операция платежного агента:".
      this-object:bpa_agent_oper:UseCompatibleTextRendering = true.
      this-object:bpa_agent_oper:Click:Subscribe(this-object:label9_Click).
      /*  */
      /* f_bpa_agent_teloper */
      /*  */
      this-object:f_bpa_agent_teloper:DataBindings:Add(new System.Windows.Forms.Binding("Text", this-object:bindingBPA, "OperTel", true)).
      this-object:f_bpa_agent_teloper:Font = new System.Drawing.Font("Microsoft Sans Serif", Progress.Util.CastUtil:ToSingle(9), System.Drawing.FontStyle:Italic, System.Drawing.GraphicsUnit:Point, System.Convert:ToByte(204)).
      this-object:f_bpa_agent_teloper:Location = new System.Drawing.Point(497, 20).
      this-object:f_bpa_agent_teloper:Multiline = true.
      this-object:f_bpa_agent_teloper:Name = "f_bpa_agent_teloper".
      this-object:f_bpa_agent_teloper:Size = new System.Drawing.Size(257, 20).
      this-object:f_bpa_agent_teloper:TabIndex = 20.
      /*  */
      /* bpa_agent_teloper */
      /*  */
      this-object:bpa_agent_teloper:Font = new System.Drawing.Font("Microsoft Sans Serif", Progress.Util.CastUtil:ToSingle(9), System.Drawing.FontStyle:Italic, System.Drawing.GraphicsUnit:Point, System.Convert:ToByte(204)).
      this-object:bpa_agent_teloper:Location = new System.Drawing.Point(352, 12).
      this-object:bpa_agent_teloper:Name = "bpa_agent_teloper".
      this-object:bpa_agent_teloper:Size = new System.Drawing.Size(151, 35).
      this-object:bpa_agent_teloper:TabIndex = 11.
      this-object:bpa_agent_teloper:Text = "Телефон оператора по приему платежей:".
      this-object:bpa_agent_teloper:UseCompatibleTextRendering = true.
      /*  */
      /* f_bpa_agent_tel */
      /*  */
      this-object:f_bpa_agent_tel:DataBindings:Add(new System.Windows.Forms.Binding("Text", this-object:bindingBPA, "AgentTel", true)).
      this-object:f_bpa_agent_tel:Font = new System.Drawing.Font("Microsoft Sans Serif", Progress.Util.CastUtil:ToSingle(9), System.Drawing.FontStyle:Italic, System.Drawing.GraphicsUnit:Point, System.Convert:ToByte(204)).
      this-object:f_bpa_agent_tel:Location = new System.Drawing.Point(111, 20).
      this-object:f_bpa_agent_tel:Multiline = true.
      this-object:f_bpa_agent_tel:Name = "f_bpa_agent_tel".
      this-object:f_bpa_agent_tel:Size = new System.Drawing.Size(234, 20).
      this-object:f_bpa_agent_tel:TabIndex = 19.
      /*  */
      /* bpa_prod */
      /*  */
      this-object:bpa_prod:Controls:Add(this-object:f_bpa_prod_tel).
      this-object:bpa_prod:Controls:Add(this-object:bpa_prod_tel).
      this-object:bpa_prod:Controls:Add(this-object:f_bpa_prod_name).
      this-object:bpa_prod:Controls:Add(this-object:bpa_prod_name).
      this-object:bpa_prod:Controls:Add(this-object:f_bpa_prod_inn).
      this-object:bpa_prod:Controls:Add(this-object:bpa_prod_inn).
      this-object:bpa_prod:Font = new System.Drawing.Font("Microsoft Sans Serif", Progress.Util.CastUtil:ToSingle(9), System.Drawing.FontStyle:Bold, System.Drawing.GraphicsUnit:Point, System.Convert:ToByte(204)).
      this-object:bpa_prod:Location = new System.Drawing.Point(12, 368).
      this-object:bpa_prod:Name = "bpa_prod".
      this-object:bpa_prod:Size = new System.Drawing.Size(760, 90).
      this-object:bpa_prod:TabIndex = 12.
      this-object:bpa_prod:TabStop = false.
      this-object:bpa_prod:Text = "Поставщик".
      this-object:bpa_prod:UseCompatibleTextRendering = true.
      this-object:bpa_prod:Visible = false.
      /*  */
      /* f_bpa_prod_tel */
      /*  */
      this-object:f_bpa_prod_tel:DataBindings:Add(new System.Windows.Forms.Binding("Text", this-object:bindingBPA, "SuppTel", true)).
      this-object:f_bpa_prod_tel:Font = new System.Drawing.Font("Microsoft Sans Serif", Progress.Util.CastUtil:ToSingle(9), System.Drawing.FontStyle:Regular, System.Drawing.GraphicsUnit:Point, System.Convert:ToByte(204)).
      this-object:f_bpa_prod_tel:Location = new System.Drawing.Point(111, 50).
      this-object:f_bpa_prod_tel:Multiline = true.
      this-object:f_bpa_prod_tel:Name = "f_bpa_prod_tel".
      this-object:f_bpa_prod_tel:Size = new System.Drawing.Size(234, 20).
      this-object:f_bpa_prod_tel:TabIndex = 25.
      /*  */
      /* bpa_prod_tel */
      /*  */
      this-object:bpa_prod_tel:Font = new System.Drawing.Font("Microsoft Sans Serif", Progress.Util.CastUtil:ToSingle(9), System.Drawing.FontStyle:Italic, System.Drawing.GraphicsUnit:Point, System.Convert:ToByte(204)).
      this-object:bpa_prod_tel:Location = new System.Drawing.Point(9, 50).
      this-object:bpa_prod_tel:Name = "bpa_prod_tel".
      this-object:bpa_prod_tel:Size = new System.Drawing.Size(96, 23).
      this-object:bpa_prod_tel:TabIndex = 11.
      this-object:bpa_prod_tel:Text = "Телефон:".
      this-object:bpa_prod_tel:UseCompatibleTextRendering = true.
      /*  */
      /* f_bpa_prod_name */
      /*  */
      this-object:f_bpa_prod_name:DataBindings:Add(new System.Windows.Forms.Binding("Text", this-object:bindingBPA, "SuppName", true)).
      this-object:f_bpa_prod_name:Font = new System.Drawing.Font("Microsoft Sans Serif", Progress.Util.CastUtil:ToSingle(9), System.Drawing.FontStyle:Regular, System.Drawing.GraphicsUnit:Point, System.Convert:ToByte(204)).
      this-object:f_bpa_prod_name:Location = new System.Drawing.Point(111, 20).
      this-object:f_bpa_prod_name:Multiline = true.
      this-object:f_bpa_prod_name:Name = "f_bpa_prod_name".
      this-object:f_bpa_prod_name:Size = new System.Drawing.Size(643, 20).
      this-object:f_bpa_prod_name:TabIndex = 24.
      /*  */
      /* bpa_prod_name */
      /*  */
      this-object:bpa_prod_name:Font = new System.Drawing.Font("Microsoft Sans Serif", Progress.Util.CastUtil:ToSingle(9), System.Drawing.FontStyle:Italic, System.Drawing.GraphicsUnit:Point, System.Convert:ToByte(204)).
      this-object:bpa_prod_name:Location = new System.Drawing.Point(9, 20).
      this-object:bpa_prod_name:Name = "bpa_prod_name".
      this-object:bpa_prod_name:Size = new System.Drawing.Size(96, 23).
      this-object:bpa_prod_name:TabIndex = 9.
      this-object:bpa_prod_name:Text = "Наименование:".
      this-object:bpa_prod_name:UseCompatibleTextRendering = true.
      /*  */
      /* f_bpa_prod_inn */
      /*  */
      this-object:f_bpa_prod_inn:DataBindings:Add(new System.Windows.Forms.Binding("Text", this-object:bindingBPA, "InnSupp", true)).
      this-object:f_bpa_prod_inn:Font = new System.Drawing.Font("Microsoft Sans Serif", Progress.Util.CastUtil:ToSingle(9), System.Drawing.FontStyle:Regular, System.Drawing.GraphicsUnit:Point, System.Convert:ToByte(204)).
      this-object:f_bpa_prod_inn:Location = new System.Drawing.Point(431, 50).
      this-object:f_bpa_prod_inn:Multiline = true.
      this-object:f_bpa_prod_inn:Name = "f_bpa_prod_inn".
      this-object:f_bpa_prod_inn:Size = new System.Drawing.Size(323, 20).
      this-object:f_bpa_prod_inn:TabIndex = 26.
      /*  */
      /* bpa_prod_inn */
      /*  */
      this-object:bpa_prod_inn:Font = new System.Drawing.Font("Microsoft Sans Serif", Progress.Util.CastUtil:ToSingle(9), System.Drawing.FontStyle:Italic, System.Drawing.GraphicsUnit:Point, System.Convert:ToByte(204)).
      this-object:bpa_prod_inn:Location = new System.Drawing.Point(382, 50).
      this-object:bpa_prod_inn:Name = "bpa_prod_inn".
      this-object:bpa_prod_inn:Size = new System.Drawing.Size(44, 23).
      this-object:bpa_prod_inn:TabIndex = 7.
      this-object:bpa_prod_inn:Text = "ИНН:".
      this-object:bpa_prod_inn:UseCompatibleTextRendering = true.
      this-object:bpa_prod_inn:Click:Subscribe(this-object:bpa_prod_inn_Click).
      /*  */
      /* bpa_groupBox3 */
      /*  */
      this-object:bpa_groupBox3:Controls:Add(this-object:b_commis1).
      this-object:bpa_groupBox3:Controls:Add(this-object:label5).
      this-object:bpa_groupBox3:Controls:Add(this-object:commis_gds1).
      this-object:bpa_groupBox3:Controls:Add(this-object:bpa_max_summ).
      this-object:bpa_groupBox3:Controls:Add(this-object:f_type_commis).
      this-object:bpa_groupBox3:Controls:Add(this-object:bpa_min_summ).
      this-object:bpa_groupBox3:Controls:Add(this-object:f_commis).
      this-object:bpa_groupBox3:Controls:Add(this-object:f_max_sum).
      this-object:bpa_groupBox3:Controls:Add(this-object:bpa_commis).
      this-object:bpa_groupBox3:Controls:Add(this-object:f_min_sum).
      this-object:bpa_groupBox3:Controls:Add(this-object:f_limit_sum).
      this-object:bpa_groupBox3:Controls:Add(this-object:bpa_sum).
      this-object:bpa_groupBox3:Controls:Add(this-object:bpa_limit_sum).
      this-object:bpa_groupBox3:Controls:Add(this-object:bpa_type_commis).
      this-object:bpa_groupBox3:Font = new System.Drawing.Font("Microsoft Sans Serif", Progress.Util.CastUtil:ToSingle(9), System.Drawing.FontStyle:Bold, System.Drawing.GraphicsUnit:Point, System.Convert:ToByte(204)).
      this-object:bpa_groupBox3:Location = new System.Drawing.Point(13, 461).
      this-object:bpa_groupBox3:Name = "bpa_groupBox3".
      this-object:bpa_groupBox3:Size = new System.Drawing.Size(393, 171).
      this-object:bpa_groupBox3:TabIndex = 14.
      this-object:bpa_groupBox3:TabStop = false.
      this-object:bpa_groupBox3:UseCompatibleTextRendering = true.
      this-object:bpa_groupBox3:Visible = false.
      /*  */
      /* b_commis1 */
      /*  */
      this-object:b_commis1:Location = new System.Drawing.Point(363, 144).
      this-object:b_commis1:Name = "b_commis1".
      this-object:b_commis1:Size = new System.Drawing.Size(19, 20).
      this-object:b_commis1:TabIndex = 75.
      this-object:b_commis1:TextImageRelation = System.Windows.Forms.TextImageRelation:ImageBeforeText.
      this-object:b_commis1:UseCompatibleTextRendering = true.
      this-object:b_commis1:UseVisualStyleBackColor = true.
      this-object:b_commis1:Click:Subscribe(this-object:choose_commis_gds).
      /*  */
      /* label5 */
      /*  */
      this-object:label5:Font = new System.Drawing.Font("Microsoft Sans Serif", Progress.Util.CastUtil:ToSingle(9), System.Drawing.FontStyle:Italic, System.Drawing.GraphicsUnit:Point, System.Convert:ToByte(204)).
      this-object:label5:Location = new System.Drawing.Point(10, 141).
      this-object:label5:Name = "label5".
      this-object:label5:Size = new System.Drawing.Size(125, 23).
      this-object:label5:TabIndex = 74.
      this-object:label5:Text = "Комиссия-товар:".
      this-object:label5:UseCompatibleTextRendering = true.
      /*  */
      /* commis_gds1 */
      /*  */
      this-object:commis_gds1:DataBindings:Add(new System.Windows.Forms.Binding("Text", this-object:bindingBPA, "gds-code", true)).
      this-object:commis_gds1:Font = new System.Drawing.Font("Microsoft Sans Serif", Progress.Util.CastUtil:ToSingle(9), System.Drawing.FontStyle:Regular, System.Drawing.GraphicsUnit:Point, System.Convert:ToByte(204)).
      this-object:commis_gds1:Location = new System.Drawing.Point(141, 144).
      this-object:commis_gds1:Multiline = true.
      this-object:commis_gds1:Name = "commis_gds1".
      this-object:commis_gds1:ReadOnly = true.
      this-object:commis_gds1:Size = new System.Drawing.Size(216, 20).
      this-object:commis_gds1:TabIndex = 73.
      this-object:commis_gds1:TextChanged:Subscribe(this-object:commis_gds1_TextChanged).
      /*  */
      /* bpa_max_summ */
      /*  */
      this-object:bpa_max_summ:Font = new System.Drawing.Font("Microsoft Sans Serif", Progress.Util.CastUtil:ToSingle(9), System.Drawing.FontStyle:Italic, System.Drawing.GraphicsUnit:Point, System.Convert:ToByte(204)).
      this-object:bpa_max_summ:Location = new System.Drawing.Point(276, 20).
      this-object:bpa_max_summ:Name = "bpa_max_summ".
      this-object:bpa_max_summ:Size = new System.Drawing.Size(37, 23).
      this-object:bpa_max_summ:TabIndex = 72.
      this-object:bpa_max_summ:Text = "max:".
      this-object:bpa_max_summ:UseCompatibleTextRendering = true.
      /*  */
      /* f_type_commis */
      /*  */
      this-object:f_type_commis:DropDownStyle = System.Windows.Forms.ComboBoxStyle:DropDownList.
      this-object:f_type_commis:Font = new System.Drawing.Font("Microsoft Sans Serif", Progress.Util.CastUtil:ToSingle(9), System.Drawing.FontStyle:Regular, System.Drawing.GraphicsUnit:Point, System.Convert:ToByte(204)).
      this-object:f_type_commis:FormattingEnabled = true.
      @VisualDesigner.FormMember (NeedsInitialize="false", InitializeArray="true").
      define variable arrayvar6 as System.Object extent 2 no-undo.
      arrayvar6[1] = "Процент".
      arrayvar6[2] = "Сумма".
      this-object:f_type_commis:Items:AddRange(arrayvar6).
      this-object:f_type_commis:Location = new System.Drawing.Point(141, 83).
      this-object:f_type_commis:Name = "f_type_commis".
      this-object:f_type_commis:Size = new System.Drawing.Size(240, 23).
      this-object:f_type_commis:TabIndex = 30.
      this-object:f_type_commis:Leave:Subscribe(this-object:leave_type_commis_bpa).
      /*  */
      /* bpa_min_summ */
      /*  */
      this-object:bpa_min_summ:Font = new System.Drawing.Font("Microsoft Sans Serif", Progress.Util.CastUtil:ToSingle(9), System.Drawing.FontStyle:Italic, System.Drawing.GraphicsUnit:Point, System.Convert:ToByte(204)).
      this-object:bpa_min_summ:Location = new System.Drawing.Point(141, 20).
      this-object:bpa_min_summ:Name = "bpa_min_summ".
      this-object:bpa_min_summ:Size = new System.Drawing.Size(32, 23).
      this-object:bpa_min_summ:TabIndex = 71.
      this-object:bpa_min_summ:Text = "min:".
      this-object:bpa_min_summ:UseCompatibleTextRendering = true.
      /*  */
      /* f_commis */
      /*  */
      this-object:f_commis:Font = new System.Drawing.Font("Microsoft Sans Serif", Progress.Util.CastUtil:ToSingle(9), System.Drawing.FontStyle:Regular, System.Drawing.GraphicsUnit:Point, System.Convert:ToByte(204)).
      this-object:f_commis:Location = new System.Drawing.Point(141, 115).
      this-object:f_commis:Multiline = true.
      this-object:f_commis:Name = "f_commis".
      this-object:f_commis:Size = new System.Drawing.Size(240, 20).
      this-object:f_commis:TabIndex = 31.
      this-object:f_commis:Leave:Subscribe(this-object:leave_summ_commis_bpa).
      /*  */
      /* f_max_sum */
      /*  */
      this-object:f_max_sum:DataBindings:Add(new System.Windows.Forms.Binding("Text", this-object:bindingBPA, "SummMax", true)).
      this-object:f_max_sum:Font = new System.Drawing.Font("Microsoft Sans Serif", Progress.Util.CastUtil:ToSingle(9), System.Drawing.FontStyle:Regular, System.Drawing.GraphicsUnit:Point, System.Convert:ToByte(204)).
      this-object:f_max_sum:Location = new System.Drawing.Point(319, 20).
      this-object:f_max_sum:Multiline = true.
      this-object:f_max_sum:Name = "f_max_sum".
      this-object:f_max_sum:Size = new System.Drawing.Size(62, 20).
      this-object:f_max_sum:TabIndex = 28.
      /*  */
      /* bpa_commis */
      /*  */
      this-object:bpa_commis:Font = new System.Drawing.Font("Microsoft Sans Serif", Progress.Util.CastUtil:ToSingle(9), System.Drawing.FontStyle:Italic, System.Drawing.GraphicsUnit:Point, System.Convert:ToByte(204)).
      this-object:bpa_commis:Location = new System.Drawing.Point(9, 115).
      this-object:bpa_commis:Name = "bpa_commis".
      this-object:bpa_commis:Size = new System.Drawing.Size(123, 23).
      this-object:bpa_commis:TabIndex = 13.
      this-object:bpa_commis:Text = "Комиссия:".
      this-object:bpa_commis:UseCompatibleTextRendering = true.
      /*  */
      /* f_min_sum */
      /*  */
      this-object:f_min_sum:AccessibleRole = System.Windows.Forms.AccessibleRole:None.
      this-object:f_min_sum:DataBindings:Add(new System.Windows.Forms.Binding("Text", this-object:bindingBPA, "SummMin", true)).
      this-object:f_min_sum:Font = new System.Drawing.Font("Microsoft Sans Serif", Progress.Util.CastUtil:ToSingle(9), System.Drawing.FontStyle:Regular, System.Drawing.GraphicsUnit:Point, System.Convert:ToByte(204)).
      this-object:f_min_sum:Location = new System.Drawing.Point(179, 20).
      this-object:f_min_sum:Multiline = true.
      this-object:f_min_sum:Name = "f_min_sum".
      this-object:f_min_sum:Size = new System.Drawing.Size(62, 20).
      this-object:f_min_sum:TabIndex = 27.
      /*  */
      /* f_limit_sum */
      /*  */
      this-object:f_limit_sum:DataBindings:Add(new System.Windows.Forms.Binding("Text", this-object:bindingBPA, "SummAtent", true)).
      this-object:f_limit_sum:Font = new System.Drawing.Font("Microsoft Sans Serif", Progress.Util.CastUtil:ToSingle(9), System.Drawing.FontStyle:Regular, System.Drawing.GraphicsUnit:Point, System.Convert:ToByte(204)).
      this-object:f_limit_sum:Location = new System.Drawing.Point(141, 52).
      this-object:f_limit_sum:Multiline = true.
      this-object:f_limit_sum:Name = "f_limit_sum".
      this-object:f_limit_sum:Size = new System.Drawing.Size(240, 20).
      this-object:f_limit_sum:TabIndex = 29.
      /*  */
      /* bpa_sum */
      /*  */
      this-object:bpa_sum:Font = new System.Drawing.Font("Microsoft Sans Serif", Progress.Util.CastUtil:ToSingle(9), System.Drawing.FontStyle:Italic, System.Drawing.GraphicsUnit:Point, System.Convert:ToByte(204)).
      this-object:bpa_sum:Location = new System.Drawing.Point(9, 17).
      this-object:bpa_sum:Name = "bpa_sum".
      this-object:bpa_sum:Size = new System.Drawing.Size(151, 23).
      this-object:bpa_sum:TabIndex = 70.
      this-object:bpa_sum:Text = "Сумма:".
      this-object:bpa_sum:UseCompatibleTextRendering = true.
      /*  */
      /* bpa_limit_sum */
      /*  */
      this-object:bpa_limit_sum:Font = new System.Drawing.Font("Microsoft Sans Serif", Progress.Util.CastUtil:ToSingle(9), System.Drawing.FontStyle:Italic, System.Drawing.GraphicsUnit:Point, System.Convert:ToByte(204)).
      this-object:bpa_limit_sum:Location = new System.Drawing.Point(9, 43).
      this-object:bpa_limit_sum:Name = "bpa_limit_sum".
      this-object:bpa_limit_sum:Size = new System.Drawing.Size(126, 32).
      this-object:bpa_limit_sum:TabIndex = 5.
      this-object:bpa_limit_sum:Text = "Порог сумм для предупреждения:".
      this-object:bpa_limit_sum:UseCompatibleTextRendering = true.
      /*  */
      /* bpa_type_commis */
      /*  */
      this-object:bpa_type_commis:Font = new System.Drawing.Font("Microsoft Sans Serif", Progress.Util.CastUtil:ToSingle(9), System.Drawing.FontStyle:Italic, System.Drawing.GraphicsUnit:Point, System.Convert:ToByte(204)).
      this-object:bpa_type_commis:Location = new System.Drawing.Point(9, 83).
      this-object:bpa_type_commis:Name = "bpa_type_commis".
      this-object:bpa_type_commis:Size = new System.Drawing.Size(126, 23).
      this-object:bpa_type_commis:TabIndex = 7.
      this-object:bpa_type_commis:Text = "Тип ввода комиссии:".
      this-object:bpa_type_commis:UseCompatibleTextRendering = true.
      /*  */
      /* b_cancel */
      /*  */
      this-object:b_cancel:Location = new System.Drawing.Point(88, 12).
      this-object:b_cancel:Name = "b_cancel".
      this-object:b_cancel:Size = new System.Drawing.Size(75, 23).
      this-object:b_cancel:TabIndex = 64.
      this-object:b_cancel:Text = "Отмена".
      this-object:b_cancel:UseCompatibleTextRendering = true.
      this-object:b_cancel:UseVisualStyleBackColor = true.
      this-object:b_cancel:Click:Subscribe(this-object:b_click_cancel).
      /*  */
      /* b_exit */
      /*  */
      this-object:b_exit:Location = new System.Drawing.Point(12, 12).
      this-object:b_exit:Name = "b_exit".
      this-object:b_exit:Size = new System.Drawing.Size(75, 23).
      this-object:b_exit:TabIndex = 63.
      this-object:b_exit:Text = "Ввод".
      this-object:b_exit:UseCompatibleTextRendering = true.
      this-object:b_exit:UseMnemonic = false.
      this-object:b_exit:UseVisualStyleBackColor = true.
      this-object:b_exit:Click:Subscribe(this-object:b_click_exit).
      /*  */
      /* type_OperServ */
      /*  */
      this-object:type_OperServ:DropDownStyle = System.Windows.Forms.ComboBoxStyle:DropDownList.
      this-object:type_OperServ:FormattingEnabled = true.
      @VisualDesigner.FormMember (NeedsInitialize="false", InitializeArray="true").
      define variable arrayvar7 as System.Object extent 1 no-undo.
      arrayvar7[1] = "ОСС (OpenWay)".
      this-object:type_OperServ:Items:AddRange(arrayvar7).
      this-object:type_OperServ:Location = new System.Drawing.Point(497, 78).
      this-object:type_OperServ:Name = "type_OperServ".
      this-object:type_OperServ:Size = new System.Drawing.Size(274, 21).
      this-object:type_OperServ:TabIndex = 4.
      this-object:type_OperServ:Visible = false.
      this-object:type_OperServ:SelectedIndexChanged:Subscribe(this-object:change_type_OperServ).
      this-object:type_OperServ:TextChanged:Subscribe(this-object:change_type_OperServ).
      this-object:type_OperServ:Leave:Subscribe(this-object:leave_type_OperServ).
      /*  */
      /* type_OperServ1 */
      /*  */
      this-object:type_OperServ1:DropDownStyle = System.Windows.Forms.ComboBoxStyle:DropDownList.
      this-object:type_OperServ1:FormattingEnabled = true.
      @VisualDesigner.FormMember (NeedsInitialize="false", InitializeArray="true").
      define variable arrayvar8 as System.Object extent 3 no-undo.
      arrayvar8[1] = "".
      arrayvar8[2] = "Автопомощь".
      arrayvar8[3] = "Выдача наличных".
      this-object:type_OperServ1:Items:AddRange(arrayvar8).
      this-object:type_OperServ1:Location = new System.Drawing.Point(497, 78).
      this-object:type_OperServ1:Name = "type_OperServ1".
      this-object:type_OperServ1:Size = new System.Drawing.Size(274, 21).
      this-object:type_OperServ1:TabIndex = 4.
      this-object:type_OperServ1:Visible = false.
      this-object:type_OperServ1:TextChanged:Subscribe(this-object:change_type_OperServ).
      this-object:type_OperServ1:Leave:Subscribe(this-object:leave_type_OperServ1).
      /*  */
      /* type_OperServ2 */
      /*  */
      this-object:type_OperServ2:DropDownStyle = System.Windows.Forms.ComboBoxStyle:DropDownList.
      this-object:type_OperServ2:FormattingEnabled = true.
      @VisualDesigner.FormMember (NeedsInitialize="false", InitializeArray="true").
      define variable arrayvar9 as System.Object extent 1 no-undo.
      arrayvar9[1] = "Пополнение ВБРР".
      this-object:type_OperServ2:Items:AddRange(arrayvar9).
      this-object:type_OperServ2:Location = new System.Drawing.Point(497, 78).
      this-object:type_OperServ2:Name = "type_OperServ2".
      this-object:type_OperServ2:Size = new System.Drawing.Size(274, 21).
      this-object:type_OperServ2:TabIndex = 4.
      this-object:type_OperServ2:Visible = false.
      this-object:type_OperServ2:TextChanged:Subscribe(this-object:change_type_OperServ).
      this-object:type_OperServ2:Leave:Subscribe(this-object:leave_type_OperServ2).
      /*  */
      /* type */
      /*  */
      this-object:type:Font = new System.Drawing.Font("Microsoft Sans Serif", Progress.Util.CastUtil:ToSingle(9), System.Drawing.FontStyle:Bold, System.Drawing.GraphicsUnit:Point, System.Convert:ToByte(204)).
      this-object:type:Location = new System.Drawing.Point(394, 78).
      this-object:type:Name = "type".
      this-object:type:Size = new System.Drawing.Size(86, 23).
      this-object:type:TabIndex = 65.
      this-object:type:Text = "Тип расчёта:".
      this-object:type:UseCompatibleTextRendering = true.
      this-object:type:Visible = false.
      /*  */
      /* auto_groupBox1 */
      /*  */
      this-object:auto_groupBox1:Controls:Add(this-object:f_auto_name_file).
      this-object:auto_groupBox1:Controls:Add(this-object:auto_name_file).
      this-object:auto_groupBox1:Controls:Add(this-object:auto_prifix).
      this-object:auto_groupBox1:Controls:Add(this-object:f_auto_prifix_min).
      this-object:auto_groupBox1:Controls:Add(this-object:f_auto_prifix_max).
      this-object:auto_groupBox1:Controls:Add(this-object:auto_prifix_min).
      this-object:auto_groupBox1:Controls:Add(this-object:auto_prifix_max).
      this-object:auto_groupBox1:Font = new System.Drawing.Font("Microsoft Sans Serif", Progress.Util.CastUtil:ToSingle(9), System.Drawing.FontStyle:Bold, System.Drawing.GraphicsUnit:Point, System.Convert:ToByte(204)).
      this-object:auto_groupBox1:Location = new System.Drawing.Point(412, 461).
      this-object:auto_groupBox1:Name = "auto_groupBox1".
      this-object:auto_groupBox1:Size = new System.Drawing.Size(360, 171).
      this-object:auto_groupBox1:TabIndex = 20.
      this-object:auto_groupBox1:TabStop = false.
      this-object:auto_groupBox1:UseCompatibleTextRendering = true.
      this-object:auto_groupBox1:Visible = false.
      /*  */
      /* f_auto_name_file */
      /*  */
      this-object:f_auto_name_file:DataBindings:Add(new System.Windows.Forms.Binding("Text", this-object:bindingBPA, "SlipName", true)).
      this-object:f_auto_name_file:Font = new System.Drawing.Font("Microsoft Sans Serif", Progress.Util.CastUtil:ToSingle(9), System.Drawing.FontStyle:Regular, System.Drawing.GraphicsUnit:Point, System.Convert:ToByte(204)).
      this-object:f_auto_name_file:Location = new System.Drawing.Point(9, 83).
      this-object:f_auto_name_file:Multiline = true.
      this-object:f_auto_name_file:Name = "f_auto_name_file".
      this-object:f_auto_name_file:Size = new System.Drawing.Size(342, 20).
      this-object:f_auto_name_file:TabIndex = 34.
      /*  */
      /* auto_name_file */
      /*  */
      this-object:auto_name_file:Font = new System.Drawing.Font("Microsoft Sans Serif", Progress.Util.CastUtil:ToSingle(9), System.Drawing.FontStyle:Italic, System.Drawing.GraphicsUnit:Point, System.Convert:ToByte(204)).
      this-object:auto_name_file:Location = new System.Drawing.Point(6, 52).
      this-object:auto_name_file:Name = "auto_name_file".
      this-object:auto_name_file:Size = new System.Drawing.Size(233, 23).
      this-object:auto_name_file:TabIndex = 67.
      this-object:auto_name_file:Text = "Имя файла конеч. слипа:".
      this-object:auto_name_file:UseCompatibleTextRendering = true.
      /*  */
      /* auto_prifix */
      /*  */
      this-object:auto_prifix:Font = new System.Drawing.Font("Microsoft Sans Serif", Progress.Util.CastUtil:ToSingle(9), System.Drawing.FontStyle:Italic, System.Drawing.GraphicsUnit:Point, System.Convert:ToByte(204)).
      this-object:auto_prifix:Location = new System.Drawing.Point(9, 17).
      this-object:auto_prifix:Name = "auto_prifix".
      this-object:auto_prifix:Size = new System.Drawing.Size(151, 23).
      this-object:auto_prifix:TabIndex = 68.
      this-object:auto_prifix:Text = "Диапазон для префикса:".
      this-object:auto_prifix:UseCompatibleTextRendering = true.
      /*  */
      /* f_auto_prifix_min */
      /*  */
      this-object:f_auto_prifix_min:DataBindings:Add(new System.Windows.Forms.Binding("Text", this-object:bindingBPA, "QuantMin", true)).
      this-object:f_auto_prifix_min:Font = new System.Drawing.Font("Microsoft Sans Serif", Progress.Util.CastUtil:ToSingle(9), System.Drawing.FontStyle:Regular, System.Drawing.GraphicsUnit:Point, System.Convert:ToByte(204)).
      this-object:f_auto_prifix_min:Location = new System.Drawing.Point(218, 17).
      this-object:f_auto_prifix_min:Multiline = true.
      this-object:f_auto_prifix_min:Name = "f_auto_prifix_min".
      this-object:f_auto_prifix_min:Size = new System.Drawing.Size(42, 20).
      this-object:f_auto_prifix_min:TabIndex = 32.
      /*  */
      /* f_auto_prifix_max */
      /*  */
      this-object:f_auto_prifix_max:DataBindings:Add(new System.Windows.Forms.Binding("Text", this-object:bindingBPA, "QuantMax", true)).
      this-object:f_auto_prifix_max:Font = new System.Drawing.Font("Microsoft Sans Serif", Progress.Util.CastUtil:ToSingle(9), System.Drawing.FontStyle:Regular, System.Drawing.GraphicsUnit:Point, System.Convert:ToByte(204)).
      this-object:f_auto_prifix_max:Location = new System.Drawing.Point(309, 17).
      this-object:f_auto_prifix_max:Multiline = true.
      this-object:f_auto_prifix_max:Name = "f_auto_prifix_max".
      this-object:f_auto_prifix_max:Size = new System.Drawing.Size(42, 20).
      this-object:f_auto_prifix_max:TabIndex = 33.
      /*  */
      /* auto_prifix_min */
      /*  */
      this-object:auto_prifix_min:Font = new System.Drawing.Font("Microsoft Sans Serif", Progress.Util.CastUtil:ToSingle(9), System.Drawing.FontStyle:Italic, System.Drawing.GraphicsUnit:Point, System.Convert:ToByte(204)).
      this-object:auto_prifix_min:Location = new System.Drawing.Point(180, 17).
      this-object:auto_prifix_min:Name = "auto_prifix_min".
      this-object:auto_prifix_min:Size = new System.Drawing.Size(32, 23).
      this-object:auto_prifix_min:TabIndex = 69.
      this-object:auto_prifix_min:Text = "min:".
      this-object:auto_prifix_min:UseCompatibleTextRendering = true.
      /*  */
      /* auto_prifix_max */
      /*  */
      this-object:auto_prifix_max:Font = new System.Drawing.Font("Microsoft Sans Serif", Progress.Util.CastUtil:ToSingle(9), System.Drawing.FontStyle:Italic, System.Drawing.GraphicsUnit:Point, System.Convert:ToByte(204)).
      this-object:auto_prifix_max:Location = new System.Drawing.Point(266, 17).
      this-object:auto_prifix_max:Name = "auto_prifix_max".
      this-object:auto_prifix_max:Size = new System.Drawing.Size(37, 23).
      this-object:auto_prifix_max:TabIndex = 70.
      this-object:auto_prifix_max:Text = "max:".
      this-object:auto_prifix_max:UseCompatibleTextRendering = true.
      /*  */
      /* BPA_form */
      /*  */
      this-object:ClientSize = new System.Drawing.Size(786, 644).
      this-object:Controls:Add(this-object:OCCgroup).
      this-object:Controls:Add(this-object:type_ras).
      this-object:Controls:Add(this-object:auto_groupBox1).
      this-object:Controls:Add(this-object:type).
      this-object:Controls:Add(this-object:type_OperServ).
      this-object:Controls:Add(this-object:type_OperServ1).
      this-object:Controls:Add(this-object:type_OperServ2).
      this-object:Controls:Add(this-object:b_cancel).
      this-object:Controls:Add(this-object:b_exit).
      this-object:Controls:Add(this-object:bpa_groupBox3).
      this-object:Controls:Add(this-object:label6).
      this-object:Controls:Add(this-object:bpa_prod).
      this-object:Controls:Add(this-object:bpa_agent).
      this-object:Controls:Add(this-object:bpa_oper).
      this-object:Controls:Add(this-object:l_name).
      this-object:Controls:Add(this-object:f_name).
      this-object:Controls:Add(this-object:l_code).
      this-object:Controls:Add(this-object:f_code).
      this-object:Name = "BPA_form".
      this-object:Text = "Платежные агенты/Операторы".
      cast(this-object:bindingBPA, System.ComponentModel.ISupportInitialize):EndInit().
      this-object:bpa_oper:ResumeLayout(false).
      this-object:bpa_oper:PerformLayout().
      this-object:OCCgroup:ResumeLayout(false).
      this-object:OCCgroup:PerformLayout().
      this-object:bpa_agent:ResumeLayout(false).
      this-object:bpa_agent:PerformLayout().
      this-object:bpa_prod:ResumeLayout(false).
      this-object:bpa_prod:PerformLayout().
      this-object:bpa_groupBox3:ResumeLayout(false).
      this-object:bpa_groupBox3:PerformLayout().
      this-object:auto_groupBox1:ResumeLayout(false).
      this-object:auto_groupBox1:PerformLayout().
      this-object:ResumeLayout(false).
      this-object:PerformLayout().
      catch e as Progress.Lang.Error:
         undo, throw e.
      end catch.
  end method.


  /*------------------------------------------------------------------------------
   Purpose:
   Notes:
  ------------------------------------------------------------------------------*/
  @VisualDesigner.
  method private void b_click_cancel( input sender as System.Object, input e as System.EventArgs ):
    empty temp-table tt-OperServ .
    close().
    return.

  end method.

  /*------------------------------------------------------------------------------
   Purpose:
   Notes:
  ------------------------------------------------------------------------------*/
  @VisualDesigner.
  method private void b_click_exit( input sender as System.Object, input e as System.EventArgs ):
    if pMode = {&add-def} then 
    do:
      /*find first buf_OperServ exclusive-lock where buf_OperServ.ext-code = f_code:Text no-error .
      if available (buf_OperServ) then 
      do:
        message "Платежный агент/оператор уже есть с таким кодом: " f_code:Text
          view-as alert-box.
        return .
      end.*/   
      bindingBPA:Assign().
      create ub.OperServ .
      buffer-copy tt-OperServ to ub.OperServ .
    end.
    if pMode = {&update} then 
    do:
      /*find first buf_OperServ exclusive-lock where buf_OperServ.ext-code = f_code:Text and buf_OperServ.id <> tt-OperServ.id no-error .
      if available (buf_OperServ) then 
      do:
        message "Платежный агент/оператор уже есть с таким кодом: " f_code:Text
          view-as alert-box.
        return .
      end. */  
      bindingBPA:Assign().
      find first ub.OperServ exclusive-lock where ub.OperServ.id = tt-OperServ.id no-error .
      buffer-copy tt-OperServ to ub.OperServ .
    end.

    Close().
    return.

  end method.

  /*------------------------------------------------------------------------------
   Purpose:
   Notes:
  ------------------------------------------------------------------------------*/
  @VisualDesigner.
  method private void bpa_prod_inn_Click( input sender as System.Object, input e as System.EventArgs ):
    
    return.

  end method.


  /*------------------------------------------------------------------------------
   Purpose:
   Notes:
  ------------------------------------------------------------------------------*/
  @VisualDesigner.
  method private void change_type_OperServ( input sender as System.Object, input e as System.EventArgs ):
    
    if this-object:type_OperServ1:Text = "Автопомощь" then 
    do:
      this-object:auto_groupBox1:Visible = true .
    end.
    else 
    do:
      this-object:auto_groupBox1:Visible = false .
    end.    
    return.

  end method.

  /*------------------------------------------------------------------------------
   Purpose:
   Notes:
  ------------------------------------------------------------------------------*/
  @VisualDesigner.
  method private void change_type_OperServRas( input sender as System.Object, input e as System.EventArgs ):
    Visual_form_Type(type_ras:Text) .    
    return.

  end method.

  /*------------------------------------------------------------------------------
   Purpose:
   Notes:
  ------------------------------------------------------------------------------*/
  @VisualDesigner.
  method private void check_slip( input sender as System.Object, input e as System.EventArgs ):
    if slip:Checked = true then 
    do:
      this-object:l_slip_name:Visible = true.
      this-object:slip_name:Visible = true.
    end.  
    else 
    do:
      this-object:l_slip_name:Visible = false.
      this-object:slip_name:Visible = false.
    end.  
    return.

  end method.

  /*------------------------------------------------------------------------------
   Purpose:
   Notes:
  ------------------------------------------------------------------------------*/
  @VisualDesigner.
  method private void f_oper_tel_TextChanged( input sender as System.Object, input e as System.EventArgs ):
    
    return.

  end method. 
  /*------------------------------------------------------------------------------
   Purpose:
   Notes:
  ------------------------------------------------------------------------------*/
  @VisualDesigner.
  method private void label1_Click( input sender as System.Object, input e as System.EventArgs ):
		
    return.

  end method.

  /*------------------------------------------------------------------------------
   Purpose:
   Notes:
  ------------------------------------------------------------------------------*/
  @VisualDesigner.
  method private void label1_Click_1( input sender as System.Object, input e as System.EventArgs ):
		
    return.

  end method.

  /*------------------------------------------------------------------------------
   Purpose:
   Notes:
  ------------------------------------------------------------------------------*/
  @VisualDesigner.
  method private void label5_Click( input sender as System.Object, input e as System.EventArgs ):
		
    return.

  end method.

	/*------------------------------------------------------------------------------
	 Purpose:
	 Notes:
	------------------------------------------------------------------------------*/
	@VisualDesigner.
	method private void label5_Click_1( input sender as System.Object, input e as System.EventArgs ):
		
		return.

	end method.

  /*------------------------------------------------------------------------------
   Purpose:
   Notes:
  ------------------------------------------------------------------------------*/
  @VisualDesigner.
  method private void label9_Click( input sender as System.Object, input e as System.EventArgs ):
		
    return.

  end method.

	
  /*------------------------------------------------------------------------------
   Purpose:
   Notes:
  ------------------------------------------------------------------------------*/
  @VisualDesigner.
  method private void leave_AgentFlag( input sender as System.Object, input e as System.EventArgs ):
		
    case c_bpa_AgentFlag:Text:
      when "Банковский платежный агент" then
        do:
          tt-OperServ.AgentFlag = 1.
        end.
      when "Банковский платежный субагент" then
        do:
          tt-OperServ.AgentFlag = 2.
        end.
      when "Платежный агент" then
        do:
          tt-OperServ.AgentFlag = 4.
        end.
      when "Платежный субагент" then
        do:
          tt-OperServ.AgentFlag = 8.
        end.
      when "Поверенный пользователь" then
        do:
          tt-OperServ.AgentFlag = 16.
        end.
      when "Комиссионер" then
        do:
          tt-OperServ.AgentFlag = 32.
        end.
      when "Агент, не явл. никем из перечисленных" then
        do:
          tt-OperServ.AgentFlag = 64.
        end.

    end case.
    return.

  end method.


  /*------------------------------------------------------------------------------
   Purpose:
   Notes:
  ------------------------------------------------------------------------------*/
  @VisualDesigner.
  method private void leave_AgentFlag_Ras( input sender as System.Object, input e as System.EventArgs ):
    case c_bpa_AgentFlagRas:Text:
      when "Банковский платежный агент" then
        do:
          tt-OperServ.AgentFlagRasch = 1.
        end.
      when "Банковский платежный субагент" then
        do:
          tt-OperServ.AgentFlagRasch = 2.
        end.
      when "Платежный агент" then
        do:
          tt-OperServ.AgentFlagRasch = 4.
        end.
      when "Платежный субагент" then
        do:
          tt-OperServ.AgentFlagRasch = 8.
        end.
      when "Поверенный пользователь" then
        do:
          tt-OperServ.AgentFlagRasch = 16.
        end.
      when "Комиссионер" then
        do:
          tt-OperServ.AgentFlagRasch = 32.
        end.
      when "Агент, не явл. никем из перечисленных" then
        do:
          tt-OperServ.AgentFlagRasch = 64.
        end.

    end case.
    return.

  end method.

  /*------------------------------------------------------------------------------
   Purpose:
   Notes:
  ------------------------------------------------------------------------------*/
  @VisualDesigner.
  method private void leave_CalcType( input sender as System.Object, input e as System.EventArgs ):

    case this-object:type_ras:Text:
      when "Оплата Сотовой связи" then 
        do:
          tt-OperServ.CalcType = 1 .
        end.
      when "Оплата по договору" then 
        do:
          tt-OperServ.CalcType = 2 .
        end.
      when "Оплата Счёта" then 
        do:
          tt-OperServ.CalcType = 3 .
        end.
      when "Начисление на карту" then 
        do:
          tt-OperServ.CalcType = 4 .
        end.
      when "Платежный агент" then 
        do:
          tt-OperServ.CalcType = 5 .
        end.
    end case.
    case this-object:type_OperServ:Text:
      when "ОСС (OpenWay)" then 
        do:
          tt-OperServ.OsType = 1 .
        end.  
    end case .
    case this-object:type_OperServ1:Text:
      when "" then 
        do:
          tt-OperServ.OsType = 0 .
        end.
      when "Автопомощь" then 
        do:
          tt-OperServ.OsType = 2 .
        end.
      when "Выдача наличных" then 
        do:
          tt-OperServ.OsType = 5 .
        end.
    end case .
    case this-object:type_OperServ2:Text:
      when "Пополнение ВБРР" then 
        do:
          tt-OperServ.OsType = 3 .
        end.          
    end case .
    return.

  end method.

  /*------------------------------------------------------------------------------
   Purpose:
   Notes:
  ------------------------------------------------------------------------------*/
  @VisualDesigner.
  method private void leave_summ_commis( input sender as System.Object, input e as System.EventArgs ):
    if tt-OperServ.CommType = 5 then tt-OperServ.CommPerc = decimal(this-object:commis:Text) .
    else tt-OperServ.CommSumm = decimal(this-object:commis:Text) .
		
    return.

  end method.

  /*------------------------------------------------------------------------------
   Purpose:
   Notes:
  ------------------------------------------------------------------------------*/
  @VisualDesigner.
  method private void leave_summ_commis_bpa( input sender as System.Object, input e as System.EventArgs ):
    if tt-OperServ.CommType = 5 then tt-OperServ.CommPerc = decimal(this-object:f_commis:Text) .
    else tt-OperServ.CommSumm = decimal(this-object:f_commis:Text) .
    
    return.

  end method.
  /*------------------------------------------------------------------------------
   Purpose:
   Notes:
  ------------------------------------------------------------------------------*/
  @VisualDesigner.
  method private void leave_type_commis( input sender as System.Object, input e as System.EventArgs ):
    if type_commis:Text = "Процент" then
    do:
      tt-OperServ.CommType = 5.
    end.
    else
    do:
      tt-OperServ.CommType = 4.
    end.
    return.

  end method.

  /*------------------------------------------------------------------------------
   Purpose:
   Notes:
  ------------------------------------------------------------------------------*/
  @VisualDesigner.
  method private void leave_type_commis_bpa( input sender as System.Object, input e as System.EventArgs ):
    if f_type_commis:Text = "Процент" then
    do:
      tt-OperServ.CommType = 5.
    end.
    else
    do:
      tt-OperServ.CommType = 4.
    end.	
    return.

  end method.

  /*------------------------------------------------------------------------------
   Purpose:
   Notes:
  ------------------------------------------------------------------------------*/
  @VisualDesigner.
  method private void leave_type_OperServ( input sender as System.Object, input e as System.EventArgs ):
    case this-object:type_OperServ:Text:
      when "" then 
        do:
          tt-OperServ.OsType = 0 .
        end.
      when "ОСС (OpenWay)" then 
        do:
          tt-OperServ.OsType = 1 .
        end.  
      when "Автопомощь" then 
        do:
          tt-OperServ.OsType = 2 .
        end.
      when "Пополнение ВБРР" then 
        do:
          tt-OperServ.OsType = 3 .
        end.
       when "Выдача наличных" then 
        do:
          tt-OperServ.OsType = 5 .
        end.            
    end case .
    return.

  end method.

  /*------------------------------------------------------------------------------
   Purpose:
   Notes:
  ------------------------------------------------------------------------------*/
  @VisualDesigner.
  method private void leave_type_OperServ1( input sender as System.Object, input e as System.EventArgs ):
    case this-object:type_OperServ1:Text:
      when "" then 
        do:
          tt-OperServ.OsType = 0 .
        end.
      when "ОСС (OpenWay)" then 
        do:
          tt-OperServ.OsType = 1 .
        end.  
      when "Автопомощь" then 
        do:
          tt-OperServ.OsType = 2 .
        end.
      when "Пополнение ВБРР" then 
        do:
          tt-OperServ.OsType = 3 .
        end.
      when "Выдача наличных" then 
        do:
          tt-OperServ.OsType = 5 .
        end.          
    end case .
    return.

  end method.
  
  /*------------------------------------------------------------------------------
 Purpose:
 Notes:
------------------------------------------------------------------------------*/
  @VisualDesigner.
  method private void leave_type_OperServ2( input sender as System.Object, input e as System.EventArgs ):
    case this-object:type_OperServ2:Text:
      when "" then 
        do:
          tt-OperServ.OsType = 0 .
        end.
      when "ОСС (OpenWay)" then 
        do:
          tt-OperServ.OsType = 1 .
        end.  
      when "Автопомощь" then 
        do:
          tt-OperServ.OsType = 2 .
        end.
      when "Пополнение ВБРР" then 
        do:
          tt-OperServ.OsType = 3 .
        end.
         when "Выдача наличных" then 
        do:
          tt-OperServ.OsType = 5 .
        end.          
    end case .
    return.

  end method.
  /*------------------------------------------------------------------------------
   Purpose:
   Notes:
  ------------------------------------------------------------------------------*/
  @VisualDesigner.
  method private void max_tel_TextChanged( input sender as System.Object, input e as System.EventArgs ):
		
    return.

  end method.

  METHOD PUBLIC VOID Visual_form_Type( INPUT OsType AS character ): 

    case OsType:
      when "" then 
        do:
          assign
            this-object:type_OperServ:Visible = false .
          this-object:type_OperServ1:Visible = false .
          this-object:type_OperServ2:Visible = false .
          this-object:type:Visible = false .
          this-object:OCCgroup:Visible = false .
          this-object:auto_groupBox1:Visible = false .
          this-object:bpa_agent:Visible = false .
          this-object:bpa_groupBox3:Visible = false .
          this-object:bpa_oper:Visible = false .
          this-object:bpa_prod:Visible = false .
          .
        end.
      when "Оплата Сотовой связи" then 
        do:
          assign
            this-object:type_OperServ:Visible = true .
          this-object:type_OperServ1:Visible = false .
          this-object:type_OperServ2:Visible = false .
          this-object:type:Visible = true .
          this-object:type_OperServ:Text = "ОСС (OpenWay)" .
          this-object:OCCgroup:Visible = true .
          this-object:auto_groupBox1:Visible = false .
          this-object:bpa_agent:Visible = false .
          this-object:bpa_groupBox3:Visible = false .
          this-object:bpa_oper:Visible = false .
          this-object:bpa_prod:Visible = false .
          .
        end.
      when "Начисление на карту" then 
        do:
          assign
            this-object:type_OperServ:Visible = false .
          this-object:type_OperServ1:Visible = false .
          this-object:type_OperServ2:Visible = true .
          this-object:type_OperServ2:Text = "Пополнение ВБРР" .
          this-object:type:Visible = true .
          this-object:OCCgroup:Visible = false .
          this-object:auto_groupBox1:Visible = false .
          this-object:bpa_agent:Visible = true .
          this-object:bpa_groupBox3:Visible = true .
          this-object:bpa_oper:Visible = true .
          this-object:bpa_prod:Visible = true .
          .
        end.
      when "Платежный агент" then 
        do:
          assign
            this-object:type_OperServ:Visible = false .
          this-object:type_OperServ1:Visible = true .
          this-object:type_OperServ2:Visible = false .
          this-object:type:Visible = true .
          this-object:OCCgroup:Visible = false .
          this-object:bpa_agent:Visible = true .
          this-object:bpa_groupBox3:Visible = true .
          this-object:bpa_oper:Visible = true .
          this-object:bpa_prod:Visible = true .
          .
        end.
    end case.     
    return.
  end method .
  
  METHOD PUBLIC VOID Visual_form_mode( INPUT PMode AS character ): 

    if PMode <> {&lookup} then 
    do:
      assign
        this-object:f_code:Enabled = true .
      this-object:f_name:Enabled = true .
      this-object:type_OperServ:Enabled = true .
      this-object:type_OperServ1:Enabled = true .
      this-object:type_OperServ2:Enabled = true .
      this-object:type_ras:Enabled = true .
      this-object:type:Enabled = true .
      this-object:OCCgroup:Enabled = true .
      this-object:auto_groupBox1:Enabled = true .
      this-object:bpa_agent:Enabled = true .
      this-object:bpa_groupBox3:Enabled = true .
      this-object:bpa_oper:Enabled = true .
      this-object:bpa_prod:Enabled = true .
      .
      if PMode = {&update} then 
      do:
        this-object:type_ras:Enabled = false .
      end.
    end.
    else 
    do:
      assign
        this-object:f_code:Enabled = false .
      this-object:f_name:Enabled = false .
      this-object:type_OperServ:Enabled = false .
      this-object:type_ras:Enabled = false .
      this-object:type_OperServ1:Enabled = false .
      this-object:type_OperServ2:Enabled = false .
      this-object:type:Enabled = false .
      this-object:OCCgroup:Enabled = false .
      this-object:auto_groupBox1:Enabled = false .
      this-object:bpa_agent:Enabled = false .
      this-object:bpa_groupBox3:Enabled = false .
      this-object:bpa_oper:Enabled = false .
      this-object:bpa_prod:Enabled = false .
      .

    end.

    return.
  end method .
  /*------------------------------------------------------------------------------
 Purpose:
 Notes:
------------------------------------------------------------------------------*/
  @VisualDesigner.
  method private void Enable_Form():
    case tt-OperServ.CalcType:
      when 1 then 
        do:
          OsTypeRas = "Оплата Сотовой связи" .
        end.
      when 2 then 
        do:
          OsTypeRas = "Оплата по договору" .
        end.
      when 3 then 
        do:
          OsTypeRas = "Оплата Счёта" .
        end.
      when 4 then 
        do:
          OsTypeRas = "Начисление на карту" .
        end.
      when 5 then 
        do:
          OsTypeRas = "Платежный агент" .
        end.                                  
    end case .  
    case tt-OperServ.OsType:
      when 0 then 
        do:
          p-OsType = "" .
        end.
      when 1 then 
        do:
          p-OsType = "ОСС (OpenWay)" .
        end.
      when 2 then 
        do:
          p-OsType = "Автопомощь" .
        end.
      when 3 then 
        do:
          p-OsType = "Пополнение ВБРР" .
        end.
      when 5 then 
        do:
          p-OsType = "Выдача наличных" .
        end.
    end case .      
    if tt-OperServ.CommType = 5 then
    do:
      CommType = "Процент".
    end.
    else
    do:
      CommType = "Сумма" .
    end. 
    if tt-OperServ.CommType = 5 then Commis_val = tt-OperServ.CommPerc .
    else Commis_val = tt-OperServ.CommSumm .
    case tt-OperServ.AgentFlagRas:
      when 1 then
        do:
          p-AgentFlagRasch = "Банковский платежный агент".
        end.
      when 2 then
        do:
          p-AgentFlagRasch = "Банковский платежный субагент".
        end.
      when 4 then
        do:
          p-AgentFlagRasch = "Платежный агент".
        end.
      when 8 then
        do:
          p-AgentFlagRasch = "Платежный субагент".
        end.
      when 16 then
        do:
          p-AgentFlagRasch = "Поверенный пользователь".
        end.
      when 32 then
        do:
          p-AgentFlagRasch = "Комиссионер".
        end.
      when 64 then
        do:
          p-AgentFlagRasch = "Агент, не явл. никем из перечисленных".
        end.

    end case. 
    case tt-OperServ.AgentFlag:
      when 1 then
        do:
          p-AgentFlag = "Банковский платежный агент".
        end.
      when 2 then
        do:
          p-AgentFlag = "Банковский платежный субагент".
        end.
      when 4 then
        do:
          p-AgentFlag = "Платежный агент".
        end.
      when 8 then
        do:
          p-AgentFlag = "Платежный субагент".
        end.
      when 16 then
        do:
          p-AgentFlag = "Поверенный пользователь".
        end.
      when 32 then
        do:
          p-AgentFlag = "Комиссионер".
        end.
      when 64 then
        do:
          p-AgentFlag = "Агент, не явл. никем из перечисленных".
        end.

    end case.     
    return.

  end method.
  destructor public BPA_form ( ):

  end destructor.

end class.