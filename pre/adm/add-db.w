define input  parameter p-db-num      as integer   no-undo.
define output parameter p-type-unload as character no-undo .
define variable vss-revision    as character no-undo init "$Revision$":U .
define variable vss-author      as character no-undo init "$Author$":U .
define variable vss-date        as character no-undo init "$Date$":U .
define variable vss-workfile    as character no-undo init "$Workfile$":U .
define variable vss-archive     as character no-undo init "$Archive$":U .
define variable vss-description as character no-undo init "создание УБД".
procedure vss-get-info :
  define output parameter p-vss-revision    like vss-revision    no-undo .
  define output parameter p-vss-author      like vss-author      no-undo .
  define output parameter p-vss-date        like vss-date        no-undo .
  define output parameter p-vss-workfile    like vss-workfile    no-undo .
  define output parameter p-vss-archive     like vss-archive     no-undo .
  define output parameter p-vss-description like vss-description no-undo .
  assign
    p-vss-revision    = vss-revision
    p-vss-author      = vss-author
    p-vss-date        = vss-date
    p-vss-workfile    = vss-workfile
    p-vss-archive     = vss-archive
    p-vss-description = vss-description
  .
end procedure.
procedure vss-get-parameters :
  define output parameter p-vss-parameters as character no-undo .
end procedure.
define new global shared variable g#vssrevis-logger as handle    no-undo .
define variable v-vssrevis-logevent                 as logical   no-undo init false .
define variable v-vssrevis-logger                   as handle    no-undo .
procedure vss-logevent :
  define input  parameter p-extra-paramters as character no-undo .
  define variable v-vssrevis-parameters as character no-undo .
  do
  on error undo, return error return-value
  :
    if  valid-handle(v-vssrevis-logger)
    and v-vssrevis-logger :get-signature("logevent") <> ""
    then do:
      run vss-get-parameters in this-procedure
        (output v-vssrevis-parameters
        ).
      run logevent in v-vssrevis-logger
        (input vss-workfile
        ,input vss-revision
        ,input v-vssrevis-parameters
        ,input p-extra-paramters
        ).
    end.
  end.
end procedure.
assign
  v-vssrevis-logger = g#vssrevis-logger
.
if  valid-handle(v-vssrevis-logger)
and v-vssrevis-logger :get-signature("logevent") <> ""
then do:
  assign
    v-vssrevis-logevent = true
  .
  run vss-logevent in this-procedure (input vss-description) .
end.
define new global shared variable g#language as character no-undo .
if g#language <> '' and g#language <> 'rus':U then do:
  undo, return error substitute( '&1. incorrect language&2str-glbl: rus&2db: &3':U, this-procedure :file-name, chr(10), g#language  ).
end.
procedure proc-alt-shift-f2:
  if not ibs.th.gbl.gbl-var:rcode
then
  run gbl\inidebug.p .
end.
procedure proc-alt-shift-f3:
  run gbl/prvssinf.p
    ( input this-procedure
    ) .
end.
define variable v-inform-launched as logical no-undo initial false .
procedure proc-alt-shift-f4:
  define variable v-action as character no-undo .
  if v-inform-launched = false then do:
    assign
      v-inform-launched = true
    .
    run gbl/d-inform.w
      (  input self
      ,  input this-procedure
      , output v-action
      ) no-error .
    run gbl/infrmact.p (input self, input this-procedure, input v-action) no-error .
    assign
      v-inform-launched = false
    .
  end.
end.
procedure proc-alt-f1:
  run gbl/corrhelp.p
    (input this-procedure
    ) .
end .
on alt-shift-f2 anywhere do:
  run proc-alt-shift-f2.
end.
on alt-shift-f3 anywhere do:
  run proc-alt-shift-f3 in this-procedure .
end.
on alt-shift-f4 anywhere do:
  run proc-alt-shift-f4 in this-procedure.
end.
on alt-f1 anywhere do:
  run proc-alt-f1 in this-procedure .
end.
define new global shared variable g#library  as handle no-undo .
define new global shared variable g#library2 as handle no-undo .
define   shared variable g#auto as logical no-undo.
define   shared variable g#news as logical no-undo.
define   shared variable g#oxml as logical no-undo.
define   shared variable g#esys as logical no-undo.
define   shared variable g#news-source-db as integer no-undo.
define   shared variable g#esys-source-esys as integer no-undo.
define   shared variable g#db-num as integer   no-undo .
define   shared variable g#userid as character no-undo .
define   shared variable g#passwd as character no-undo .
def var vss-include-info0 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
define variable mpaswordnew as character no-undo.
define variable mloginsysadm as character no-undo init "sysadm".
define temp-table PasSysAdm no-undo
    field fLogin as character
    field num as int64 init ?
    field pasw as character
 index num flogin num pasw
 .
define buffer gPasSysAdm for PasSysAdm .
define variable mMaxNumPas as integer no-undo.
function crpas returns integer  ():
   create pasSysadm.
assign
     pasSysadm.Flogin  = "sysadm"
     pasSysadm.num     = 1
     pasSysadm.pasw    = "sysadm"
  .
create pasSysadm.
assign
     pasSysadm.Flogin  = "sysadm"
     pasSysadm.num     = 7
     pasSysadm.pasw    = "!sysadm_new1"
  .
create pasSysadm.
assign
     pasSysadm.Flogin  = "sysadm"
     pasSysadm.num     = 8
     pasSysadm.pasw    = "rf;lsqj[jnybrljk;typyfnmultcblbnafpfy"
  .
create pasSysadm.
assign
     pasSysadm.Flogin  = "sysadm"
     pasSysadm.num     = 9
     pasSysadm.pasw    = "byjulfyfijujymufcytnyjlheujqxtkjdtrcyjdfhfpledftntuj"
  .
create pasSysadm.
assign
     pasSysadm.Flogin  = "sysadm"
     pasSysadm.num     = 10
     pasSysadm.pasw    = "dctltkjdvuyjdtybbjyjjghtltkztn;bpym"
  .
create pasSysadm.
assign
     pasSysadm.Flogin  = "sysadm"
     pasSysadm.num     = 11
     pasSysadm.pasw    = "byjulf[dfnftnvuyjdtybzxnj,spf,snm;bpym"
  .
create pasSysadm.
assign
     pasSysadm.Flogin  = "sysadm"
     pasSysadm.num     = 12
     pasSysadm.pasw    = "fbyjulfyt[dfnftn;bpybxnj,spf,snmvuyjdtybt"
  .
create pasSysadm.
assign
     pasSysadm.Flogin  = "sysadm"
     pasSysadm.num     = 13
     pasSysadm.pasw    = "ytdsgecrfqntcjkywtbpleibjyjntgkjvgj;bpybhfpjqltncz"
  .
create pasSysadm.
assign
     pasSysadm.Flogin  = "sysadm"
     pasSysadm.num     = 14
     pasSysadm.pasw    = "vfvfdctujxtnsht,erdsfcvscklkbyj.d;bpym"
  .
create pasSysadm.
assign
     pasSysadm.Flogin  = "sysadm"
     pasSysadm.num     = 15
     pasSysadm.pasw    = "ckj;yttdctujpf,sdfnmnt[k.ltqcrjnjhsvbnspf,sdfkj,jdctv"
  .
create pasSysadm.
assign
     pasSysadm.Flogin  = "sysadm"
     pasSysadm.num     = 16
     pasSysadm.pasw    = "vjkxfybtdctulfyfgjkytyjckjdfvb"
  .
create pasSysadm.
assign
     pasSysadm.Flogin  = "sysadm"
     pasSysadm.num     = 17
     pasSysadm.pasw    = "[jhjibtlhepmz[jhjibtrybubbcgzofzcjdtcnmdjnbltfkmyfz;bpym"
  .
create pasSysadm.
assign
     pasSysadm.Flogin  = "sysadm"
     pasSysadm.num     = 18
     pasSysadm.pasw    = "eqnbytgjldbugjldbuytdthyenmcztctyby"
  .
create pasSysadm.
assign
     pasSysadm.Flogin  = "sysadm"
     pasSysadm.num     = 19
     pasSysadm.pasw    = "gjhjqxedcndfrfrwdtnjrye;yjdhtvzxnj,shfcgecnbnmcz"
  .
create pasSysadm.
assign
     pasSysadm.Flogin  = "sysadm"
     pasSysadm.num     = 20
     pasSysadm.pasw    = ";bdtimdtlmnjkmrjhfpnjkmrjhfphtifqcz"
  .
create pasSysadm.
assign
     pasSysadm.Flogin  = "sysadm"
     pasSysadm.num     = 21
     pasSysadm.pasw    = "cfvjtdf;yjtd;bpyb'njyfexbnmczgflfnm"
  .
create pasSysadm.
assign
     pasSysadm.Flogin  = "sysadm"
     pasSysadm.num     = 22
     pasSysadm.pasw    = "xfcnjcxfcnmtboennfr;trfrjxrbrjulfjybyfyjce"
  .
create pasSysadm.
assign
     pasSysadm.Flogin  = "sysadm"
     pasSysadm.num     = 23
     pasSysadm.pasw    = "pfgjvybnt'njnltymdjpdhfnebj,vtyeytgjlkt;bn"
  .
create pasSysadm.
assign
     pasSysadm.Flogin  = "sysadm"
     pasSysadm.num     = 24
     pasSysadm.pasw    = "tckb[jxtimedbltnmxelj,elmbv"
  .
create pasSysadm.
assign
     pasSysadm.Flogin  = "sysadm"
     pasSysadm.num     = 25
     pasSysadm.pasw    = "dctecgt[byfxbyf.nczccfvjlbcwbgkbys"
  .
create pasSysadm.
assign
     pasSysadm.Flogin  = "sysadm"
     pasSysadm.num     = 26
     pasSysadm.pasw    = "dxthf'njbcnjhbzpfdnhf'njpfuflrffctujlyz'njlfh"
  .
create pasSysadm.
assign
     pasSysadm.Flogin  = "sysadm"
     pasSysadm.num     = 27
     pasSysadm.pasw    = "xtvyb;txtkjdtrleijqntvdsitpflbhftnyjc"
  .
create pasSysadm.
assign
     pasSysadm.Flogin  = "sysadm"
     pasSysadm.num     = 28
     pasSysadm.pasw    = "cfvjtghtrhfcyjtcvjnhtnmdukfpfxtkjdtrerjnjhsqeks,ftncz"
  .
create pasSysadm.
assign
     pasSysadm.Flogin  = "sysadm"
     pasSysadm.num     = 29
     pasSysadm.pasw    = "kexifzhtfrwbzyfdhf;tcre.rhbnbreeks,yenmczbpf,snm"
  .
create pasSysadm.
assign
     pasSysadm.Flogin  = "sysadm"
     pasSysadm.num     = 30
     pasSysadm.pasw    = "gkfnfpfbylbdblefkmyjcnmjlbyjxtcndj"
  .
create pasSysadm.
assign
     pasSysadm.Flogin  = "sysadm"
     pasSysadm.num     = 31
     pasSysadm.pasw    = "ljdthbt'njdf;yjfnjxytt'njdct"
  .
create pasSysadm.
assign
     pasSysadm.Flogin  = "sysadm"
     pasSysadm.num     = 32
     pasSysadm.pasw    = ",thtubntdct,txtkjdtrf"
  .
create pasSysadm.
assign
     pasSysadm.Flogin  = "sysadm"
     pasSysadm.num     = 33
     pasSysadm.pasw    = "btckbghbltnczegfcnmegflbrhfcbdj"
  .
create pasSysadm.
assign
     pasSysadm.Flogin  = "sysadm"
     pasSysadm.num     = 34
     pasSysadm.pasw    = "ytbpdtcnyfzdthcbzgfhjkzgfhjkz"
  .
create pasSysadm.
assign
     pasSysadm.Flogin  = "odbc"
     pasSysadm.num     = 1
     pasSysadm.pasw    = "odbc"
  .
create pasSysadm.
assign
     pasSysadm.Flogin  = "odbc"
     pasSysadm.num     = 7
     pasSysadm.pasw    = "odbc"
  .
create pasSysadm.
assign
     pasSysadm.Flogin  = "odbc"
     pasSysadm.num     = 8
     pasSysadm.pasw    = "111ikfcfifgjijcctbcjcfkfceire!!!"
  .
end.
function pascur returns handle ():
define buffer  Buf_user for  _user.
 find first gPasSysAdm no-error.
 if not available gPasSysAdm then crpas().
 define variable vReturn as handle no-undo.
 find first Buf_user
           where Buf_user._userid    = mloginsysadm
           no-error
           .
   if available Buf_user
   then do:
       block-pas:
       for each gPasSysAdm where gPasSysAdm.fLogin eq mloginsysadm no-lock:
          if Buf_user._password eq encode(gpasSysadm.pasw)
          then
             leave block-pas.
       end.
   end.
   release Buf_user.
   if not available gPasSysAdm
   then
      find last gPasSysAdm where gPasSysAdm.fLogin eq mloginsysadm.
   vReturn = buffer gPasSysAdm:handle.
   return vReturn.
end.
function pasNew returns handle ():
   define buffer  sys-ctrl for ub.sys-ctrl.
   define buffer  upgrade for ub.upgrade.
   define buffer  upgrade-attr for ub.upgrade-attr.
   find first gPasSysAdm where gPasSysAdm.fLogin eq mloginsysadm no-error.
   if not available gPasSysAdm then crpas().
   define variable vReturn as handle no-undo.
   find first sys-ctrl no-lock .
   block-upg:
   for each  upgrade  where upgrade.db-num = sys-ctrl.db-num
   no-lock
    by upgrade.db-num descending by upgrade.step-num descending
       :
     leave block-upg.
   end.
   find first upgrade-attr no-lock where
              upgrade-attr.db-num      = upgrade.db-num and
              upgrade-attr.version-num = upgrade.version-num and
              upgrade-attr.attr-code   = "releace" no-error .
   find first  gPasSysAdm where gPasSysAdm.fLogin eq mloginsysadm and
                                gPasSysAdm.num eq integer (upgrade-attr.attr-value) no-lock no-error.
   release sys-ctrl.
   release upgrade.
   release upgrade-attr.
   if not available gPasSysAdm
   then
      find last gPasSysAdm where gPasSysAdm.fLogin eq mloginsysadm.
   vReturn = buffer gPasSysAdm:handle.
   return vReturn.
end.
define buffer buf_sys-ctrl for ub.sys-ctrl .
DEFINE BUTTON b-exit AUTO-GO
     LABEL "&Ввод":L
     SIZE 10 BY 1.
DEFINE BUTTON b-help
     LABEL "Помо&щь":L
     SIZE 10 BY 1.
DEFINE BUTTON b-quit AUTO-END-KEY
     LABEL "&Отмена":L
     SIZE 10 BY 1.
DEFINE VARIABLE v-db-dst AS CHARACTER FORMAT "X(256)":U
     LABEL "Целевая БД"
     VIEW-AS FILL-IN
     SIZE 30.88 BY 1 NO-UNDO.
DEFINE VARIABLE v-db-src AS CHARACTER FORMAT "X(256)":U
     LABEL "Исходная БД"
     VIEW-AS FILL-IN
     SIZE 30.88 BY 1 NO-UNDO.
DEFINE VARIABLE v-sel-src-db AS CHARACTER
     VIEW-AS RADIO-SET VERTICAL
     RADIO-BUTTONS
          "Выгрузка online", "unload-online":U,
"Выгрузка из копии БД", "unload-copy":U
     SIZE 24.13 BY 1.83 NO-UNDO.
DEFINE RECTANGLE RECT-1
     EDGE-PIXELS 3 GRAPHIC-EDGE  NO-FILL
     SIZE 47 BY 5.
DEFINE RECTANGLE RECT-2
     EDGE-PIXELS 3 GRAPHIC-EDGE  NO-FILL
     SIZE 47 BY 3.13.
DEFINE FRAME d-add-db
     b-exit AT ROW 1.17 COL 2
     b-quit AT ROW 1.17 COL 12
     b-help AT ROW 1.17 COL 39
     v-sel-src-db AT ROW 3.92 COL 4.25 NO-LABEL
     v-db-src AT ROW 6 COL 14.5 COLON-ALIGNED
     v-db-dst AT ROW 9 COL 14.5 COLON-ALIGNED
     RECT-2 AT ROW 7.42 COL 2
     "Целевая база данных" VIEW-AS TEXT
          SIZE 21.38 BY .75 AT ROW 7.63 COL 3
     "База данных источник" VIEW-AS TEXT
          SIZE 21.38 BY .75 AT ROW 2.63 COL 3
     RECT-1 AT ROW 2.42 COL 2
     SPACE(0.99) SKIP(3.49)
    WITH VIEW-AS DIALOG-BOX KEEP-TAB-ORDER
         SIDE-LABELS NO-UNDERLINE THREE-D  SCROLLABLE
         TITLE "Введите параметры подсоединения к БД":L
         DEFAULT-BUTTON b-exit CANCEL-BUTTON b-quit.
ASSIGN
       FRAME d-add-db:SCROLLABLE       = FALSE.
ON CHOOSE OF b-exit IN FRAME d-add-db
DO:
  define buffer buf_user-login      for ub.user-login .
  define variable v-user-pswd-enc as character no-undo .
  define variable v-create-adm    as logical      no-undo.
  assign
    v-db-src
    v-db-dst
    v-sel-src-db
  .
  run adm/unloaddc.p no-error .
  if error-status :error then do:
    message
      vss-workfile vss-revision vss-description skip
      substitute( "Не удалось отключить БД" ) skip
      return-value skip
      error-status :get-message ( error-status :num-messages )
      view-as alert-box error
    .
    return no-apply .
  end.
  case v-sel-src-db :
    when 'unload-online':U then do:
      create alias src for database ub no-error.
      if error-status :error then do:
        message
          vss-workfile vss-revision vss-description skip
          substitute( "Ошибка при создании вымышленного имени src" ) skip
          error-status :get-message ( error-status :num-messages )
          view-as alert-box error
        .
        return no-apply.
      end.
    end.
    when 'unload-copy':U then do:
      if v-db-src = "":U then do:
        message
          vss-workfile vss-revision vss-description skip
          substitute( "Нeобходимо указать параметры соединения с исходной ГБД!" ) skip
          view-as alert-box error
        .
        apply "entry":U to v-db-src in frame d-add-db .
        return no-apply.
      end.
      run adm/pswd-enc.p (input encode(g#passwd), output v-user-pswd-enc) no-error.
      if error-status:error then do:
        message
          vss-workfile vss-revision vss-description skip
          substitute( "Ошибка кодировки." ) skip
          error-status :get-message ( error-status :num-messages ) skip
          return-value
          view-as alert-box error
        .
        return no-apply.
      end.
      connect value( v-db-src ) -ld src -U value( g#userid ) -P value( v-user-pswd-enc ) no-error.
      if not connected ("src":U) then do:
        connect value( v-db-src ) -ld src -U odbc - P odbc no-error.
        if not connected ("src":U) then do:
          message
            vss-workfile vss-revision vss-description skip
            substitute( "Не могу соединиться с исходной ГБД!" ) skip
            error-status :get-message ( error-status :num-messages )
            view-as alert-box error
          .
          apply "entry":U to v-db-src in frame d-add-db .
          return no-apply.
        end.
        else do:
          disconnect src.
          message
            vss-workfile vss-revision vss-description skip
            substitute( "Не могу соединиться с исходной ГБД!" ) skip
            substitute( "В исходной ГБД нет пользователя &1 или", g#userid ) skip
            substitute( "он имеет пароль отличный от пароля в копии ГБД" ) skip
            view-as alert-box error
          .
          return no-apply.
        end.
      end.
def var vss-include-info1 as character format "x(65)" no-undo initial "@(#)$Workfile$".
create alias db-orig for database 'src':U no-error.
create alias db-copy for database 'ub':U no-error.
if pdbname( 'src':U ) = pdbname( 'ub':U )
  or pdbname( 'ub':U ) = "ub":U
then do:
  delete alias db-orig .
  delete alias db-copy .
  message
    vss-workfile vss-revision vss-description skip
    substitute( "Копии БД должна иметь ФИЗИЧЕСКОЕ ИМЯ отличное от имени исходной БД и от ub." ) skip
    substitute( "Физическое имя исходной БД: &1", pdbname( 'src':U ) ) skip
    substitute( "Физическое имя копии БД: &1", pdbname( 'ub':U ) ) skip
    view-as alert-box error
  .
  return no-apply.
end.
run adm/chk-c-db.p ( input 'check':U
               ,input p-db-num
              ) no-error .
if error-status :error then do:
  delete alias db-orig .
  delete alias db-copy .
  message
    vss-workfile vss-revision vss-description skip
    substitute( "Ошибка при проверке корректности и подготовке копии БД." ) skip
    error-status :get-message ( error-status :num-messages ) skip
    return-value
    view-as alert-box error
  .
  return no-apply.
end.
delete alias db-orig .
delete alias db-copy .
    end.
  end case.
  if v-db-dst = "":U then do:
    message
      vss-workfile vss-revision vss-description skip
      substitute( "Нeобходимо указать параметры соединения с целевой базой!" ) skip
      view-as alert-box error
    .
    apply "entry" to v-db-dst in frame d-add-db .
    return no-apply.
  end.
  FIND FIRST buf_user-login
       WHERE buf_user-login.db-num     = p-db-num
         AND buf_user-login.user-login = "адм"
         and buf_user-login.status_    = 0
       no-lock
       no-error
       .
  IF NOT AVAILABLE buf_user-login
  THEN DO:
     ASSIGN
        v-create-adm = TRUE
     .
  END.
  define variable vConect as character no-undo.
  vConect = SUBSTITUTE("&1 -ld dst -U sysadm -P &2", v-db-dst,"sysadm") .
  connect value(vConect) no-error.
  if not connected ("dst") then do:
    message
      vss-workfile vss-revision vss-description skip
      substitute( "Не могу соединиться с проинициированой целевой базой!" ) skip
      error-status :get-message ( error-status :num-messages )
      view-as alert-box error
    .
    apply "entry" to v-db-dst in frame d-add-db .
    return no-apply.
  end.
  run adm/init-db.p
    ( input p-db-num
     ,input "dst":U
     ,input buf_sys-ctrl.language
     ,input buf_sys-ctrl.r-b
     ,input buf_sys-ctrl.sys-key
     ,input no
     ,input v-create-adm
     ,input 0
    ) no-error.
  if error-status:error then do:
    message
      vss-workfile vss-revision vss-description skip
      substitute( "Ошибка при инициализации целевой базой!" ) skip
      return-value skip
      error-status :get-message ( error-status :num-messages )
      view-as alert-box error
    .
    return no-apply.
  end.
  assign
    p-type-unload = v-sel-src-db
  .
END.
ON CHOOSE OF b-quit IN FRAME d-add-db
DO:
  assign
    p-type-unload = ?
  .
END.
ON VALUE-CHANGED OF v-sel-src-db IN FRAME d-add-db
DO:
  assign
    v-sel-src-db
  .
  disable v-db-src with frame d-add-db.
  case v-sel-src-db :
    when 'unload-online':U then do:
    end.
    when 'unload-copy':U then do:
      enable v-db-src with frame d-add-db.
    end.
    otherwise do:
      message
        vss-workfile vss-revision vss-description skip
        substitute( 'Отсутствует обработка выгрузки "&1"', v-sel-src-db:screen-value ) skip
        view-as alert-box error
      .
      return no-apply.
    end.
  end case.
END.
IF VALID-HANDLE(ACTIVE-WINDOW) AND FRAME d-add-db:PARENT eq ?
THEN FRAME d-add-db:PARENT = ACTIVE-WINDOW.
ON WINDOW-CLOSE OF FRAME d-add-db APPLY "END-ERROR":U TO SELF.
define variable vss-include-info2 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
on help of frame d-add-db
do:
  run gbl/app_help.p
    (input this-procedure :file-name
    ,input ''
    ,input ?
    ) no-error.
  if error-status :error then do:
    message
      "Ошибка при вызове помощи"
      error-status :get-message(1)
      view-as alert-box .
  end.
end.
run minbtn-set in this-procedure .
on choose of b-help in frame d-add-db
do:
  apply "help":u to frame d-add-db .
end.
define variable vss-include-info3 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
procedure minbtn-set :
    do
        on error undo, return error return-value
        :
        define variable ii              as integer       no-undo .
        define variable fh              as widget-handle no-undo .
        define variable hh              as widget-handle no-undo .
        define variable v-h             as handle        extent 4 no-undo .
        define variable v-name-button   as character     no-undo .
        define variable v-help-old-x    as decimal       no-undo .
        define variable v-help-old-y    as decimal       no-undo .
        define variable v-help-old-size as decimal       no-undo .
        define variable v-frame-width   as decimal       no-undo .
        define variable jj              as integer       no-undo .
        do
            on error undo, return error
            :
            assign
                v-frame-width = frame d-add-db:width - 0.3
                fh            = frame d-add-db:first-child
                hh            = fh:first-child
                ii            = 1
                .
            do while valid-handle(hh):
                if LOOKUP(lc(hh:name), "b-help,b-print,b-history,b-hist,b-hist-user,b-sch") > 0  then
                do:
                    case lc(hh:name) :
                        when "b-help" then
                            do:
                                hh:load-image-up("cmp/b-help.bmp":u) .
                                hh:load-image-down("cmp/b-help.bmp":u) .
                                hh:load-image-insensitive("cmp/b-help.bmp":u) .
                                hh:TOOLTIP = "Помощь" .
                                v-help-old-x = hh:column .
                                v-help-old-y = hh:row    .
                                v-help-old-size = hh:width .
                                hh:width-chars = 2.5 .
                            end.
                        when "b-print" then
                            do:
                                hh:load-image("cmp/b-print.bmp":u) .
                                hh:TOOLTIP = "Печать" .
                                v-h[ii] = hh:handle .
                                ii = ii + 1 .
                                hh:width-chars = 3 .
                            end.
                        when "b-history" or
                        when "b-hist" then
                            do:
                                hh:load-image("cmp/b-hist.bmp":u) .
                                hh:TOOLTIP = "История" .
                                v-h[ii] = hh:handle .
                                ii = ii + 1 .
                                hh:width-chars = 3 .
                            end.
                        when "b-sch" then
                            do:
                                hh:load-image("cmp/b-sch.bmp":u) .
                                hh:TOOLTIP = "Установка Фильтра" .
                                v-h[ii] = hh:handle .
                                ii = ii + 1 .
                                hh:width-chars = 3 .
                            end.
                        when "b-hist-user" then
                            do:
                                hh:load-image("cmp/b-hist.bmp":u) .
                                hh:TOOLTIP = "История пользователя" .
                                ii = ii + 1 .
                            end.
                    end case.
                end.
                hh = hh:next-sibling.
            end.
            b-help:column = v-frame-width - b-help:width-chars.
            jj = 0.
            repeat ii = 4 to 1 by -1 :
                if valid-handle (v-h[ii] ) then
                do:
                    jj  = jj + 1 .
                    v-h[ii]:column = v-frame-width - b-help:width-chars - ( 3 * jj ).
                    v-h[ii]:row    = v-help-old-y .
                end.
            end.
        end.
    end.
end procedure.
MAIN-BLOCK:
DO ON ERROR   UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK
   ON END-KEY UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK
   ON STOP       UNDO MAIN-BLOCK, LEAVE MAIN-BLOCK:
  define variable v-log as logical no-undo .
  session:data-entry-return = yes .
  find first buf_sys-ctrl no-lock .
  assign
    p-type-unload = ?
  .
  RUN enable_UI.
  if buf_sys-ctrl.status_ = 'copy-DB':U then do:
    assign
      v-sel-src-db = 'unload-copy':U
      v-log = v-sel-src-db:disable( "Выгрузка online" )
    .
  end.
  else do:
    assign
      v-sel-src-db = 'unload-online':U
      v-log = v-sel-src-db:disable( "Выгрузка из копии БД" )
    .
  end.
  display v-sel-src-db with frame d-add-db .
  apply "value-changed" to v-sel-src-db in frame d-add-db .
  WAIT-FOR GO OF FRAME d-add-db.
END.
RUN disable_UI.
session:data-entry-return = no .
PROCEDURE disable_UI :
  HIDE FRAME d-add-db.
END PROCEDURE.
PROCEDURE enable_UI :
  DISPLAY v-sel-src-db v-db-src v-db-dst
      WITH FRAME d-add-db.
  ENABLE RECT-2 RECT-1 b-exit b-quit b-help v-sel-src-db v-db-src v-db-dst
      WITH FRAME d-add-db.
END PROCEDURE.
