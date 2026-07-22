block-level on error undo, throw.
/*

$Revision: aea5316774be, 0, rls $
$Author: expertek $
$Date: Mon Jan 27 18:27:46 2014 +0400 $
$Workfile: sendscal.p $
$Archive: ref/sendscal.p $

Передача измененных товаров на все весы

Автор: Бахтадзе Наталья Викторовна
Дата создания: 09/07/05
Author: Bakhtadze Natalya
Creation date: 09/07/05

*/

define input parameter parparentproc as widget-handle no-undo .
define input parameter p-parent-handle  as widget-handle no-undo .
define input parameter p-log-handle  as handle no-undo .
define input parameter p-parameter   as character no-undo .

/*
p-parameter включает
define input parameter p-obj-type like ub.clients.obj-type no-undo .
define input parameter p-obj-code like ub.clients.obj-code no-undo .
define variable rec-t-scales as recid no-undo .
DEFINE INPUT PARAMETER SendOption as Char NO-UNDO.
define input parameter send-rid-list as character no-undo .
DEFINE INPUT PARAMETER ObjectOption as CHar NO-UNDO.
DEFINE INPUT PARAMETER qnty-buf as integer NO-UNDO.
*/

define variable p-obj-type like ub.clients.obj-type no-undo .
define variable p-obj-code like ub.clients.obj-code no-undo .
define variable rec-t-scales as recid no-undo .
define variable SendOption as Character NO-UNDO.
define variable send-rid-list as character no-undo .
define variable ObjectOption as CHaracter NO-UNDO.
DEFINE variable qnty-buf as integer NO-UNDO.

define variable vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo init "$Author: expertek $":U .
define variable vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: sendscal.p $":U .
define variable vss-archive     as character no-undo init "$Archive: ref/sendscal.p $":U .
define variable vss-description as character no-undo init "Передача измененных товаров на все весы".
{ cmp/vssrevis.i }
{ cmp/str-glbl.i }
{ cmp/library.i  }
{ str/lib-trn.i  }
{ gbl/waitfram.i }
{ str/get-pr.i def }
{ ref/gdsoattr.i }
{ ref/gds-attr.i }
{ gbl/prn-lib.i }
{ cmp/ini-lib.i }
{ ref/iniscal0.i }
{ ref/scl-attr.i }
{ gbl/getcntxt.i def }

define variable glog as logical no-undo .
define variable log-file-name                as character      no-undo init "send-cd.txt".
define variable v-view-log                   as logical        no-undo .
define variable v-stop                       as logical        no-undo .
define variable g#news                       as logical        no-undo .
define variable g#auto                       as logical        no-undo .
define buffer buf_scales for ub.scales.
{ ref/sclgdsld.i }
{ ref/sendscls.i }
{ ref/iniscals.i }


&scop view-log   ~{ str/cdviewlg.i   ~
                    "'!!!При передаче информации на весы произошли ошибки!!!'" ~
                    "'send-cd.txt'" ~}   ~
                    return
                        /*точку не ставим для контроля синтаксиса*/

assign
p-obj-type = entry(1, p-parameter, {&delim-par} )
p-obj-code = integer(entry(2, p-parameter, {&delim-par} ))
rec-t-scales = (if entry(3, p-parameter, {&delim-par} ) = {&question-mark} then ? else integer(entry(3, p-parameter, {&delim-par} )))
sendoption = entry(4, p-parameter, {&delim-par})
send-rid-list = entry(5, p-parameter, {&delim-par} )
ObjectOption = entry(6, p-parameter, {&delim-par} )
qnty-buf = integer(entry(7, p-parameter, {&delim-par} ))
no-error .
if error-status:error then do:
  run write-log-and-file in p-log-handle (
        input 1
      , input log-file-name
      , input 1
      , input substitute("Ошибка входных параметров &1:&2&3&4"
                         , p-parameter
                         , {&new-line}
                         , error-status:get-message(1)
                         , return-value
                         )).
  assign
  v-view-log = yes.
  {&view-log}.
end.

{ gbl/getcntxt.i get }

{ gbl/chk-actg.i
  v-cntxt-db-num
  v-cntxt-userid
  {&action-head-code-main}
  'actn_scales_sending':U
  {&cntxt-object}
  0
  '':U
  0
  0
  0
  0
  true
  glog
}

if NOT glog then do:
    return error.
end.

if v-cntxt-db-num <> v-cntxt-db-num-obj then do:
  message
  substitute("Невозможна Передача измененных товаров на все весы в чужой БД&1" +
              "БД текущего объекта &2, текущая БД &3"
              , {&new-line}
              , v-cntxt-db-num-obj
              , v-cntxt-db-num)
 view-as alert-box error .
 return.
end.

/*получение параметров для работы с весами*/
run  iniscals  in this-procedure (
                                         input  p-obj-type
                                        ,input  p-obj-code
                                        ,output ini-types
                                        ,output ini-progs
                                        ,output rnd-znak
                                        ) no-error .
if error-status:error then do:
  run write-log-and-file in p-log-handle (
        input 1
      , input log-file-name
      , input 1
      , input substitute( "!!!Ошибки при получении параметров работы с весами&1&2&1&3"
                        , {&new-line}
                        , return-value
                        , error-status:get-message(1)
                        , {&new-line}
                        , return-value
                        )
                                        ).
  assign
  v-view-log = yes.
  {&view-log}.
end.

&scop general-send ~
  RUN general-send in this-procedure (input parparentproc                                               ~
                                      ,input p-parent-handle                                            ~
                                      ,input p-log-handle                                               ~
                                      ,input p-obj-type                                                 ~
                                      ,input p-obj-code                                                 ~
                                      ,buffer buf_scales                                                ~
                                      ,input sendoption                                                 ~
                                      ,input send-rid-list                                              ~
                                      ,input objectoption) no-error.                                    ~
  if error-status:error then do:                                                                        ~
    run write-log-and-file in p-log-handle (                                                            ~
          input 1                                                                                       ~
        , input log-file-name                                                                           ~
        , input 1                                                                                       ~
        , input substitute( "!!!Ошибки при передаче данных по измененным товарам (&1&2) на весы &3:&4&5&4&6"   ~
                          , p-obj-type                                                                         ~
                          , p-obj-code                                                                         ~
                          , buf_scales.scales-name                                                             ~
                          , ~{&new-line~}                                                                      ~
                          , error-status:get-message(1)                                                        ~
                          , return-value                                                                       ~
                          )                                                                                    ~
                                          ).                                                                   ~
    assign                                                                                                     ~
    v-view-log = yes                                                                                           ~
    .                                                                                                          ~
  end

&SCOPED-DEFINE status-code STRING(buf_scales.sts)

CASE sendoption:
  when "changed":u then do:
    FOR EACH buf_scales WHERE
            buf_scales.db-num = v-cntxt-db-num
      AND buf_scales.to-send = yes
      AND buf_scales.master = 0
      by buf_scales.scales-num
   on error undo, next
   on stop undo, next :
      if rec-t-scales <> ? and rec-t-scales <> recid(buf_scales) then NEXT.
      if buf_scales.sts = integer({&deleted-status-int}) then do:
        if buf_scales.master = 0 then do:
          run write-log-and-file in p-log-handle (
                input 1
              , input log-file-name
              , input 1
              , input substitute( "!!!Попытка пересылки товаров на весы №&1 &2,&4имеющие статус &3"
                                , buf_scales.scales-num
                                , buf_scales.scales-name
                                , {&status-int-name}
                                , {&new-line}
                                )).
          assign
          v-view-log = yes
          .
        end.
        next.
      end.

      if rec-t-scales = ? then do:
        run set-title in p-log-handle (
              input substitute("Передача данных по измененным товарам (&1&2) на весы &3"
                              , p-obj-type
                              , p-obj-code
                              , buf_scales.scales-name)).
      end.
      {&general-send}.
    end.
  end.
  otherwise do:
    FOR EACH buf_scales WHERE
        buf_scales.master = 0
    AND buf_scales.db-num = v-cntxt-db-num
    by buf_scales.scales-num
    on error undo, next
    on stop undo, next :
      if rec-t-scales <> ? and rec-t-scales <> recid(buf_scales) then NEXT.
      if buf_scales.sts = integer({&deleted-status-int}) then do:
        if buf_scales.master = 0 then do:
          run write-log-and-file in p-log-handle (
                input 1
              , input log-file-name
              , input 1
              , input substitute( "!!!Попытка пересылки товаров на весы №&1 &2,&4имеющие статус &3"
                                , buf_scales.scales-num
                                , buf_scales.scales-name
                                , {&status-int-name}
                                , {&new-line}
                                )).
          assign
          v-view-log = yes
          .
        end.
        next.
      end.
      {&general-send}.
    end.
  end.
END CASE.

{&view-log}.