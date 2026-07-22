using Progress.Windows.Form.
using ibs.th.ref.cashbookstorage from propath.
block-level on error undo, throw.
class ibs.th.ref.cashbookbrw inherits Form :
define variable vss-include-info0 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
  define variable v-cntxt-db-num        as integer   no-undo .
  define variable v-cntxt-userid        as character no-undo .
  define variable v-cntxt-level         as character no-undo .
  define variable v-cntxt-host-code-obj as integer   no-undo .
  define variable v-cntxt-obj-type      as character no-undo .
  define variable v-cntxt-obj-code      as integer   no-undo .
  define variable v-cntxt-db-num-obj    as integer   no-undo .
  define variable v-cntxt-is-admin      as logical   no-undo .
  define variable objKeyRec as ibs.th.gbl.keyrec no-undo.
  define private variable bAdd as System.Windows.Forms.Button no-undo.
  define private variable bAddObj as System.Windows.Forms.Button no-undo.
  define private variable bChange as System.Windows.Forms.Button no-undo.
  define private variable bChangeObj as System.Windows.Forms.Button no-undo.
  define private variable bDel as System.Windows.Forms.Button no-undo.
  define private variable bDelObj as System.Windows.Forms.Button no-undo.
  define private variable bGoods as System.Windows.Forms.Button no-undo.
   define private variable bhist as System.Windows.Forms.Button no-undo.
   define private variable bhistpko as System.Windows.Forms.Button no-undo.
  define private variable bindingSource1 as Progress.Data.BindingSource no-undo.
  define private variable bindingSource2 as Progress.Data.BindingSource no-undo.
   define private variable bistrko as System.Windows.Forms.Button no-undo.
  define private variable bLookup as System.Windows.Forms.Button no-undo.
  define private variable bLookupObj as System.Windows.Forms.Button no-undo.
  define private variable bMark as System.Windows.Forms.Button no-undo.
  define private variable bSelect as System.Windows.Forms.Button no-undo.
  define private variable buhFIODataGridViewTextBoxColumn as System.Windows.Forms.DataGridViewTextBoxColumn no-undo.
  define private variable cashbookBrowse as System.Windows.Forms.DataGridView no-undo.
  define private variable cashbookIdDataGridViewTextBoxColumn as System.Windows.Forms.DataGridViewTextBoxColumn no-undo.
  define private variable cashBookNameDataGridViewTextBoxColumn as System.Windows.Forms.DataGridViewTextBoxColumn no-undo.
  define private variable cashbookRuleBrowse as System.Windows.Forms.DataGridView no-undo.
  define private variable components as System.ComponentModel.IContainer no-undo.
  define private variable buttonOk as System.Windows.Forms.Button no-undo.
  define private variable currRkoDataGridViewTextBoxColumn as System.Windows.Forms.DataGridViewTextBoxColumn no-undo.
  define private variable currPkoDataGridViewTextBoxColumn as System.Windows.Forms.DataGridViewTextBoxColumn no-undo.
  define private variable groupBox1 as System.Windows.Forms.GroupBox no-undo.
  define private variable groupBox2 as System.Windows.Forms.GroupBox no-undo.
  define private variable hostcodeDataGridViewTextBoxColumn as System.Windows.Forms.DataGridViewTextBoxColumn no-undo.
  define private variable flagSepFullDataGridViewCheckBoxColumn as System.Windows.Forms.DataGridViewCheckBoxColumn no-undo.
  define private variable flagSepCashDataGridViewCheckBoxColumn as System.Windows.Forms.DataGridViewCheckBoxColumn no-undo.
  define private variable extcodeDataGridViewTextBoxColumn as System.Windows.Forms.DataGridViewTextBoxColumn no-undo.
  define private variable id as System.Windows.Forms.DataGridViewTextBoxColumn no-undo.
  define private variable labelObj as System.Windows.Forms.Label no-undo.
  define private variable managerPositionDataGridViewTextBoxColumn as System.Windows.Forms.DataGridViewTextBoxColumn no-undo.
  define private variable managerFIODataGridViewTextBoxColumn as System.Windows.Forms.DataGridViewTextBoxColumn no-undo.
  define private variable markDataGridViewTextBoxColumn as System.Windows.Forms.DataGridViewTextBoxColumn no-undo.
  define private variable obj as System.Windows.Forms.DataGridViewTextBoxColumn no-undo.
  define private variable objtypeDataGridViewTextBoxColumn as System.Windows.Forms.DataGridViewTextBoxColumn no-undo.
  define private variable objcodeDataGridViewTextBoxColumn as System.Windows.Forms.DataGridViewTextBoxColumn no-undo.
   define private variable OcnAcct as System.Windows.Forms.DataGridViewTextBoxColumn no-undo.
  define private variable rbFirmSelect as System.Windows.Forms.RadioButton no-undo.
  define private variable rbFirmCurr as System.Windows.Forms.RadioButton no-undo.
  define private variable rbFirmAll as System.Windows.Forms.RadioButton no-undo.
  define private variable rbStatDel as System.Windows.Forms.RadioButton no-undo.
  define private variable rbStatCurr as System.Windows.Forms.RadioButton no-undo.
  define private variable rbStatAll as System.Windows.Forms.RadioButton no-undo.
  define private variable rkoMaskDataGridViewTextBoxColumn as System.Windows.Forms.DataGridViewTextBoxColumn no-undo.
  define private variable pkoMaskDataGridViewTextBoxColumn as System.Windows.Forms.DataGridViewTextBoxColumn no-undo.
   define private variable RuleOsnPko as System.Windows.Forms.DataGridViewTextBoxColumn no-undo.
  define private variable rulePrilDataGridViewTextBoxColumn as System.Windows.Forms.DataGridViewTextBoxColumn no-undo.
  define private variable statDataGridViewTextBoxColumn as System.Windows.Forms.DataGridViewTextBoxColumn no-undo.
  define private variable uchetDataGridViewTextBoxColumn as System.Windows.Forms.DataGridViewTextBoxColumn no-undo.
  define private variable structDataGridViewTextBoxColumn as System.Windows.Forms.DataGridViewTextBoxColumn no-undo.
  define         variable v-status                         as character                                      no-undo .
  define         variable v-firmes                         as character                                      no-undo .
  define         variable v-id                             as integer                                        no-undo .
  define         variable v-ext-code                       as character                                      no-undo .
  define         variable v-list                           as character                                      no-undo .
  define variable v-host-code as character no-undo .
  define variable v-obj-code as integer no-undo .
  define variable v-obj-type as character no-undo .
  define private variable iH as handle no-undo .
  define         variable mCashBook as class ibs.th.ref.cashbookstorage no-undo .
  define variable vMode as character no-undo .
  define variable mQuery as handle no-undo .
  define variable mQueryRule as handle no-undo .
  define private variable v-firmChoosed as logical no-undo .
  define variable parparentproc as handle no-undo .
  define property out-list-id as character no-undo
  public get.
  private set (input iList as character) :
    out-list-id = iList .
  end.
  constructor public cashbookbrw( input Mode as character, input p-parparentproc as handle ):
    super().
    parparentproc = p-parparentproc .
    vMode = Mode .
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
    InitializeComponent().
    Visual_form(vMode) .
    v-status = 'тек':U.
    v-firmes = 'все':U .
    mCashBook = new cashbookstorage () .
    bindingSource1:Handle = mCashBook:getquery(input v-status, input v-firmes, output mQuery, output mQueryRule).
    bindingSource2:handle = mQueryRule .
    this-object:ComponentsCollection:ADD(this-object:components).
    catch e as Progress.Lang.Error:
      undo, throw e.
    end catch.
  end constructor.
  constructor public cashbookbrw( ):
    super().
    InitializeComponent ( ).
    catch e as Progress.Lang.Error:
       undo, throw e.
    end catch.
  end constructor.
  destructor public cashbookbrw( ):
     delete object mCashBook no-error .
     if valid-object(components) then do:
        cast(components, System.IDisposable):Dispose().
     end.
  end destructor.
        @VisualDesigner.
        method private void bhist_Click( input sender as System.Object, input e as System.EventArgs ):
           define variable v-rid-list as character no-undo.
                run ref/ccbhist.w (v-id, // id
                   parparentproc,
                   0,
                   "",
                   0,
                   "",
                   "one",
                   ?,
                   "",
                   "",
                   ibs.th.gbl.gbl-var:g#db-num,
                   ?,
                   input-output v-rid-list ).
                return.
        end method.
        @VisualDesigner.
   method private void bhistpko_Click( input sender as System.Object, input e as System.EventArgs ):
      define variable v-cashbookrule-key-rec as character no-undo.
      define variable v-rid-list as character no-undo.
      define variable v-id as int64 no-undo.
      define variable v-obj-code as integer no-undo.
      define variable v-obj-type as character no-undo.
      v-id = cashbookBrowse:CurrentRow:Cells["id"]:Value .
      v-obj-code = integer(substring(cashbookRuleBrowse:CurrentRow:Cells["obj"]:Value:ToString(), 4)) .
      v-obj-type = substring(cashbookRuleBrowse:CurrentRow:Cells["obj"]:Value:ToString(), 1, 3) .
      find first cashbookrule where CashBookRule.CashBookID eq v-id
                                and CashBookRule.Obj-type   eq v-obj-type
                                and CashBookRule.Obj-code   eq v-obj-code
                                and CashBookRule.Code       eq "currPko"
      no-lock no-error.
      if available cashbookrule
      then do:
         objKeyRec = new ibs.th.gbl.keyrec().
         objKeyRec:GenKeyRec ( input 'CashBookRule':U
                              ,input buffer ub.cashbookrule:handle
                              ,output v-cashbookrule-key-rec).
         delete object objKeyRec.
         find first clients where clients.obj-type eq cashbookrule.obj-type
                             and clients.obj-code  eq  cashbookrule.obj-code
         no-lock no-error.
         if     available clients
            and clients.db-num ne ?
         then
            run ref/ccounhist.w (clients.db-num, // id
                               "cashbookrule",
                               v-cashbookrule-key-rec,
                               "currPKO",
                               parparentproc,
                               0,
                               "",
                               0,
                               "",
                               "one",
                               ?,
                               "",
                               "",
                               ibs.th.gbl.gbl-var:g#db-num,
                               ?,
                               input-output v-rid-list ).
      end.
      return.
   end method.
        @VisualDesigner.
        method private void bistrko_Click( input sender as System.Object, input e as System.EventArgs ):
                define variable v-cashbookrule-key-rec as character no-undo.
      define variable v-rid-list as character no-undo.
      define variable v-id as int64 no-undo.
      define variable v-obj-code as integer no-undo.
      define variable v-obj-type as character no-undo.
      v-id = cashbookBrowse:CurrentRow:Cells["id"]:Value .
      v-obj-code = integer(substring(cashbookRuleBrowse:CurrentRow:Cells["obj"]:Value:ToString(), 4)) .
      v-obj-type = substring(cashbookRuleBrowse:CurrentRow:Cells["obj"]:Value:ToString(), 1, 3) .
      find first cashbookrule where CashBookRule.CashBookID eq v-id
                                and CashBookRule.Obj-type   eq v-obj-type
                                and CashBookRule.Obj-code   eq v-obj-code
                                and CashBookRule.Code       eq "currRko"
      no-lock no-error.
      if available cashbookrule
      then do:
         objKeyRec = new ibs.th.gbl.keyrec().
         objKeyRec:GenKeyRec ( input 'CashBookRule':U
                              ,input buffer ub.cashbookrule:handle
                              ,output v-cashbookrule-key-rec).
         delete object objKeyRec.
         find first clients where clients.obj-type eq cashbookrule.obj-type
                              and clients.obj-code eq cashbookrule.obj-code
         no-lock no-error.
         if     available clients
            and clients.db-num ne ?
         then
            run ref/ccounhist.w (clients.db-num, // id
                               "cashbookrule",
                               v-cashbookrule-key-rec,
                               "currRKO",
                               parparentproc,
                               0,
                               "",
                               0,
                               "",
                               "one",
                               ?,
                               "",
                               "",
                               ibs.th.gbl.gbl-var:g#db-num,
                               ?,
                               input-output v-rid-list
                            ).
      end.
                return.
        end method.
        @VisualDesigner.
        method private void cashbookBrowse_SelectionChanged( input sender as System.Object, input e as System.EventArgs ):
                if mQuery:num-results > 0
                then do :
                v-id = cashbookBrowse:CurrentRow:Cells["id"]:Value no-error.
                if error-status:error then return .
                mQueryRule:query-prepare(substitute("FOR EACH tt-cashbookrule where tt-cashbookrule.CashBookId = &1 break by tt-cashbookrule.host-code by tt-cashbookrule.obj-type desc by tt-cashbookrule.obj-code", v-id)).
      mQueryRule:query-open ().
      bindingSource2:handle = mQueryRule .
    end .
        end method.
        @VisualDesigner.
        method private void labelObj_Click( input sender as System.Object, input e as System.EventArgs ):
                return.
        end method.
        @VisualDesigner.
        method private void labelObj_DoubleClick( input sender as System.Object, input e as System.EventArgs ):
                this-object:cashbookBrowse:Columns[1]:Visible = not this-object:cashbookBrowse:Columns[1]:Visible .
                return.
        end method.
  method public void Visual_form( input iChange AS character ):
    define variable v-log as logical no-undo .
    IF iChange = 'ИЗМЕНЕНИЕ':U then
    do:
      assign
        this-object:bMark:Enabled = false
        this-object:bSelect:Enabled = false
      .
      if v-cntxt-db-num <> 0
      then do :
        v-log = true .
define variable vss-include-info2 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
    ,output v-log
    )  .
end.
        assign
          this-object:bAdd:Enabled = false
          this-object:bChange:Enabled = false
          this-object:bDel:Enabled = false
          this-object:bAddObj:Enabled = false
          this-object:bChangeObj:Enabled = false
          this-object:bDelObj:Enabled = false
        .
        if v-log then this-object:bChangeObj:Enabled = true .
      end.
    end.
    if iChange = 'ВЫБОР':U then do:
      assign
        this-object:bAdd:Enabled = false
        this-object:bChange:Enabled = false
        this-object:bDel:Enabled = false
        this-object:bAddObj:Enabled = false
        this-object:bChangeObj:Enabled = false
        this-object:bDelObj:Enabled = false
        this-object:bMark:Enabled = false
      .
    end.
    if iChange = "multiselect" then do:
      assign
        this-object:bAdd:Enabled = false
        this-object:bChange:Enabled = false
        this-object:bDel:Enabled = false
        this-object:bAddObj:Enabled = false
        this-object:bChangeObj:Enabled = false
        this-object:bDelObj:Enabled = false
      .
    end.
    if iChange = 'ПРОСМОТР':U then do:
      assign
        this-object:bMark:Enabled = false
        this-object:bSelect:Enabled = false
      .
      v-log = true .
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
    ,output v-log
    )  .
end.
      assign
        this-object:bAdd:Enabled = false
        this-object:bChange:Enabled = false
        this-object:bDel:Enabled = false
        this-object:bAddObj:Enabled = false
        this-object:bChangeObj:Enabled = false
        this-object:bDelObj:Enabled = false
      .
      if v-log then this-object:bChangeObj:Enabled = true .
    end.
    return.
  end method .
        @VisualDesigner.
        method private void bAdd_Click( input sender as System.Object, input e as System.EventArgs ):
          define variable v-log as logical no-undo .
    v-log = true .
define variable vss-include-info4 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
do:
  run chk-actg in ibs.th.gbl.gbl-hndllib:g#library2
    (input  v-cntxt-db-num
    ,input  v-cntxt-userid
    ,input  0
    ,input  'actn_fin-cashbook_add-def':U
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
    if v-log = false then do :
      message 'Для добавления требуется право "кассовые книги ДОБАВЛЕНИЕ"' view-as alert-box .
      return .
    end.
                AddCashBook('ДОБАВЛЕНИЕ':U, v-id) .
                return.
        end method.
        method private void AddCashBook( Mode as character, v-id as int64):
    run ref/cashbookfrm.p (parparentproc,Mode,v-id).
    define variable vPos      as integer   no-undo.
    vPos = bindingSource1:Position.
    bindingSource1:Handle = mCashBook:getquery(input v-status, input v-firmes, output mQuery, output mQueryRule).
    bindingSource2:handle = mQueryRule .
    bindingSource1:Position = vPos .
  end method.
        @VisualDesigner.
        method private void bAddObj_Click( input sender as System.Object, input e as System.EventArgs ):
    if valid-handle (mQuery)
    and mQuery:num-results > 0
    then do :
      define variable v-log as logical no-undo .
      v-log = true .
define variable vss-include-info5 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
do:
  run chk-actg in ibs.th.gbl.gbl-hndllib:g#library2
    (input  v-cntxt-db-num
    ,input  v-cntxt-userid
    ,input  0
    ,input  'actn_fin-cashbook_add-def':U
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
      if v-log = false then do :
        message 'Для добавления требуется право "кассовые книги ДОБАВЛЕНИЕ"' view-as alert-box .
        return .
      end.
                v-id = cashbookBrowse:CurrentRow:Cells["id"]:Value .
                v-obj-code = ? .
                v-obj-type = ? .
                AddCashBookObj('ДОБАВЛЕНИЕ':U, v-id, v-obj-code, v-obj-type) .
    end.
    else do :
      message "Сначала выберите (или создайте) тип кассовой книги!" view-as alert-box .
    end.
                return.
        end method.
        method private void AddCashBookObj( Mode as character, p-id as int64, p-obj-code as integer, p-obj-type as character):
    run ref/cashbookobj.p(parparentproc,mode,p-id,p-obj-code,p-obj-type).
    define variable vPos      as integer   no-undo.
    vPos = bindingSource1:Position.
    bindingSource1:Handle = mCashBook:getquery(input v-status, input v-firmes, output mQuery, output mQueryRule).
    bindingSource2:handle = mQueryRule .
    bindingSource1:Position = vPos .
  end method.
        @VisualDesigner.
        method private void bChange_Click( input sender as System.Object, input e as System.EventArgs ):
          define variable v-log as logical no-undo .
    v-log = true .
define variable vss-include-info6 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
    if v-log = false then do :
      message 'Для изменения требуется право "кассовые книги ИЗМЕНЕНИЕ"' view-as alert-box .
      return .
    end.
          v-id = cashbookBrowse:CurrentRow:Cells["id"]:Value .
                AddCashBook('ИЗМЕНЕНИЕ':U, v-id) .
                return.
        end method.
        @VisualDesigner.
        method private void bChangeObj_Click( input sender as System.Object, input e as System.EventArgs ):
                if valid-handle (mQueryRule)
                and mQueryRule:num-results > 0
                then do :
                  define variable v-log as logical no-undo .
                  define variable v-log2 as logical no-undo .
      v-log = true .
define variable vss-include-info7 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
define variable vss-include-info8 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
      if v-log = false and v-log2 = false then do :
        message 'Для изменения требуется право "кассовые книги ИЗМЕНЕНИЕ" либо право "Текущий номер ПКО/РКО ИЗМЕНЕНИЕ"' view-as alert-box .
        return .
      end.
                v-id = cashbookBrowse:CurrentRow:Cells["id"]:Value .
      v-obj-code = integer(substring(cashbookRuleBrowse:CurrentRow:Cells["obj"]:Value:ToString(), 4)) .
      v-obj-type = substring(cashbookRuleBrowse:CurrentRow:Cells["obj"]:Value:ToString(), 1, 3) .
      AddCashBookObj('ИЗМЕНЕНИЕ':U, v-id, v-obj-code, v-obj-type) .
    end.
    return.
        end method.
        @VisualDesigner.
        method private void bDel_Click( input sender as System.Object, input e as System.EventArgs ):
          define variable v-ok as logical no-undo .
          define variable vPos      as integer   no-undo.
          define variable v-log as logical no-undo .
    v-log = true .
define variable vss-include-info9 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
do:
  run chk-actg in ibs.th.gbl.gbl-hndllib:g#library2
    (input  v-cntxt-db-num
    ,input  v-cntxt-userid
    ,input  0
    ,input  'actn_fin-cashbook_deletion':U
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
    if v-log = false then do :
      message 'Для удаления требуется право "кассовые книги удаления"' view-as alert-box .
      return .
    end.
          message "Вы уверены?" view-as alert-box question buttons yes-no update v-ok .
          if not v-ok then return .
          vPos = bindingSource1:Position.
                v-id = cashbookBrowse:CurrentRow:Cells["id"]:Value .
                mCashBook:deleteDB(v-id) .
    bindingSource1:Handle = mCashBook:getquery(input v-status, input v-firmes, output mQuery, output mQueryRule).
    bindingSource2:handle = mQueryRule .
    bindingSource1:Position = vPos no-error .
                return.
        end method.
        @VisualDesigner.
        method private void bDelObj_Click( input sender as System.Object, input e as System.EventArgs ):
                define variable v-ok as logical no-undo .
                if valid-handle (mQueryRule)
    and mQueryRule:num-results > 0
    then do :
      define variable v-log as logical no-undo .
      v-log = true .
define variable vss-include-info10 as character format "X(65)" no-undo initial "@(#)$Workfile$ $Revision$".
do:
  run chk-actg in ibs.th.gbl.gbl-hndllib:g#library2
    (input  v-cntxt-db-num
    ,input  v-cntxt-userid
    ,input  0
    ,input  'actn_fin-cashbook_deletion':U
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
      if v-log = false then do :
        message 'Для удаления требуется право "кассовые книги удаления"' view-as alert-box .
        return .
      end.
      message "Вы уверены? Настройки будут удалены из базы!" view-as alert-box question buttons yes-no update v-ok .
      if not v-ok then return .
      v-id = cashbookBrowse:CurrentRow:Cells["id"]:Value .
      v-obj-code = integer(substring(cashbookRuleBrowse:CurrentRow:Cells["obj"]:Value:ToString(), 4)) .
      v-obj-type = substring(cashbookRuleBrowse:CurrentRow:Cells["obj"]:Value:ToString(), 1, 3) .
      mCashBook:deleteDBobj(v-id, v-obj-type, v-obj-code) .
      bindingSource1:Handle = mCashBook:getquery(input v-status, input v-firmes, output mQuery, output mQueryRule).
      bindingSource2:handle = mQueryRule .
    end.
                return.
        end method.
        @VisualDesigner.
        method private void bLookup_Click( input sender as System.Object, input e as System.EventArgs ):
          define variable v-log as logical no-undo .
                v-id = cashbookBrowse:CurrentRow:Cells["id"]:Value .
    AddCashBook('ПРОСМОТР':U, v-id) .
    return.
        end method.
        @VisualDesigner.
        method private void bLookupObj_Click( input sender as System.Object, input e as System.EventArgs ):
                if valid-handle (mQueryRule)
    and mQueryRule:num-results > 0
    then do :
      v-id = cashbookBrowse:CurrentRow:Cells["id"]:Value .
      v-obj-code = integer(substring(cashbookRuleBrowse:CurrentRow:Cells["obj"]:Value:ToString(), 4)) .
      v-obj-type = substring(cashbookRuleBrowse:CurrentRow:Cells["obj"]:Value:ToString(), 1, 3) .
      AddCashBookObj('ПРОСМОТР':U, v-id, v-obj-code, v-obj-type) .
    end.
                return.
        end method.
        @VisualDesigner.
        method private void bMark_Click( input sender as System.Object, input e as System.EventArgs ):
                define variable vPos as integer no-undo.
    define variable v-mark as character no-undo .
    vPos = bindingSource1:Position.
    v-mark = cashbookBrowse:CurrentRow:Cells["markDataGridViewTextBoxColumn"]:Value .
    v-id = cashbookBrowse:CurrentRow:Cells["id"]:Value .
    v-list = "" .
    if v-mark = "*"
    then do :
      cashbookBrowse:CurrentRow:Cells["markDataGridViewTextBoxColumn"]:Value = "" .
      mQuery:reposition-to-row (vPos + 1) .
      mQuery:get-buffer-handle("tt-cashbook"):buffer-field("mark"):buffer-value = "" .
    end.
    else do :
      cashbookBrowse:CurrentRow:Cells["markDataGridViewTextBoxColumn"]:Value = "*" .
      mQuery:reposition-to-row (vPos + 1) .
      mQuery:get-buffer-handle("tt-cashbook"):buffer-field("mark"):buffer-value = "*" .
    end.
    mQuery:get-first () .
    repeat :
      v-id = mQuery:get-buffer-handle("tt-cashbook"):buffer-field("id"):buffer-value .
      if mQuery:get-buffer-handle("tt-cashbook"):buffer-field("mark"):buffer-value = "*"
      then v-list = v-list + chr(6) + string(v-id) .
      mQuery:get-next () no-error.
      if mQuery:query-off-end then leave .
    end.
    v-list = trim (v-list,chr(6)) .
    if cashbookBrowse:RowCount <> (bindingSource1:position + 1) then bindingSource1:Position = vPos + 1 .
                return.
        end method.
        @VisualDesigner.
        method private void bSelect_Click( input sender as System.Object, input e as System.EventArgs ):
                if trim(v-list) <> ""
                then do :
                  out-list-id = v-list .
                end.
                else do :
                  out-list-id = string(cashbookBrowse:CurrentRow:Cells["id"]:Value) .
                end.
                close() .
                return.
        end method.
        @VisualDesigner.
        method private void goods_Click( input sender as System.Object, input e as System.EventArgs ):
    define variable v-err-msg as character no-undo .
    define variable vPos      as integer   no-undo .
    define variable v-listact-brw as class ibs.th.ref.bpa.BPA_Goods no-undo .
    if valid-handle (mQuery)
    and mQuery:num-results > 0
    then.
    else return .
    v-ext-code = cashbookBrowse:CurrentRow:Cells["id"]:Value .
    v-listact-brw = new ibs.th.ref.bpa.BPA_Goods ( vMode, v-ext-code, 'cash-book-id':U).
 //v-listact-brw:Visual_form(iChange).
    v-listact-brw:parparentproc = parparentproc.
    wait-for  v-listact-brw:ShowDialog() .
    catch exAppErrors as class Progress.Lang.AppError :
      v-err-msg = exAppErrors:ReturnValue .
      if v-err-msg > "" then .
      else
      do :
        v-err-msg = exAppErrors:GetMessage(1) .
        if v-err-msg > "" then .
        else v-err-msg = "AppError в модуле c:\tester\Rls_16_0\rc_160_rus\cmpdir\src\ibs\th\ref\cashbookbrw.cls" .
      end .
      message v-err-msg  view-as alert-box.
    end catch .
    catch exProErrors as class Progress.Lang.ProError :
      v-err-msg = exProErrors:GetMessage(1) .
      if v-err-msg > "" then .
      else v-err-msg = "ProError в модуле c:\tester\Rls_16_0\rc_160_rus\cmpdir\src\ibs\th\ref\cashbookbrw.cls" .
      message "ProError" skip(1) v-err-msg  view-as alert-box.
    end catch .
    catch exAnyErrors as class Progress.Lang.Error:
      v-err-msg = "Unexpected error в модуле c:\tester\Rls_16_0\rc_160_rus\cmpdir\src\ibs\th\ref\cashbookbrw.cls " + exAnyErrors:GetMessage(1).
      message "LangError" skip(1) v-err-msg  view-as alert-box.
    end catch .
    finally:
      if valid-object(v-listact-brw) then delete object v-listact-brw no-error .
    end finally.
        end method.
  method private void okButton_Click (sender as System.Object, e as System.EventArgs):
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
      tableDesc1 = new Progress.Data.TableDesc("tt-cashbook").
      @VisualDesigner.FormMember (NeedsInitialize="true").
      define variable tableDesc2 as Progress.Data.TableDesc no-undo.
      tableDesc2 = new Progress.Data.TableDesc("tt-cashbook-rule").
      this-object:buttonOk = new System.Windows.Forms.Button().
      this-object:cashbookBrowse = new System.Windows.Forms.DataGridView().
      this-object:bindingSource1 = new Progress.Data.BindingSource(this-object:components).
      this-object:bGoods = new System.Windows.Forms.Button().
      this-object:cashbookRuleBrowse = new System.Windows.Forms.DataGridView().
      this-object:hostcodeDataGridViewTextBoxColumn = new System.Windows.Forms.DataGridViewTextBoxColumn().
      this-object:obj = new System.Windows.Forms.DataGridViewTextBoxColumn().
      this-object:cashbookIdDataGridViewTextBoxColumn = new System.Windows.Forms.DataGridViewTextBoxColumn().
      this-object:objtypeDataGridViewTextBoxColumn = new System.Windows.Forms.DataGridViewTextBoxColumn().
      this-object:objcodeDataGridViewTextBoxColumn = new System.Windows.Forms.DataGridViewTextBoxColumn().
      this-object:managerPositionDataGridViewTextBoxColumn = new System.Windows.Forms.DataGridViewTextBoxColumn().
      this-object:managerFIODataGridViewTextBoxColumn = new System.Windows.Forms.DataGridViewTextBoxColumn().
      this-object:buhFIODataGridViewTextBoxColumn = new System.Windows.Forms.DataGridViewTextBoxColumn().
      this-object:structDataGridViewTextBoxColumn = new System.Windows.Forms.DataGridViewTextBoxColumn().
      this-object:uchetDataGridViewTextBoxColumn = new System.Windows.Forms.DataGridViewTextBoxColumn().
      this-object:pkoMaskDataGridViewTextBoxColumn = new System.Windows.Forms.DataGridViewTextBoxColumn().
      this-object:rkoMaskDataGridViewTextBoxColumn = new System.Windows.Forms.DataGridViewTextBoxColumn().
      this-object:currPkoDataGridViewTextBoxColumn = new System.Windows.Forms.DataGridViewTextBoxColumn().
      this-object:currRkoDataGridViewTextBoxColumn = new System.Windows.Forms.DataGridViewTextBoxColumn().
      this-object:bindingSource2 = new Progress.Data.BindingSource(this-object:components).
      this-object:bAdd = new System.Windows.Forms.Button().
      this-object:bMark = new System.Windows.Forms.Button().
      this-object:bSelect = new System.Windows.Forms.Button().
      this-object:bChange = new System.Windows.Forms.Button().
      this-object:bLookup = new System.Windows.Forms.Button().
      this-object:bDel = new System.Windows.Forms.Button().
      this-object:rbStatDel = new System.Windows.Forms.RadioButton().
      this-object:groupBox1 = new System.Windows.Forms.GroupBox().
      this-object:rbStatCurr = new System.Windows.Forms.RadioButton().
      this-object:rbStatAll = new System.Windows.Forms.RadioButton().
      this-object:rbFirmSelect = new System.Windows.Forms.RadioButton().
      this-object:groupBox2 = new System.Windows.Forms.GroupBox().
      this-object:rbFirmCurr = new System.Windows.Forms.RadioButton().
      this-object:rbFirmAll = new System.Windows.Forms.RadioButton().
      this-object:bDelObj = new System.Windows.Forms.Button().
      this-object:bLookupObj = new System.Windows.Forms.Button().
      this-object:bChangeObj = new System.Windows.Forms.Button().
      this-object:bAddObj = new System.Windows.Forms.Button().
      this-object:labelObj = new System.Windows.Forms.Label().
      this-object:bhist = new System.Windows.Forms.Button().
      this-object:bhistpko = new System.Windows.Forms.Button().
      this-object:bistrko = new System.Windows.Forms.Button().
      this-object:markDataGridViewTextBoxColumn = new System.Windows.Forms.DataGridViewTextBoxColumn().
      this-object:extcodeDataGridViewTextBoxColumn = new System.Windows.Forms.DataGridViewTextBoxColumn().
      this-object:id = new System.Windows.Forms.DataGridViewTextBoxColumn().
      this-object:cashBookNameDataGridViewTextBoxColumn = new System.Windows.Forms.DataGridViewTextBoxColumn().
      this-object:rulePrilDataGridViewTextBoxColumn = new System.Windows.Forms.DataGridViewTextBoxColumn().
      this-object:flagSepCashDataGridViewCheckBoxColumn = new System.Windows.Forms.DataGridViewCheckBoxColumn().
      this-object:flagSepFullDataGridViewCheckBoxColumn = new System.Windows.Forms.DataGridViewCheckBoxColumn().
      this-object:statDataGridViewTextBoxColumn = new System.Windows.Forms.DataGridViewTextBoxColumn().
      this-object:RuleOsnPko = new System.Windows.Forms.DataGridViewTextBoxColumn().
      this-object:OcnAcct = new System.Windows.Forms.DataGridViewTextBoxColumn().
      cast(this-object:cashbookBrowse, System.ComponentModel.ISupportInitialize):BeginInit().
      cast(this-object:bindingSource1, System.ComponentModel.ISupportInitialize):BeginInit().
      cast(this-object:cashbookRuleBrowse, System.ComponentModel.ISupportInitialize):BeginInit().
      cast(this-object:bindingSource2, System.ComponentModel.ISupportInitialize):BeginInit().
      this-object:groupBox1:SuspendLayout().
      this-object:groupBox2:SuspendLayout().
      this-object:SuspendLayout().
      this-object:buttonOk:Location = new System.Drawing.Point(12, 12).
      this-object:buttonOk:Name = "buttonOk".
      this-object:buttonOk:Size = new System.Drawing.Size(75, 23).
      this-object:buttonOk:TabIndex = 0.
      this-object:buttonOk:Text = "Выход".
      this-object:buttonOk:UseCompatibleTextRendering = true.
      this-object:buttonOk:Click:Subscribe(this-object:okButton_Click).
      this-object:cashbookBrowse:AllowUserToAddRows = false.
      this-object:cashbookBrowse:AllowUserToDeleteRows = false.
      this-object:cashbookBrowse:AllowUserToOrderColumns = true.
      define variable nestedvar0 as System.Windows.Forms.AnchorStyles no-undo.
      nestedvar0 = cast(Progress.Util.EnumHelper:Or(cast(Progress.Util.EnumHelper:Or(System.Windows.Forms.AnchorStyles:Top, System.Windows.Forms.AnchorStyles:Bottom), System.Windows.Forms.AnchorStyles), System.Windows.Forms.AnchorStyles:Left), System.Windows.Forms.AnchorStyles).
      this-object:cashbookBrowse:Anchor = cast(Progress.Util.EnumHelper:Or(nestedvar0, System.Windows.Forms.AnchorStyles:Right), System.Windows.Forms.AnchorStyles).
      this-object:cashbookBrowse:AutoGenerateColumns = false.
      this-object:cashbookBrowse:AutoSizeColumnsMode = System.Windows.Forms.DataGridViewAutoSizeColumnsMode:DisplayedCells.
      this-object:cashbookBrowse:CausesValidation = false.
      this-object:cashbookBrowse:ColumnHeadersHeightSizeMode = System.Windows.Forms.DataGridViewColumnHeadersHeightSizeMode:AutoSize.
      @VisualDesigner.FormMember (NeedsInitialize="false", InitializeArray="true").
      define variable arrayvar0 as System.Windows.Forms.DataGridViewColumn extent 10 no-undo.
      arrayvar0[1] = this-object:markDataGridViewTextBoxColumn.
      arrayvar0[2] = this-object:extcodeDataGridViewTextBoxColumn.
      arrayvar0[3] = this-object:id.
      arrayvar0[4] = this-object:cashBookNameDataGridViewTextBoxColumn.
      arrayvar0[5] = this-object:rulePrilDataGridViewTextBoxColumn.
      arrayvar0[6] = this-object:flagSepCashDataGridViewCheckBoxColumn.
      arrayvar0[7] = this-object:flagSepFullDataGridViewCheckBoxColumn.
      arrayvar0[8] = this-object:statDataGridViewTextBoxColumn.
      arrayvar0[9] = this-object:RuleOsnPko.
      arrayvar0[10] = this-object:OcnAcct.
      this-object:cashbookBrowse:Columns:AddRange(arrayvar0).
      this-object:cashbookBrowse:DataSource = this-object:bindingSource1.
      this-object:cashbookBrowse:Location = new System.Drawing.Point(12, 88).
      this-object:cashbookBrowse:Name = "cashbookBrowse".
      this-object:cashbookBrowse:ReadOnly = true.
      this-object:cashbookBrowse:ScrollBars = System.Windows.Forms.ScrollBars:Vertical.
      this-object:cashbookBrowse:Size = new System.Drawing.Size(1055, 195).
      this-object:cashbookBrowse:TabIndex = 2.
      this-object:cashbookBrowse:SelectionChanged:Subscribe(this-object:cashbookBrowse_SelectionChanged).
      this-object:bindingSource1:MaxDataGuess = 0.
      this-object:bindingSource1:NoLOBs = false.
      this-object:bindingSource1:Position = 0.
      @VisualDesigner.FormMember (NeedsInitialize="false", InitializeArray="true").
      define variable arrayvar1 as "Progress.Data.TableDesc[]" no-undo.
      arrayvar1 = new "Progress.Data.TableDesc[]"(0).
      tableDesc1:ChildTables = arrayvar1.
      @VisualDesigner.FormMember (NeedsInitialize="false", InitializeArray="true").
      define variable arrayvar2 as Progress.Data.ColumnPropDesc extent 12 no-undo.
      arrayvar2[1] = new Progress.Data.ColumnPropDesc("mark", "*", Progress.Data.DataType:CHARACTER).
      arrayvar2[2] = new Progress.Data.ColumnPropDesc("CashBookName", "Наименование", Progress.Data.DataType:CHARACTER).
      arrayvar2[3] = new Progress.Data.ColumnPropDesc("id", "id", Progress.Data.DataType:INT64).
      arrayvar2[4] = new Progress.Data.ColumnPropDesc("ext-code", "Код/номер", Progress.Data.DataType:CHARACTER).
      arrayvar2[5] = new Progress.Data.ColumnPropDesc("RuleOsnPko", "Правила заполнения графы ~"Основание~"", Progress.Data.DataType:CHARACTER).
      arrayvar2[6] = new Progress.Data.ColumnPropDesc("RulePril", "Правила заполнения графы ~"Приложение~"", Progress.Data.DataType:CHARACTER).
      arrayvar2[7] = new Progress.Data.ColumnPropDesc("CorrPko", "Кредит", Progress.Data.DataType:CHARACTER).
      arrayvar2[8] = new Progress.Data.ColumnPropDesc("OsnAcct", "Дебет", Progress.Data.DataType:CHARACTER).
      arrayvar2[9] = new Progress.Data.ColumnPropDesc("FlagSepCash", "Отдельно для каждой кассы", Progress.Data.DataType:LOGICAL).
      arrayvar2[10] = new Progress.Data.ColumnPropDesc("FlagSepFull", "Раздельно НП и ТНП", Progress.Data.DataType:LOGICAL).
      arrayvar2[11] = new Progress.Data.ColumnPropDesc("Status_", "Статус", Progress.Data.DataType:INTEGER).
      arrayvar2[12] = new Progress.Data.ColumnPropDesc("stat", "Статус", Progress.Data.DataType:CHARACTER).
      tableDesc1:Columns = arrayvar2.
      this-object:bindingSource1:TableSchema = tableDesc1.
      this-object:bGoods:Location = new System.Drawing.Point(564, 12).
      this-object:bGoods:Name = "bGoods".
      this-object:bGoods:Size = new System.Drawing.Size(75, 23).
      this-object:bGoods:TabIndex = 3.
      this-object:bGoods:Text = "Товары".
      this-object:bGoods:UseCompatibleTextRendering = true.
      this-object:bGoods:UseVisualStyleBackColor = true.
      this-object:bGoods:Click:Subscribe(this-object:goods_Click).
      this-object:cashbookRuleBrowse:AllowUserToAddRows = false.
      this-object:cashbookRuleBrowse:AllowUserToDeleteRows = false.
      this-object:cashbookRuleBrowse:AllowUserToOrderColumns = true.
      this-object:cashbookRuleBrowse:AutoGenerateColumns = false.
      this-object:cashbookRuleBrowse:CausesValidation = false.
      this-object:cashbookRuleBrowse:ColumnHeadersHeightSizeMode = System.Windows.Forms.DataGridViewColumnHeadersHeightSizeMode:AutoSize.
      @VisualDesigner.FormMember (NeedsInitialize="false", InitializeArray="true").
      define variable arrayvar3 as System.Windows.Forms.DataGridViewColumn extent 14 no-undo.
      arrayvar3[1] = this-object:hostcodeDataGridViewTextBoxColumn.
      arrayvar3[2] = this-object:obj.
      arrayvar3[3] = this-object:cashbookIdDataGridViewTextBoxColumn.
      arrayvar3[4] = this-object:objtypeDataGridViewTextBoxColumn.
      arrayvar3[5] = this-object:objcodeDataGridViewTextBoxColumn.
      arrayvar3[6] = this-object:managerPositionDataGridViewTextBoxColumn.
      arrayvar3[7] = this-object:managerFIODataGridViewTextBoxColumn.
      arrayvar3[8] = this-object:buhFIODataGridViewTextBoxColumn.
      arrayvar3[9] = this-object:structDataGridViewTextBoxColumn.
      arrayvar3[10] = this-object:uchetDataGridViewTextBoxColumn.
      arrayvar3[11] = this-object:pkoMaskDataGridViewTextBoxColumn.
      arrayvar3[12] = this-object:rkoMaskDataGridViewTextBoxColumn.
      arrayvar3[13] = this-object:currPkoDataGridViewTextBoxColumn.
      arrayvar3[14] = this-object:currRkoDataGridViewTextBoxColumn.
      this-object:cashbookRuleBrowse:Columns:AddRange(arrayvar3).
      this-object:cashbookRuleBrowse:DataSource = this-object:bindingSource2.
      this-object:cashbookRuleBrowse:Location = new System.Drawing.Point(12, 332).
      this-object:cashbookRuleBrowse:Name = "cashbookRuleBrowse".
      this-object:cashbookRuleBrowse:ReadOnly = true.
      this-object:cashbookRuleBrowse:Size = new System.Drawing.Size(1055, 293).
      this-object:cashbookRuleBrowse:TabIndex = 5.
      this-object:hostcodeDataGridViewTextBoxColumn:DataPropertyName = "host-code".
      this-object:hostcodeDataGridViewTextBoxColumn:HeaderText = "Фирма".
      this-object:hostcodeDataGridViewTextBoxColumn:Name = "hostcodeDataGridViewTextBoxColumn".
      this-object:hostcodeDataGridViewTextBoxColumn:ReadOnly = true.
      this-object:hostcodeDataGridViewTextBoxColumn:Width = 69.
      this-object:obj:DataPropertyName = "obj".
      this-object:obj:HeaderText = "Объект".
      this-object:obj:Name = "obj".
      this-object:obj:ReadOnly = true.
      this-object:obj:Width = 90.
      this-object:cashbookIdDataGridViewTextBoxColumn:DataPropertyName = "cashbookId".
      this-object:cashbookIdDataGridViewTextBoxColumn:HeaderText = "cashbookId".
      this-object:cashbookIdDataGridViewTextBoxColumn:Name = "cashbookIdDataGridViewTextBoxColumn".
      this-object:cashbookIdDataGridViewTextBoxColumn:ReadOnly = true.
      this-object:cashbookIdDataGridViewTextBoxColumn:Visible = false.
      this-object:cashbookIdDataGridViewTextBoxColumn:Width = 50.
      this-object:objtypeDataGridViewTextBoxColumn:DataPropertyName = "obj-type".
      this-object:objtypeDataGridViewTextBoxColumn:HeaderText = "obj-type".
      this-object:objtypeDataGridViewTextBoxColumn:Name = "objtypeDataGridViewTextBoxColumn".
      this-object:objtypeDataGridViewTextBoxColumn:ReadOnly = true.
      this-object:objtypeDataGridViewTextBoxColumn:Visible = false.
      this-object:objcodeDataGridViewTextBoxColumn:DataPropertyName = "obj-code".
      this-object:objcodeDataGridViewTextBoxColumn:HeaderText = "obj-code".
      this-object:objcodeDataGridViewTextBoxColumn:Name = "objcodeDataGridViewTextBoxColumn".
      this-object:objcodeDataGridViewTextBoxColumn:ReadOnly = true.
      this-object:objcodeDataGridViewTextBoxColumn:Visible = false.
      this-object:managerPositionDataGridViewTextBoxColumn:DataPropertyName = "ManagerPosition".
      this-object:managerPositionDataGridViewTextBoxColumn:HeaderText = "Должность руководителя".
      this-object:managerPositionDataGridViewTextBoxColumn:Name = "managerPositionDataGridViewTextBoxColumn".
      this-object:managerPositionDataGridViewTextBoxColumn:ReadOnly = true.
      this-object:managerFIODataGridViewTextBoxColumn:DataPropertyName = "ManagerFIO".
      this-object:managerFIODataGridViewTextBoxColumn:HeaderText = "ФИО руководителя".
      this-object:managerFIODataGridViewTextBoxColumn:Name = "managerFIODataGridViewTextBoxColumn".
      this-object:managerFIODataGridViewTextBoxColumn:ReadOnly = true.
      this-object:managerFIODataGridViewTextBoxColumn:Width = 120.
      this-object:buhFIODataGridViewTextBoxColumn:DataPropertyName = "BuhFIO".
      this-object:buhFIODataGridViewTextBoxColumn:HeaderText = "ФИО Бухгалтера".
      this-object:buhFIODataGridViewTextBoxColumn:Name = "buhFIODataGridViewTextBoxColumn".
      this-object:buhFIODataGridViewTextBoxColumn:ReadOnly = true.
      this-object:buhFIODataGridViewTextBoxColumn:Width = 120.
      this-object:structDataGridViewTextBoxColumn:DataPropertyName = "Struct".
      this-object:structDataGridViewTextBoxColumn:HeaderText = "Поле ~"Структурное подразделение~"".
      this-object:structDataGridViewTextBoxColumn:Name = "structDataGridViewTextBoxColumn".
      this-object:structDataGridViewTextBoxColumn:ReadOnly = true.
      this-object:uchetDataGridViewTextBoxColumn:DataPropertyName = "uchet".
      this-object:uchetDataGridViewTextBoxColumn:HeaderText = "Учёт ведётся".
      this-object:uchetDataGridViewTextBoxColumn:Name = "uchetDataGridViewTextBoxColumn".
      this-object:uchetDataGridViewTextBoxColumn:ReadOnly = true.
      this-object:uchetDataGridViewTextBoxColumn:Width = 80.
      this-object:pkoMaskDataGridViewTextBoxColumn:DataPropertyName = "PkoMask".
      this-object:pkoMaskDataGridViewTextBoxColumn:HeaderText = "Маска номера ПКО".
      this-object:pkoMaskDataGridViewTextBoxColumn:Name = "pkoMaskDataGridViewTextBoxColumn".
      this-object:pkoMaskDataGridViewTextBoxColumn:ReadOnly = true.
      this-object:pkoMaskDataGridViewTextBoxColumn:Width = 90.
      this-object:rkoMaskDataGridViewTextBoxColumn:DataPropertyName = "RkoMask".
      this-object:rkoMaskDataGridViewTextBoxColumn:HeaderText = "Маска номера РКО".
      this-object:rkoMaskDataGridViewTextBoxColumn:Name = "rkoMaskDataGridViewTextBoxColumn".
      this-object:rkoMaskDataGridViewTextBoxColumn:ReadOnly = true.
      this-object:rkoMaskDataGridViewTextBoxColumn:Width = 90.
      this-object:currPkoDataGridViewTextBoxColumn:DataPropertyName = "currPko".
      this-object:currPkoDataGridViewTextBoxColumn:HeaderText = "Текущий номер ПКО".
      this-object:currPkoDataGridViewTextBoxColumn:Name = "currPkoDataGridViewTextBoxColumn".
      this-object:currPkoDataGridViewTextBoxColumn:ReadOnly = true.
      this-object:currPkoDataGridViewTextBoxColumn:Width = 90.
      this-object:currRkoDataGridViewTextBoxColumn:DataPropertyName = "currRko".
      this-object:currRkoDataGridViewTextBoxColumn:HeaderText = "Текущий номер РКО".
      this-object:currRkoDataGridViewTextBoxColumn:Name = "currRkoDataGridViewTextBoxColumn".
      this-object:currRkoDataGridViewTextBoxColumn:ReadOnly = true.
      this-object:currRkoDataGridViewTextBoxColumn:Width = 90.
      this-object:bindingSource2:MaxDataGuess = 0.
      this-object:bindingSource2:NoLOBs = false.
      this-object:bindingSource2:Position = 0.
      @VisualDesigner.FormMember (NeedsInitialize="false", InitializeArray="true").
      define variable arrayvar4 as "Progress.Data.TableDesc[]" no-undo.
      arrayvar4 = new "Progress.Data.TableDesc[]"(0).
      tableDesc2:ChildTables = arrayvar4.
      @VisualDesigner.FormMember (NeedsInitialize="false", InitializeArray="true").
      define variable arrayvar5 as Progress.Data.ColumnPropDesc extent 16 no-undo.
      arrayvar5[1] = new Progress.Data.ColumnPropDesc("host-code", "Фирма", Progress.Data.DataType:CHARACTER).
      arrayvar5[2] = new Progress.Data.ColumnPropDesc("id", "id", Progress.Data.DataType:INT64).
      arrayvar5[3] = new Progress.Data.ColumnPropDesc("cashbookId", "cashbookId", Progress.Data.DataType:INT64).
      arrayvar5[4] = new Progress.Data.ColumnPropDesc("obj-type", "obj-type", Progress.Data.DataType:CHARACTER).
      arrayvar5[5] = new Progress.Data.ColumnPropDesc("obj-code", "obj-code", Progress.Data.DataType:INTEGER).
      arrayvar5[6] = new Progress.Data.ColumnPropDesc("ManagerPosition", "Должность руководителя", Progress.Data.DataType:CHARACTER).
      arrayvar5[7] = new Progress.Data.ColumnPropDesc("PkoMask", "Маска номера ПКО", Progress.Data.DataType:CHARACTER).
      arrayvar5[8] = new Progress.Data.ColumnPropDesc("RkoMask", "Маска номера РКО", Progress.Data.DataType:CHARACTER).
      arrayvar5[9] = new Progress.Data.ColumnPropDesc("currPko", "Текущий номер ПКО", Progress.Data.DataType:CHARACTER).
      arrayvar5[10] = new Progress.Data.ColumnPropDesc("currRko", "Текущий номер РКО", Progress.Data.DataType:CHARACTER).
      arrayvar5[11] = new Progress.Data.ColumnPropDesc("status_", "Статус", Progress.Data.DataType:INTEGER).
      arrayvar5[12] = new Progress.Data.ColumnPropDesc("obj", "Объект", Progress.Data.DataType:CHARACTER).
      arrayvar5[13] = new Progress.Data.ColumnPropDesc("ManagerFIO", "ФИО руководителя", Progress.Data.DataType:CHARACTER).
      arrayvar5[14] = new Progress.Data.ColumnPropDesc("BuhFIO", "ФИО Бухгалтера", Progress.Data.DataType:CHARACTER).
      arrayvar5[15] = new Progress.Data.ColumnPropDesc("Struct", "Поле ~"Структурное подразделение~"", Progress.Data.DataType:CHARACTER).
      arrayvar5[16] = new Progress.Data.ColumnPropDesc("uchet", "Учёт ведётся", Progress.Data.DataType:CHARACTER).
      tableDesc2:Columns = arrayvar5.
      this-object:bindingSource2:TableSchema = tableDesc2.
      this-object:bAdd:Location = new System.Drawing.Point(205, 12).
      this-object:bAdd:Name = "bAdd".
      this-object:bAdd:Size = new System.Drawing.Size(75, 23).
      this-object:bAdd:TabIndex = 6.
      this-object:bAdd:Text = "Добавить".
      this-object:bAdd:UseCompatibleTextRendering = true.
      this-object:bAdd:UseVisualStyleBackColor = true.
      this-object:bAdd:Click:Subscribe(this-object:bAdd_Click).
      this-object:bMark:Location = new System.Drawing.Point(93, 12).
      this-object:bMark:Name = "bMark".
      this-object:bMark:Size = new System.Drawing.Size(25, 23).
      this-object:bMark:TabIndex = 7.
      this-object:bMark:Text = "*".
      this-object:bMark:TextAlign = System.Drawing.ContentAlignment:BottomCenter.
      this-object:bMark:UseCompatibleTextRendering = true.
      this-object:bMark:UseVisualStyleBackColor = true.
      this-object:bMark:Click:Subscribe(this-object:bMark_Click).
      this-object:bSelect:Location = new System.Drawing.Point(124, 12).
      this-object:bSelect:Name = "bSelect".
      this-object:bSelect:Size = new System.Drawing.Size(75, 23).
      this-object:bSelect:TabIndex = 8.
      this-object:bSelect:Text = "Выбор".
      this-object:bSelect:UseCompatibleTextRendering = true.
      this-object:bSelect:UseVisualStyleBackColor = true.
      this-object:bSelect:Click:Subscribe(this-object:bSelect_Click).
      this-object:bChange:Location = new System.Drawing.Point(286, 12).
      this-object:bChange:Name = "bChange".
      this-object:bChange:Size = new System.Drawing.Size(75, 23).
      this-object:bChange:TabIndex = 9.
      this-object:bChange:Text = "Изменить".
      this-object:bChange:UseCompatibleTextRendering = true.
      this-object:bChange:UseVisualStyleBackColor = true.
      this-object:bChange:Click:Subscribe(this-object:bChange_Click).
      this-object:bLookup:Location = new System.Drawing.Point(367, 12).
      this-object:bLookup:Name = "bLookup".
      this-object:bLookup:Size = new System.Drawing.Size(75, 23).
      this-object:bLookup:TabIndex = 10.
      this-object:bLookup:Text = "Просмотр".
      this-object:bLookup:UseCompatibleTextRendering = true.
      this-object:bLookup:UseVisualStyleBackColor = true.
      this-object:bLookup:Click:Subscribe(this-object:bLookup_Click).
      this-object:bDel:Location = new System.Drawing.Point(448, 12).
      this-object:bDel:Name = "bDel".
      this-object:bDel:Size = new System.Drawing.Size(75, 23).
      this-object:bDel:TabIndex = 11.
      this-object:bDel:Text = "Удалить".
      this-object:bDel:UseCompatibleTextRendering = true.
      this-object:bDel:UseVisualStyleBackColor = true.
      this-object:bDel:Click:Subscribe(this-object:bDel_Click).
      this-object:rbStatDel:Location = new System.Drawing.Point(182, 13).
      this-object:rbStatDel:Name = "rbStatDel".
      this-object:rbStatDel:Size = new System.Drawing.Size(104, 24).
      this-object:rbStatDel:TabIndex = 2.
      this-object:rbStatDel:Text = "Удаленные".
      this-object:rbStatDel:UseCompatibleTextRendering = true.
      this-object:rbStatDel:UseVisualStyleBackColor = true.
      this-object:rbStatDel:CheckedChanged:Subscribe(this-object:status_CheckedChanged).
      this-object:groupBox1:Controls:Add(this-object:rbStatDel).
      this-object:groupBox1:Controls:Add(this-object:rbStatCurr).
      this-object:groupBox1:Controls:Add(this-object:rbStatAll).
      this-object:groupBox1:Location = new System.Drawing.Point(12, 41).
      this-object:groupBox1:Name = "groupBox1".
      this-object:groupBox1:Size = new System.Drawing.Size(302, 40).
      this-object:groupBox1:TabIndex = 18.
      this-object:groupBox1:TabStop = false.
      this-object:groupBox1:Text = "Статус".
      this-object:groupBox1:UseCompatibleTextRendering = true.
      this-object:rbStatCurr:Checked = true.
      this-object:rbStatCurr:Location = new System.Drawing.Point(88, 13).
      this-object:rbStatCurr:Name = "rbStatCurr".
      this-object:rbStatCurr:Size = new System.Drawing.Size(77, 24).
      this-object:rbStatCurr:TabIndex = 1.
      this-object:rbStatCurr:TabStop = true.
      this-object:rbStatCurr:Text = "Текущие".
      this-object:rbStatCurr:UseCompatibleTextRendering = true.
      this-object:rbStatCurr:UseVisualStyleBackColor = true.
      this-object:rbStatCurr:CheckedChanged:Subscribe(this-object:status_CheckedChanged).
      this-object:rbStatAll:Location = new System.Drawing.Point(25, 13).
      this-object:rbStatAll:Name = "rbStatAll".
      this-object:rbStatAll:Size = new System.Drawing.Size(54, 24).
      this-object:rbStatAll:TabIndex = 0.
      this-object:rbStatAll:Text = "Все".
      this-object:rbStatAll:UseCompatibleTextRendering = true.
      this-object:rbStatAll:UseVisualStyleBackColor = true.
      this-object:rbStatAll:CheckedChanged:Subscribe(this-object:status_CheckedChanged).
      this-object:rbFirmSelect:Location = new System.Drawing.Point(182, 13).
      this-object:rbFirmSelect:Name = "rbFirmSelect".
      this-object:rbFirmSelect:Size = new System.Drawing.Size(104, 24).
      this-object:rbFirmSelect:TabIndex = 2.
      this-object:rbFirmSelect:Text = "Выборочно".
      this-object:rbFirmSelect:UseCompatibleTextRendering = true.
      this-object:rbFirmSelect:UseVisualStyleBackColor = true.
      this-object:rbFirmSelect:CheckedChanged:Subscribe(this-object:firm_CheckedChanged).
      this-object:groupBox2:Controls:Add(this-object:rbFirmSelect).
      this-object:groupBox2:Controls:Add(this-object:rbFirmCurr).
      this-object:groupBox2:Controls:Add(this-object:rbFirmAll).
      this-object:groupBox2:Location = new System.Drawing.Point(337, 41).
      this-object:groupBox2:Name = "groupBox2".
      this-object:groupBox2:Size = new System.Drawing.Size(302, 40).
      this-object:groupBox2:TabIndex = 19.
      this-object:groupBox2:TabStop = false.
      this-object:groupBox2:Text = "Фирмы".
      this-object:groupBox2:UseCompatibleTextRendering = true.
      this-object:rbFirmCurr:Location = new System.Drawing.Point(88, 13).
      this-object:rbFirmCurr:Name = "rbFirmCurr".
      this-object:rbFirmCurr:Size = new System.Drawing.Size(77, 24).
      this-object:rbFirmCurr:TabIndex = 1.
      this-object:rbFirmCurr:Text = "Текущая".
      this-object:rbFirmCurr:UseCompatibleTextRendering = true.
      this-object:rbFirmCurr:UseVisualStyleBackColor = true.
      this-object:rbFirmCurr:CheckedChanged:Subscribe(this-object:firm_CheckedChanged).
      this-object:rbFirmAll:Checked = true.
      this-object:rbFirmAll:Location = new System.Drawing.Point(25, 13).
      this-object:rbFirmAll:Name = "rbFirmAll".
      this-object:rbFirmAll:Size = new System.Drawing.Size(54, 24).
      this-object:rbFirmAll:TabIndex = 0.
      this-object:rbFirmAll:TabStop = true.
      this-object:rbFirmAll:Text = "Все".
      this-object:rbFirmAll:UseCompatibleTextRendering = true.
      this-object:rbFirmAll:UseVisualStyleBackColor = true.
      this-object:rbFirmAll:CheckedChanged:Subscribe(this-object:firm_CheckedChanged).
      this-object:bDelObj:Location = new System.Drawing.Point(255, 303).
      this-object:bDelObj:Name = "bDelObj".
      this-object:bDelObj:Size = new System.Drawing.Size(75, 23).
      this-object:bDelObj:TabIndex = 23.
      this-object:bDelObj:Text = "Удалить".
      this-object:bDelObj:UseCompatibleTextRendering = true.
      this-object:bDelObj:UseVisualStyleBackColor = true.
      this-object:bDelObj:Click:Subscribe(this-object:bDelObj_Click).
      this-object:bLookupObj:Location = new System.Drawing.Point(174, 303).
      this-object:bLookupObj:Name = "bLookupObj".
      this-object:bLookupObj:Size = new System.Drawing.Size(75, 23).
      this-object:bLookupObj:TabIndex = 22.
      this-object:bLookupObj:Text = "Просмотр".
      this-object:bLookupObj:UseCompatibleTextRendering = true.
      this-object:bLookupObj:UseVisualStyleBackColor = true.
      this-object:bLookupObj:Click:Subscribe(this-object:bLookupObj_Click).
      this-object:bChangeObj:Location = new System.Drawing.Point(93, 303).
      this-object:bChangeObj:Name = "bChangeObj".
      this-object:bChangeObj:Size = new System.Drawing.Size(75, 23).
      this-object:bChangeObj:TabIndex = 21.
      this-object:bChangeObj:Text = "Изменить".
      this-object:bChangeObj:UseCompatibleTextRendering = true.
      this-object:bChangeObj:UseVisualStyleBackColor = true.
      this-object:bChangeObj:Click:Subscribe(this-object:bChangeObj_Click).
      this-object:bAddObj:Location = new System.Drawing.Point(12, 303).
      this-object:bAddObj:Name = "bAddObj".
      this-object:bAddObj:Size = new System.Drawing.Size(75, 23).
      this-object:bAddObj:TabIndex = 20.
      this-object:bAddObj:Text = "Добавить".
      this-object:bAddObj:UseCompatibleTextRendering = true.
      this-object:bAddObj:UseVisualStyleBackColor = true.
      this-object:bAddObj:Click:Subscribe(this-object:bAddObj_Click).
      this-object:labelObj:Font = new System.Drawing.Font("Microsoft Sans Serif", Progress.Util.CastUtil:ToSingle(12), System.Drawing.FontStyle:Regular, System.Drawing.GraphicsUnit:Point, System.Convert:ToByte(204)).
      this-object:labelObj:Location = new System.Drawing.Point(416, 306).
      this-object:labelObj:Name = "labelObj".
      this-object:labelObj:Size = new System.Drawing.Size(207, 23).
      this-object:labelObj:TabIndex = 24.
      this-object:labelObj:Text = "Настройки для объектов".
      this-object:labelObj:UseCompatibleTextRendering = true.
      this-object:labelObj:Click:Subscribe(this-object:labelObj_Click).
      this-object:labelObj:DoubleClick:Subscribe(this-object:labelObj_DoubleClick).
      this-object:bhist:Location = new System.Drawing.Point(645, 13).
      this-object:bhist:Name = "bhist".
      this-object:bhist:Size = new System.Drawing.Size(75, 23).
      this-object:bhist:TabIndex = 25.
      this-object:bhist:Text = "История".
      this-object:bhist:UseCompatibleTextRendering = true.
      this-object:bhist:UseVisualStyleBackColor = true.
      this-object:bhist:Click:Subscribe(this-object:bhist_Click).
      this-object:bhistpko:Location = new System.Drawing.Point(734, 303).
      this-object:bhistpko:Name = "bhistpko".
      this-object:bhistpko:Size = new System.Drawing.Size(86, 23).
      this-object:bhistpko:TabIndex = 26.
      this-object:bhistpko:Text = "История ПКО".
      this-object:bhistpko:UseCompatibleTextRendering = true.
      this-object:bhistpko:UseVisualStyleBackColor = true.
      this-object:bhistpko:Click:Subscribe(this-object:bhistpko_Click).
      this-object:bistrko:Location = new System.Drawing.Point(826, 303).
      this-object:bistrko:Name = "bistrko".
      this-object:bistrko:Size = new System.Drawing.Size(85, 23).
      this-object:bistrko:TabIndex = 27.
      this-object:bistrko:Text = "История РКО".
      this-object:bistrko:UseCompatibleTextRendering = true.
      this-object:bistrko:UseVisualStyleBackColor = true.
      this-object:bistrko:Click:Subscribe(this-object:bistrko_Click).
      this-object:markDataGridViewTextBoxColumn:DataPropertyName = "mark".
      this-object:markDataGridViewTextBoxColumn:FillWeight = Progress.Util.CastUtil:ToSingle(19.6377163).
      this-object:markDataGridViewTextBoxColumn:HeaderText = "*".
      this-object:markDataGridViewTextBoxColumn:Name = "markDataGridViewTextBoxColumn".
      this-object:markDataGridViewTextBoxColumn:ReadOnly = true.
      this-object:markDataGridViewTextBoxColumn:Width = 36.
      this-object:extcodeDataGridViewTextBoxColumn:AutoSizeMode = System.Windows.Forms.DataGridViewAutoSizeColumnMode:DisplayedCellsExceptHeader.
      this-object:extcodeDataGridViewTextBoxColumn:DataPropertyName = "ext-code".
      this-object:extcodeDataGridViewTextBoxColumn:HeaderText = "ext-code".
      this-object:extcodeDataGridViewTextBoxColumn:Name = "extcodeDataGridViewTextBoxColumn".
      this-object:extcodeDataGridViewTextBoxColumn:ReadOnly = true.
      this-object:extcodeDataGridViewTextBoxColumn:Visible = false.
      this-object:extcodeDataGridViewTextBoxColumn:Width = 21.
      this-object:id:AutoSizeMode = System.Windows.Forms.DataGridViewAutoSizeColumnMode:DisplayedCells.
      this-object:id:DataPropertyName = "id".
      this-object:id:FillWeight = Progress.Util.CastUtil:ToSingle(58.2789688).
      this-object:id:HeaderText = "Код/номер".
      this-object:id:Name = "id".
      this-object:id:ReadOnly = true.
      this-object:id:Width = 88.
      this-object:cashBookNameDataGridViewTextBoxColumn:AutoSizeMode = System.Windows.Forms.DataGridViewAutoSizeColumnMode:Fill.
      this-object:cashBookNameDataGridViewTextBoxColumn:DataPropertyName = "CashBookName".
      this-object:cashBookNameDataGridViewTextBoxColumn:FillWeight = Progress.Util.CastUtil:ToSingle(86.5020294).
      this-object:cashBookNameDataGridViewTextBoxColumn:HeaderText = "Наименование".
      this-object:cashBookNameDataGridViewTextBoxColumn:Name = "cashBookNameDataGridViewTextBoxColumn".
      this-object:cashBookNameDataGridViewTextBoxColumn:ReadOnly = true.
      this-object:rulePrilDataGridViewTextBoxColumn:AutoSizeMode = System.Windows.Forms.DataGridViewAutoSizeColumnMode:Fill.
      this-object:rulePrilDataGridViewTextBoxColumn:DataPropertyName = "RulePril".
      this-object:rulePrilDataGridViewTextBoxColumn:FillWeight = Progress.Util.CastUtil:ToSingle(109.7253876).
      this-object:rulePrilDataGridViewTextBoxColumn:HeaderText = "Правила заполнения графы ~"Приложение~"".
      this-object:rulePrilDataGridViewTextBoxColumn:Name = "rulePrilDataGridViewTextBoxColumn".
      this-object:rulePrilDataGridViewTextBoxColumn:ReadOnly = true.
      this-object:flagSepCashDataGridViewCheckBoxColumn:DataPropertyName = "FlagSepCash".
      this-object:flagSepCashDataGridViewCheckBoxColumn:FillWeight = Progress.Util.CastUtil:ToSingle(70.3734589).
      this-object:flagSepCashDataGridViewCheckBoxColumn:HeaderText = "Отдельно для каждой кассы".
      this-object:flagSepCashDataGridViewCheckBoxColumn:Name = "flagSepCashDataGridViewCheckBoxColumn".
      this-object:flagSepCashDataGridViewCheckBoxColumn:ReadOnly = true.
      this-object:flagSepCashDataGridViewCheckBoxColumn:Width = 114.
      this-object:flagSepFullDataGridViewCheckBoxColumn:DataPropertyName = "FlagSepFull".
      this-object:flagSepFullDataGridViewCheckBoxColumn:FillWeight = Progress.Util.CastUtil:ToSingle(78.2929916).
      this-object:flagSepFullDataGridViewCheckBoxColumn:HeaderText = "Раздельно НП и ТНП".
      this-object:flagSepFullDataGridViewCheckBoxColumn:Name = "flagSepFullDataGridViewCheckBoxColumn".
      this-object:flagSepFullDataGridViewCheckBoxColumn:ReadOnly = true.
      this-object:flagSepFullDataGridViewCheckBoxColumn:Width = 78.
      this-object:statDataGridViewTextBoxColumn:DataPropertyName = "stat".
      this-object:statDataGridViewTextBoxColumn:FillWeight = Progress.Util.CastUtil:ToSingle(0.2856203).
      this-object:statDataGridViewTextBoxColumn:HeaderText = "Статус".
      this-object:statDataGridViewTextBoxColumn:Name = "statDataGridViewTextBoxColumn".
      this-object:statDataGridViewTextBoxColumn:ReadOnly = true.
      this-object:statDataGridViewTextBoxColumn:Width = 66.
      this-object:RuleOsnPko:AutoSizeMode = System.Windows.Forms.DataGridViewAutoSizeColumnMode:Fill.
      this-object:RuleOsnPko:DataPropertyName = "RuleOsnPko".
      this-object:RuleOsnPko:HeaderText = "Основание для ПКО".
      this-object:RuleOsnPko:Name = "RuleOsnPko".
      this-object:RuleOsnPko:ReadOnly = true.
      this-object:OcnAcct:DataPropertyName = "osnAcct".
      this-object:OcnAcct:HeaderText = "Основной счет".
      this-object:OcnAcct:Name = "OcnAcct".
      this-object:OcnAcct:ReadOnly = true.
      this-object:OcnAcct:Width = 98.
      this-object:AcceptButton = this-object:buttonOk.
      this-object:ClientSize = new System.Drawing.Size(1079, 637).
      this-object:Controls:Add(this-object:bistrko).
      this-object:Controls:Add(this-object:bhistpko).
      this-object:Controls:Add(this-object:bhist).
      this-object:Controls:Add(this-object:labelObj).
      this-object:Controls:Add(this-object:bDelObj).
      this-object:Controls:Add(this-object:bLookupObj).
      this-object:Controls:Add(this-object:bChangeObj).
      this-object:Controls:Add(this-object:bAddObj).
      this-object:Controls:Add(this-object:groupBox2).
      this-object:Controls:Add(this-object:groupBox1).
      this-object:Controls:Add(this-object:bDel).
      this-object:Controls:Add(this-object:bLookup).
      this-object:Controls:Add(this-object:bChange).
      this-object:Controls:Add(this-object:bSelect).
      this-object:Controls:Add(this-object:bMark).
      this-object:Controls:Add(this-object:bAdd).
      this-object:Controls:Add(this-object:cashbookRuleBrowse).
      this-object:Controls:Add(this-object:bGoods).
      this-object:Controls:Add(this-object:cashbookBrowse).
      this-object:Controls:Add(this-object:buttonOk).
      this-object:FormBorderStyle = System.Windows.Forms.FormBorderStyle:FixedDialog.
      this-object:MaximizeBox = false.
      this-object:MinimizeBox = false.
      this-object:Name = "cashbookbrw".
      this-object:ShowInTaskbar = false.
      this-object:StartPosition = System.Windows.Forms.FormStartPosition:CenterParent.
      this-object:Text = "Типы кассовых книг".
      cast(this-object:cashbookBrowse, System.ComponentModel.ISupportInitialize):EndInit().
      cast(this-object:bindingSource1, System.ComponentModel.ISupportInitialize):EndInit().
      cast(this-object:cashbookRuleBrowse, System.ComponentModel.ISupportInitialize):EndInit().
      cast(this-object:bindingSource2, System.ComponentModel.ISupportInitialize):EndInit().
      this-object:groupBox1:ResumeLayout(false).
      this-object:groupBox2:ResumeLayout(false).
      this-object:ResumeLayout(false).
      catch e as Progress.Lang.Error:
         undo, throw e.
      end catch.
   end method.
        @VisualDesigner.
        method private void firm_CheckedChanged( input sender as System.Object, input e as System.EventArgs ):
          define variable ref-rec as recid no-undo .
    define variable ref-list as character no-undo.
                if this-object:rbFirmAll:Checked = true
                then do :
                  v-firmes = 'все':U .
                  v-firmChoosed = no .
                end.
    if this-object:rbFirmCurr:Checked = true
    then do :
      v-firmes = string(v-cntxt-host-code-obj) .
      v-firmChoosed = no .
    end.
    if this-object:rbFirmSelect:Checked = true
    then do :
      if v-firmChoosed then return .
      run ref/cli-all.w ( input parParentProc
                     ,input "b-add,b-sel"
                     ,input 'орг':U
                     ,input ?
                     ,input ?
                     ,input ?
                     ,input ?
                     ,input ?
                     ,output ref-list) .
      if ref-list = "" then do:
        this-object:rbFirmCurr:Checked = true .
        v-firmes = string(v-cntxt-host-code-obj) .
        return .
      end.
      ref-rec = integer( ref-list ).
      FIND ub.clients WHERE recid (ub.clients) = ref-rec NO-LOCK .
      v-firmes = string(ub.clients.obj-code) .
      v-firmChoosed = yes .
    end .
    bindingSource1:Handle = mCashBook:getquery(input v-status, input v-firmes, output mQuery, output mQueryRule).
    bindingSource2:handle = mQueryRule .
                return.
        end method.
        @VisualDesigner.
        method private void status_CheckedChanged( input sender as System.Object, input e as System.EventArgs ):
                if this-object:rbStatAll:Checked = true then v-status = 'все':U .
    if this-object:rbStatCurr:Checked = true then v-status = 'тек':U .
    if this-object:rbStatDel:Checked = true then v-status = 'удал':U .
    bindingSource1:Handle = mCashBook:getquery(input v-status, input v-firmes, output mQuery, output mQueryRule).
    bindingSource2:handle = mQueryRule .
                return.
        end method.
   method public void ShowModalDialog(  ):
      wait-for this-object:ShowDialog().
   end method.
   method public void getobj(input iText as character,output oType as character , output oCode as integer    ):
      if iText begins 'всем':U
      then
         assign
         oCode = 0
         oType = 'всем':U .
      else
      assign
         oCode = integer(substring(iText, 4))
         oType = substring(iText, 1, 3) .
   end method.
end class.
