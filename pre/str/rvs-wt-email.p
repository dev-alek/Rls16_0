block-level on error undo, throw.
define input parameter p-rvs-code as character no-undo.
define variable vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo init "$Author: expertek $":U .
define variable vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: rvs-wt-email.p $":U .
define variable vss-archive     as character no-undo init "$Archive: str/rvs-wt-email.p $":U .
define variable vss-description as character no-undo init "Отправка емайла при воде в линии сверки".
define variable v-param-type as character no-undo .
define variable v-value-date as date no-undo .
define variable v-value-decimal as decimal no-undo .
define variable v-value-integer as INTEGER no-undo .
define variable v-value-logical AS LOGICAL no-undo .
define variable v-tth as handle no-undo .
define variable v-emails as character no-undo.
define buffer buf_rvs-line for ub.rvs-line.
define buffer buf_rvs-doc for ub.rvs-doc.
define stream fs1.
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
find first buf_rvs-doc no-lock
    where buf_rvs-doc.rvs-code = p-rvs-code
    no-error.
if not available buf_rvs-doc then
    run write-error(subst("Сверка &1 не найдена", p-rvs-code)) no-error.
run adm/shattri.p (
    input "get":U
    ,input  buf_rvs-doc.obj-type
    ,input  buf_rvs-doc.obj-code
    ,input  'petrol':U
    ,input  'rvs-wt-email':U
    ,output v-emails
    ,output v-value-date
    ,output v-value-decimal
    ,output v-value-integer
    ,output v-value-logical
    ,output v-param-type
    ,INPUT-OUTPUT table-handle v-tth
) no-error .
if v-emails = ? or v-emails = "" then
    return.
for each buf_rvs-line no-lock where buf_rvs-line.rvs-code = p-rvs-code:
    if (buf_rvs-line.level-water <> ? and buf_rvs-line.level-water <> 0) or (buf_rvs-line.state-level-water <> ? and buf_rvs-line.state-level-water <> 0) then do:
        run send-messages no-error.
        if error-status:error then
            run write-error(return-value) no-error.
    end.
end.
procedure send-messages:
    define variable email as character no-undo.
    define variable num as integer no-undo.
    define variable i as integer no-undo.
    define variable subject as character no-undo.
    define variable body as character no-undo.
    define variable obj as character no-undo.
    define variable rvs as character no-undo.
    define variable pl as character no-undo.
    define variable gds as character no-undo.
    define buffer buf_place for ub.place.
    define buffer buf_goods for ub.goods.
    find first buf_place no-lock
        where buf_place.pl-code = buf_rvs-line.pl-code.
    find first buf_goods no-lock
        where buf_goods.gds-code = buf_rvs-line.gds-code.
    num = num-entries (v-emails).
    subject = "Вода в сверке".
    body = " Объект &1 ~n Сверка &2 ~n Складское место &3 ~n Товар &4".
    obj = subst("&1 &2", buf_rvs-line.obj-type, buf_rvs-line.obj-code).
    rvs = subst("&1 &2 &3", buf_rvs-line.rvs-code, buf_rvs-doc.fact-date, string(buf_rvs-doc.fact-time, "HH:MM")).
    pl = subst("&1 &2", buf_place.pl-code, buf_place.pl-name).
    gds = subst("&1 &2", buf_goods.gds-code, buf_goods.gds-name).
    body = subst(body, obj, rvs, pl, gds).
    do i = 1 to num:
        email = trim(entry(i, v-emails)).
        if email = ? or email = "" then next.
        run gbl/sendmail.p(
            email,
            subject,
            body,
            ""
        ) no-error.
        if error-status:error then
            run write-error(subst("Ошибка при отправке на почту &1 - &2", email, return-value)) no-error.
    end.
end.
procedure write-error:
    define input parameter p-str as character no-undo.
    output stream fs1 to value("rvs_water_email_errors.txt").
    put stream fs1 unformatted p-str skip.
    output stream fs1 close.
end.
