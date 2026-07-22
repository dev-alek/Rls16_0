using Progress.Windows.Form.
using ibs.th.ref.cashbookstorage from propath.
block-level on error undo, throw.
class ibs.th.ref.cashbookobj inherits Form :
define variable vss-include-info0 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
  define variable v-cntxt-db-num        as integer   no-undo .
  define variable v-cntxt-userid        as character no-undo .
  define variable v-cntxt-level         as character no-undo .
  define variable v-cntxt-host-code-obj as integer   no-undo .
  define variable v-cntxt-obj-type      as character no-undo .
  define variable v-cntxt-obj-code      as integer   no-undo .
  define variable v-cntxt-db-num-obj    as integer   no-undo .
  define variable v-cntxt-is-admin      as logical   no-undo .
define temp-table tt-cashbookrule like ub.cashbookrule
  field RkoMask         as character
  field PkoMask         as character
  field currPko         as character
  field currRko         as character
  field ManagerPosition as character
  field ManagerFIO      as character
  field BuhFIO          as character
  field struct          as character
  field uchet           as character
  field DptName         as character
  field DptType         as character
  field DptCode         as integer
  field obj             as character
  field stat            as character
  field Pin             as character
.
define dataset ds-cashbookrule for tt-cashbookrule .
 method private character getMgrPositionName (input p-post-chief as character) :
    define variable v-name as character no-undo .
    case p-post-chief :
      when "1" then v-name = "Директор" .
      when "2" then v-name = "Управляющий" .
      when "0" then v-name = "Должность рук-ля фирмы" .
      otherwise v-name = p-post-chief .
    end case .
    return v-name .
  end method .
 method private character getMgrPositionID (input p-post-chief as character) :
    define variable v-id as character no-undo .
    case p-post-chief :
      when "Директор" then v-id = "1" .
      when "Управляющий" then v-id = "2" .
      when "Должность рук-ля фирмы" then v-id = "0" .
      otherwise v-id = p-post-chief.
    end case .
    return v-id .
  end method .
  method private character getMgrFioName (input p-fio-chief as character) :
    define variable v-name as character no-undo .
    case p-fio-chief :
      when "1" then v-name = "ФИО руководителя магазина" .
      when "0" then v-name = "ФИО руководителя фирмы" .
      otherwise v-name = p-fio-chief .
    end case .
    return v-name .
  end method .
  method private character getMgrFioID (input p-fio-chief as character) :
    define variable v-id as character no-undo .
    case p-fio-chief :
      when "ФИО руководителя магазина" then v-id = "1" .
      when "ФИО руководителя фирмы" then v-id = "0" .
        otherwise v-id = p-fio-chief .
    end case .
    return v-id .
  end method .
  method private character getBuhFioName (input p-fio-booker as character) :
    define variable v-name as character no-undo .
    case p-fio-booker :
      when "1" then v-name = "ФИО бухгалтера магазина" .
      when "0" then v-name = "ФИО гл. бухгалтера фирмы" .
      otherwise v-name = p-fio-booker .
    end case .
    return v-name .
  end method .
  method private character getBuhFioID (input p-fio-booker as character) :
    define variable v-id as character no-undo .
    case p-fio-booker :
      when "ФИО бухгалтера магазина" then v-id = "1" .
      when "ФИО гл. бухгалтера фирмы" then v-id = "0" .
      otherwise v-id = p-fio-booker .
    end case .
    return v-id .
  end method .
  method private character getStructName (input p-struct-unit as integer) :
    define variable v-name as character no-undo .
    case p-struct-unit :
      when 1 then v-name = "Взять из объекта" .
      when 2 then v-name = "Значение по умолчанию" .
      when 0 then v-name = "Заполняет оператор" .
        otherwise v-name = string(p-struct-unit) .
    end case .
    return v-name .
  end method .
  method private character getStructID (input p-struct-unit as character) :
    define variable v-id as character no-undo .
    case p-struct-unit :
      when "Взять из объекта" then v-id = "1" .
      when "Значение по умолчанию" then v-id = "2" .
      when "Заполняет оператор" then v-id = "0" .
        otherwise v-id = p-struct-unit .
    end case .
    return v-id .
  end method .
  method private character getUchetName (input p-acc-shift as integer) :
    define variable v-name as character no-undo .
    case p-acc-shift :
      when 1 then v-name = "по сменным датам" .
      when 0 then v-name = "по календарным датам" .
        otherwise v-name = string (p-acc-shift) .
    end case .
    return v-name .
  end method .
  method private character getUchetID (input p-acc-shift as character) :
    define variable v-id as character no-undo .
    case p-acc-shift :
      when "по сменным датам" then v-id = "1" .
      when "по календарным датам" then v-id = "0" .
        otherwise v-id = p-acc-shift .
    end case .
    return v-id .
  end method .
  define private variable bindingSource1 as Progress.Data.BindingSource no-undo.
  define private variable bObj as System.Windows.Forms.Button no-undo.
  define private variable components as System.ComponentModel.IContainer no-undo.
  define private variable buttonOk as System.Windows.Forms.Button no-undo.
  define private variable buttonCancel as System.Windows.Forms.Button no-undo.
  define private variable fBuhFIO as System.Windows.Forms.ComboBox no-undo.
  define private variable fCurrRko as System.Windows.Forms.TextBox no-undo.
  define private variable fCurrPKO as System.Windows.Forms.TextBox no-undo.
  define private variable fDptCode as System.Windows.Forms.TextBox no-undo.
  define private variable fDptName as System.Windows.Forms.TextBox no-undo.
  define private variable fDptType as System.Windows.Forms.TextBox no-undo.
  define private variable fManagerFIO as System.Windows.Forms.ComboBox no-undo.
  define private variable fManagerPosition as System.Windows.Forms.ComboBox no-undo.
  define private variable fMaskRko as System.Windows.Forms.TextBox no-undo.
  define private variable fMaskPko as System.Windows.Forms.TextBox no-undo.
  define private variable fObjCode as System.Windows.Forms.TextBox no-undo.
  define private variable fStruct as System.Windows.Forms.ComboBox no-undo.
  define private variable fUchet as System.Windows.Forms.ComboBox no-undo.
  define private variable label1 as System.Windows.Forms.Label no-undo.
  define private variable label10 as System.Windows.Forms.Label no-undo.
  define private variable label11 as System.Windows.Forms.Label no-undo.
  define private variable label12 as System.Windows.Forms.Label no-undo.
  define private variable label13 as System.Windows.Forms.Label no-undo.
   define private variable label14 as System.Windows.Forms.Label no-undo.
  define private variable label2 as System.Windows.Forms.Label no-undo.
  define private variable label3 as System.Windows.Forms.Label no-undo.
  define private variable label7 as System.Windows.Forms.Label no-undo.
  define private variable label6 as System.Windows.Forms.Label no-undo.
  define private variable label5 as System.Windows.Forms.Label no-undo.
  define private variable label4 as System.Windows.Forms.Label no-undo.
  define private variable label9 as System.Windows.Forms.Label no-undo.
  define private variable label8 as System.Windows.Forms.Label no-undo.
  define         variable mCashBook as class ibs.th.ref.cashbookstorage no-undo .
   define private variable textBox1 as System.Windows.Forms.TextBox no-undo.
  define variable v-cashbookID as int64 no-undo .
  define variable v-obj-code  as integer no-undo .
  define variable v-obj-type  as character no-undo .
  define buffer buf_cashbook for ub.cashbook .
  define buffer buf_cashbookrule for ub.cashbookrule .
  define property parparentproc as handle no-undo
  private get.
  set(input iH as handle):
        parparentproc = ih.
  end.
  constructor public cashbookobj (inParparentproc as handle, Mode as character, p-id as int64, p-obj-code as integer, p-obj-type as character):
    super().
    parparentproc = inParparentproc .
define variable vss-include-info1 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
  run mainmenu_getcntxt in parparentproc
    (output v-cntxt-db-num
    ,output v-cntxt-userid
    ,output v-cntxt-level
    ,output v-cntxt-host-code-obj
    ,output v-cntxt-obj-type
    ,output v-cntxt-obj-code
    ,output v-cntxt-db-num-obj
    ,output v-cntxt-is-admin
    ) .
    v-cashbookID = p-id .
    v-obj-code = p-obj-code .
    v-obj-type = p-obj-type .
    mCashBook = new cashbookstorage () .
    empty temp-table tt-cashbookrule .
    case Mode:
      when 'ДОБАВЛЕНИЕ':U then
      do:
        create tt-CashBookrule .
        assign
          tt-cashbookrule.host-code = ?
          tt-cashbookrule.cashbookID = v-cashbookID
          tt-cashbookrule.obj-type   =  p-obj-type
          tt-cashbookrule.obj-code   =  p-obj-code
        .
      end.
      when 'ИЗМЕНЕНИЕ':U
      or when 'ПРОСМОТР':U then
      do:
        mCashBook:getCashBookRule(input v-cashbookID, input v-obj-type, input v-obj-code, output dataset ds-cashbookrule) .
        find first tt-cashbookrule exclusive-lock .
        tt-cashbookrule.obj = tt-cashbookrule.Obj-type + string(tt-cashbookrule.obj-code) .
      end.
    end case .
    InitializeComponent().
    Visual_form(Mode).
    bindingSource1:Handle = buffer tt-CashBookRule:handle .
    this-object:ComponentsCollection:ADD(this-object:components).
    catch e as Progress.Lang.Error:
      undo, throw e.
    end catch.
  end constructor.
  constructor public cashbookobj( ):
      super().
      InitializeComponent ( ).
      catch e as Progress.Lang.Error:
         undo, throw e.
      end catch.
  end constructor.
  destructor public cashbookobj( ):
    delete object mCashBook no-error .
      if valid-object(components) then do:
         cast(components, System.IDisposable):Dispose().
      end.
  end destructor.
        @VisualDesigner.
        method private void bObj_Click( input sender as System.Object, input e as System.EventArgs ):
                define variable ref-rec as recid no-undo .
    define variable ref-list as character no-undo.
    run ref/cli-all.w ( input parParentProc
                     ,input "b-add,b-sel"
                     ,input 'все':U
                     ,input ?
                     ,input ?
                     ,input ?
                     ,input ?
                     ,input ?
                     ,output ref-list) .
    if ref-list = "" then do:
      return .
    end.
    ref-rec = integer( ref-list ).
    FIND ub.clients WHERE recid (ub.clients) = ref-rec NO-LOCK .
    if ub.clients.obj-type = 'чел':U
    then do :
      message "Нельзя добавлять настройки для физического лица!" view-as alert-box .
      return.
    end.
    if ub.clients.obj-type = 'скл':U
    then do :
      message "Нельзя добавлять настройки для склада!" view-as alert-box .
      return.
    end.
    if ub.clients.obj-type = 'орг':U
    then do :
      find first ub.sysconf no-lock where ub.sysconf.host-code = ub.clients.obj-code no-error.
      if not available ub.sysconf
      then do :
        message "Можно выбрать только свою фирму!" view-as alert-box .
        return.
      end.
    end.
    this-object:fObjCode:Text = ub.clients.obj-type + string(ub.clients.obj-code) .
    this-object:fObjCode:Focus().
    assign
      tt-CashBookrule.Obj-code = ub.clients.obj-code
      tt-CashBookrule.Obj-type = ub.clients.obj-type
      tt-CashBookrule.host-code = if ub.clients.obj-type = 'орг':U then string(ub.clients.obj-code) else string(ub.clients.host-code)
    .
    if tt-CashBookrule.Obj-type = 'орг':U
    then do :
      assign
        this-object:fCurrRKO:Enabled = false
        this-object:fCurrPKO:Enabled = false
      .
    end.
    else do :
      assign
        this-object:fCurrRKO:Enabled = true
        this-object:fCurrPKO:Enabled = true
      .
    end.
                return.
        end method.
        @VisualDesigner.
        method private void fStruct_TextChanged( input sender as System.Object, input e as System.EventArgs ):
                if fStruct:Text = "Значение по умолчанию"
    then do :
      assign
        fDptName:visible = true
        fDptType:visible = true
        fDptCode:visible = true
        label11:visible = true
        label12:visible = true
        label13:visible = true
      .
    end.
    else do :
      assign
        fDptName:text = ""
        fDptType:text = ""
        fDptCode:text = "0"
      .
      fDptName:Focus() .
      fDptType:Focus() .
      fDptCode:Focus() .
      assign
        fDptName:visible = false
        fDptType:visible = false
        fDptCode:visible = false
        label11:visible = false
        label12:visible = false
        label13:visible = false
      .
    end.
                return.
        end method.
  method private void okButton_Click (sender as System.Object, e as System.EventArgs):
      bindingSource1:Assign().
      tt-cashbookrule.obj = tt-cashbookrule.obj-type + string(tt-cashbookrule.obj-code) .
      mCashBook:updateDBobj(input dataset ds-cashbookrule) .
      if mCashBook:Msg <> ""
      then do :
        message mCashBook:Msg view-as alert-box .
        return .
      end.
      this-object:DialogResult = System.Windows.Forms.DialogResult:Ok.
      this-object:Close ( ).
  end method.
  method private void cancelButton_Click (sender as System.Object, e as System.EventArgs):
      this-object:DialogResult = System.Windows.Forms.DialogResult:Cancel.
      this-object:Close ( ).
  end method.
  method private void InitializeComponent ( ):
      this-object:components = new System.ComponentModel.Container().
      @VisualDesigner.FormMember (NeedsInitialize="true").
      define variable tableDesc1 as Progress.Data.TableDesc no-undo.
      tableDesc1 = new Progress.Data.TableDesc("tt-cashbook-rule").
      this-object:buttonOk = new System.Windows.Forms.Button().
      this-object:buttonCancel = new System.Windows.Forms.Button().
      this-object:fObjCode = new System.Windows.Forms.TextBox().
      this-object:bindingSource1 = new Progress.Data.BindingSource(this-object:components).
      this-object:label2 = new System.Windows.Forms.Label().
      this-object:bObj = new System.Windows.Forms.Button().
      this-object:label8 = new System.Windows.Forms.Label().
      this-object:label9 = new System.Windows.Forms.Label().
      this-object:fMaskPko = new System.Windows.Forms.TextBox().
      this-object:fMaskRko = new System.Windows.Forms.TextBox().
      this-object:fCurrRko = new System.Windows.Forms.TextBox().
      this-object:fCurrPKO = new System.Windows.Forms.TextBox().
      this-object:label1 = new System.Windows.Forms.Label().
      this-object:label3 = new System.Windows.Forms.Label().
      this-object:label4 = new System.Windows.Forms.Label().
      this-object:label5 = new System.Windows.Forms.Label().
      this-object:label6 = new System.Windows.Forms.Label().
      this-object:label7 = new System.Windows.Forms.Label().
      this-object:label10 = new System.Windows.Forms.Label().
      this-object:fManagerPosition = new System.Windows.Forms.ComboBox().
      this-object:fManagerFIO = new System.Windows.Forms.ComboBox().
      this-object:fBuhFIO = new System.Windows.Forms.ComboBox().
      this-object:fStruct = new System.Windows.Forms.ComboBox().
      this-object:fUchet = new System.Windows.Forms.ComboBox().
      this-object:label11 = new System.Windows.Forms.Label().
      this-object:fDptName = new System.Windows.Forms.TextBox().
      this-object:label12 = new System.Windows.Forms.Label().
      this-object:fDptType = new System.Windows.Forms.TextBox().
      this-object:label13 = new System.Windows.Forms.Label().
      this-object:fDptCode = new System.Windows.Forms.TextBox().
      this-object:textBox1 = new System.Windows.Forms.TextBox().
      this-object:label14 = new System.Windows.Forms.Label().
      cast(this-object:bindingSource1, System.ComponentModel.ISupportInitialize):BeginInit().
      this-object:SuspendLayout().
      this-object:buttonOk:Location = new System.Drawing.Point(12, 12).
      this-object:buttonOk:Name = "buttonOk".
      this-object:buttonOk:Size = new System.Drawing.Size(75, 23).
      this-object:buttonOk:TabIndex = 0.
      this-object:buttonOk:Text = "Ввод".
      this-object:buttonOk:UseCompatibleTextRendering = true.
      this-object:buttonOk:Click:Subscribe(this-object:okButton_Click).
      this-object:buttonCancel:DialogResult = System.Windows.Forms.DialogResult:Cancel.
      this-object:buttonCancel:Location = new System.Drawing.Point(93, 12).
      this-object:buttonCancel:Name = "buttonCancel".
      this-object:buttonCancel:Size = new System.Drawing.Size(75, 23).
      this-object:buttonCancel:TabIndex = 1.
      this-object:buttonCancel:Text = "Отмена".
      this-object:buttonCancel:UseCompatibleTextRendering = true.
      this-object:buttonCancel:Click:Subscribe(this-object:cancelButton_Click).
      this-object:fObjCode:DataBindings:Add(new System.Windows.Forms.Binding("Text", this-object:bindingSource1, "obj", true)).
      this-object:fObjCode:Location = new System.Drawing.Point(68, 44).
      this-object:fObjCode:Name = "fObjCode".
      this-object:fObjCode:Size = new System.Drawing.Size(100, 20).
      this-object:fObjCode:TabIndex = 1.
      this-object:bindingSource1:MaxDataGuess = 0.
      this-object:bindingSource1:NoLOBs = false.
      this-object:bindingSource1:Position = 0.
      @VisualDesigner.FormMember (NeedsInitialize="false", InitializeArray="true").
      define variable arrayvar0 as "Progress.Data.TableDesc[]" no-undo.
      arrayvar0 = new "Progress.Data.TableDesc[]"(0).
      tableDesc1:ChildTables = arrayvar0.
      @VisualDesigner.FormMember (NeedsInitialize="false", InitializeArray="true").
      define variable arrayvar1 as Progress.Data.ColumnPropDesc extent 18 no-undo.
      arrayvar1[1] = new Progress.Data.ColumnPropDesc("mark", "*", Progress.Data.DataType:CHARACTER).
      arrayvar1[2] = new Progress.Data.ColumnPropDesc("id", "id", Progress.Data.DataType:INT64).
      arrayvar1[3] = new Progress.Data.ColumnPropDesc("cashbookId", "cashbookId", Progress.Data.DataType:INT64).
      arrayvar1[4] = new Progress.Data.ColumnPropDesc("ManagerPosition", "Должность руководителя", Progress.Data.DataType:CHARACTER).
      arrayvar1[5] = new Progress.Data.ColumnPropDesc("PkoMask", "Маска номера ПКО", Progress.Data.DataType:CHARACTER).
      arrayvar1[6] = new Progress.Data.ColumnPropDesc("RkoMask", "Маска номера РКО", Progress.Data.DataType:CHARACTER).
      arrayvar1[7] = new Progress.Data.ColumnPropDesc("currPko", "Текущий номер ПКО", Progress.Data.DataType:CHARACTER).
      arrayvar1[8] = new Progress.Data.ColumnPropDesc("currRko", "Текущий номер РКО", Progress.Data.DataType:CHARACTER).
      arrayvar1[9] = new Progress.Data.ColumnPropDesc("status_", "Статус", Progress.Data.DataType:INTEGER).
      arrayvar1[10] = new Progress.Data.ColumnPropDesc("obj", "Объект", Progress.Data.DataType:CHARACTER).
      arrayvar1[11] = new Progress.Data.ColumnPropDesc("ManagerFIO", "ФИО руководителя", Progress.Data.DataType:CHARACTER).
      arrayvar1[12] = new Progress.Data.ColumnPropDesc("BuhFIO", "ФИО Бухгалтера", Progress.Data.DataType:CHARACTER).
      arrayvar1[13] = new Progress.Data.ColumnPropDesc("Struct", "Поле ~"Структурное подразделение~"", Progress.Data.DataType:CHARACTER).
      arrayvar1[14] = new Progress.Data.ColumnPropDesc("uchet", "Учёт ведётся", Progress.Data.DataType:CHARACTER).
      arrayvar1[15] = new Progress.Data.ColumnPropDesc("DptName", "DptName", Progress.Data.DataType:CHARACTER).
      arrayvar1[16] = new Progress.Data.ColumnPropDesc("DptType", "DptType", Progress.Data.DataType:CHARACTER).
      arrayvar1[17] = new Progress.Data.ColumnPropDesc("DptCode", "DptCode", Progress.Data.DataType:INTEGER).
      arrayvar1[18] = new Progress.Data.ColumnPropDesc("Pin", "ПИН", Progress.Data.DataType:CHARACTER).
      tableDesc1:Columns = arrayvar1.
      this-object:bindingSource1:TableSchema = tableDesc1.
      this-object:label2:Location = new System.Drawing.Point(12, 47).
      this-object:label2:Name = "label2".
      this-object:label2:Size = new System.Drawing.Size(105, 23).
      this-object:label2:TabIndex = 4.
      this-object:label2:Text = "Объект:".
      this-object:label2:UseCompatibleTextRendering = true.
      this-object:bObj:Location = new System.Drawing.Point(179, 42).
      this-object:bObj:Name = "bObj".
      this-object:bObj:Size = new System.Drawing.Size(22, 23).
      this-object:bObj:TabIndex = 2.
      this-object:bObj:UseCompatibleTextRendering = true.
      this-object:bObj:UseVisualStyleBackColor = true.
      this-object:bObj:Click:Subscribe(this-object:bObj_Click).
      this-object:label8:Location = new System.Drawing.Point(12, 208).
      this-object:label8:Name = "label8".
      this-object:label8:Size = new System.Drawing.Size(233, 23).
      this-object:label8:TabIndex = 26.
      this-object:label8:Text = "Маска номера ПКО:".
      this-object:label8:UseCompatibleTextRendering = true.
      this-object:label9:Location = new System.Drawing.Point(12, 231).
      this-object:label9:Name = "label9".
      this-object:label9:Size = new System.Drawing.Size(233, 23).
      this-object:label9:TabIndex = 27.
      this-object:label9:Text = "Маска номера РКО:".
      this-object:label9:UseCompatibleTextRendering = true.
      this-object:fMaskPko:DataBindings:Add(new System.Windows.Forms.Binding("Text", this-object:bindingSource1, "PkoMask", true)).
      this-object:fMaskPko:Location = new System.Drawing.Point(179, 205).
      this-object:fMaskPko:Name = "fMaskPko".
      this-object:fMaskPko:Size = new System.Drawing.Size(231, 20).
      this-object:fMaskPko:TabIndex = 3.
      this-object:fMaskRko:DataBindings:Add(new System.Windows.Forms.Binding("Text", this-object:bindingSource1, "RkoMask", true)).
      this-object:fMaskRko:Location = new System.Drawing.Point(179, 228).
      this-object:fMaskRko:Name = "fMaskRko".
      this-object:fMaskRko:Size = new System.Drawing.Size(231, 20).
      this-object:fMaskRko:TabIndex = 4.
      this-object:fCurrRko:DataBindings:Add(new System.Windows.Forms.Binding("Text", this-object:bindingSource1, "currRko", true)).
      this-object:fCurrRko:Enabled = false.
      this-object:fCurrRko:Location = new System.Drawing.Point(179, 274).
      this-object:fCurrRko:Name = "fCurrRko".
      this-object:fCurrRko:Size = new System.Drawing.Size(231, 20).
      this-object:fCurrRko:TabIndex = 29.
      this-object:fCurrPKO:DataBindings:Add(new System.Windows.Forms.Binding("Text", this-object:bindingSource1, "currPko", true)).
      this-object:fCurrPKO:Enabled = false.
      this-object:fCurrPKO:Location = new System.Drawing.Point(179, 251).
      this-object:fCurrPKO:Name = "fCurrPKO".
      this-object:fCurrPKO:Size = new System.Drawing.Size(231, 20).
      this-object:fCurrPKO:TabIndex = 28.
      this-object:label1:Location = new System.Drawing.Point(12, 277).
      this-object:label1:Name = "label1".
      this-object:label1:Size = new System.Drawing.Size(233, 23).
      this-object:label1:TabIndex = 31.
      this-object:label1:Text = "Текущий номер РКО:".
      this-object:label1:UseCompatibleTextRendering = true.
      this-object:label3:Location = new System.Drawing.Point(12, 254).
      this-object:label3:Name = "label3".
      this-object:label3:Size = new System.Drawing.Size(233, 23).
      this-object:label3:TabIndex = 30.
      this-object:label3:Text = "Текущий номер ПКО:".
      this-object:label3:UseCompatibleTextRendering = true.
      this-object:label4:Location = new System.Drawing.Point(12, 70).
      this-object:label4:Name = "label4".
      this-object:label4:Size = new System.Drawing.Size(233, 23).
      this-object:label4:TabIndex = 33.
      this-object:label4:Text = "Должность руководителя:".
      this-object:label4:UseCompatibleTextRendering = true.
      this-object:label5:Location = new System.Drawing.Point(12, 93).
      this-object:label5:Name = "label5".
      this-object:label5:Size = new System.Drawing.Size(233, 23).
      this-object:label5:TabIndex = 35.
      this-object:label5:Text = "ФИО руководителя:".
      this-object:label5:UseCompatibleTextRendering = true.
      this-object:label6:Location = new System.Drawing.Point(12, 116).
      this-object:label6:Name = "label6".
      this-object:label6:Size = new System.Drawing.Size(233, 23).
      this-object:label6:TabIndex = 37.
      this-object:label6:Text = "ФИО бухгалтера:".
      this-object:label6:UseCompatibleTextRendering = true.
      this-object:label7:Location = new System.Drawing.Point(12, 139).
      this-object:label7:Name = "label7".
      this-object:label7:Size = new System.Drawing.Size(233, 23).
      this-object:label7:TabIndex = 39.
      this-object:label7:Text = "Структурное подразделение:".
      this-object:label7:UseCompatibleTextRendering = true.
      this-object:label10:Location = new System.Drawing.Point(12, 185).
      this-object:label10:Name = "label10".
      this-object:label10:Size = new System.Drawing.Size(233, 23).
      this-object:label10:TabIndex = 41.
      this-object:label10:Text = "Учет ведется:".
      this-object:label10:UseCompatibleTextRendering = true.
      this-object:fManagerPosition:DataBindings:Add(new System.Windows.Forms.Binding("Text", this-object:bindingSource1, "ManagerPosition", true)).
      this-object:fManagerPosition:FormattingEnabled = true.
      @VisualDesigner.FormMember (NeedsInitialize="false", InitializeArray="true").
      define variable arrayvar2 as System.Object extent 3 no-undo.
      arrayvar2[1] = "Должность рук-ля фирмы".
      arrayvar2[2] = "Директор".
      arrayvar2[3] = "Управляющий".
      this-object:fManagerPosition:Items:AddRange(arrayvar2).
      this-object:fManagerPosition:Location = new System.Drawing.Point(179, 67).
      this-object:fManagerPosition:Name = "fManagerPosition".
      this-object:fManagerPosition:Size = new System.Drawing.Size(231, 21).
      this-object:fManagerPosition:TabIndex = 42.
      this-object:fManagerFIO:DataBindings:Add(new System.Windows.Forms.Binding("Text", this-object:bindingSource1, "ManagerFIO", true)).
      this-object:fManagerFIO:FormattingEnabled = true.
      @VisualDesigner.FormMember (NeedsInitialize="false", InitializeArray="true").
      define variable arrayvar3 as System.Object extent 2 no-undo.
      arrayvar3[1] = "ФИО руководителя фирмы".
      arrayvar3[2] = "ФИО руководителя магазина".
      this-object:fManagerFIO:Items:AddRange(arrayvar3).
      this-object:fManagerFIO:Location = new System.Drawing.Point(179, 90).
      this-object:fManagerFIO:Name = "fManagerFIO".
      this-object:fManagerFIO:Size = new System.Drawing.Size(231, 21).
      this-object:fManagerFIO:TabIndex = 43.
      this-object:fBuhFIO:DataBindings:Add(new System.Windows.Forms.Binding("Text", this-object:bindingSource1, "BuhFIO", true)).
      this-object:fBuhFIO:FormattingEnabled = true.
      @VisualDesigner.FormMember (NeedsInitialize="false", InitializeArray="true").
      define variable arrayvar4 as System.Object extent 2 no-undo.
      arrayvar4[1] = "ФИО гл. бухгалтера фирмы".
      arrayvar4[2] = "ФИО бухгалтера магазина".
      this-object:fBuhFIO:Items:AddRange(arrayvar4).
      this-object:fBuhFIO:Location = new System.Drawing.Point(179, 113).
      this-object:fBuhFIO:Name = "fBuhFIO".
      this-object:fBuhFIO:Size = new System.Drawing.Size(231, 21).
      this-object:fBuhFIO:TabIndex = 44.
      this-object:fStruct:DataBindings:Add(new System.Windows.Forms.Binding("Text", this-object:bindingSource1, "Struct", true)).
      this-object:fStruct:DropDownStyle = System.Windows.Forms.ComboBoxStyle:DropDownList.
      this-object:fStruct:FormattingEnabled = true.
      @VisualDesigner.FormMember (NeedsInitialize="false", InitializeArray="true").
      define variable arrayvar5 as System.Object extent 3 no-undo.
      arrayvar5[1] = "Заполняет оператор".
      arrayvar5[2] = "Взять из объекта".
      arrayvar5[3] = "Значение по умолчанию".
      this-object:fStruct:Items:AddRange(arrayvar5).
      this-object:fStruct:Location = new System.Drawing.Point(179, 136).
      this-object:fStruct:Name = "fStruct".
      this-object:fStruct:Size = new System.Drawing.Size(231, 21).
      this-object:fStruct:TabIndex = 45.
      this-object:fStruct:TextChanged:Subscribe(this-object:fStruct_TextChanged).
      this-object:fUchet:DataBindings:Add(new System.Windows.Forms.Binding("Text", this-object:bindingSource1, "uchet", true)).
      this-object:fUchet:DropDownStyle = System.Windows.Forms.ComboBoxStyle:DropDownList.
      this-object:fUchet:FormattingEnabled = true.
      @VisualDesigner.FormMember (NeedsInitialize="false", InitializeArray="true").
      define variable arrayvar6 as System.Object extent 2 no-undo.
      arrayvar6[1] = "по сменным датам".
      arrayvar6[2] = "по календарным датам".
      this-object:fUchet:Items:AddRange(arrayvar6).
      this-object:fUchet:Location = new System.Drawing.Point(179, 182).
      this-object:fUchet:Name = "fUchet".
      this-object:fUchet:Size = new System.Drawing.Size(231, 21).
      this-object:fUchet:TabIndex = 46.
      this-object:label11:Location = new System.Drawing.Point(12, 162).
      this-object:label11:Name = "label11".
      this-object:label11:Size = new System.Drawing.Size(61, 17).
      this-object:label11:TabIndex = 47.
      this-object:label11:Text = "Название:".
      this-object:label11:UseCompatibleTextRendering = true.
      this-object:label11:Visible = false.
      this-object:fDptName:DataBindings:Add(new System.Windows.Forms.Binding("Text", this-object:bindingSource1, "DptName", true)).
      this-object:fDptName:Location = new System.Drawing.Point(73, 159).
      this-object:fDptName:Name = "fDptName".
      this-object:fDptName:Size = new System.Drawing.Size(172, 20).
      this-object:fDptName:TabIndex = 48.
      this-object:fDptName:Visible = false.
      this-object:label12:Location = new System.Drawing.Point(251, 162).
      this-object:label12:Name = "label12".
      this-object:label12:Size = new System.Drawing.Size(30, 17).
      this-object:label12:TabIndex = 49.
      this-object:label12:Text = "Тип:".
      this-object:label12:UseCompatibleTextRendering = true.
      this-object:label12:Visible = false.
      this-object:fDptType:DataBindings:Add(new System.Windows.Forms.Binding("Text", this-object:bindingSource1, "DptType", true)).
      this-object:fDptType:Location = new System.Drawing.Point(277, 159).
      this-object:fDptType:Name = "fDptType".
      this-object:fDptType:Size = new System.Drawing.Size(35, 20).
      this-object:fDptType:TabIndex = 50.
      this-object:fDptType:Visible = false.
      this-object:label13:Location = new System.Drawing.Point(318, 162).
      this-object:label13:Name = "label13".
      this-object:label13:Size = new System.Drawing.Size(30, 17).
      this-object:label13:TabIndex = 51.
      this-object:label13:Text = "Код:".
      this-object:label13:UseCompatibleTextRendering = true.
      this-object:label13:Visible = false.
      this-object:fDptCode:DataBindings:Add(new System.Windows.Forms.Binding("Text", this-object:bindingSource1, "DptCode", true)).
      this-object:fDptCode:Location = new System.Drawing.Point(344, 159).
      this-object:fDptCode:Name = "fDptCode".
      this-object:fDptCode:Size = new System.Drawing.Size(66, 20).
      this-object:fDptCode:TabIndex = 52.
      this-object:fDptCode:Visible = false.
      this-object:textBox1:DataBindings:Add(new System.Windows.Forms.Binding("Text", this-object:bindingSource1, "Pin", true)).
      this-object:textBox1:Location = new System.Drawing.Point(179, 300).
      this-object:textBox1:Name = "textBox1".
      this-object:textBox1:Size = new System.Drawing.Size(231, 20).
      this-object:textBox1:TabIndex = 53.
      this-object:label14:Location = new System.Drawing.Point(12, 297).
      this-object:label14:Name = "label14".
      this-object:label14:Size = new System.Drawing.Size(100, 23).
      this-object:label14:TabIndex = 54.
      this-object:label14:Text = "ПИН:".
      this-object:label14:UseCompatibleTextRendering = true.
      this-object:AcceptButton = this-object:buttonOk.
      this-object:CancelButton = this-object:buttonCancel.
      this-object:ClientSize = new System.Drawing.Size(422, 343).
      this-object:Controls:Add(this-object:label14).
      this-object:Controls:Add(this-object:textBox1).
      this-object:Controls:Add(this-object:fDptCode).
      this-object:Controls:Add(this-object:label13).
      this-object:Controls:Add(this-object:fDptType).
      this-object:Controls:Add(this-object:label12).
      this-object:Controls:Add(this-object:fDptName).
      this-object:Controls:Add(this-object:label11).
      this-object:Controls:Add(this-object:fUchet).
      this-object:Controls:Add(this-object:fStruct).
      this-object:Controls:Add(this-object:fBuhFIO).
      this-object:Controls:Add(this-object:fManagerFIO).
      this-object:Controls:Add(this-object:fManagerPosition).
      this-object:Controls:Add(this-object:label10).
      this-object:Controls:Add(this-object:label7).
      this-object:Controls:Add(this-object:label6).
      this-object:Controls:Add(this-object:label5).
      this-object:Controls:Add(this-object:label4).
      this-object:Controls:Add(this-object:fCurrRko).
      this-object:Controls:Add(this-object:fCurrPKO).
      this-object:Controls:Add(this-object:label1).
      this-object:Controls:Add(this-object:label3).
      this-object:Controls:Add(this-object:fMaskRko).
      this-object:Controls:Add(this-object:fMaskPko).
      this-object:Controls:Add(this-object:label9).
      this-object:Controls:Add(this-object:label8).
      this-object:Controls:Add(this-object:bObj).
      this-object:Controls:Add(this-object:fObjCode).
      this-object:Controls:Add(this-object:label2).
      this-object:Controls:Add(this-object:buttonCancel).
      this-object:Controls:Add(this-object:buttonOk).
      this-object:FormBorderStyle = System.Windows.Forms.FormBorderStyle:FixedDialog.
      this-object:MaximizeBox = false.
      this-object:MinimizeBox = false.
      this-object:Name = "cashbookobj".
      this-object:ShowInTaskbar = false.
      this-object:StartPosition = System.Windows.Forms.FormStartPosition:CenterParent.
      this-object:Text = "Настройки для объекта".
      cast(this-object:bindingSource1, System.ComponentModel.ISupportInitialize):EndInit().
      this-object:ResumeLayout(false).
      this-object:PerformLayout().
      catch e as Progress.Lang.Error:
         undo, throw e.
      end catch.
   end method.
  method public void ShowModalDialog(  ):
      wait-for this-object:ShowDialog().
  end method.
  method public void Visual_form( input iChange AS character ):
    if iChange = 'ПРОСМОТР':U then
    do:
      assign
        this-object:fObjCode:ReadOnly = true
        this-object:fMaskPko:ReadOnly = true
        this-object:fMaskRko:ReadOnly = true
        this-object:fDptName:ReadOnly = true
        this-object:fDptType:ReadOnly = true
        this-object:fDptCode:ReadOnly = true
        this-object:fBuhFIO:Enabled = false
        this-object:fManagerFIO:Enabled = false
        this-object:fManagerPosition:Enabled = false
        this-object:fStruct:Enabled = false
        this-object:fUchet:Enabled = false
        this-object:fCurrPKO:ReadOnly = true
        this-object:fCurrRKO:ReadOnly = true
        this-object:bObj:Enabled = false
        this-object:buttonOk:Enabled = false
      .
    end.
    if iChange = 'ИЗМЕНЕНИЕ':U then
    do:
      assign
        this-object:fObjCode:ReadOnly = true
        this-object:bObj:Enabled = false
      .
      define variable v-log as logical no-undo .
      define variable v-log2 as logical no-undo .
      v-log = true .
define variable vss-include-info2 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
do:
  run chk-actg in ibs.th.gbl.gbl-hndllib:g#library2
    (input  v-cntxt-db-num
    ,input  v-cntxt-userid
    ,input  0
    ,input  'actn_fin-cashbook_update':U
    ,input  'global':U
    ,input  0
    ,input  '':U
    ,input  0
    ,input  0
    ,input  0
    ,input  0
    ,input  false
    ,output v-log
    )  .
end.
      v-log2 = true .
define variable vss-include-info3 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
do:
  run chk-actg in ibs.th.gbl.gbl-hndllib:g#library2
    (input  v-cntxt-db-num
    ,input  v-cntxt-userid
    ,input  0
    ,input  'actn_fin-counter_update':U
    ,input  'object':U
    ,input  v-cntxt-host-code-obj
    ,input  v-cntxt-obj-type
    ,input  v-cntxt-obj-code
    ,input  0
    ,input  0
    ,input  0
    ,input  false
    ,output v-log2
    )  .
end.
      define variable v-cntxt-db-num  as integer no-undo.
      assign
        this-object:fMaskPko:ReadOnly = not (v-log and v-cntxt-db-num = 0)
        this-object:fMaskRko:ReadOnly = not (v-log and v-cntxt-db-num = 0)
        this-object:fDptName:ReadOnly = not (v-log and v-cntxt-db-num = 0)
        this-object:fDptType:ReadOnly = not (v-log and v-cntxt-db-num = 0)
        this-object:fDptCode:ReadOnly = not (v-log and v-cntxt-db-num = 0)
        this-object:fBuhFIO:Enabled = (v-log and v-cntxt-db-num = 0)
        this-object:fManagerFIO:Enabled = (v-log and v-cntxt-db-num = 0)
        this-object:fManagerPosition:Enabled = (v-log and v-cntxt-db-num = 0)
        this-object:fStruct:Enabled = (v-log and v-cntxt-db-num = 0)
        this-object:fUchet:Enabled = (v-log and v-cntxt-db-num = 0)
        this-object:buttonOk:Enabled = (v-log and v-cntxt-db-num = 0) or v-log2
      .
      if tt-CashBookrule.Obj-type = 'орг':U
      then do :
        assign
          this-object:fCurrRKO:Enabled = false
          this-object:fCurrPKO:Enabled = false
        .
      end.
      else do :
        assign
          this-object:fCurrRKO:Enabled = v-log2
          this-object:fCurrPKO:Enabled = v-log2
        .
      end.
    end.
    return.
  end method .
end class.
