/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Диалог ввода параметров для импорта накладных из 15.0

Автор: Молотков Сергей
Дата создания: 10/04/18
Author: Molotkov Sergey
Creation date: 10/04/18

Задать имя файла импорта, код целевого магазина и признак автоматического закрытия на факт
*/
USING Progress.Windows.Form.
  
BLOCK-LEVEL ON ERROR UNDO, THROW.
CLASS ibs.th.str.impdoc4dlg INHERITS Form : 

  { cmp/str-glbl.i class }
  
  DEFINE PRIVATE VARIABLE cbCloseFact AS System.Windows.Forms.CheckBox NO-UNDO.
  define public variable fi-file-name   as character no-undo .
  define public variable fi-obj-type    as character no-undo .
  define public variable fi-obj-code    as integer no-undo .
  define public variable is-doc-close   as logical initial false no-undo .

  define private variable parparentproc as handle no-undo .
  
  DEFINE PRIVATE VARIABLE buttonFile AS System.Windows.Forms.Button NO-UNDO.
  DEFINE PRIVATE VARIABLE buttonObj AS System.Windows.Forms.Button NO-UNDO.
  DEFINE PRIVATE VARIABLE code_obj AS System.Windows.Forms.TextBox NO-UNDO.
  DEFINE PRIVATE VARIABLE components AS System.ComponentModel.IContainer NO-UNDO.
    DEFINE PRIVATE VARIABLE buttonOk AS System.Windows.Forms.Button NO-UNDO.
    DEFINE PRIVATE VARIABLE buttonCancel AS System.Windows.Forms.Button NO-UNDO.
  DEFINE PRIVATE VARIABLE file_name AS System.Windows.Forms.TextBox NO-UNDO.
  DEFINE PRIVATE VARIABLE lb_code_obj AS System.Windows.Forms.Label NO-UNDO.
  DEFINE PRIVATE VARIABLE lb_file_name AS System.Windows.Forms.Label NO-UNDO.
    
  CONSTRUCTOR PUBLIC impdoc4dlg( ):
  
    SUPER().
    InitializeComponent ( ).
    CATCH e AS Progress.Lang.Error:
      UNDO, THROW e.
    END CATCH.    

  END CONSTRUCTOR.

  DESTRUCTOR PUBLIC impdoc4dlg( ):

    IF VALID-OBJECT(components) THEN DO:
      CAST(components, System.IDisposable):Dispose().
    END.

  END DESTRUCTOR.  


  method public void setParentproc (input p-parentproc-hdl as handle) :
    parparentproc = p-parentproc-hdl .
  end method .
  
	/*------------------------------------------------------------------------------
	 Purpose:
	 Notes:
	------------------------------------------------------------------------------*/
	@VisualDesigner.
	METHOD PRIVATE VOID fileButton_click( INPUT sender AS System.Object, INPUT e AS System.EventArgs ):
  define variable v-file-name as character no-undo .
  define variable v-ok        as logical no-undo .

  system-dialog get-file v-file-name
    filters "Файлы импорта ПН (*.adb)" "*.adb",
            "Все файлы (*.*)" "*.*"
    title "Выберите файл для импорта накладных"
    update v-ok
  .
  if v-ok then file_name:Text = v-file-name .
  
		RETURN.
	END METHOD.

	/*------------------------------------------------------------------------------
	 Purpose: Выберите магазин для копирования ПАРАМЕТРОВ
	 Notes:
	------------------------------------------------------------------------------*/
	@VisualDesigner.
	METHOD PRIVATE VOID objButton_click( INPUT sender AS System.Object, INPUT e AS System.EventArgs ):
    define variable v-rid-list as character no-undo .
    define variable v-rid-rec  as recid no-undo .
    define buffer buf_shop for ub.shop .
    
    v-rid-list = "" . // можно взять текущее подразделение
    run adm/shops.w ( input parparentproc
                     ,input "b-sel"
                     ,input-output v-rid-list
                     ,no ).
    if v-rid-list = "":U then return.
    v-rid-rec = integer(v-rid-list) no-error .
    find first buf_shop no-lock where recid(buf_shop) = v-rid-rec no-error .
    if available buf_shop then code_obj:Text = string (buf_shop.obj-code) .
/*
  case o-type :
    when {&stock} then run adm/stores.w ( parparentproc
                                       , "b-sel,b-mark"
                                       , input-output rid-list
                                       , (if v-cntxt-db-num = 0 then no else yes)
                                       ) .
    when {&shop} then run adm/shops.w  ( parparentproc
                                       , "b-sel,b-mark"
                                       , input-output rid-list
                                       , (if v-cntxt-db-num = 0 then no else yes)).
  end case.
  if rid-list <> "" then do :
    do num-rec = 1 to num-entries (rid-list):
      if o-type = {&shop} then do:
        find buf_shop where recid (buf_shop) = integer (entry (num-rec, rid-list)) no-lock.
        find first buf_clients
             where buf_clients.obj-type = {&shop}
               and buf_clients.obj-code = buf_shop.obj-code no-lock no-error .
        IF NOT AVAILABLE buf_clients THEN NEXT .
      ...  
      else do:
        find buf_store where recid (buf_store) = integer (entry (num-rec, rid-list)) no-lock.
        find first buf_clients
             where buf_clients.obj-type = {&stock}
               and buf_clients.obj-code = buf_store.obj-code no-lock no-error .
        IF NOT AVAILABLE buf_clients THEN NEXT .
*/
		RETURN.
	END METHOD.


  METHOD PRIVATE VOID okButton_Click (sender AS System.Object, e AS System.EventArgs):
    assign
      fi-file-name   = file_name:Text
      fi-obj-type    = {&shop}
      fi-obj-code    = integer(code_obj:Text)
      is-doc-close   = cbCloseFact:Checked
    no-error .
    if fi-file-name = "" then do:
      message "Не задан файл импорта" view-as alert-box error .
      return .
    end .
    THIS-OBJECT:DialogResult = System.Windows.Forms.DialogResult:Ok.
    THIS-OBJECT:Close ( ).
  END METHOD.

  METHOD PRIVATE VOID cancelButton_Click (sender AS System.Object, e AS System.EventArgs):
    THIS-OBJECT:DialogResult = System.Windows.Forms.DialogResult:Cancel.
    THIS-OBJECT:Close ( ).
  END METHOD.
    
  METHOD PRIVATE VOID InitializeComponent ( ):

    /* NOTE: The following method is automatically generated.
       
       We strongly suggest that the contents of this method only be modified using the 
       Visual Designer to avoid any incompatible modifications.
       
       Modifying the contents of this method using a code editor will invalidate any support for this file. */
    
    THIS-OBJECT:buttonOk = NEW System.Windows.Forms.Button().
    THIS-OBJECT:buttonCancel = NEW System.Windows.Forms.Button().
    THIS-OBJECT:buttonFile = NEW System.Windows.Forms.Button().
    THIS-OBJECT:lb_file_name = NEW System.Windows.Forms.Label().
    THIS-OBJECT:file_name = NEW System.Windows.Forms.TextBox().
    THIS-OBJECT:code_obj = NEW System.Windows.Forms.TextBox().
    THIS-OBJECT:buttonObj = NEW System.Windows.Forms.Button().
    THIS-OBJECT:lb_code_obj = NEW System.Windows.Forms.Label().
    THIS-OBJECT:cbCloseFact = NEW System.Windows.Forms.CheckBox().
    THIS-OBJECT:SuspendLayout().
    /*  */
    /* buttonOk */
    /*  */
    DEFINE VARIABLE nestedvar0 AS System.Windows.Forms.AnchorStyles NO-UNDO.
    nestedvar0 = System.Windows.Forms.AnchorStyles:Bottom.
    THIS-OBJECT:buttonOk:Anchor = CAST(Progress.Util.EnumHelper:Or(nestedvar0, System.Windows.Forms.AnchorStyles:Right), System.Windows.Forms.AnchorStyles).
    THIS-OBJECT:buttonOk:Location = NEW System.Drawing.Point(321, 105).
    THIS-OBJECT:buttonOk:Name = "buttonOk".
    THIS-OBJECT:buttonOk:Size = NEW System.Drawing.Size(75, 23).
    THIS-OBJECT:buttonOk:TabIndex = 0.
    THIS-OBJECT:buttonOk:Text = "OK".
    THIS-OBJECT:buttonOk:UseCompatibleTextRendering = true.
    THIS-OBJECT:buttonOk:Click:Subscribe(THIS-OBJECT:okButton_Click).
    /*  */
    /* buttonCancel */
    /*  */
    DEFINE VARIABLE nestedvar1 AS System.Windows.Forms.AnchorStyles NO-UNDO.
    nestedvar1 = System.Windows.Forms.AnchorStyles:Bottom.
    THIS-OBJECT:buttonCancel:Anchor = CAST(Progress.Util.EnumHelper:Or(nestedvar1, System.Windows.Forms.AnchorStyles:Right), System.Windows.Forms.AnchorStyles).
    THIS-OBJECT:buttonCancel:DialogResult = System.Windows.Forms.DialogResult:Cancel.
    THIS-OBJECT:buttonCancel:Location = NEW System.Drawing.Point(405, 105).
    THIS-OBJECT:buttonCancel:Name = "buttonCancel".
    THIS-OBJECT:buttonCancel:Size = NEW System.Drawing.Size(75, 23).
    THIS-OBJECT:buttonCancel:TabIndex = 1.
    THIS-OBJECT:buttonCancel:Text = "Cancel".
    THIS-OBJECT:buttonCancel:UseCompatibleTextRendering = true.
    THIS-OBJECT:buttonCancel:Click:Subscribe(THIS-OBJECT:cancelButton_Click).
    /*  */
    /* buttonFile */
    /*  */
    THIS-OBJECT:buttonFile:Location = NEW System.Drawing.Point(405, 10).
    THIS-OBJECT:buttonFile:Name = "buttonFile".
    THIS-OBJECT:buttonFile:Size = NEW System.Drawing.Size(75, 23).
    THIS-OBJECT:buttonFile:TabIndex = 5.
    THIS-OBJECT:buttonFile:Text = "Выбрать".
    THIS-OBJECT:buttonFile:UseCompatibleTextRendering = true.
    THIS-OBJECT:buttonFile:UseVisualStyleBackColor = true.
    THIS-OBJECT:buttonFile:Click:Subscribe(THIS-OBJECT:fileButton_click).
    /*  */
    /* lb_file_name */
    /*  */
    THIS-OBJECT:lb_file_name:Location = NEW System.Drawing.Point(12, 15).
    THIS-OBJECT:lb_file_name:Name = "lb_file_name".
    THIS-OBJECT:lb_file_name:Size = NEW System.Drawing.Size(152, 23).
    THIS-OBJECT:lb_file_name:TabIndex = 7.
    THIS-OBJECT:lb_file_name:Text = "Имя файла импорта".
    THIS-OBJECT:lb_file_name:UseCompatibleTextRendering = true.
    /*  */
    /* file_name */
    /*  */
    THIS-OBJECT:file_name:Location = NEW System.Drawing.Point(170, 12).
    THIS-OBJECT:file_name:Name = "file_name".
    THIS-OBJECT:file_name:Size = NEW System.Drawing.Size(229, 22).
    THIS-OBJECT:file_name:TabIndex = 6.
    /*  */
    /* code_obj */
    /*  */
    THIS-OBJECT:code_obj:Location = NEW System.Drawing.Point(277, 40).
    THIS-OBJECT:code_obj:Name = "code_obj".
    THIS-OBJECT:code_obj:Size = NEW System.Drawing.Size(122, 22).
    THIS-OBJECT:code_obj:TabIndex = 8.
    /*  */
    /* buttonObj */
    /*  */
    THIS-OBJECT:buttonObj:Location = NEW System.Drawing.Point(405, 40).
    THIS-OBJECT:buttonObj:Name = "buttonObj".
    THIS-OBJECT:buttonObj:Size = NEW System.Drawing.Size(75, 23).
    THIS-OBJECT:buttonObj:TabIndex = 9.
    THIS-OBJECT:buttonObj:Text = "Выбрать".
    THIS-OBJECT:buttonObj:UseCompatibleTextRendering = true.
    THIS-OBJECT:buttonObj:UseVisualStyleBackColor = true.
    THIS-OBJECT:buttonObj:Click:Subscribe(THIS-OBJECT:objButton_click).
    /*  */
    /* lb_code_obj */
    /*  */
    THIS-OBJECT:lb_code_obj:Location = NEW System.Drawing.Point(103, 43).
    THIS-OBJECT:lb_code_obj:Name = "lb_code_obj".
    THIS-OBJECT:lb_code_obj:Size = NEW System.Drawing.Size(168, 23).
    THIS-OBJECT:lb_code_obj:TabIndex = 10.
    THIS-OBJECT:lb_code_obj:Text = "Импортировать в объект".
    THIS-OBJECT:lb_code_obj:UseCompatibleTextRendering = true.
    /*  */
    /* cbCloseFact */
    /*  */
    THIS-OBJECT:cbCloseFact:CausesValidation = false.
    THIS-OBJECT:cbCloseFact:Location = NEW System.Drawing.Point(170, 68).
    THIS-OBJECT:cbCloseFact:Name = "cbCloseFact".
    THIS-OBJECT:cbCloseFact:Size = NEW System.Drawing.Size(310, 24).
    THIS-OBJECT:cbCloseFact:TabIndex = 11.
    THIS-OBJECT:cbCloseFact:Text = "Закрыть на факт после импорта".
    THIS-OBJECT:cbCloseFact:UseCompatibleTextRendering = true.
    THIS-OBJECT:cbCloseFact:UseMnemonic = false.
    THIS-OBJECT:cbCloseFact:UseVisualStyleBackColor = true.
    /*  */
    /* impdoc4dlg */
    /*  */
    THIS-OBJECT:AcceptButton = THIS-OBJECT:buttonOk.
    THIS-OBJECT:CancelButton = THIS-OBJECT:buttonCancel.
    THIS-OBJECT:ClientSize = NEW System.Drawing.Size(494, 142).
    THIS-OBJECT:Controls:Add(THIS-OBJECT:cbCloseFact).
    THIS-OBJECT:Controls:Add(THIS-OBJECT:lb_code_obj).
    THIS-OBJECT:Controls:Add(THIS-OBJECT:buttonObj).
    THIS-OBJECT:Controls:Add(THIS-OBJECT:code_obj).
    THIS-OBJECT:Controls:Add(THIS-OBJECT:lb_file_name).
    THIS-OBJECT:Controls:Add(THIS-OBJECT:file_name).
    THIS-OBJECT:Controls:Add(THIS-OBJECT:buttonFile).
    THIS-OBJECT:Controls:Add(THIS-OBJECT:buttonCancel).
    THIS-OBJECT:Controls:Add(THIS-OBJECT:buttonOk).
    THIS-OBJECT:Font = NEW System.Drawing.Font("Microsoft Sans Serif", Progress.Util.CastUtil:ToSingle(9.75), System.Drawing.FontStyle:Regular, System.Drawing.GraphicsUnit:Point, System.Convert:ToByte(204)).
    THIS-OBJECT:FormBorderStyle = System.Windows.Forms.FormBorderStyle:FixedDialog.
    THIS-OBJECT:MaximizeBox = false.
    THIS-OBJECT:MinimizeBox = false.
    THIS-OBJECT:Name = "impdoc4dlg".
    THIS-OBJECT:ShowInTaskbar = false.
    THIS-OBJECT:StartPosition = System.Windows.Forms.FormStartPosition:CenterParent.
    THIS-OBJECT:Text = "Импорт накладных".
    THIS-OBJECT:ResumeLayout(false).
    THIS-OBJECT:PerformLayout().
    CATCH e AS Progress.Lang.Error:
      UNDO, THROW e.
    END CATCH.
  END METHOD. 
 
  METHOD PUBLIC VOID ShowModalDialog(  ):
    
    WAIT-FOR THIS-OBJECT:ShowDialog().

  END METHOD.

 
END CLASS.
