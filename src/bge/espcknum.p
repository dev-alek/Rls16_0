block-level on error undo, throw.
/*

$Revision: 0704feb42aff, 2004, rls $
$Author: ostroukhov $
$Date: Wed Sep 18 21:02:01 2019 +0300 $
$Workfile: espcknum.p $
$Archive: bge/espcknum.p $

Генерация для ВС номера пакета, имени файла пакета, имени каталога источника и каталога назначени

Автор: Бахтадзе Наталья Викторовна
Дата создания: 12/26/07
Author: Bakhtadze Natalya
Creation date: 12/26/07

*/

define input        parameter p-action         as   character    no-undo .
define input        parameter p-esys-id        like ub.ext-system.esys-id no-undo .
define input        parameter p-db-num         like ub.ext-system.db-num no-undo .
define input        parameter p-delivery-method as integer   no-undo .
define input        parameter oxml-exch-dir    as character no-undo .
define input        parameter oxml-heap-dir    as character no-undo .
define input        parameter p-sign-fileext   as character no-undo .
define input-output parameter p-pack-num       as   integer      no-undo .
define input-output parameter p-custom-pack-name as character no-undo .
/*имя файла возвращается без расширения!!!!*/
define output       parameter p-pack-name      as   character    no-undo .
define output       parameter p-source-dir     as   character    no-undo .
define output       parameter p-target-dir     as   character    no-undo .
define output       parameter p-temp-dir       as   character    no-undo .
define output       parameter p-log-file-name  as character no-undo .
define output       parameter p-list-file-name as character no-undo .
define output       parameter p-custom-pack-flag as logical no-undo .

define variable vss-revision    as character no-undo init "$Revision: 0704feb42aff, 2004, rls $":U .
define variable vss-author      as character no-undo init "$Author: ostroukhov $":U .
define variable vss-date        as character no-undo init "$Date: Wed Sep 18 21:02:01 2019 +0300 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: espcknum.p $":U .
define variable vss-archive     as character no-undo init "$Archive: bge/espcknum.p $":U .
define variable vss-description as character no-undo init "Генерация для ВС номера пакета, имени файла пакета, имени каталога источника и каталога назначени".
{ cmp/vssrevis.i }
{ cmp/trg-def.i  }
{ bge/espcknam.i }
{ bge/esallatr.i work }
{ bge/esysattr.i }
{ gbl/filelist.i }
{ gbl/db-attr.i  }

/* 01/III-2019
function esys-id-format returns character ( input p-esys-id as integer):
  return string(p-esys-id, "99999").
end.

FUNCTION nws-db-format returns character ( input p-db-num as integer):
  define variable v-nws-db-format as character no-undo .
  assign
    v-nws-db-format = string( p-db-num,  (if p-db-num > 999 then "99999":U else "999":U ) )
  .
  return v-nws-db-format.
END FUNCTION.
*/

  define buffer buf_esys-pck-sent for ub.esys-pck-sent .
//  define buffer buf_esys-pck-rcvd for ub.esys-pck-rcvd .
  define buffer buf_esys-pck-keys for ub.esys-pck-keys .
  define buffer buf_esys-all-attr for ub.esys-all-attr.
  define buffer buf_temp-filelist for temp-filelist.

  define variable v-work-dir as character no-undo .
  define variable v-mess as character no-undo .
  define variable v-new-pack as logical no-undo .
  define variable v-to-return as logical no-undo .
  
  define variable v-ftp-path-in as character no-undo .
  define variable v-type as character no-undo .
/*  define variable v-dbnum-str as character no-undo .*/
/*  define variable v-esysid-str as character no-undo .*/
  define variable v-num-entries as integer no-undo .



do
on error undo, return error
:

  /* 1. имя директории */
  run bge/esdirnam.p ( input p-action
                      ,input p-esys-id
                      ,input p-db-num
                      ,input p-delivery-method
                      ,input oxml-exch-dir
                      ,input oxml-heap-dir
                      ,output p-source-dir
                      ,output p-target-dir
                      ,output p-temp-dir
                      ,output p-log-file-name
                     ) .

  /* если каталога source-dir нет, то создадим его */
  file-info:file-name = p-source-dir .
  if file-info:file-type begins "D":U then . else do :
    os-create-dir value( p-source-dir ).
    if os-error <> 0 then do:
      run gbl/os-errnm.p ( input os-error, output v-mess ).
      return error substitute("&1 Каталог &2 отсутствует, а создать его не удалось.&3&4"
                             ,vss-workfile
                             ,p-source-dir
                             ,{&new-line}
                             ,v-mess
                           ).

    end.
  end.
  
  /* если каталога target-dir нет, то создадим его */
  file-info:file-name = p-target-dir .
  if file-info:file-type begins "D":U then . else do :
    os-create-dir value( p-target-dir ).
    if os-error <> 0 then do:
      run gbl/os-errnm.p ( input os-error, output v-mess ) .
      return error substitute("&1 Каталог &2 отсутствует, а создать его не удалось.&3&4"
                             ,vss-workfile
                             ,p-target-dir
                             ,{&new-line}
                             ,v-mess
                           ).
    end.
  end.

  /* 01/III-2019 - фармирование имени деректории выделено в bge/esdirnam.p
  assign
    v-esysid-str = esys-id-format( p-esys-id )
    v-dbnum-str  = nws-db-format( ibs.th.gbl.gbl-var:g#db-num )
  .
  
  case p-action :
    when "get":U
    or
    when "fget":U
    then do:
      assign
        v-work-dir   = "ES" + v-esysid-str + "-":U + v-dbnum-str
        p-temp-dir   = oxml-exch-dir + {&back-slash-char} + v-work-dir + ".":U + v-esysid-str
        p-source-dir = oxml-exch-dir + {&back-slash-char} + v-work-dir
        p-target-dir = oxml-heap-dir + {&back-slash-char} + v-work-dir
        p-log-file-name  =  (if p-delivery-method = integer({&esys-dm-oracle-retail})
                            then (oxml-heap-dir + {&back-slash-char} + v-dbnum-str + "-":U + "ES" + v-esysid-str)
                            else (oxml-heap-dir + {&back-slash-char} + "actions.log")
                            )
      .
    end.
    when "put":U
    or
    when "fput"
    then do:
      assign
      v-work-dir   = v-dbnum-str + "-":U + "ES" + v-esysid-str
      p-temp-dir   = oxml-exch-dir + {&back-slash-char} + v-work-dir + ".":U + v-dbnum-str
      p-source-dir = oxml-heap-dir + {&back-slash-char} + v-work-dir
      p-target-dir = oxml-exch-dir + {&back-slash-char} + v-work-dir
      p-log-file-name  =  oxml-heap-dir + {&back-slash-char} + "actions.log"
      .
    end.
    otherwise do:
      message
        vss-workfile vss-revision vss-description skip
        "Не предусмотрена операция" p-action "для" vss-workfile
        view-as alert-box error.
      return error.
    end.
  end case.
  */

  /* 2. номер пакета */

  if p-pack-num = -1 then do:
    run findPackNum in this-procedure (p-action, p-esys-id, p-db-num, p-delivery-method,
                                       output p-pack-num) no-error .
    if error-status:error then return error return-value .                                       
    v-new-pack = yes.
/* 23/VII-2019 локализован поиск номера пакета  
    case p-action :
      when "get":U then do:

        find last buf_esys-pck-rcvd
          where buf_esys-pck-rcvd.esys-id = p-esys-id
             and buf_esys-pck-rcvd.db-num = p-db-num
             and buf_esys-pck-rcvd.espr-cr-db-num = ibs.th.gbl.gbl-var:g#db-num
          use-index pi no-error .
        if available buf_esys-pck-rcvd then do:
          p-pack-num = buf_esys-pck-rcvd.espr-pack-num + 1 .
        end.
        else do:  /* не было ни одного пакета */
          p-pack-num = (if p-delivery-method = integer({&esys-dm-nn})
                        or p-delivery-method = integer({&esys-dm-nnold})
                        or p-delivery-method = integer({&esys-dm-oracle-retail})
                  then 1
                  else 0) .
        end.
      end.
      when "fget":U then do:
        p-pack-num = 0.
      end.
      when "put":U then do:
        find last buf_esys-pck-sent share-lock
          where buf_esys-pck-sent.esys-id = p-esys-id
            and buf_esys-pck-sent.db-num = p-db-num
            and buf_esys-pck-sent.esps-cr-db-num = ibs.th.gbl.gbl-var:g#db-num
          use-index pi no-error .
        if available buf_esys-pck-sent then do:
          assign
            p-pack-num = buf_esys-pck-sent.esps-pack-num + 1
          .
        end.
        else do:  /* не было ни одного пакета */
          assign
            p-pack-num = if p-delivery-method = integer({&esys-dm-erp-1C-RN}) then 1 else 0
          .
        end.
        release buf_esys-pck-sent.
        if ((p-custom-pack-name <> ?
        and p-custom-pack-name <> '')
        or p-delivery-method = integer({&esys-dm-oracle-retail})
        or p-delivery-method = integer({&esys-dm-exite-edi})
        or p-delivery-method = integer({&esys-dm-contour-edi}))
        and v-new-pack
        then do:
           /* 25/IX-2018 - как будто v-custom-pack-name только присваивается
           define variable v-custom-pack-name as character no-undo .
           v-custom-pack-name = p-custom-pack-name.
           */
        end.
      end.
      when "fput" then do:
        /*экспорт файла*/
        p-pack-num = if p-delivery-method = integer({&esys-dm-erp-1C-RN}) then 1 else 0.
      end.
      otherwise do:
        /* 25/IX-2018 - сообщение на экран заменено на сообщение в вызывающую процедуру
        message
          vss-workfile vss-revision vss-description skip
          
          view-as alert-box error.
        return error.
        */
        return error substitute("&1 &2 &3&4Не предусмотрена операция &5 для &1&4"
                             ,vss-workfile, vss-revision, vss-description 
                             ,{&new-line}
                             ,p-action
                           ).
      end.
    end case.
*/  
  end. /*if p-pack-num = -1 then do:*/
  if p-pack-num < 0 then do:
    v-new-pack = yes.
    p-pack-num = abs(p-pack-num).
  end.
  p-list-file-name =  oxml-heap-dir + {&back-slash-char} + "lst":U + string( p-pack-num, "999999999") + ".":U .


  /* 3. имя файла */
  if (p-action = "put" or p-action = "fput") and p-custom-pack-name > '' then do:
    assign
    p-pack-name = p-custom-pack-name
    p-custom-pack-flag = yes
    .
  end.
  else do: /*esle if (p-action = "put" or p-action = "fput")*/
    if p-action = "put" then do:
      if p-custom-pack-name = ? then do:
        find first buf_esys-pck-sent no-lock where
                buf_esys-pck-sent.esps-pack-num = p-pack-num
            and buf_esys-pck-sent.esys-id = p-esys-id
            and buf_esys-pck-sent.db-num = p-db-num
            and buf_esys-pck-sent.esps-cr-db-num = g#db-num no-error.
        if available buf_esys-pck-sent
        and buf_esys-pck-sent.custom-pack-name <> ''
        then do:
          assign
          p-pack-name = buf_esys-pck-sent.custom-pack-name
          p-custom-pack-name = buf_esys-pck-sent.custom-pack-name
          p-custom-pack-flag = yes
          .
        end.
        else do:
          assign
          p-pack-name = get-short-pack-name( input p-action
                                           , input p-pack-num
                                           , input p-delivery-method
                                           , input buf_esys-pck-sent.custom-pack-name
                                           , output p-custom-pack-flag)
          p-custom-pack-name = p-pack-name
          .
        end.
      end. /*if p-custom-pack-name = ? then do:*/
      else do:
        assign
        p-pack-name = get-short-pack-name( input p-action
                                        , input p-pack-num
                                        , input p-delivery-method
                                        , input p-custom-pack-name
                                        , output p-custom-pack-flag)
        p-custom-pack-name = p-pack-name
        .
      end.
    end. /*if p-action = "put" then do:*/
    if p-action = "get" then do:
      if p-delivery-method = integer({&esys-dm-erp-1C-RN}) then do:

          empty temp-table temp-filelist .
          /* 04/III-2019 забираем только файлы с нужным расширением */
          run filelist-init in this-procedure
          (input p-source-dir /* внутри требуется наличие p-source-dir */
          ,input true
          ,input "xml,zip" // ,p7s,p7c"
          ,input ""
          ) no-error.
          
          for each buf_temp-filelist exclusive-lock :
              /* 23/VIII-2018 заглушка: исключаем файлы с электронной подисью,
                              чтобы они читались строго позже файлов с данными */
              if (p-sign-fileext > "") and (buf_temp-filelist.file-extension = p-sign-fileext) then do :
                  delete buf_temp-filelist .
                  next .
              end . 
              /* 05/IX-2018 ещё заглушка: если в настройках в bge/oxmlspci.w указали неправильное расширение,
                                          а файлы с электронной подписью всё же пришли */
              if can-do("p7s,p7c", buf_temp-filelist.file-extension) then do :
                  delete buf_temp-filelist .
                  next .
              end . 
            v-num-entries = num-entries(buf_temp-filelist.file-name, "_") .
              if v-num-entries = 4
              or (v-num-entries = 5 and buf_temp-filelist.file-name begins "ack")
              then .
              else do :
                  delete buf_temp-filelist .
                  next .
              end.
          end.
          find first buf_temp-filelist no-error.
          if available buf_temp-filelist
          then do :
              p-custom-pack-name = buf_temp-filelist.file-name .
          end.
      end.
      
      find first buf_esys-all-attr share-lock where
              buf_esys-all-attr.attr-code = {&attr-custom-pack-name}
          and buf_esys-all-attr.table-name = {&table_esys-pck-rcvd}
          and buf_esys-all-attr.key1 = p-pack-num
          and buf_esys-all-attr.key2 = p-esys-id
          and buf_esys-all-attr.key5 = p-db-num
          and buf_esys-all-attr.key6 = ibs.th.gbl.gbl-var:g#db-num no-error.
      assign
      p-pack-name = get-short-pack-name( input p-action
                                      , input p-pack-num
                                      , input p-delivery-method
                                      , input p-custom-pack-name
                                      , output p-custom-pack-flag)
      p-custom-pack-name = (if p-custom-pack-flag
                            then p-pack-name
                            else p-custom-pack-name)
      .
      if p-pack-name = '' then do:
        v-to-return = yes.
        /*не можем сделать просто return - надо еще директорию создать*/
      end.
      if not v-to-return then do:
        if v-new-pack = yes
        and p-custom-pack-flag
        then do:
        if not available buf_esys-all-attr then do:
          create buf_esys-all-attr.
          assign
          buf_esys-all-attr.attr-code = {&attr-custom-pack-name}
          buf_esys-all-attr.table-name = {&table_esys-pck-rcvd}
          buf_esys-all-attr.key1 = p-pack-num
          buf_esys-all-attr.key2 = p-esys-id
          buf_esys-all-attr.key5 = p-db-num
          buf_esys-all-attr.key6 = ibs.th.gbl.gbl-var:g#db-num
          .
        end.
        buf_esys-all-attr.attr-value = p-custom-pack-name .
        end. /*if v-new-pack = yes*/
      end. /*if not v-to-return then do:*/
    end. /*if p-action = "get" then do:*/
  end. /*else if (p-action = "put" or p-action = "fput")*/


end.

procedure findPackNum private :
define input  parameter p-action   as character no-undo .
define input  parameter p-esys-id  as integer no-undo .
define input  parameter p-db-num   as integer no-undo .
define input  parameter p-delivery-method as integer no-undo .
define output parameter p-pack-num as integer no-undo .
define variable v-cr-db-num as integer no-undo .
define variable v-s-method  as character no-undo .
define buffer buf_esys-pck-rcvd for ub.esys-pck-rcvd .
define buffer buf_esys-pck-sent for ub.esys-pck-sent .

  assign
    v-cr-db-num = ibs.th.gbl.gbl-var:g#db-num
    v-s-method  = string(p-delivery-method)
  no-error.
  case p-action :
    
    when "get":U then do:
      find last buf_esys-pck-rcvd no-lock
          where buf_esys-pck-rcvd.esys-id = p-esys-id
            and buf_esys-pck-rcvd.db-num  = p-db-num
            and buf_esys-pck-rcvd.espr-cr-db-num = v-cr-db-num
          use-index pi no-error .
      if available buf_esys-pck-rcvd then
        p-pack-num = buf_esys-pck-rcvd.espr-pack-num + 1 .
      else /* "первый", он же - "нулевой" пакет */
        p-pack-num = (if v-s-method = {&esys-dm-nn}
                      or v-s-method = {&esys-dm-nnold}
                      or v-s-method = {&esys-dm-oracle-retail} then 1 else 0) .
    end. /* end_of "get":U */
    when "fget":U then do:
      p-pack-num = 0.
    end.

    when "put":U then do:
      find last buf_esys-pck-sent no-lock
          where buf_esys-pck-sent.esys-id = p-esys-id
            and buf_esys-pck-sent.db-num  = p-db-num
            and buf_esys-pck-sent.esps-cr-db-num = v-cr-db-num
          use-index pi no-error .
      if available buf_esys-pck-sent then
        p-pack-num = buf_esys-pck-sent.esps-pack-num + 1 .
      else /* "первый", он же - "нулевой" пакет */
        p-pack-num = (if v-s-method = {&esys-dm-erp-1C-RN} then 1 else 0) .
    end. /* end_of "put":U */
    when "fput" then do:
        /*экспорт файла*/
        p-pack-num = (if v-s-method = {&esys-dm-erp-1C-RN} then 1 else 0) .
    end.

    otherwise do:
      return error substitute("&1 &2 &3&4Не предусмотрена операция &5 для &1&4"
                             ,vss-workfile, vss-revision, vss-description 
                             ,{&new-line}
                             ,p-action
                           ).
    end.
  end case . /* end_of case_p_action */
  
end procedure . /* end_of findPackNum */

/* $Workfile: espcknum.p $ end */