using Progress.Lang.*.
using Progress.Windows.Form.
using ibs.th.ref.bpa.OCC_form from propath.
using System.Array from assembly.
block-level on error undo, throw.
class ibs.th.ref.bpa.OCC_form inherits Form:
  define private variable b_exit         as System.Windows.Forms.Button      no-undo.
  define private variable b_cancel       as System.Windows.Forms.Button      no-undo.
  define private variable bindingSource1 as Progress.Data.BindingSource      no-undo.
  define private variable c_CalcType     as System.Windows.Forms.ComboBox    no-undo.
  define private variable c_type_commis  as System.Windows.Forms.ComboBox    no-undo.
  define private variable components     as System.ComponentModel.IContainer no-undo.
  define private variable l_limit_sum    as System.Windows.Forms.Label       no-undo.
  define private variable l_commis       as System.Windows.Forms.Label       no-undo.
  define private variable l_abbr         as System.Windows.Forms.Label       no-undo.
  define private variable f_print        as System.Windows.Forms.CheckBox    no-undo.
  define private variable f_name_file    as System.Windows.Forms.TextBox     no-undo.
  define private variable f_min_tel      as System.Windows.Forms.TextBox     no-undo.
  define private variable f_min_sum      as System.Windows.Forms.TextBox     no-undo.
  define private variable f_max_tel      as System.Windows.Forms.TextBox     no-undo.
  define private variable f_max_sum      as System.Windows.Forms.TextBox     no-undo.
  define private variable f_limit_sum    as System.Windows.Forms.TextBox     no-undo.
  define private variable f_commis       as System.Windows.Forms.TextBox     no-undo.
  define private variable f_auth         as System.Windows.Forms.CheckBox    no-undo.
  define private variable f_abbr         as System.Windows.Forms.TextBox     no-undo.
  define private variable l_name         as System.Windows.Forms.Label       no-undo.
  define private variable l_code         as System.Windows.Forms.Label       no-undo.
  define private variable f_name         as System.Windows.Forms.TextBox     no-undo.
  define private variable f_code         as System.Windows.Forms.TextBox     no-undo.
  define private variable l_type_pay     as System.Windows.Forms.Label       no-undo.
  define private variable l_type_commis  as System.Windows.Forms.Label       no-undo.
  define private variable l_tel          as System.Windows.Forms.Label       no-undo.
  define private variable l_sum          as System.Windows.Forms.Label       no-undo.
  define private variable l_name_file    as System.Windows.Forms.Label       no-undo.
  define private variable label2         as System.Windows.Forms.Label       no-undo.
  define private variable label8         as System.Windows.Forms.Label       no-undo.
  define private variable label7         as System.Windows.Forms.Label       no-undo.
  define private variable label6         as System.Windows.Forms.Label       no-undo.
  define private variable pMode          as character                        no-undo .
  constructor public OCC_form (iChange as character, p-id as integer ):
    super().
    pMode = iChange .
    case pMode:
      when 'ДОБАВЛЕНИЕ':U then
        do:
          create OperServ .
          ub.OperServ.id = next-value (s-operserv-id) .
          ub.OperServ.OsType  = 1 .
        end.
      when 'ИЗМЕНЕНИЕ':U then
        do:
          find first ub.OperServ exclusive-lock where ub.OperServ.id = p-id no-error .
        end.
      when 'ПРОСМОТР':U then
        do:
          find first ub.OperServ exclusive-lock where ub.OperServ.id = p-id no-error .
        end.
    end case .
    InitializeComponent().
    Visual_form(pMode).
    bindingSource1:Handle = buffer OperServ:handle .
    this-object:ComponentsCollection:ADD(this-object:components).
    catch e as Progress.Lang.Error:
      undo, throw e.
    end catch.
  end constructor.
  constructor public OCC_form ():
  end constructor.
  @VisualDesigner.
  method private void b_cancel_Click( input sender as System.Object, input e as System.EventArgs ):
    if pMode = 'ДОБАВЛЕНИЕ':U then delete ub.OperServ .
    Close().
    return.
  end method.
  @VisualDesigner.
  method private void b_exit_Click( input sender as System.Object, input e as System.EventArgs ):
    if pMode = 'ДОБАВЛЕНИЕ':U then do:
      find first ub.OperServ exclusive-lock where ub.OperServ.ext-code = f_code:Text no-error .
      if available (ub.OperServ) then do:
        message "Платежный агент/оператор уже есть с таким кодом: " f_code:Text
        view-as alert-box.
        return .
      end.
    bindingSource1:Assign().
    end.
    Close().
    return.
  end method.
  @VisualDesigner.
  method private void c_type_commis_SelectedIndexChanged( input sender as System.Object, input e as System.EventArgs ):
    return.
  end method.
  @VisualDesigner.
  method private void change_slip( input sender as System.Object, input e as System.EventArgs ):
    if f_print:Checked = true then
    do:
      this-object:l_name_file:Visible = true.
      this-object:l_name_file:Enabled = true.
      this-object:f_name_file:Visible = true.
      this-object:f_name_file:Enabled = true.
    end.
    else
    do:
      this-object:l_name_file:Visible = false.
      this-object:l_name_file:Enabled = false.
      this-object:f_name_file:Visible = false.
      this-object:f_name_file:Enabled = false.
    end.
    return.
  end method.
        @VisualDesigner.
        method private void check_code( input sender as System.Object, input e as System.EventArgs ):
if pMode = 'ДОБАВЛЕНИЕ':U then do:
                find first ub.OperServ exclusive-lock where ub.OperServ.ext-code = f_code:Text no-error .
                if available (ub.OperServ) then do:
                  message "Платежный агент/оператор уже есть с таким кодом: " f_code:Text
      view-as alert-box.
      return .
                end.
end.
                return.
        end method.
  @VisualDesigner.
  method private void f_abbr_TextChanged( input sender as System.Object, input e as System.EventArgs ):
    return.
  end method.
  @VisualDesigner.
  method private void f_code_TextChanged( input sender as System.Object, input e as System.EventArgs ):
    return.
  end method.
  method private void InitializeComponent(  ):
    this-object:components = new System.ComponentModel.Container().
    @VisualDesigner.FormMember (NeedsInitialize="true").
    define variable tableDesc1 as Progress.Data.TableDesc no-undo.
    tableDesc1 = new Progress.Data.TableDesc("OperServ").
    this-object:f_code = new System.Windows.Forms.TextBox().
    this-object:bindingSource1 = new Progress.Data.BindingSource(this-object:components).
    this-object:l_code = new System.Windows.Forms.Label().
    this-object:f_name = new System.Windows.Forms.TextBox().
    this-object:l_name = new System.Windows.Forms.Label().
    this-object:f_limit_sum = new System.Windows.Forms.TextBox().
    this-object:l_limit_sum = new System.Windows.Forms.Label().
    this-object:f_min_tel = new System.Windows.Forms.TextBox().
    this-object:l_tel = new System.Windows.Forms.Label().
    this-object:f_abbr = new System.Windows.Forms.TextBox().
    this-object:l_abbr = new System.Windows.Forms.Label().
    this-object:f_name_file = new System.Windows.Forms.TextBox().
    this-object:l_name_file = new System.Windows.Forms.Label().
    this-object:l_commis = new System.Windows.Forms.Label().
    this-object:l_type_commis = new System.Windows.Forms.Label().
    this-object:l_type_pay = new System.Windows.Forms.Label().
    this-object:f_max_tel = new System.Windows.Forms.TextBox().
    this-object:label6 = new System.Windows.Forms.Label().
    this-object:label7 = new System.Windows.Forms.Label().
    this-object:l_sum = new System.Windows.Forms.Label().
    this-object:c_type_commis = new System.Windows.Forms.ComboBox().
    this-object:f_commis = new System.Windows.Forms.TextBox().
    this-object:label2 = new System.Windows.Forms.Label().
    this-object:label8 = new System.Windows.Forms.Label().
    this-object:f_max_sum = new System.Windows.Forms.TextBox().
    this-object:f_min_sum = new System.Windows.Forms.TextBox().
    this-object:f_auth = new System.Windows.Forms.CheckBox().
    this-object:f_print = new System.Windows.Forms.CheckBox().
    this-object:b_cancel = new System.Windows.Forms.Button().
    this-object:b_exit = new System.Windows.Forms.Button().
    this-object:c_CalcType = new System.Windows.Forms.ComboBox().
    cast(this-object:bindingSource1, System.ComponentModel.ISupportInitialize):BeginInit().
    this-object:SuspendLayout().
    this-object:f_code:DataBindings:Add(new System.Windows.Forms.Binding("Text", this-object:bindingSource1, "ext-code", true)).
    this-object:f_code:Font = new System.Drawing.Font("Microsoft Sans Serif", Progress.Util.CastUtil:ToSingle(8.25), System.Drawing.FontStyle:Italic, System.Drawing.GraphicsUnit:Point, System.Convert:ToByte(204)).
    this-object:f_code:Location = new System.Drawing.Point(241, 51).
    this-object:f_code:Name = "f_code".
    this-object:f_code:Size = new System.Drawing.Size(264, 20).
    this-object:f_code:TabIndex = 0.
    this-object:f_code:TextChanged:Subscribe(this-object:f_code_TextChanged).
    this-object:f_code:Leave:Subscribe(this-object:check_code).
    this-object:bindingSource1:MaxDataGuess = 0.
    this-object:bindingSource1:NoLOBs = false.
    this-object:bindingSource1:Position = 0.
    @VisualDesigner.FormMember (NeedsInitialize="false", InitializeArray="true").
    define variable arrayvar0 as "Progress.Data.TableDesc[]" no-undo.
    arrayvar0 = new "Progress.Data.TableDesc[]"(0).
    tableDesc1:ChildTables = arrayvar0.
    @VisualDesigner.FormMember (NeedsInitialize="false", InitializeArray="true").
    define variable arrayvar1 as Progress.Data.ColumnPropDesc extent 28 no-undo.
    arrayvar1[1] = new Progress.Data.ColumnPropDesc("AgentData", "данные агента", Progress.Data.DataType:LOGICAL).
    arrayvar1[2] = new Progress.Data.ColumnPropDesc("AgentFlag", "признак агента", Progress.Data.DataType:LOGICAL).
    arrayvar1[3] = new Progress.Data.ColumnPropDesc("AgentFlagRasch", "признак агента по предмету расчета", Progress.Data.DataType:LOGICAL).
    arrayvar1[4] = new Progress.Data.ColumnPropDesc("AgentTel", "тел. агента", Progress.Data.DataType:CHARACTER).
    arrayvar1[5] = new Progress.Data.ColumnPropDesc("CalcType", "Тип расч.", Progress.Data.DataType:INTEGER).
    arrayvar1[6] = new Progress.Data.ColumnPropDesc("CommPerc", "% комиссии", Progress.Data.DataType:DECIMAL).
    arrayvar1[7] = new Progress.Data.ColumnPropDesc("CommSumm", "Сумма ком.", Progress.Data.DataType:DECIMAL).
    arrayvar1[8] = new Progress.Data.ColumnPropDesc("CommType", "Тип ком.", Progress.Data.DataType:INTEGER).
    arrayvar1[9] = new Progress.Data.ColumnPropDesc("ext-code", "ext-code", Progress.Data.DataType:CHARACTER).
    arrayvar1[10] = new Progress.Data.ColumnPropDesc("id", "id", Progress.Data.DataType:INT64).
    arrayvar1[11] = new Progress.Data.ColumnPropDesc("InnSupp", "ИНН", Progress.Data.DataType:CHARACTER).
    arrayvar1[12] = new Progress.Data.ColumnPropDesc("OperAddr", "адрес опер.", Progress.Data.DataType:CHARACTER).
    arrayvar1[13] = new Progress.Data.ColumnPropDesc("OperInn", "ИНН", Progress.Data.DataType:CHARACTER).
    arrayvar1[14] = new Progress.Data.ColumnPropDesc("OperName", "Наим. опер", Progress.Data.DataType:CHARACTER).
    arrayvar1[15] = new Progress.Data.ColumnPropDesc("OperTel", "тел. опер.", Progress.Data.DataType:CHARACTER).
    arrayvar1[16] = new Progress.Data.ColumnPropDesc("OSname", "Наим. опер.", Progress.Data.DataType:CHARACTER).
    arrayvar1[17] = new Progress.Data.ColumnPropDesc("OsNameAbbr", "Аббр. опер.", Progress.Data.DataType:CHARACTER).
    arrayvar1[18] = new Progress.Data.ColumnPropDesc("OsType", "Тип", Progress.Data.DataType:INTEGER).
    arrayvar1[19] = new Progress.Data.ColumnPropDesc("PreAAvt", "Необх.автор.", Progress.Data.DataType:LOGICAL).
    arrayvar1[20] = new Progress.Data.ColumnPropDesc("PreSlip", "Печ. слипа", Progress.Data.DataType:LOGICAL).
    arrayvar1[21] = new Progress.Data.ColumnPropDesc("QuantMax", "Макс.кол.цифр", Progress.Data.DataType:INTEGER).
    arrayvar1[22] = new Progress.Data.ColumnPropDesc("QuantMin", "Мин.кол.цифр", Progress.Data.DataType:INTEGER).
    arrayvar1[23] = new Progress.Data.ColumnPropDesc("SlipName", "Файла слипа", Progress.Data.DataType:CHARACTER).
    arrayvar1[24] = new Progress.Data.ColumnPropDesc("SummAtent", "Сумм.для предупр.", Progress.Data.DataType:DECIMAL).
    arrayvar1[25] = new Progress.Data.ColumnPropDesc("SummMax", "Макс.сумма", Progress.Data.DataType:DECIMAL).
    arrayvar1[26] = new Progress.Data.ColumnPropDesc("SummMin", "Мин.сумма", Progress.Data.DataType:DECIMAL).
    arrayvar1[27] = new Progress.Data.ColumnPropDesc("SuppData", "данные поставщика", Progress.Data.DataType:LOGICAL).
    arrayvar1[28] = new Progress.Data.ColumnPropDesc("SuppName", "Наим. пост.", Progress.Data.DataType:CHARACTER).
    tableDesc1:Columns = arrayvar1.
    this-object:bindingSource1:TableSchema = tableDesc1.
    this-object:l_code:Font = new System.Drawing.Font("Microsoft Sans Serif", Progress.Util.CastUtil:ToSingle(9), System.Drawing.FontStyle:Bold, System.Drawing.GraphicsUnit:Point, System.Convert:ToByte(204)).
    this-object:l_code:Location = new System.Drawing.Point(12, 51).
    this-object:l_code:Name = "l_code".
    this-object:l_code:Size = new System.Drawing.Size(119, 23).
    this-object:l_code:TabIndex = 1.
    this-object:l_code:Text = "Код оператора:".
    this-object:l_code:UseCompatibleTextRendering = true.
    this-object:f_name:DataBindings:Add(new System.Windows.Forms.Binding("Text", this-object:bindingSource1, "OSname", true)).
    this-object:f_name:Font = new System.Drawing.Font("Microsoft Sans Serif", Progress.Util.CastUtil:ToSingle(8.25), System.Drawing.FontStyle:Italic, System.Drawing.GraphicsUnit:Point, System.Convert:ToByte(204)).
    this-object:f_name:Location = new System.Drawing.Point(241, 81).
    this-object:f_name:Name = "f_name".
    this-object:f_name:Size = new System.Drawing.Size(264, 20).
    this-object:f_name:TabIndex = 2.
    this-object:l_name:Font = new System.Drawing.Font("Microsoft Sans Serif", Progress.Util.CastUtil:ToSingle(9), System.Drawing.FontStyle:Bold, System.Drawing.GraphicsUnit:Point, System.Convert:ToByte(204)).
    this-object:l_name:Location = new System.Drawing.Point(12, 81).
    this-object:l_name:Name = "l_name".
    this-object:l_name:Size = new System.Drawing.Size(177, 23).
    this-object:l_name:TabIndex = 3.
    this-object:l_name:Text = "Наименование оператора:".
    this-object:l_name:UseCompatibleTextRendering = true.
    this-object:f_limit_sum:DataBindings:Add(new System.Windows.Forms.Binding("Text", this-object:bindingSource1, "SummAtent", true)).
    this-object:f_limit_sum:Font = new System.Drawing.Font("Microsoft Sans Serif", Progress.Util.CastUtil:ToSingle(9), System.Drawing.FontStyle:Italic, System.Drawing.GraphicsUnit:Point, System.Convert:ToByte(204)).
    this-object:f_limit_sum:Location = new System.Drawing.Point(364, 209).
    this-object:f_limit_sum:Multiline = true.
    this-object:f_limit_sum:Name = "f_limit_sum".
    this-object:f_limit_sum:Size = new System.Drawing.Size(141, 20).
    this-object:f_limit_sum:TabIndex = 9.
    this-object:l_limit_sum:Font = new System.Drawing.Font("Microsoft Sans Serif", Progress.Util.CastUtil:ToSingle(9), System.Drawing.FontStyle:Italic, System.Drawing.GraphicsUnit:Point, System.Convert:ToByte(204)).
    this-object:l_limit_sum:Location = new System.Drawing.Point(12, 206).
    this-object:l_limit_sum:Name = "l_limit_sum".
    this-object:l_limit_sum:Size = new System.Drawing.Size(233, 23).
    this-object:l_limit_sum:TabIndex = 27.
    this-object:l_limit_sum:Text = "Порог сумм для предупреждений:".
    this-object:l_limit_sum:UseCompatibleTextRendering = true.
    this-object:f_min_tel:DataBindings:Add(new System.Windows.Forms.Binding("Text", this-object:bindingSource1, "QuantMin", true)).
    this-object:f_min_tel:Font = new System.Drawing.Font("Microsoft Sans Serif", Progress.Util.CastUtil:ToSingle(9), System.Drawing.FontStyle:Italic, System.Drawing.GraphicsUnit:Point, System.Convert:ToByte(204)).
    this-object:f_min_tel:Location = new System.Drawing.Point(284, 146).
    this-object:f_min_tel:Multiline = true.
    this-object:f_min_tel:Name = "f_min_tel".
    this-object:f_min_tel:Size = new System.Drawing.Size(62, 20).
    this-object:f_min_tel:TabIndex = 5.
    this-object:l_tel:Font = new System.Drawing.Font("Microsoft Sans Serif", Progress.Util.CastUtil:ToSingle(9), System.Drawing.FontStyle:Italic, System.Drawing.GraphicsUnit:Point, System.Convert:ToByte(204)).
    this-object:l_tel:Location = new System.Drawing.Point(12, 146).
    this-object:l_tel:Name = "l_tel".
    this-object:l_tel:Size = new System.Drawing.Size(151, 23).
    this-object:l_tel:TabIndex = 23.
    this-object:l_tel:Text = "Кол-во цифр телефона:".
    this-object:l_tel:UseCompatibleTextRendering = true.
    this-object:f_abbr:DataBindings:Add(new System.Windows.Forms.Binding("Text", this-object:bindingSource1, "OsNameAbbr", true)).
    this-object:f_abbr:Font = new System.Drawing.Font("Microsoft Sans Serif", Progress.Util.CastUtil:ToSingle(9), System.Drawing.FontStyle:Italic, System.Drawing.GraphicsUnit:Point, System.Convert:ToByte(204)).
    this-object:f_abbr:Location = new System.Drawing.Point(241, 111).
    this-object:f_abbr:Multiline = true.
    this-object:f_abbr:Name = "f_abbr".
    this-object:f_abbr:Size = new System.Drawing.Size(264, 20).
    this-object:f_abbr:TabIndex = 4.
    this-object:f_abbr:TextChanged:Subscribe(this-object:f_abbr_TextChanged).
    this-object:l_abbr:Font = new System.Drawing.Font("Microsoft Sans Serif", Progress.Util.CastUtil:ToSingle(9), System.Drawing.FontStyle:Italic, System.Drawing.GraphicsUnit:Point, System.Convert:ToByte(204)).
    this-object:l_abbr:Location = new System.Drawing.Point(12, 111).
    this-object:l_abbr:Name = "l_abbr".
    this-object:l_abbr:Size = new System.Drawing.Size(133, 23).
    this-object:l_abbr:TabIndex = 21.
    this-object:l_abbr:Text = "Аббр. оператора:".
    this-object:l_abbr:UseCompatibleTextRendering = true.
    this-object:f_name_file:DataBindings:Add(new System.Windows.Forms.Binding("Text", this-object:bindingSource1, "SlipName", true)).
    this-object:f_name_file:Enabled = false.
    this-object:f_name_file:Font = new System.Drawing.Font("Microsoft Sans Serif", Progress.Util.CastUtil:ToSingle(9), System.Drawing.FontStyle:Italic, System.Drawing.GraphicsUnit:Point, System.Convert:ToByte(204)).
    this-object:f_name_file:Location = new System.Drawing.Point(281, 356).
    this-object:f_name_file:Multiline = true.
    this-object:f_name_file:Name = "f_name_file".
    this-object:f_name_file:Size = new System.Drawing.Size(224, 20).
    this-object:f_name_file:TabIndex = 14.
    this-object:f_name_file:Visible = false.
    this-object:l_name_file:Enabled = false.
    this-object:l_name_file:Font = new System.Drawing.Font("Microsoft Sans Serif", Progress.Util.CastUtil:ToSingle(9), System.Drawing.FontStyle:Italic, System.Drawing.GraphicsUnit:Point, System.Convert:ToByte(204)).
    this-object:l_name_file:Location = new System.Drawing.Point(12, 356).
    this-object:l_name_file:Name = "l_name_file".
    this-object:l_name_file:Size = new System.Drawing.Size(233, 23).
    this-object:l_name_file:TabIndex = 39.
    this-object:l_name_file:Text = "Имя файла конеч. слипа:".
    this-object:l_name_file:UseCompatibleTextRendering = true.
    this-object:l_name_file:Visible = false.
    this-object:l_commis:Font = new System.Drawing.Font("Microsoft Sans Serif", Progress.Util.CastUtil:ToSingle(9), System.Drawing.FontStyle:Italic, System.Drawing.GraphicsUnit:Point, System.Convert:ToByte(204)).
    this-object:l_commis:Location = new System.Drawing.Point(12, 266).
    this-object:l_commis:Name = "l_commis".
    this-object:l_commis:Size = new System.Drawing.Size(194, 23).
    this-object:l_commis:TabIndex = 35.
    this-object:l_commis:Text = "Комиссия:".
    this-object:l_commis:UseCompatibleTextRendering = true.
    this-object:l_type_commis:Font = new System.Drawing.Font("Microsoft Sans Serif", Progress.Util.CastUtil:ToSingle(9), System.Drawing.FontStyle:Italic, System.Drawing.GraphicsUnit:Point, System.Convert:ToByte(204)).
    this-object:l_type_commis:Location = new System.Drawing.Point(12, 236).
    this-object:l_type_commis:Name = "l_type_commis".
    this-object:l_type_commis:Size = new System.Drawing.Size(133, 23).
    this-object:l_type_commis:TabIndex = 33.
    this-object:l_type_commis:Text = "Тип ввода комиссии:".
    this-object:l_type_commis:UseCompatibleTextRendering = true.
    this-object:l_type_pay:Font = new System.Drawing.Font("Microsoft Sans Serif", Progress.Util.CastUtil:ToSingle(9), System.Drawing.FontStyle:Italic, System.Drawing.GraphicsUnit:Point, System.Convert:ToByte(204)).
    this-object:l_type_pay:Location = new System.Drawing.Point(12, 388).
    this-object:l_type_pay:Name = "l_type_pay".
    this-object:l_type_pay:Size = new System.Drawing.Size(233, 23).
    this-object:l_type_pay:TabIndex = 41.
    this-object:l_type_pay:Text = "Тип расчета с опер. пополн.:".
    this-object:l_type_pay:UseCompatibleTextRendering = true.
    this-object:f_max_tel:DataBindings:Add(new System.Windows.Forms.Binding("Text", this-object:bindingSource1, "QuantMax", true)).
    this-object:f_max_tel:Font = new System.Drawing.Font("Microsoft Sans Serif", Progress.Util.CastUtil:ToSingle(9), System.Drawing.FontStyle:Italic, System.Drawing.GraphicsUnit:Point, System.Convert:ToByte(204)).
    this-object:f_max_tel:Location = new System.Drawing.Point(443, 146).
    this-object:f_max_tel:Multiline = true.
    this-object:f_max_tel:Name = "f_max_tel".
    this-object:f_max_tel:Size = new System.Drawing.Size(62, 20).
    this-object:f_max_tel:TabIndex = 6.
    this-object:label6:Font = new System.Drawing.Font("Microsoft Sans Serif", Progress.Util.CastUtil:ToSingle(9), System.Drawing.FontStyle:Italic, System.Drawing.GraphicsUnit:Point, System.Convert:ToByte(204)).
    this-object:label6:Location = new System.Drawing.Point(241, 146).
    this-object:label6:Name = "label6".
    this-object:label6:Size = new System.Drawing.Size(43, 23).
    this-object:label6:TabIndex = 43.
    this-object:label6:Text = "min:".
    this-object:label6:UseCompatibleTextRendering = true.
    this-object:label7:Font = new System.Drawing.Font("Microsoft Sans Serif", Progress.Util.CastUtil:ToSingle(9), System.Drawing.FontStyle:Italic, System.Drawing.GraphicsUnit:Point, System.Convert:ToByte(204)).
    this-object:label7:Location = new System.Drawing.Point(400, 146).
    this-object:label7:Name = "label7".
    this-object:label7:Size = new System.Drawing.Size(37, 23).
    this-object:label7:TabIndex = 44.
    this-object:label7:Text = "max:".
    this-object:label7:UseCompatibleTextRendering = true.
    this-object:label7:Click:Subscribe(this-object:label7_Click).
    this-object:l_sum:Font = new System.Drawing.Font("Microsoft Sans Serif", Progress.Util.CastUtil:ToSingle(9), System.Drawing.FontStyle:Italic, System.Drawing.GraphicsUnit:Point, System.Convert:ToByte(204)).
    this-object:l_sum:Location = new System.Drawing.Point(12, 176).
    this-object:l_sum:Name = "l_sum".
    this-object:l_sum:Size = new System.Drawing.Size(151, 23).
    this-object:l_sum:TabIndex = 46.
    this-object:l_sum:Text = "Сумма:".
    this-object:l_sum:UseCompatibleTextRendering = true.
    this-object:c_type_commis:FormattingEnabled = true.
    @VisualDesigner.FormMember (NeedsInitialize="false", InitializeArray="true").
    define variable arrayvar2 as System.Object extent 2 no-undo.
    arrayvar2[1] = "Процент".
    arrayvar2[2] = "Сумма".
    this-object:c_type_commis:Items:AddRange(arrayvar2).
    this-object:c_type_commis:Location = new System.Drawing.Point(364, 239).
    this-object:c_type_commis:Name = "c_type_commis".
    this-object:c_type_commis:Size = new System.Drawing.Size(141, 21).
    this-object:c_type_commis:TabIndex = 10.
    this-object:c_type_commis:SelectedIndexChanged:Subscribe(this-object:c_type_commis_SelectedIndexChanged).
    this-object:c_type_commis:Leave:Subscribe(this-object:leave_type_commis).
    this-object:f_commis:Font = new System.Drawing.Font("Microsoft Sans Serif", Progress.Util.CastUtil:ToSingle(9), System.Drawing.FontStyle:Italic, System.Drawing.GraphicsUnit:Point, System.Convert:ToByte(204)).
    this-object:f_commis:Location = new System.Drawing.Point(364, 269).
    this-object:f_commis:Multiline = true.
    this-object:f_commis:Name = "f_commis".
    this-object:f_commis:Size = new System.Drawing.Size(141, 20).
    this-object:f_commis:TabIndex = 11.
    this-object:f_commis:Leave:Subscribe(this-object:leave_commis).
    this-object:label2:Font = new System.Drawing.Font("Microsoft Sans Serif", Progress.Util.CastUtil:ToSingle(9), System.Drawing.FontStyle:Italic, System.Drawing.GraphicsUnit:Point, System.Convert:ToByte(204)).
    this-object:label2:Location = new System.Drawing.Point(400, 176).
    this-object:label2:Name = "label2".
    this-object:label2:Size = new System.Drawing.Size(37, 23).
    this-object:label2:TabIndex = 58.
    this-object:label2:Text = "max:".
    this-object:label2:UseCompatibleTextRendering = true.
    this-object:label8:Font = new System.Drawing.Font("Microsoft Sans Serif", Progress.Util.CastUtil:ToSingle(9), System.Drawing.FontStyle:Italic, System.Drawing.GraphicsUnit:Point, System.Convert:ToByte(204)).
    this-object:label8:Location = new System.Drawing.Point(241, 176).
    this-object:label8:Name = "label8".
    this-object:label8:Size = new System.Drawing.Size(43, 23).
    this-object:label8:TabIndex = 57.
    this-object:label8:Text = "min:".
    this-object:label8:UseCompatibleTextRendering = true.
    this-object:f_max_sum:DataBindings:Add(new System.Windows.Forms.Binding("Text", this-object:bindingSource1, "SummMax", true)).
    this-object:f_max_sum:Font = new System.Drawing.Font("Microsoft Sans Serif", Progress.Util.CastUtil:ToSingle(9), System.Drawing.FontStyle:Italic, System.Drawing.GraphicsUnit:Point, System.Convert:ToByte(204)).
    this-object:f_max_sum:Location = new System.Drawing.Point(443, 176).
    this-object:f_max_sum:Multiline = true.
    this-object:f_max_sum:Name = "f_max_sum".
    this-object:f_max_sum:Size = new System.Drawing.Size(62, 20).
    this-object:f_max_sum:TabIndex = 8.
    this-object:f_min_sum:AccessibleRole = System.Windows.Forms.AccessibleRole:None.
    this-object:f_min_sum:DataBindings:Add(new System.Windows.Forms.Binding("Text", this-object:bindingSource1, "SummMin", true)).
    this-object:f_min_sum:Font = new System.Drawing.Font("Microsoft Sans Serif", Progress.Util.CastUtil:ToSingle(9), System.Drawing.FontStyle:Italic, System.Drawing.GraphicsUnit:Point, System.Convert:ToByte(204)).
    this-object:f_min_sum:Location = new System.Drawing.Point(284, 176).
    this-object:f_min_sum:Multiline = true.
    this-object:f_min_sum:Name = "f_min_sum".
    this-object:f_min_sum:Size = new System.Drawing.Size(62, 20).
    this-object:f_min_sum:TabIndex = 7.
    this-object:f_auth:DataBindings:Add(new System.Windows.Forms.Binding("Checked", this-object:bindingSource1, "PreAAvt", true)).
    this-object:f_auth:Location = new System.Drawing.Point(12, 296).
    this-object:f_auth:Name = "f_auth".
    this-object:f_auth:Size = new System.Drawing.Size(104, 24).
    this-object:f_auth:TabIndex = 12.
    this-object:f_auth:Text = "Авторизация".
    this-object:f_auth:UseCompatibleTextRendering = true.
    this-object:f_auth:UseVisualStyleBackColor = true.
    this-object:f_print:DataBindings:Add(new System.Windows.Forms.Binding("Checked", this-object:bindingSource1, "PreSlip", true)).
    this-object:f_print:Location = new System.Drawing.Point(12, 326).
    this-object:f_print:Name = "f_print".
    this-object:f_print:Size = new System.Drawing.Size(104, 24).
    this-object:f_print:TabIndex = 13.
    this-object:f_print:Text = "Печать слипа".
    this-object:f_print:UseCompatibleTextRendering = true.
    this-object:f_print:UseVisualStyleBackColor = true.
    this-object:f_print:CheckedChanged:Subscribe(this-object:change_slip).
    this-object:b_cancel:Location = new System.Drawing.Point(88, 12).
    this-object:b_cancel:Name = "b_cancel".
    this-object:b_cancel:Size = new System.Drawing.Size(75, 23).
    this-object:b_cancel:TabIndex = 62.
    this-object:b_cancel:Text = "Отмена".
    this-object:b_cancel:UseCompatibleTextRendering = true.
    this-object:b_cancel:UseVisualStyleBackColor = true.
    this-object:b_cancel:Click:Subscribe(this-object:b_cancel_Click).
    this-object:b_exit:Location = new System.Drawing.Point(12, 12).
    this-object:b_exit:Name = "b_exit".
    this-object:b_exit:Size = new System.Drawing.Size(75, 23).
    this-object:b_exit:TabIndex = 61.
    this-object:b_exit:Text = "Ввод".
    this-object:b_exit:UseCompatibleTextRendering = true.
    this-object:b_exit:UseMnemonic = false.
    this-object:b_exit:UseVisualStyleBackColor = true.
    this-object:b_exit:Click:Subscribe(this-object:b_exit_Click).
    this-object:c_CalcType:FormattingEnabled = true.
    @VisualDesigner.FormMember (NeedsInitialize="false", InitializeArray="true").
    define variable arrayvar3 as System.Object extent 5 no-undo.
    arrayvar3[1] = "Оплата Сотовой связи".
    arrayvar3[2] = "Оплата по договору".
    arrayvar3[3] = "Оплата Счёта".
    arrayvar3[4] = "Начисление на карту".
    arrayvar3[5] = "Платежный агент".
    this-object:c_CalcType:Items:AddRange(arrayvar3).
    this-object:c_CalcType:Location = new System.Drawing.Point(281, 387).
    this-object:c_CalcType:Name = "c_CalcType".
    this-object:c_CalcType:Size = new System.Drawing.Size(224, 21).
    this-object:c_CalcType:TabIndex = 63.
    this-object:c_CalcType:Leave:Subscribe(this-object:leave_CalcType).
    this-object:ClientSize = new System.Drawing.Size(517, 416).
    this-object:Controls:Add(this-object:c_CalcType).
    this-object:Controls:Add(this-object:b_cancel).
    this-object:Controls:Add(this-object:b_exit).
    this-object:Controls:Add(this-object:f_print).
    this-object:Controls:Add(this-object:f_auth).
    this-object:Controls:Add(this-object:label2).
    this-object:Controls:Add(this-object:label8).
    this-object:Controls:Add(this-object:f_max_sum).
    this-object:Controls:Add(this-object:f_min_sum).
    this-object:Controls:Add(this-object:f_commis).
    this-object:Controls:Add(this-object:c_type_commis).
    this-object:Controls:Add(this-object:l_sum).
    this-object:Controls:Add(this-object:label7).
    this-object:Controls:Add(this-object:label6).
    this-object:Controls:Add(this-object:f_max_tel).
    this-object:Controls:Add(this-object:l_type_pay).
    this-object:Controls:Add(this-object:f_name_file).
    this-object:Controls:Add(this-object:l_name_file).
    this-object:Controls:Add(this-object:l_commis).
    this-object:Controls:Add(this-object:l_type_commis).
    this-object:Controls:Add(this-object:f_limit_sum).
    this-object:Controls:Add(this-object:l_limit_sum).
    this-object:Controls:Add(this-object:l_name).
    this-object:Controls:Add(this-object:f_min_tel).
    this-object:Controls:Add(this-object:f_name).
    this-object:Controls:Add(this-object:l_tel).
    this-object:Controls:Add(this-object:f_abbr).
    this-object:Controls:Add(this-object:l_code).
    this-object:Controls:Add(this-object:l_abbr).
    this-object:Controls:Add(this-object:f_code).
    this-object:Name = "OCC_form".
    this-object:Text = "OCC".
    cast(this-object:bindingSource1, System.ComponentModel.ISupportInitialize):EndInit().
    this-object:ResumeLayout(false).
    this-object:PerformLayout().
    catch e as Progress.Lang.Error:
      undo, throw e.
    end catch.
  end method.
  @VisualDesigner.
  method private void leave_CalcType( input sender as System.Object, input e as System.EventArgs ):
    case c_type_commis:Items:ToString():
      when "Оплата Сотовой связи" then
        do:
          OperServ.CalcType = 1 .
        end.
      when "Оплата по договору" then
        do:
          OperServ.CalcType = 2 .
        end.
      when "Оплата Счёта" then
        do:
          OperServ.CalcType = 3 .
        end.
      when "Начисление на карту" then
        do:
          OperServ.CalcType = 4 .
        end.
      when "Платежный агент" then
        do:
          OperServ.CalcType = 5 .
        end.
    end case.
    return.
  end method.
  METHOD PUBLIC VOID Visual_form( INPUT iChange AS character ):
    if iChange = 'ПРОСМОТР':U then
    do:
      assign
        this-object:f_code:ReadOnly = true.
      this-object:f_name:ReadOnly = true.
      this-object:f_abbr:ReadOnly = true.
      this-object:f_auth:Enabled = false.
      this-object:f_commis:ReadOnly = true.
      this-object:f_limit_sum:ReadOnly = true.
      this-object:f_max_sum:ReadOnly = true.
      this-object:f_max_tel:ReadOnly = true.
      this-object:f_min_sum:ReadOnly = true.
      this-object:f_min_tel:ReadOnly = true.
      this-object:f_name_file:ReadOnly = true.
      this-object:f_print:Enabled = false.
      this-object:c_CalcType:Enabled = false.
      this-object:c_type_commis:Enabled = false.
      .
    end.
  END METHOD.
  @VisualDesigner.
  method private void label7_Click( input sender as System.Object, input e as System.EventArgs ):
    return.
  end method.
  @VisualDesigner.
  method private void leave_commis( input sender as System.Object, input e as System.EventArgs ):
    if c_type_commis:Items:ToString() = "Процент" then
    do:
      OperServ.CommPerc = integer(f_commis:Text).
    end.
    else
    do:
      OperServ.CommSumm = integer(f_commis:Text).
    end.
    return.
  end method.
  @VisualDesigner.
  method private void leave_type_commis( input sender as System.Object, input e as System.EventArgs ):
    if c_type_commis:Items:ToString() = "Процент" then
    do:
      OperServ.CommType = 0.
    end.
    else
    do:
      OperServ.CommType = 1.
    end.
    return.
  end method.
  destructor OCC_form ( ):
    bindingSource1:Dispose().
  end destructor.
end class.
