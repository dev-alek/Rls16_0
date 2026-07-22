/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$
  
"Просмотр/редактирование одной акции"

Автор: Рубан Дмитрий Андреевич
Дата создания: 11/07/18
Author: 
Creation date: 11/07/18

*/
using Progress.Windows.Form.
  
block-level on error undo, throw.
class ibs.th.ref.promo.dPromoActions inherits Form : 
    { cmp/str-glbl.i class }
  define variable vss-revision    as character no-undo initial "$Revision$":U .
  define variable vss-author      as character no-undo initial "$Author$":U .
  define variable vss-date        as character no-undo initial "$Date$":U .
  define variable vss-workfile    as character no-undo initial "$Workfile$":U .
  define variable vss-archive     as character no-undo initial "$Archive$":U . 
  define variable vss-description as character no-undo initial "Просмотр/редактирование одной акции". 

    DEFINE PRIVATE VARIABLE uc_TabAddEdit1 AS ibs.th.ref.promo.uc_TabAddEdit NO-UNDO.
    DEFINE PRIVATE VARIABLE uc_TabAZS1 AS ibs.th.ref.promo.uc_TabAZS NO-UNDO.
    DEFINE PRIVATE VARIABLE uc_TabBase1 AS ibs.th.ref.promo.uc_TabBase NO-UNDO.
    DEFINE PRIVATE VARIABLE uc_TabPresents1 AS ibs.th.ref.promo.uc_Tab_Presents NO-UNDO.
    DEFINE PRIVATE VARIABLE uc_TabPromoAction1 AS ibs.th.ref.promo.uc_TabPromoAction NO-UNDO.
    DEFINE PRIVATE VARIABLE uc_TabTypePay1 AS ibs.th.ref.promo.uc_TabTypePay NO-UNDO.
    
    define private variable button3 as System.Windows.Forms.Button no-undo.
    define private variable button2 as System.Windows.Forms.Button no-undo.
    define private variable button1 as System.Windows.Forms.Button no-undo.
    define private variable components as System.ComponentModel.IContainer no-undo.
    define private variable buttonOk as System.Windows.Forms.Button no-undo.
    define private variable buttonCancel as System.Windows.Forms.Button no-undo.
    define private variable label21 as System.Windows.Forms.Label no-undo.
    define private variable label20 as System.Windows.Forms.Label no-undo.
    define private variable label19 as System.Windows.Forms.Label no-undo.
    define private variable tabControl1 as System.Windows.Forms.TabControl no-undo.
    define private variable tableLayoutPanel19 as System.Windows.Forms.TableLayoutPanel no-undo.
    define private variable tableLayoutPanel2 as System.Windows.Forms.TableLayoutPanel no-undo.
    define private variable tableLayoutPanel1 as System.Windows.Forms.TableLayoutPanel no-undo.
    define private variable tableLayoutPanel3 as System.Windows.Forms.TableLayoutPanel no-undo.
    define private variable tableLayoutPanel4 as System.Windows.Forms.TableLayoutPanel no-undo.
    define private variable tabPage6 AS System.Windows.Forms.TabPage NO-UNDO.
    define private variable tabPage5 as System.Windows.Forms.TabPage no-undo.
    define private variable tabPage4 as System.Windows.Forms.TabPage no-undo.
    define private variable tabPage3 as System.Windows.Forms.TabPage no-undo.
    define private variable tabPage2 as System.Windows.Forms.TabPage no-undo.
    define private variable tabPage1 as System.Windows.Forms.TabPage no-undo.
    define private variable textBox7 as System.Windows.Forms.TextBox no-undo.
    define private variable textBox6 as System.Windows.Forms.TextBox no-undo.
    define private variable textBox5 as System.Windows.Forms.TextBox no-undo.

  /* --- собственные переменные --- */
     {ibs/th/ref/promo/promo_trg_heder.i &child_1 = uc_TabPromoAction1 &child_2 = uc_TabPresents1 &NotLocalEvent =yes &notSetBind = yes}
    define private variable m-sub       as class Progress.Lang.Object no-undo .
    DEFINE private VARIABLE tabPage5Save AS System.Windows.Forms.TabPage NO-UNDO.
     {ibs/th/ref/promo/promoType.def ttMethodCalc}
  /* --- end_of собственные переменные --- */
   
    //{ bge/ds-promo.i &ref}
    
    constructor public dPromoActions( ):
        super().
        m-promo-trg = new  ibs.th.ref.promo.promo_trg().
        InitializeComponent ( ).
        INIT_TAB_CONTROLS().
        catch e as Progress.Lang.Error:
            undo, throw e.
        end catch.        
    end constructor.

    constructor public dPromoActions(input p-mode as character):
        define variable v-promo-trg as class ibs.th.ref.promo.promo_trg no-undo.
        this-object(p-mode,v-promo-trg).
    end constructor.
    constructor public dPromoActions(input p-mode as character, input p-promo-trg as class ibs.th.ref.promo.promo_trg):
      super().
        InitializeComponent ( ).
        m-promo-trg = p-promo-trg.
        INIT_TAB_CONTROLS().
        
            case p-mode:
            when {&add-def} then do:
                Disable_Field(false).
                this-object:text = if m-promo-trg:ModeCopy
                                   then "Копирование промоакции"
                                   else "Создание промоакции".
            end .
            when {&lookup} then do:
                Disable_Field(true).
                this-object:text = "Просмотр промоакции".
            end.
            when {&update} then do:
                if    m-promo-trg:ModeChangeStatus
                   or m-promo-trg:ModeEarlyTermination
                then do:
                  Disable_Field(true).
                  buttonOk:enabled = yes.
                end.
                else  
                   Disable_Field(false).
                this-object:text =  if m-promo-trg:ModeChangeStatus
                                   then "Смена статуса промо акции"
                                   else if m-promo-trg:ModeEarlyTermination
                                   then "Досрочное завершение промоакции"
                                   
                                   else "Редактироване промоакции".   
            end.
            otherwise do:
                message "error" view-as alert-box.
            end.
            end case.        catch e as Progress.Lang.Error:
            undo, throw e.
        end catch.
      
      
    end constructor .
    destructor public dPromoActions( ):
        if valid-object(components) then do:
            cast(components, System.IDisposable):Dispose().
        end.
    end destructor.    

  method public void prepareobj ():
    
  end method .
  method public Progress.Lang.Object getSub () :
    return m-sub .
  end .
    method private void deleteObject():
      if valid-object(uc_TabAddEdit1)       then delete object uc_TabAddEdit1 .
      if valid-object(uc_TabAZS1)           then delete object uc_TabAZS1 .
      if valid-object(uc_TabBase1)          then delete object uc_TabBase1 .
      if valid-object(uc_TabPresents1)      then delete object uc_TabPresents1 .
      if valid-object(uc_TabPromoAction1)   then delete object uc_TabPromoAction1 .
      if valid-object(uc_TabTypePay1)       then delete object uc_TabTypePay1 .
    end.     

    method private void okButton_Click (sender as System.Object, e as System.EventArgs):

do on error undo, throw:
      uc_TabAddEdit1:AssignBind() .
      m-promo-trg:checkPromoAction() .

      // для остальных вкладок bindingSounce:Assign() внутри :
      deleteObject().
         
  define variable v-err-msg as character no-undo .  
  catch exAppErrors as class Progress.Lang.AppError :
    v-err-msg = exAppErrors:ReturnValue .
    if v-err-msg > "" then . else do :
      v-err-msg = exAppErrors:GetMessage(1) .
      if v-err-msg > "" then . else v-err-msg = "AppError в модуле {&FILE-NAME}" .
    end .
    message "AppError" skip(1) v-err-msg skip exAppErrors:CallStack view-as alert-box.
  end catch .
  catch exProErrors as class Progress.Lang.ProError :
    v-err-msg = exProErrors:GetMessage(1) . 
    if v-err-msg > "" then . else v-err-msg = "ProError в модуле {&FILE-NAME}" .
    message "ProError" skip(1) v-err-msg skip exProErrors:CallStack view-as alert-box.
  end catch .
  catch exAnyErrors as class Progress.Lang.Error:
    v-err-msg = "Unexpected error в модуле {&FILE-NAME} " + exAnyErrors:GetMessage(1).
    message "LangError" skip(1) v-err-msg skip exAnyErrors:CallStack view-as alert-box.
  end catch .
  finally: 
  end finally.
end .    
        this-object:DialogResult = System.Windows.Forms.DialogResult:Ok.
        this-object:Close ( ).
        
    end method.
 
    method private void cancelButton_Click (sender as System.Object, e as System.EventArgs):
              // для остальных вкладок bindingSounce:Assign() внутри :
      deleteObject().
         

        this-object:DialogResult = System.Windows.Forms.DialogResult:Cancel.
        this-object:Close ( ).
  define variable v-err-msg as character no-undo .  
  catch exAppErrors as class Progress.Lang.AppError :
    v-err-msg = exAppErrors:ReturnValue .
    if v-err-msg > "" then . else do :
      v-err-msg = exAppErrors:GetMessage(1) .
      if v-err-msg > "" then . else v-err-msg = "AppError в модуле {&FILE-NAME}" .
    end .
    message "AppError" skip(1) v-err-msg skip exAppErrors:CallStack view-as alert-box.
  end catch .
  catch exProErrors as class Progress.Lang.ProError :
    v-err-msg = exProErrors:GetMessage(1) . 
    if v-err-msg > "" then . else v-err-msg = "ProError в модуле {&FILE-NAME}" .
    message "ProError" skip(1) v-err-msg skip exProErrors:CallStack view-as alert-box.
  end catch .
  catch exAnyErrors as class Progress.Lang.Error:
    v-err-msg = "Unexpected error в модуле {&FILE-NAME} " + exAnyErrors:GetMessage(1).
    message "LangError" skip(1) v-err-msg skip exAnyErrors:CallStack view-as alert-box.
  end catch .
  finally: 
  end finally.

    end method.
    
    method private void InitializeComponent ( ):

        /* NOTE: The following method is automatically generated.
           
           We strongly suggest that the contents of this method only be modified using the 
           Visual Designer to avoid any incompatible modifications.
           
           Modifying the contents of this method using a code editor will invalidate any support for this file. */
        
    this-object:buttonOk = new System.Windows.Forms.Button().
    this-object:buttonCancel = new System.Windows.Forms.Button().
    this-object:tableLayoutPanel1 = new System.Windows.Forms.TableLayoutPanel().
    this-object:tableLayoutPanel2 = new System.Windows.Forms.TableLayoutPanel().
    this-object:tableLayoutPanel3 = new System.Windows.Forms.TableLayoutPanel().
    this-object:tableLayoutPanel4 = new System.Windows.Forms.TableLayoutPanel().
    this-object:button1 = new System.Windows.Forms.Button().
    this-object:button2 = new System.Windows.Forms.Button().
    this-object:button3 = new System.Windows.Forms.Button().
    this-object:tabControl1 = new System.Windows.Forms.TabControl().
    this-object:tabPage1 = new System.Windows.Forms.TabPage().
    this-object:uc_TabBase1 = new ibs.th.ref.promo.uc_TabBase().
    this-object:tabPage2 = new System.Windows.Forms.TabPage().
    this-object:uc_TabAZS1 = new ibs.th.ref.promo.uc_TabAZS().
    this-object:tabPage3 = new System.Windows.Forms.TabPage().
    this-object:uc_TabPromoAction1 = new ibs.th.ref.promo.uc_TabPromoAction().
    this-object:tabPage4 = new System.Windows.Forms.TabPage().
    this-object:uc_TabTypePay1 = new ibs.th.ref.promo.uc_TabTypePay().
    this-object:tabPage5 = new System.Windows.Forms.TabPage().
    this-object:uc_TabAddEdit1 = new ibs.th.ref.promo.uc_TabAddEdit().
    this-object:tabPage6 = new System.Windows.Forms.TabPage().
    this-object:uc_TabPresents1 = new ibs.th.ref.promo.uc_Tab_Presents().
    this-object:tableLayoutPanel19 = new System.Windows.Forms.TableLayoutPanel().
    this-object:textBox5 = new System.Windows.Forms.TextBox().
    this-object:textBox6 = new System.Windows.Forms.TextBox().
    this-object:label19 = new System.Windows.Forms.Label().
    this-object:label20 = new System.Windows.Forms.Label().
    this-object:label21 = new System.Windows.Forms.Label().
    this-object:textBox7 = new System.Windows.Forms.TextBox().
    this-object:tableLayoutPanel1:SuspendLayout().
    this-object:tableLayoutPanel2:SuspendLayout().
    this-object:tableLayoutPanel3:SuspendLayout().
    this-object:tableLayoutPanel4:SuspendLayout().
    this-object:tabControl1:SuspendLayout().
    this-object:tabPage1:SuspendLayout().
    this-object:tabPage2:SuspendLayout().
    this-object:tabPage3:SuspendLayout().
    this-object:tabPage4:SuspendLayout().
    this-object:tabPage5:SuspendLayout().
    this-object:tabPage6:SuspendLayout().
    this-object:tableLayoutPanel19:SuspendLayout().
    this-object:SuspendLayout().
    /*  */
    /* buttonOk */
    /*  */
    this-object:buttonOk:Dock = System.Windows.Forms.DockStyle:Fill.
    this-object:buttonOk:Location = new System.Drawing.Point(722, 3).
    this-object:buttonOk:Name = "buttonOk".
    this-object:buttonOk:Size = new System.Drawing.Size(124, 23).
    this-object:buttonOk:TabIndex = 0.
    this-object:buttonOk:Text = "Сохранить".
    this-object:buttonOk:UseCompatibleTextRendering = true.
    this-object:buttonOk:Click:Subscribe(this-object:okButton_Click).
    /*  */
    /* buttonCancel */
    /*  */
    this-object:buttonCancel:DialogResult = System.Windows.Forms.DialogResult:Cancel.
    this-object:buttonCancel:Dock = System.Windows.Forms.DockStyle:Fill.
    this-object:buttonCancel:Location = new System.Drawing.Point(852, 3).
    this-object:buttonCancel:Name = "buttonCancel".
    this-object:buttonCancel:Size = new System.Drawing.Size(124, 23).
    this-object:buttonCancel:TabIndex = 1.
    this-object:buttonCancel:Text = "Отмена".
    this-object:buttonCancel:UseCompatibleTextRendering = true.
    this-object:buttonCancel:Click:Subscribe(this-object:cancelButton_Click).
    /*  */
    /* tableLayoutPanel1 */
    /*  */
    this-object:tableLayoutPanel1:ColumnCount = 1.
    this-object:tableLayoutPanel1:ColumnStyles:Add(new System.Windows.Forms.ColumnStyle(System.Windows.Forms.SizeType:Percent, Progress.Util.CastUtil:ToSingle(100))).
    this-object:tableLayoutPanel1:Controls:Add(this-object:tableLayoutPanel2, 0, 2).
    this-object:tableLayoutPanel1:Controls:Add(this-object:tableLayoutPanel3, 0, 0).
    this-object:tableLayoutPanel1:Controls:Add(this-object:tabControl1, 0, 1).
    this-object:tableLayoutPanel1:Dock = System.Windows.Forms.DockStyle:Fill.
    this-object:tableLayoutPanel1:Location = new System.Drawing.Point(0, 0).
    this-object:tableLayoutPanel1:Name = "tableLayoutPanel1".
    this-object:tableLayoutPanel1:RowCount = 3.
    this-object:tableLayoutPanel1:RowStyles:Add(new System.Windows.Forms.RowStyle()).
    this-object:tableLayoutPanel1:RowStyles:Add(new System.Windows.Forms.RowStyle(System.Windows.Forms.SizeType:Percent, Progress.Util.CastUtil:ToSingle(100))).
    this-object:tableLayoutPanel1:RowStyles:Add(new System.Windows.Forms.RowStyle(System.Windows.Forms.SizeType:Absolute, Progress.Util.CastUtil:ToSingle(35))).
    this-object:tableLayoutPanel1:Size = new System.Drawing.Size(985, 623).
    this-object:tableLayoutPanel1:TabIndex = 2.
    /*  */
    /* tableLayoutPanel2 */
    /*  */
    this-object:tableLayoutPanel2:ColumnCount = 3.
    this-object:tableLayoutPanel2:ColumnStyles:Add(new System.Windows.Forms.ColumnStyle(System.Windows.Forms.SizeType:Percent, Progress.Util.CastUtil:ToSingle(100))).
    this-object:tableLayoutPanel2:ColumnStyles:Add(new System.Windows.Forms.ColumnStyle(System.Windows.Forms.SizeType:Absolute, Progress.Util.CastUtil:ToSingle(130))).
    this-object:tableLayoutPanel2:ColumnStyles:Add(new System.Windows.Forms.ColumnStyle(System.Windows.Forms.SizeType:Absolute, Progress.Util.CastUtil:ToSingle(130))).
    this-object:tableLayoutPanel2:Controls:Add(this-object:buttonCancel, 2, 0).
    this-object:tableLayoutPanel2:Controls:Add(this-object:buttonOk, 1, 0).
    this-object:tableLayoutPanel2:Dock = System.Windows.Forms.DockStyle:Fill.
    this-object:tableLayoutPanel2:Location = new System.Drawing.Point(3, 591).
    this-object:tableLayoutPanel2:Name = "tableLayoutPanel2".
    this-object:tableLayoutPanel2:RowCount = 1.
    this-object:tableLayoutPanel2:RowStyles:Add(new System.Windows.Forms.RowStyle(System.Windows.Forms.SizeType:Percent, Progress.Util.CastUtil:ToSingle(100))).
    this-object:tableLayoutPanel2:Size = new System.Drawing.Size(979, 29).
    this-object:tableLayoutPanel2:TabIndex = 0.
    /*  */
    /* tableLayoutPanel3 */
    /*  */
    this-object:tableLayoutPanel3:ColumnCount = 1.
    this-object:tableLayoutPanel3:ColumnStyles:Add(new System.Windows.Forms.ColumnStyle(System.Windows.Forms.SizeType:Percent, Progress.Util.CastUtil:ToSingle(50))).
    this-object:tableLayoutPanel3:ColumnStyles:Add(new System.Windows.Forms.ColumnStyle(System.Windows.Forms.SizeType:Percent, Progress.Util.CastUtil:ToSingle(50))).
    this-object:tableLayoutPanel3:Controls:Add(this-object:tableLayoutPanel4, 0, 1).
    this-object:tableLayoutPanel3:Dock = System.Windows.Forms.DockStyle:Fill.
    this-object:tableLayoutPanel3:Location = new System.Drawing.Point(3, 3).
    this-object:tableLayoutPanel3:Name = "tableLayoutPanel3".
    this-object:tableLayoutPanel3:RowCount = 2.
    this-object:tableLayoutPanel3:RowStyles:Add(new System.Windows.Forms.RowStyle(System.Windows.Forms.SizeType:Percent, Progress.Util.CastUtil:ToSingle(50))).
    this-object:tableLayoutPanel3:RowStyles:Add(new System.Windows.Forms.RowStyle(System.Windows.Forms.SizeType:Percent, Progress.Util.CastUtil:ToSingle(50))).
    this-object:tableLayoutPanel3:Size = new System.Drawing.Size(979, 64).
    this-object:tableLayoutPanel3:TabIndex = 1.
    this-object:tableLayoutPanel3:Visible = false.
    /*  */
    /* tableLayoutPanel4 */
    /*  */
    this-object:tableLayoutPanel4:ColumnCount = 7.
    this-object:tableLayoutPanel4:ColumnStyles:Add(new System.Windows.Forms.ColumnStyle(System.Windows.Forms.SizeType:Absolute, Progress.Util.CastUtil:ToSingle(130))).
    this-object:tableLayoutPanel4:ColumnStyles:Add(new System.Windows.Forms.ColumnStyle(System.Windows.Forms.SizeType:Absolute, Progress.Util.CastUtil:ToSingle(10))).
    this-object:tableLayoutPanel4:ColumnStyles:Add(new System.Windows.Forms.ColumnStyle(System.Windows.Forms.SizeType:Absolute, Progress.Util.CastUtil:ToSingle(130))).
    this-object:tableLayoutPanel4:ColumnStyles:Add(new System.Windows.Forms.ColumnStyle(System.Windows.Forms.SizeType:Absolute, Progress.Util.CastUtil:ToSingle(10))).
    this-object:tableLayoutPanel4:ColumnStyles:Add(new System.Windows.Forms.ColumnStyle(System.Windows.Forms.SizeType:Absolute, Progress.Util.CastUtil:ToSingle(130))).
    this-object:tableLayoutPanel4:ColumnStyles:Add(new System.Windows.Forms.ColumnStyle(System.Windows.Forms.SizeType:Percent, Progress.Util.CastUtil:ToSingle(100))).
    this-object:tableLayoutPanel4:ColumnStyles:Add(new System.Windows.Forms.ColumnStyle(System.Windows.Forms.SizeType:Absolute, Progress.Util.CastUtil:ToSingle(50))).
    this-object:tableLayoutPanel4:Controls:Add(this-object:button1, 0, 0).
    this-object:tableLayoutPanel4:Controls:Add(this-object:button2, 2, 0).
    this-object:tableLayoutPanel4:Controls:Add(this-object:button3, 6, 0).
    this-object:tableLayoutPanel4:Dock = System.Windows.Forms.DockStyle:Fill.
    this-object:tableLayoutPanel4:Location = new System.Drawing.Point(3, 35).
    this-object:tableLayoutPanel4:Name = "tableLayoutPanel4".
    this-object:tableLayoutPanel4:RowCount = 1.
    this-object:tableLayoutPanel4:RowStyles:Add(new System.Windows.Forms.RowStyle(System.Windows.Forms.SizeType:Percent, Progress.Util.CastUtil:ToSingle(100))).
    this-object:tableLayoutPanel4:Size = new System.Drawing.Size(973, 26).
    this-object:tableLayoutPanel4:TabIndex = 0.
    this-object:tableLayoutPanel4:Visible = false.
    /*  */
    /* button1 */
    /*  */
    this-object:button1:Dock = System.Windows.Forms.DockStyle:Fill.
    this-object:button1:Location = new System.Drawing.Point(3, 3).
    this-object:button1:Name = "button1".
    this-object:button1:Size = new System.Drawing.Size(124, 20).
    this-object:button1:TabIndex = 0.
    this-object:button1:Text = "Записать и закрыть".
    this-object:button1:UseCompatibleTextRendering = true.
    this-object:button1:UseVisualStyleBackColor = true.
    /*  */
    /* button2 */
    /*  */
    this-object:button2:Dock = System.Windows.Forms.DockStyle:Fill.
    this-object:button2:Location = new System.Drawing.Point(143, 3).
    this-object:button2:Name = "button2".
    this-object:button2:Size = new System.Drawing.Size(124, 20).
    this-object:button2:TabIndex = 1.
    this-object:button2:Text = "Запись".
    this-object:button2:UseCompatibleTextRendering = true.
    this-object:button2:UseVisualStyleBackColor = true.
    /*  */
    /* button3 */
    /*  */
    this-object:button3:Location = new System.Drawing.Point(926, 3).
    this-object:button3:Name = "button3".
    this-object:button3:Size = new System.Drawing.Size(44, 20).
    this-object:button3:TabIndex = 2.
    this-object:button3:Text = "Еще".
    this-object:button3:UseCompatibleTextRendering = true.
    this-object:button3:UseVisualStyleBackColor = true.
    /*  */
    /* tabControl1 */
    /*  */
    this-object:tabControl1:Controls:Add(this-object:tabPage1).
    this-object:tabControl1:Controls:Add(this-object:tabPage2).
    this-object:tabControl1:Controls:Add(this-object:tabPage3).
    this-object:tabControl1:Controls:Add(this-object:tabPage4).
    this-object:tabControl1:Controls:Add(this-object:tabPage5).
    this-object:tabControl1:Controls:Add(this-object:tabPage6).
    this-object:tabControl1:Dock = System.Windows.Forms.DockStyle:Fill.
    this-object:tabControl1:Location = new System.Drawing.Point(3, 73).
    this-object:tabControl1:Name = "tabControl1".
    this-object:tabControl1:SelectedIndex = 0.
    this-object:tabControl1:Size = new System.Drawing.Size(979, 512).
    this-object:tabControl1:TabIndex = 2.
    this-object:tabControl1:Selected:Subscribe(this-object:tabControl1_Selected).
    /*  */
    /* tabPage1 */
    /*  */
    this-object:tabPage1:Controls:Add(this-object:uc_TabBase1).
    this-object:tabPage1:Location = new System.Drawing.Point(4, 22).
    this-object:tabPage1:Name = "tabPage1".
    this-object:tabPage1:Padding = new System.Windows.Forms.Padding(3).
    this-object:tabPage1:Size = new System.Drawing.Size(971, 486).
    this-object:tabPage1:TabIndex = 0.
    this-object:tabPage1:Text = "Основное".
    this-object:tabPage1:UseVisualStyleBackColor = true.
    /*  */
    /* uc_TabBase1 */
    /*  */
    this-object:uc_TabBase1:Dock = System.Windows.Forms.DockStyle:Fill.
    this-object:uc_TabBase1:Location = new System.Drawing.Point(3, 3).
    this-object:uc_TabBase1:Name = "uc_TabBase1".
    this-object:uc_TabBase1:Size = new System.Drawing.Size(965, 480).
    this-object:uc_TabBase1:TabIndex = 0.
    /*  */
    /* tabPage2 */
    /*  */
    this-object:tabPage2:Controls:Add(this-object:uc_TabAZS1).
    this-object:tabPage2:Location = new System.Drawing.Point(4, 22).
    this-object:tabPage2:Name = "tabPage2".
    this-object:tabPage2:Padding = new System.Windows.Forms.Padding(3).
    this-object:tabPage2:Size = new System.Drawing.Size(971, 486).
    this-object:tabPage2:TabIndex = 1.
    this-object:tabPage2:Text = "Применение на АЗК/АЗС".
    this-object:tabPage2:UseVisualStyleBackColor = true.
    /*  */
    /* uc_TabAZS1 */
    /*  */
    this-object:uc_TabAZS1:Dock = System.Windows.Forms.DockStyle:Fill.
    this-object:uc_TabAZS1:Location = new System.Drawing.Point(3, 3).
    this-object:uc_TabAZS1:Margin = new System.Windows.Forms.Padding(0).
    this-object:uc_TabAZS1:Name = "uc_TabAZS1".
    this-object:uc_TabAZS1:Size = new System.Drawing.Size(965, 480).
    this-object:uc_TabAZS1:TabIndex = 0.
    /*  */
    /* tabPage3 */
    /*  */
    this-object:tabPage3:Controls:Add(this-object:uc_TabPromoAction1).
    this-object:tabPage3:Location = new System.Drawing.Point(4, 22).
    this-object:tabPage3:Name = "tabPage3".
    this-object:tabPage3:Size = new System.Drawing.Size(971, 486).
    this-object:tabPage3:TabIndex = 2.
    this-object:tabPage3:Text = "Настройки промоакций".
    this-object:tabPage3:UseVisualStyleBackColor = true.
    /*  */
    /* uc_TabPromoAction1 */
    /*  */
    this-object:uc_TabPromoAction1:Dock = System.Windows.Forms.DockStyle:Fill.
    this-object:uc_TabPromoAction1:Location = new System.Drawing.Point(0, 0).
    this-object:uc_TabPromoAction1:Name = "uc_TabPromoAction1".
    this-object:uc_TabPromoAction1:Size = new System.Drawing.Size(971, 486).
    this-object:uc_TabPromoAction1:TabIndex = 0.
    /*  */
    /* tabPage4 */
    /*  */
    this-object:tabPage4:Controls:Add(this-object:uc_TabTypePay1).
    this-object:tabPage4:Location = new System.Drawing.Point(4, 22).
    this-object:tabPage4:Name = "tabPage4".
    this-object:tabPage4:Size = new System.Drawing.Size(971, 486).
    this-object:tabPage4:TabIndex = 3.
    this-object:tabPage4:Text = "Типы оплаты".
    this-object:tabPage4:UseVisualStyleBackColor = true.
    /*  */
    /* uc_TabTypePay1 */
    /*  */
    this-object:uc_TabTypePay1:Dock = System.Windows.Forms.DockStyle:Fill.
    this-object:uc_TabTypePay1:Location = new System.Drawing.Point(0, 0).
    this-object:uc_TabTypePay1:Name = "uc_TabTypePay1".
    this-object:uc_TabTypePay1:Size = new System.Drawing.Size(971, 486).
    this-object:uc_TabTypePay1:TabIndex = 0.
    /*  */
    /* tabPage5 */
    /*  */
    this-object:tabPage5:Controls:Add(this-object:uc_TabAddEdit1).
    this-object:tabPage5:Location = new System.Drawing.Point(4, 22).
    this-object:tabPage5:Name = "tabPage5".
    this-object:tabPage5:Size = new System.Drawing.Size(971, 486).
    this-object:tabPage5:TabIndex = 4.
    this-object:tabPage5:Text = "Расписание".
    this-object:tabPage5:UseVisualStyleBackColor = true.
    /*  */
    /* uc_TabAddEdit1 */
    /*  */
    this-object:uc_TabAddEdit1:Dock = System.Windows.Forms.DockStyle:Fill.
    this-object:uc_TabAddEdit1:Location = new System.Drawing.Point(0, 0).
    this-object:uc_TabAddEdit1:Name = "uc_TabAddEdit1".
    this-object:uc_TabAddEdit1:Size = new System.Drawing.Size(971, 486).
    this-object:uc_TabAddEdit1:TabIndex = 0.
    /*  */
    /* tabPage6 */
    /*  */
    this-object:tabPage6:Controls:Add(this-object:uc_TabPresents1).
    this-object:tabPage6:Location = new System.Drawing.Point(4, 22).
    this-object:tabPage6:Name = "tabPage6".
    this-object:tabPage6:Size = new System.Drawing.Size(971, 486).
    this-object:tabPage6:TabIndex = 5.
    this-object:tabPage6:Text = "Подарки".
    this-object:tabPage6:UseVisualStyleBackColor = true.
    /*  */
    /* uc_TabPresents1 */
    /*  */
    this-object:uc_TabPresents1:Dock = System.Windows.Forms.DockStyle:Fill.
    this-object:uc_TabPresents1:Location = new System.Drawing.Point(0, 0).
    this-object:uc_TabPresents1:Name = "uc_TabPresents1".
    this-object:uc_TabPresents1:Size = new System.Drawing.Size(971, 486).
    this-object:uc_TabPresents1:TabIndex = 0.
    /*  */
    /* tableLayoutPanel19 */
    /*  */
    this-object:tableLayoutPanel19:ColumnCount = 2.
    this-object:tableLayoutPanel19:ColumnStyles:Add(new System.Windows.Forms.ColumnStyle(System.Windows.Forms.SizeType:Absolute, Progress.Util.CastUtil:ToSingle(110))).
    this-object:tableLayoutPanel19:ColumnStyles:Add(new System.Windows.Forms.ColumnStyle(System.Windows.Forms.SizeType:Percent, Progress.Util.CastUtil:ToSingle(100))).
    this-object:tableLayoutPanel19:Controls:Add(this-object:textBox5, 1, 2).
    this-object:tableLayoutPanel19:Controls:Add(this-object:textBox6, 1, 0).
    this-object:tableLayoutPanel19:Controls:Add(this-object:label19, 0, 0).
    this-object:tableLayoutPanel19:Controls:Add(this-object:label20, 0, 1).
    this-object:tableLayoutPanel19:Controls:Add(this-object:label21, 0, 2).
    this-object:tableLayoutPanel19:Controls:Add(this-object:textBox7, 1, 1).
    this-object:tableLayoutPanel19:Dock = System.Windows.Forms.DockStyle:Fill.
    this-object:tableLayoutPanel19:Location = new System.Drawing.Point(380, 3).
    this-object:tableLayoutPanel19:Name = "tableLayoutPanel19".
    this-object:tableLayoutPanel19:RowCount = 4.
    this-object:tableLayoutPanel19:RowStyles:Add(new System.Windows.Forms.RowStyle(System.Windows.Forms.SizeType:Percent, Progress.Util.CastUtil:ToSingle(25))).
    this-object:tableLayoutPanel19:RowStyles:Add(new System.Windows.Forms.RowStyle(System.Windows.Forms.SizeType:Percent, Progress.Util.CastUtil:ToSingle(25))).
    this-object:tableLayoutPanel19:RowStyles:Add(new System.Windows.Forms.RowStyle(System.Windows.Forms.SizeType:Percent, Progress.Util.CastUtil:ToSingle(25))).
    this-object:tableLayoutPanel19:RowStyles:Add(new System.Windows.Forms.RowStyle(System.Windows.Forms.SizeType:Percent, Progress.Util.CastUtil:ToSingle(25))).
    this-object:tableLayoutPanel19:RowStyles:Add(new System.Windows.Forms.RowStyle(System.Windows.Forms.SizeType:Absolute, Progress.Util.CastUtil:ToSingle(20))).
    this-object:tableLayoutPanel19:Size = new System.Drawing.Size(371, 114).
    this-object:tableLayoutPanel19:TabIndex = 1.
    /*  */
    /* textBox5 */
    /*  */
    this-object:textBox5:Dock = System.Windows.Forms.DockStyle:Fill.
    this-object:textBox5:Location = new System.Drawing.Point(113, 59).
    this-object:textBox5:Name = "textBox5".
    this-object:textBox5:Size = new System.Drawing.Size(255, 20).
    this-object:textBox5:TabIndex = 10.
    /*  */
    /* textBox6 */
    /*  */
    this-object:textBox6:Dock = System.Windows.Forms.DockStyle:Fill.
    this-object:textBox6:Location = new System.Drawing.Point(113, 3).
    this-object:textBox6:Name = "textBox6".
    this-object:textBox6:Size = new System.Drawing.Size(255, 20).
    this-object:textBox6:TabIndex = 9.
    /*  */
    /* label19 */
    /*  */
    this-object:label19:Dock = System.Windows.Forms.DockStyle:Fill.
    this-object:label19:Location = new System.Drawing.Point(3, 0).
    this-object:label19:Name = "label19".
    this-object:label19:Size = new System.Drawing.Size(104, 28).
    this-object:label19:TabIndex = 4.
    this-object:label19:TextAlign = System.Drawing.ContentAlignment:MiddleLeft.
    this-object:label19:UseCompatibleTextRendering = true.
    /*  */
    /* label20 */
    /*  */
    this-object:label20:Dock = System.Windows.Forms.DockStyle:Fill.
    this-object:label20:Location = new System.Drawing.Point(3, 28).
    this-object:label20:Name = "label20".
    this-object:label20:Size = new System.Drawing.Size(104, 28).
    this-object:label20:TabIndex = 7.
    this-object:label20:TextAlign = System.Drawing.ContentAlignment:MiddleLeft.
    this-object:label20:UseCompatibleTextRendering = true.
    /*  */
    /* label21 */
    /*  */
    this-object:label21:Dock = System.Windows.Forms.DockStyle:Fill.
    this-object:label21:Location = new System.Drawing.Point(3, 56).
    this-object:label21:Name = "label21".
    this-object:label21:Size = new System.Drawing.Size(104, 28).
    this-object:label21:TabIndex = 5.
    this-object:label21:TextAlign = System.Drawing.ContentAlignment:MiddleLeft.
    this-object:label21:UseCompatibleTextRendering = true.
    /*  */
    /* textBox7 */
    /*  */
    this-object:textBox7:Dock = System.Windows.Forms.DockStyle:Fill.
    this-object:textBox7:Location = new System.Drawing.Point(113, 31).
    this-object:textBox7:Name = "textBox7".
    this-object:textBox7:Size = new System.Drawing.Size(255, 20).
    this-object:textBox7:TabIndex = 8.
    /*  */
    /* dPromoActions */
    /*  */
    this-object:AcceptButton = this-object:buttonOk.
    this-object:CancelButton = this-object:buttonCancel.
    this-object:ClientSize = new System.Drawing.Size(985, 623).
    this-object:Controls:Add(this-object:tableLayoutPanel1).
    this-object:Name = "dPromoActions".
    this-object:ShowInTaskbar = false.
    this-object:StartPosition = System.Windows.Forms.FormStartPosition:CenterParent.
    this-object:Text = "Просмотр/Редактирование Акции".
    this-object:tableLayoutPanel1:ResumeLayout(false).
    this-object:tableLayoutPanel2:ResumeLayout(false).
    this-object:tableLayoutPanel3:ResumeLayout(false).
    this-object:tableLayoutPanel4:ResumeLayout(false).
    this-object:tabControl1:ResumeLayout(false).
    this-object:tabPage1:ResumeLayout(false).
    this-object:tabPage2:ResumeLayout(false).
    this-object:tabPage3:ResumeLayout(false).
    this-object:tabPage4:ResumeLayout(false).
    this-object:tabPage5:ResumeLayout(false).
    this-object:tabPage6:ResumeLayout(false).
    this-object:tableLayoutPanel19:ResumeLayout(false).
    this-object:tableLayoutPanel19:PerformLayout().
    this-object:ResumeLayout(false).
    catch e as Progress.Lang.Error:
      undo, throw e.
    end catch.
    end method. 

	/*------------------------------------------------------------------------------
	 Purpose:
	 Notes:
	------------------------------------------------------------------------------*/
	@VisualDesigner.
	method private void tabControl1_Selected( input sender as System.Object, input e as System.Windows.Forms.TabControlEventArgs ):
		uc_TabPromoAction1:cleanPanel().
        uc_TabPresents1:clenObject().
        if tabControl1:SelectedIndex  = 5 
        then
           uc_TabPresents1:Show_Panet_SelectConditonItem().
        if tabControl1:SelectedIndex  = 2 
        then
           uc_TabPromoAction1:Show_Panet_SelectConditonItem(). 
		return.

	end method.


    method public void viewpage6 (input iFlag as logical) :
        if iFlag 
        then do:
           if tabControl1:TabPages:Count = 5 THEN
           tabControl1:TabPages:Add(tabPage6).
        end.   
        else 
        if tabControl1:TabPages:Count ne 5 then do:   
           tabPage5save = tabControl1:TabPages[5].
           tabControl1:TabPages:Remove(tabPage6).
        end.
    end.
    METHOD PRIVATE VOID INIT_TAB_CONTROLS():
        uc_TabBase1:SetPromoTrg(m-promo-trg).
        uc_TabPromoAction1:SetPromoTrg(m-promo-trg).
        //uc_TabPromoAction1:Set_TabControl(tabControl1).
        uc_TabAddEdit1:SetPromoTrg(m-promo-trg) .
        uc_TabAZS1:SetPromoTrg(m-promo-trg).
        
       // uc_TabPresents1:SetPromoTrg(m-promo-trg).
        
        uc_TabTypePay1:SetPromoTrg(m-promo-trg).
        uc_TabPresents1:SetPromoTrg(m-promo-trg).
        /*
        DEFINE VARIABLE uc_TabBase as ibs.th.ref.promo.uc_TabBase no-undo.
        uc_TabBase = NEW ibs.th.ref.promo.uc_TabBase().
        uc_TabBase:Dock = System.Windows.Forms.DockStyle:Fill.
        tabPage1:Controls:Add(uc_TabBase).
        */
        
        /*
        DEFINE VARIABLE uc_TabAZS as ibs.th.ref.promo.uc_TabAZS no-undo.
        uc_TabAZS = NEW ibs.th.ref.promo.uc_TabAZS(m-promo-trg).
        uc_TabAZS:Dock = System.Windows.Forms.DockStyle:Fill.
        //tabPage2:Controls:Add(uc_TabAZS).
        */
        
        /*
        DEFINE VARIABLE uc_TabPromo as ibs.th.ref.promo.uc_TabPromoAction no-undo.
        uc_TabPromo = NEW ibs.th.ref.promo.uc_TabPromoAction().
        uc_TabPromo:Dock = System.Windows.Forms.DockStyle:Fill.
        tabPage3:Controls:Add(uc_TabPromo).
        */
        /*
        DEFINE VARIABLE uc_TabAddEdit as ibs.th.ref.promo.uc_TabAddEdit no-undo.
        uc_TabAddEdit = NEW ibs.th.ref.promo.uc_TabAddEdit().
        uc_TabAddEdit:Dock = System.Windows.Forms.DockStyle:Fill.
        tabPage5:Controls:Add(uc_TabAddEdit).
        */
        
    END METHOD.


    method public void ShowModalDialog(  ):
        
        wait-for this-object:ShowDialog().
define variable v-err-msg as character no-undo .  
  catch exAppErrors as class Progress.Lang.AppError :
    v-err-msg = exAppErrors:ReturnValue .
    if v-err-msg > "" then . else do :
      v-err-msg = exAppErrors:GetMessage(1) .
      if v-err-msg > "" then . else v-err-msg = "AppError в модуле {&FILE-NAME}" .
    end .
    message "AppError" skip(1) v-err-msg skip exAppErrors:CallStack view-as alert-box.
  end catch .
  catch exProErrors as class Progress.Lang.ProError :
    v-err-msg = exProErrors:GetMessage(1) . 
    if v-err-msg > "" then . else v-err-msg = "ProError в модуле {&FILE-NAME}" .
    message "ProError" skip(1) v-err-msg skip exProErrors:CallStack view-as alert-box.
  end catch .
  catch exAnyErrors as class Progress.Lang.Error:
    v-err-msg = "Unexpected error в модуле {&FILE-NAME} " + exAnyErrors:GetMessage(1).
    message "LangError" skip(1) v-err-msg skip exAnyErrors:CallStack view-as alert-box.
  end catch .
    end method.


    method private void Disable_Field(input Field_DISABLE as logical ): 

        if Field_DISABLE then do:
            button1:Enabled = false.
            button2:Enabled = false.
            button3:Enabled = false.
            buttonOk:Enabled = false. 
            uc_TabPromoAction1:Enabled_Controls(false).
            uc_TabAddEdit1:Enabled= false.
            uc_TabAZS1:Enabled= false.
            //uc_TabBase1:Enabled= false.
            
            uc_TabTypePay1:Enabled= false.
            //uc_TabPresents1:Enabled= false.
            
        end.
        
    end method.

    

end class.
