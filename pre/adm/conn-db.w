define input  parameter p-title-par as character no-undo .
define input  parameter p-conn-par  as character no-undo .
define input  parameter p-user-name as character no-undo .
define input  parameter p-user-pswd as character no-undo .
define input  parameter p-ld-name   as character no-undo .
define output parameter p-new-conn  as character no-undo .
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
DEFINE BUTTON b-exit AUTO-GO
     LABEL "&Ввод":L
     SIZE 10 BY 1.
DEFINE BUTTON b-help
     LABEL "Помо&щь":L
     SIZE 3 BY 1.
DEFINE BUTTON b-quit AUTO-END-KEY
     LABEL "&Отмена":L
     SIZE 10 BY 1.
DEFINE VARIABLE v-conn-par AS CHARACTER FORMAT "X(256)":U
     VIEW-AS FILL-IN
     SIZE 86.5 BY 1 NO-UNDO.
DEFINE VARIABLE v-title-par AS CHARACTER FORMAT "X(256)":U INITIAL "Параметры подключения к БД"
      VIEW-AS TEXT
     SIZE 86.5 BY .67 NO-UNDO.
DEFINE FRAME d-get-conn-par
     b-exit AT ROW 1 COL 2
     b-quit AT ROW 1 COL 12
     b-help AT ROW 1 COL 87
     v-conn-par AT ROW 4 COL 3.5 NO-LABEL
     v-title-par AT ROW 2.75 COL 1.5 COLON-ALIGNED NO-LABEL WIDGET-ID 2
     SPACE(0.87) SKIP(2.11)
    WITH VIEW-AS DIALOG-BOX KEEP-TAB-ORDER
         SIDE-LABELS NO-UNDERLINE THREE-D  SCROLLABLE
         TITLE "Ввод параметров подключения к БД":L
         DEFAULT-BUTTON b-exit CANCEL-BUTTON b-quit.
ASSIGN
       FRAME d-get-conn-par:SCROLLABLE       = FALSE.
ASSIGN
       v-title-par:READ-ONLY IN FRAME d-get-conn-par        = TRUE.
ON CHOOSE OF b-exit IN FRAME d-get-conn-par
DO:
  define variable v-user-pswd-enc as character no-undo .
  define variable v-tmp-conn      as character no-undo .
  assign
    v-conn-par
  .
  if v-conn-par = "":U then do:
    message
      vss-workfile vss-revision vss-description skip
      substitute( "Нeобходимо указать параметры соединения с исходной ГБД!" ) skip
      view-as alert-box error
    .
    apply "entry":U to v-conn-par in frame d-get-conn-par .
    return no-apply.
  end.
  run proc-conn in this-procedure
    ( input v-conn-par
    , input p-user-name
    , input p-user-pswd
    , input p-ld-name
    ) no-error .
  if error-status :error then do:
    message
      vss-workfile vss-revision vss-description skip
      error-status :get-message(1) skip
      return-value skip
      view-as alert-box error .
    apply "entry":U to v-conn-par in frame d-get-conn-par .
    return no-apply .
  end.
  if connected( p-ld-name ) then do:
    assign
      p-new-conn = v-conn-par
    .
  end.
END.
ON CHOOSE OF b-quit IN FRAME d-get-conn-par
DO:
  assign
    p-new-conn = ?
  .
END.
IF VALID-HANDLE(ACTIVE-WINDOW) AND FRAME d-get-conn-par:PARENT eq ?
THEN FRAME d-get-conn-par:PARENT = ACTIVE-WINDOW.
ON WINDOW-CLOSE OF FRAME d-get-conn-par APPLY "END-ERROR":U TO SELF.
define variable vss-include-info0 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
on help of frame d-get-conn-par
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
on choose of b-help in frame d-get-conn-par
do:
  apply "help":u to frame d-get-conn-par .
end.
define variable vss-include-info1 as character format "x(65)" no-undo initial "@(#)$Workfile$ $Revision$".
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
                v-frame-width = frame d-get-conn-par:width - 0.3
                fh            = frame d-get-conn-par:first-child
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
  if p-ld-name = ?
    or trim( p-ld-name ) = "":U
    or trim( p-ld-name ) = "ub":U
  then do:
    message
      vss-workfile vss-revision vss-description skip
      substitute('Ошибка задания входных параметров.') skip
      substitute('Логическое имя БД должно быть не пустым и не "ub".') skip
      substitute('Логическое имя БД &1', p-ld-name ) skip
      view-as alert-box error .
  end.
  if p-user-name = "":U
    or p-user-name = ?
    or p-user-pswd = "":U
    or p-user-pswd = ?
  then do:
    assign
      p-user-name = "sysadm":U
      p-user-pswd = pasCur()::pasw
    .
  end.
  assign
    p-new-conn = ?
    v-conn-par = p-conn-par
  .
  if p-title-par <> ?
    or trim( p-title-par ) <> "":U
  then do:
    assign
      v-title-par = p-title-par
    .
  end.
  if connected( p-ld-name ) then do:
    return error substitute( "БД с логическим именем &1 уже подключена", p-ld-name ) .
  end.
  if trim( p-conn-par ) <> "":U
    and p-conn-par <> ?
  then do:
    run proc-conn in this-procedure
      ( input p-conn-par
      , input p-user-name
      , input p-user-pswd
      , input p-ld-name
      ) no-error .
    if not error-status :error then do:
      assign
        p-new-conn = p-conn-par
      .
      return .
    end.
  end.
  RUN enable_UI.
  WAIT-FOR GO OF FRAME d-get-conn-par.
END.
RUN disable_UI.
PROCEDURE disable_UI :
  HIDE FRAME d-get-conn-par.
END PROCEDURE.
PROCEDURE enable_UI :
  DISPLAY v-conn-par v-title-par
      WITH FRAME d-get-conn-par.
  ENABLE b-exit b-quit b-help v-conn-par
      WITH FRAME d-get-conn-par.
END PROCEDURE.
PROCEDURE proc-conn :
define input  parameter par-conn-par  as character no-undo .
  define input  parameter par-user-name as character no-undo .
  define input  parameter par-user-pswd as character no-undo .
  define input  parameter par-ld-name   as character no-undo .
  connect value( par-conn-par ) -ld value( par-ld-name ) -U value( par-user-name ) -P value( par-user-pswd ) no-error.
  if not connected( par-ld-name ) then do:
    connect value( par-conn-par ) -ld test-conn -U odbc -P odbc no-error.
    if connected( "test-conn":U ) then do:
      disconnect test-conn .
      return error substitute( "Не удалось подключиться к БД с пользователем &1", par-user-name ).
    end.
    else do:
      return error substitute( "Не удалось подключиться к БД с параметрами &2!&1&3", chr(10), par-conn-par, error-status :get-message ( 1 ) ).
    end.
  end.
END PROCEDURE.
