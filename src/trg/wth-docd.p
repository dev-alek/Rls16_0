block-level on error undo, throw.
/*

$Revision$
$Author$
$Date$
$Workfile$
$Archive$

Триггер на удаление документов МЦ

Автор: Бахтадзе Наталья Викторовна
Дата создания: 04/10/06
Author: Bakhtadze Natalya
Creation date: 04/10/06

*/

TRIGGER PROCEDURE FOR DELETE OF ub.wth-doc.

define variable vss-revision    AS CHAR NO-UNDO INIT "$Revision$":U.
define variable vss-author      AS CHAR NO-UNDO INIT "$Author$":U.
define variable vss-date        AS CHAR NO-UNDO INIT "$Date$":U.
define variable vss-workfile    AS CHAR NO-UNDO INIT "$Workfile$":U.
define variable vss-archive     AS CHAR NO-UNDO INIT "$Archive$":U.
define variable vss-description AS CHAR NO-UNDO INIT "триггер на удаление документов МЦ":U.
{ cmp/vssrevis.i "substitute('&1|&2|&3'
                      ,ub.wth-doc.doc-code
                      ,ub.wth-doc.ext-doc-type
                      ,ub.wth-doc.status_ )" }
{ cmp/trg-def.i }
{ gbl/thbjattr.i }
{ str/wthcalib.i }


DEF BUFFER buf-line FOR ub.wth-line.
DEF BUFFER buf_line FOR ub.wth-line.
DEF BUFFER buf-dtl  FOR ub.wth-dtl.
DEF BUFFER buf_dtl  FOR ub.wth-dtl.
DEF BUFFER buf_c-wth-doc FOR ub.c-wth-doc.
DEF BUFFER buf_c-wth-line FOR ub.c-wth-line.
DEF BUFFER buf_c-wth-dtl FOR ub.c-wth-dtl.
define buffer buf_c-wth-parts  for ub.c-wth-parts.
define buffer buf_wth-parts   for ub.wth-parts.
define buffer buf_wth-doc-attr    for ub.wth-doc-attr.
define buffer buf-wth-doc-attr    for ub.wth-doc-attr.

define    variable v-dstnws as logical init YES no-undo.

main-block:
do
on error  undo main-block, return error substitute( "&1. &2&3&4", vss-workfile, return-value, {&new-line}, error-status :get-message (1))
on stop   undo main-block, return error substitute( "&1. stop", vss-workfile )
on endkey undo main-block, return error substitute( "&1. endkey", vss-workfile )
:


  if ( ub.wth-doc.is-del = no) AND
    (ub.wth-doc.status_ = {&fact} or
     ub.wth-doc.status_ = {&permitted}) then undo main-block, return error.
/* проверяем, что не осталось привязанных чеков */
  find first ub.chk-doc no-lock
    where ub.chk-doc.out-code = ub.wth-doc.doc-code
    and   lookup(string(ub.chk-doc.chk-type),{&wth-receipt-codes} )  > 0
    no-error .
  if available ub.chk-doc then do:
    message
      vss-workfile vss-revision vss-description skip
      "Ошибка при удалении автоматического документа МЦ" skip
      "Найден чек привязанный к документу" skip
      "Документ" ub.wth-doc.doc-code skip
      "Код чека" ub.chk-doc.doc-code skip
      view-as alert-box error .
    undo main-block, return error .
  end.
  IF NOT g#news THEN DO:

    /* Скручивание счетчика номера сч.-фактуры при удалении документа.  */
      define variable v-atrValue    as character no-undo .
      define variable v-atrType     as character no-undo .
      define variable v-value-character as character no-undo .
      define variable v-value-date as date no-undo .
      define variable v-value-decimal as decimal no-undo .
      define variable v-value-integer as INTEGER no-undo .
      define variable v-value-logical AS LOGICAL no-undo .
      define variable v-param-type as character no-undo .
      define variable v-stfactpref as character no-undo .
      define variable v-numsfact   as integer no-undo .
      define temp-table temp-thbj-attr no-undo like ub.thbj-attr.
      define variable v-tth as handle no-undo .
      assign
      v-tth = buffer thbjattr_thbj-attr:table-handle .
      { str/wthatval.i
          ub.wth-doc.doc-code
          {&wthcattr-nsf}
          v-atrValue
          v-atrType
          NO-ERROR
      }
      if v-atrValue > '' then do:
         run adm/shattri.p (
            input "get":U
            ,input  ub.wth-doc.obj-type
            ,input  ub.wth-doc.obj-code
            ,input  {&attr-wthdoc}
            ,input  '':U /*p-param-code*/
            ,output v-value-character
            ,output v-value-date
            ,output v-value-decimal
            ,output v-value-integer
            ,output v-value-logical
            ,output v-param-type
            ,INPUT-OUTPUT table-handle v-tth
            ) no-error .
        IF not error-status:error  then do:
          for each thbjattr_thbj-attr no-lock:
            if thbjattr_thbj-attr.prop-code = {&attr-wthdoc_obj_stfactpref} then v-stfactpref = thbjattr_thbj-attr.property-value-character.
            if thbjattr_thbj-attr.prop-code = {&attr-wthdoc_obj_numsfact} then v-numsfact = thbjattr_thbj-attr.property-value-integer.
          end.
        end.
        if v-atrValue = v-stfactpref + string(v-numsfact) then do:
          v-numsfact = v-numsfact - 1.
          RUN thbjattr_write IN THIS-PROCEDURE (
               input ub.wth-doc.obj-type
              ,input ub.wth-doc.obj-code
              ,input {&attr-wthdoc}
              ,input {&attr-wthdoc_obj_numsfact}
              ,input '':U
              ,input ?
              ,input 0
              ,input v-numsfact
              ,input no
          ) NO-ERROR.
          IF ERROR-STATUS:error THEN do:
            MESSAGE ERROR-STATUS:get-message(1)  SKIP
            RETURN-VALUE
            VIEW-AS ALERT-BOX warning.
            /*UNDO, RETURN ERROR. */
          END.

        end.
      end.

  END.

  FOR EACH buf-line NO-LOCK WHERE buf-line.doc-code = ub.wth-doc.doc-code :
    FIND buf_line EXCLUSIVE-LOCK WHERE RECID( buf_line ) = RECID( buf-line ).

    FOR EACH buf-dtl NO-LOCK WHERE
     buf-dtl.doc-code = buf_line.doc-code AND
     buf-dtl.wth-code = buf_line.wth-code AND
     buf-dtl.w-p-code = buf_line.w-p-code :
      FIND buf_dtl EXCLUSIVE-LOCK WHERE RECID( buf_dtl ) = RECID( buf-dtl ).
      /* история удаления buf_dtl в евоном триггере */
      DELETE buf_dtl.
    END. /* buf-dtl */

    /* история удаления buf-line  тоже в евоном триггере */
    DELETE buf_line.
  END. /* buf-line */
  if can-find(first buf_wth-parts where buf_wth-parts.out-code = ub.wth-doc.doc-code  ) then do:
    undo, return error 'Найдены неснятые резервы по документу'.
  end.
  if can-find(first buf_wth-parts where buf_wth-parts.doc-code = ub.wth-doc.doc-code  ) then do:
    undo, return error 'Найдены партии, порожденные данным документом'.
  end.
  FOR EACH buf_wth-doc-attr NO-LOCK WHERE buf_wth-doc-attr.doc-code = ub.wth-doc.doc-code :
    FIND buf-wth-doc-attr EXCLUSIVE-LOCK WHERE RECID( buf-wth-doc-attr ) = RECID( buf_wth-doc-attr ).
    delete buf-wth-doc-attr.
  end.

  if ub.wth-doc.status_ = {&wayb} then do:
    for each buf_c-wth-doc where
            buf_c-wth-doc.doc-code = ub.wth-doc.doc-code
    on error undo MAin-block,  return error return-value
    :
      delete buf_c-wth-doc.
    end.
    for each buf_c-wth-line where
            buf_c-wth-line.doc-code = ub.wth-doc.doc-code
    on error undo MAin-block,  return error return-value
    :
      delete buf_c-wth-line.
    end.
    for each buf_c-wth-dtl where
            buf_c-wth-dtl.doc-code = ub.wth-doc.doc-code
    on error undo MAin-block,  return error return-value
    :
      delete buf_c-wth-dtl.
    end.
    for each buf_c-wth-parts where
             buf_c-wth-parts.out-code = wth-doc.doc-code
    on error undo MAin-block,  return error return-value
    :
      delete buf_c-wth-parts.
    end.

  end.

  /* история */

   /* Проверяем надо ли передавать по СПН уничтожения и перемещение зоны погашения. Хождение отключается в случае, когда эта избыточная информация на УБД не нужна */
    if lookup(ub.wth-doc.ext-doc-type,{&WDEDT_NwsDoc}) > 0 and g#db-num = 0  then do:
            run adm/shattri.p ( input "get":U
                          , input ""
                          , input 0
                          , input {&attr-wthrep}
                          , input  ""
                          , output v-value-character
                          , output v-value-date
                          , output v-value-decimal
                          , output v-value-integer
                          , output v-value-logical
                          , output v-param-type
                          , INPUT-OUTPUT TABLE thbjattr_thbj-attr
                          ) no-error .

        for first thbjattr_thbj-attr
              where thbjattr_thbj-attr.obj-code  = 0
                and thbjattr_thbj-attr.obj-type  = ""
                and thbjattr_thbj-attr.prop-code = {&attr-wthrep_docdstnws}
                and thbjattr_thbj-attr.upper-prop-code = {&attr-wthrep}
              no-lock:
            assign
            v-dstnws = not thbjattr_thbj-attr.property-value-logical.
        end.
    end.


  if /*not g#news */
  ub.wth-doc.status_ = {&fact}
  and  (lookup(ub.wth-doc.ext-doc-type,{&WDEDT_NwsDoc}) = 0 or ( lookup(ub.wth-doc.ext-doc-type,{&WDEDT_NwsDoc}) > 0 and v-dstnws))

  then do:
    run nws/cmd-del.p
      ( input "wth-doc":U
       ,input (buffer ub.wth-doc:handle)
       ,input "":U
      ) no-error .
    if error-status :error then do:
      undo, return error substitute( "&1. Ошибка при отправке в новости команды на удаление записи. &2&3&2&4", vss-workfile, {&new-line}, return-value, error-status :get-message ( error-status :num-messages ) ).
    end.
  end.


    if g#oxml = yes
    then do:
    run str/calloxml.p (
          input {&nwsdochs_action_delete}
        , input {&table_wth-doc}
        , input ( buffer ub.wth-doc:handle )
    ) no-error.
    if error-status :error
    then do:
        undo, return error substitute( "&2&1Ошибка при отправке в систему OpenXML команды на удаление записи&1&3&1&4"
                             , {&new-line}
                             , vss-workfile
                             , return-value
                             , error-status :get-message ( 1 ) ).
    end.
    end.
END. /* Main-Block */