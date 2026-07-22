block-level on error undo, throw.
/*

$Revision: 7aa39a4c7e01, 2814, rls $
$Author: SSlivenko $
$Date: Чт сен 02 12:05:36 2021 +0300 $
$Workfile: sxg-pack.p $
$Archive: bge/sxg-pack.p $

отправка и прием пакета новостей (файла)

Автор: Бахтадзе Наталья Викторовна
Дата создания: 10/02/08
Author: Bakhtadze Natalya
Creation date: 10/02/08

*/

define input parameter parparentproc as widget-handle no-undo .
/* 11/I-2019 parparentproc передайтся в:
   - gbl/ftp-ls.p
   - gbl/ftp-get.p
   - gbl/ftp-put.p
*/
define input parameter p-parent-handle as handle no-undo .
define input parameter p-log-handle  as handle no-undo .
define input parameter p0-action     as character no-undo .
define input parameter p0-arch       as logical   no-undo .
define input parameter p0-file-name  as character no-undo .
define input parameter p0-source-dir as character no-undo .
define input parameter p0-target-dir as character no-undo .
define input parameter p0-temp-dir   as character no-undo .
define input parameter p-pck-num     as integer no-undo .
define input parameter p-esys-id     as integer no-undo .
define input parameter p-db-num      as integer no-undo .
define input parameter p-cr-db-num   as integer no-undo .
define input parameter p-delivery-method as integer no-undo .


define variable vss-revision    as character no-undo init "$Revision: 7aa39a4c7e01, 2814, rls $":U .
define variable vss-author      as character no-undo init "$Author: SSlivenko $":U .
define variable vss-date        as character no-undo init "$Date: Чт сен 02 12:05:36 2021 +0300 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: sxg-pack.p $":U .
define variable vss-archive     as character no-undo init "$Archive: bge/sxg-pack.p $":U .
define variable vss-description as character no-undo init "отправка и прием пакета новостей (файла)".
{ cmp/vssrevis.i }
{ cmp/trg-def.i }
{ bge/esallatr.i  work }
{ bge/esysattr.i }
{ gbl/filelist.i }
{ gbl/ftp-fl.i }
{ gbl/ftp-df.i }
{ gbl/cur-time.i }
{ rul/ora-rcpt.i proc }
{ bge/esysattr.i } // ext-system-attr-value для проверки сертификатов
{ utl/search.i }
DEFINE VARIABLE v-today as date no-undo .
DEFINE VARIABLE v-time as integer no-undo .
FUNCTION availFile RETURNS logical
  ( INPUT ifile AS character ) :

    def var vii as int no-undo.
    do vii = 1 to 5:
       assign
          file-info:file-name = ifile
       .
               
       if    file-info:file-type = ?
          or not ( file-info:file-type begins "F":U )
          or file-info:file-size = 0
       then do:
          if vii = 5
          then do:
             return false.
          end.
          else do:
             pause 1 no-message.
          end. 
       end.
       else do:
          return true.
       end.  
    end.
end.

  define stream FLStream.

  define variable v-filename         as character no-undo .
  define variable v-fullfilename     as character no-undo .
  define variable v-filetype         as character no-undo .
//  define variable v-num-name-parts   as integer no-undo . 23/VII-2019
  define variable v-r-index          as integer no-undo .
  define variable v-fileext          as character no-undo .
  define variable v-filenamenoext    as character no-undo .
  define variable v-current-pack-num as integer no-undo .
  define variable v-ftp-ip as character no-undo .
  define variable v-ftp-login as character no-undo .
  define variable v-ftp-password as character no-undo .
  define variable v-ftp-path as character no-undo .
  define variable v-ftp-path-in as character no-undo .
  define variable v-ftp-path-out as character no-undo .
  define variable v-flags as character no-undo .
  define variable v-cmd-line as character no-undo .
  define variable l-res as integer no-undo .
  define variable v-type as character no-undo .
  define variable v-parameter as character no-undo .
  define variable log-file-name as character no-undo .

    define variable v-cert-enstr       as character no-undo . // чтение v-cert-enabled строкой
    define variable v-cert-enabled     as logical no-undo . // true - добавить цифровую подпись
    define variable v-attr-type        as character no-undo . // для чтения значений из ext-system-attr

  define buffer buf_esys-all-attr for ub.esys-all-attr.
  define buffer buf_temp-filelist for temp-filelist.
  define buffer buf_esys-pck-sent for ub.esys-pck-sent.
  
do
on error undo, return error
:

  /* если каталога temp-dir нет, то создадим его */
  assign
    file-info:file-name = p0-temp-dir
  .
  if file-info:file-type = ?
    or not ( file-info:file-type begins "D":U )
  then do:
    os-create-dir value( p0-temp-dir ).
    if os-error <> 0 then do:
      return error substitute( "&1. Каталог &2 отсутствует, а создать его не удалось.", vss-workfile, p0-temp-dir ).
    end.
  end.
  

  if p0-file-name <> ? then do:  /*при get так не бывает*/
    /* 11/I-2019  добавлена передача полного имени файле в file-s-g().
                  При put мы получаем это имя из оглавления source-dir */
    v-fullfilename = p0-source-dir + {&back-slash-char} + p0-file-name .
    /* проверим наличие исходного файла */
    assign
      file-info:file-name = v-fullfilename
    .
    if file-info:file-type = ?
      or not ( file-info:file-type begins "F":U )
    then do:
      return error substitute( "&1. Исходный файл &2 не найден.", vss-workfile, v-fullfilename ).
    end.
    /* 23/VII-2019  добавлена имени файла без расширения и расширения файла отдельно в file-s-g(). */
    v-r-index = r-index(p0-file-name, '.':u) .
    if v-r-index > 0 then assign
      v-filenamenoext = substring( p0-file-name, 1, v-r-index - 1 )
      v-fileext       = substring( p0-file-name, v-r-index + 1 )
    .
    else assign
      v-filenamenoext = p0-file-name
      v-fileext       = "":U
    .
    
    run ext-system-attr-value in this-procedure (
                                      input  p-esys-id
                                     ,input  p-db-num
                                     ,input  {&attr-esys-cert-sign}
                                     ,output v-cert-enstr
                                     ,output v-attr-type) .
    v-cert-enabled = logical (v-cert-enstr) .
    run file-s-g ( input p0-action
                  ,input p0-arch
                  ,input p0-file-name
                  ,input v-fullfilename
                  ,input v-filenamenoext
                  ,input v-fileext
                  ,input p0-source-dir
                  ,input p0-target-dir
                  ,input p0-temp-dir
                  ,input p-pck-num
                  ,input v-cert-enabled
                 ) no-error.
    if error-status :error then do:
      return error return-value.
    end.
  end.
  else do:
    if p-delivery-method = integer({&esys-dm-nn})
    or p-delivery-method = integer({&esys-dm-nnold})
    or p-delivery-method = integer({&esys-dm-exite-edi})
    or p-delivery-method = integer({&esys-dm-contour-edi})
    then do:
      /*надо получить список файлов и всем сделать get*/
      run ext-system-attr-value in this-procedure ( input p-esys-id
                                                    ,input p-db-num
                                                    ,input {&attr-esys-ftp-ip}
                                                    ,output v-ftp-ip
                                                    ,output v-type) no-error.
      run ext-system-attr-value in this-procedure ( input p-esys-id
                                                    ,input p-db-num
                                                    ,input {&attr-esys-ftp-login}
                                                    ,output v-ftp-login
                                                    ,output v-type) no-error.
      run ext-system-attr-value in this-procedure ( input p-esys-id
                                                    ,input p-db-num
                                                    ,input {&attr-esys-ftp-password}
                                                    ,output v-ftp-password
                                                    ,output v-type) no-error.
      run ext-system-attr-value in this-procedure ( input p-esys-id
                                                    ,input p-db-num
                                                    ,input {&attr-esys-ftp-path}
                                                    ,output v-ftp-path
                                                    ,output v-type) no-error.
      if p-delivery-method = integer({&esys-dm-exite-edi}) or p-delivery-method = integer({&esys-dm-contour-edi}) then do:
        run ext-system-attr-value in this-procedure ( input p-esys-id
                                                      ,input p-db-num
                                                      ,input {&attr-esys-ftp-path-in}
                                                      ,output v-ftp-path-in
                                                      ,output v-type) no-error.
        run ext-system-attr-value in this-procedure ( input p-esys-id
                                                      ,input p-db-num
                                                      ,input {&attr-esys-ftp-path-out}
                                                      ,output v-ftp-path-out
                                                      ,output v-type) no-error.
        v-flags = string({&INTERNET_FLAG_PASSIVE}).
      end.
      else do:
        v-ftp-path-in = "in".
        v-ftp-path-out = "out".
        v-flags = string(0).
      end.
      run get-log-file-name in p-parent-handle ( output log-file-name) no-error.
      assign
      v-parameter = v-ftp-ip + {&delim-par} +
                    v-ftp-login + {&delim-par} +
                    v-ftp-password + {&delim-par} +
                    v-flags + {&delim-par} + /*flags*/
                    (if v-ftp-path <> ''
                    then (trim (trim (trim(v-ftp-path
                                    , {&back-slash-char})
                                ,{&slash-char})
                          ,{&back-slash-char}) + {&slash-char})
                    else '') +
                    v-ftp-path-in + {&delim-par} +
                    "ftp-fl_CreateFileList" + {&delim-par} +
                    log-file-name.
      .
      for each buf_temp-filelist :
        delete buf_temp-filelist.
      end.
      run gbl/ftp-ls.p ( input parparentproc
                        ,input this-procedure:handle
                        ,input p-log-handle
                        ,input v-parameter ) no-error.

      if not can-find(first buf_temp-filelist) then do:
        if p-delivery-method = integer({&esys-dm-exite-edi}) or p-delivery-method = integer({&esys-dm-contour-edi}) then do:
          define variable v-to-return as logical no-undo .
          v-to-return = yes.
        end.
        else do:
        return.
      end.
      end.
      if not v-to-return then do:
        assign
        v-parameter = v-ftp-ip + {&delim-par} +
                      v-ftp-login + {&delim-par} +
                      v-ftp-password + {&delim-par} +
                    v-flags + {&delim-par} + /*flags*/
                    '' + {&delim-par} +
                    '' + {&delim-par} +
                      string(yes) + {&delim-par} +
                    "cb_getnextfilename" + {&delim-par} +
                      "process-edoc.txt"
        .
        run gbl/ftp-get.p ( input parparentproc
                          ,input this-procedure:handle
                          ,input p-log-handle
                          ,input v-parameter ) no-error.
        if error-status:error then do:
          return error return-value.
        end.
      end.
    end.

    input stream FLStream from os-dir ( p0-source-dir ) .
    v-current-pack-num = p-pck-num - 1.
    repeat
    on error undo, return error
    :
      import stream FLStream v-filename v-fullfilename v-filetype.
      
      v-r-index = r-index(v-filename, '.':u) .
      if v-r-index > 0 then assign
        v-filenamenoext = substring( v-filename, 1, v-r-index - 1 )
        v-fileext       = substring( v-filename, v-r-index + 1 )
      .
      else assign
        v-filenamenoext = v-filename
        v-fileext       = "":U
      .
      if v-filetype begins "F"
        and v-r-index > 0
        and lookup(  v-fileext,  "$$$"  ) = 0
      then do:
        assign
          file-info:file-name = v-fullfilename
        .

      //  if lookup(entry( num-entries( v-filename, "." ), v-filename, "." ), "$$$") = 0 and
           if file-info:file-type MATCHES "*W*":U /* проверка на атрибут read-only */
          and file-info:file-type MATCHES "*R*":U /* проверка на возможность чтения файла */
          and not ( file-info:file-type MATCHES "*H*":U )
        then do:
          v-current-pack-num = v-current-pack-num + 1.
          // переносит пакет из exch в heap и распаковывает его там, если он архив
          run file-s-g ( input p0-action
                        ,input p0-arch
                        ,input v-filename
                        ,input v-fullfilename
                        ,input v-filenamenoext
                        ,input v-fileext
                        ,input p0-source-dir
                        ,input p0-target-dir
                        ,input p0-temp-dir
                        ,input v-current-pack-num
                        ,input false
                      ) no-error.
          if error-status :error then do:
            return error return-value.
          end.
          if p-delivery-method = integer({&esys-dm-exite-edi}) or p-delivery-method = integer({&esys-dm-contour-edi}) then do:
            /* запишем в контенер список файлов  */
            define variable v-caller-handle as handle no-undo .
            v-caller-handle = this-procedure:instantiating-procedure.
            if lookup("cb_fill-filelist", v-caller-handle:internal-entries) > 0 then do:
              run cb_fill-filelist in v-caller-handle ( input v-filename, input p-delivery-method) no-error.
            end.
          end.
        end.
      end.
    END.
    input stream FLStream close.

  end.

  return .

end.

procedure file-s-g private :
  define input parameter p-action     as character no-undo .
  define input parameter p-arch       as logical   no-undo .
  define input parameter p-file-name  as character no-undo .
  define input parameter p-fullfile-name    as character no-undo .
  define input parameter p-file-name-no-ext as character no-undo .
  define input parameter p-file-ext   as character no-undo .
  define input parameter p-source-dir as character no-undo .
  define input parameter p-target-dir as character no-undo .
  define input parameter p-temp-dir   as character no-undo .
  define input parameter p-current-pack-num as integer no-undo .
  define input parameter p-cert-enabled as logical no-undo . /* true - включено использование цифровой подписи */

    define variable v-arch             as logical   no-undo .
    define variable v-arh-name         as character no-undo .
    define variable v-arh-type         as character no-undo .
    define variable v-file-hash        as character no-undo .

/*    define variable v-file-source      as character no-undo .*/
    define variable v-file-source-arj  as character no-undo .
    define variable v-file-temp        as character no-undo .
    define variable v-file-target      as character no-undo .
    define variable v-file-source-all  as character no-undo .
    define variable v-log-file-source      as character no-undo .
    define variable v-log-file-source-arj  as character no-undo .
    define variable v-log-file-temp        as character no-undo .
    define variable v-log-file-target      as character no-undo .
/* 23/VII-2019
    define variable v-r-index          as integer no-undo .
    define variable v-file-name-no-ext as character no-undo .
    define variable v-ext-name         as character no-undo .
*/    
    define variable v-zip-command      as character no-undo .

    define variable v-unzip-command    as character no-undo .
    
    define variable v-err-mess         as character no-undo .
    define variable v-send-log         as logical   no-undo .
    define buffer buf_esys-pck-rcvd for ub.esys-pck-rcvd.

  do
  on error undo, return error
  :

/* 23/VII-2019 - вынесено на верхний уровень
    v-r-index = r-index(p-file-name, '.':u) .
    if v-r-index > 0 then assign
      v-file-name-no-ext = substring( p-file-name, 1, v-r-index - 1 )
      v-ext-name         = substring( p-file-name, v-r-index + 1 )
    .
    else assign
      v-file-name-no-ext = p-file-name
      v-ext-name         = "":U
    .
*/    
    assign
/* 11/I-2019 - вместо v-file-source используется p-fullfile-name
      v-file-source     = p-source-dir + {&back-slash-char} + p-file-name*/
      v-file-temp       = p-temp-dir   + {&back-slash-char} + p-file-name
      v-file-target     = p-target-dir + {&back-slash-char} + p-file-name
    .
    
  case p-delivery-method:
    when integer({&esys-dm-nn}) or
    when integer({&esys-dm-nnold}) then do:
      v-arh-name = ''.
      p-arch = no.
    end.
    when integer({&esys-dm-CDash}) then do:
      v-arh-name = "".
      v-arh-type = "".
      p-arch = no.
    end.
    when integer({&esys-dm-exite-edi}) then do:
      v-arh-name = ''.
      p-arch = no.
    end.
    when integer({&esys-dm-contour-edi}) then do:
      v-arh-name = ''.
      p-arch = no.
    end.
    when integer({&esys-dm-oracle-retail}) then do:
      v-arh-name = search('exe/pkzipc.exe':U).
      v-arh-type = "zip".
      if p-action = "put" then do :
            if search(p-source-dir + {&back-slash-char} + p-file-name-no-ext + ".LOG") <> ? then do:
              v-send-log = yes.
              assign
              v-log-file-source     = p-source-dir + {&back-slash-char} + p-file-name-no-ext + ".LOG"
              v-log-file-temp       = p-temp-dir   + {&back-slash-char} + p-file-name-no-ext + ".LOG"
              v-log-file-target     = p-target-dir + {&back-slash-char} + p-file-name-no-ext + ".LOG"
              .
            end.
      end . /* end_of put */
    end.
    when integer({&esys-dm-erp-1C-RN}) then do:
      p-arch = yes.
      v-arh-type = "zip".
      
      if p-action = "put":U
      or p-action = "fput" then do :
                               v-arh-name = search( "exe/7z.exe":U ) .
        if v-arh-name = ? then v-arh-name = search( "exe/7za.exe":U ) .
      end .
      else do :
                               v-arh-name = search('exe/pkzipc.exe':U).
      end .
      if p-file-ext = "zip" then do :
        if p-action = "get" then do :
          if v-arh-name = ? then
            return error substitute( "&1. Программа архиватор не найдена", vss-workfile ).
          v-arch = true .
        end .
      end .
      else do :
        if p-action = "get" then do :
        /* 01/III-2019
           1. Нам надо забирать из EXCH только нужные расширения,
           2. и в разбор тоже надо брать только нужные файлы.
        */
          if not can-do ("xml,p7s,p7c", p-file-ext) then return .
          v-arch = false .
        end .
      end .
    end.
    otherwise do :
        v-arh-name = search( "exe/arj32.exe":U ) .
      if v-arh-name = ? then
        v-arh-name = search( "exe/arj.exe":U ) .
      v-arh-type = "arj".
    end .
  end case .
  if p-action = "get" or p-action = "fget" then do:
    if lookup( p-file-ext, "arj") <> 0
    or lookup( p-file-ext, "zip") <> 0 then do:
      run write-to-log in p-parent-handle ( substitute( "Прием файла &1 (&2)", p-fullfile-name, v-arh-name ) ) .
      if v-arh-name = ? then
         return error substitute( "&1. Программа архиватор не найдена!", vss-workfile ).
      v-arch = true .
    end.
    else do:
      run write-to-log in p-parent-handle ( substitute( "Прием файла &1 (copy)", p-fullfile-name ) ) .
      v-arch = false .
    end.
  end .
  
    run gbl/md5.p(p-fullfile-name, output v-file-hash).
    run write-to-log in p-parent-handle ( substitute("Файл: &1; Контрольная сумма: &2.", p-fullfile-name,  v-file-hash) ) .
    
    case p-action :
      when "fput" or
      when "fget" then .
      when "put" then do :
      end . /* end_of put */
      otherwise do :
        
      if p-delivery-method = integer({&esys-dm-nnold})
      or p-delivery-method = integer({&esys-dm-oracle-retail})
      or p-delivery-method = integer({&esys-dm-exite-edi})
      or p-delivery-method = integer({&esys-dm-contour-edi})
      then do:
        find first buf_esys-all-attr share-lock where
                  buf_esys-all-attr.attr-code = {&attr-custom-pack-name}
              and buf_esys-all-attr.table-name = {&table_esys-pck-rcvd}
              and buf_esys-all-attr.key1 = p-current-pack-num
              and buf_esys-all-attr.key2 = p-esys-id
              and buf_esys-all-attr.key5 = p-db-num
              and buf_esys-all-attr.key6 = g#db-num
              no-error .
        if not available buf_esys-all-attr then do:
          create buf_esys-all-attr.
          assign
          buf_esys-all-attr.attr-code = {&attr-custom-pack-name}
          buf_esys-all-attr.table-name = {&table_esys-pck-rcvd}
          buf_esys-all-attr.key1 = p-current-pack-num
          buf_esys-all-attr.key2 = p-esys-id
          buf_esys-all-attr.key5 = p-db-num
          buf_esys-all-attr.key6 = g#db-num
          .
        end.
        if p-delivery-method = integer({&esys-dm-oracle-retail}) then do:
          buf_esys-all-attr.attr-value = p-file-name-no-ext + ".DAT".
        end.
        else do:
          buf_esys-all-attr.attr-value = p-file-name.
        end.
      end.

      end .
    end case .

    if p-action = "put":U
    or p-action = "fput"
    then do:
      if p-arch = true then do:
        if v-arh-name = ? then do:
          return error substitute( "&1. Программа архиватор не найдена!", vss-workfile ).
        end.
        run write-to-log in p-parent-handle ( substitute( "Отправка файла &1 (&2)", p-fullfile-name, v-arh-name ) ).

        if v-arh-type = "arj" then do:
        assign
          v-file-source-arj = p-source-dir + {&back-slash-char} + p-file-name-no-ext + ".arj":U
          v-file-temp       = p-temp-dir   + {&back-slash-char} + p-file-name-no-ext + ".arj":U
          v-file-target     = p-target-dir + {&back-slash-char} + p-file-name-no-ext + ".arj":U
        .
        // @FUTU в зависимости от параметра запаковать или только файл, или файл вместе с цифровой подписью
        os-command silent
          value( v-arh-name )
          value( "a -e -y":U )
          value( v-file-source-arj )
          value( p-fullfile-name )
        .
        end.
        if v-arh-type = "zip" then do:
          case p-delivery-method:
            when integer({&esys-dm-oracle-retail}) then do:
              assign
                /* 23/VII-2019  сумма v-file-name-no-ext + "." + v-ext-name есть p-file-name,
                                из которого они были получены снаружи  
                v-file-source-arj = p-source-dir + {&back-slash-char} + v-file-name-no-ext + "." + v-ext-name + ".zip":U
                v-file-temp       = p-temp-dir   + {&back-slash-char} + v-file-name-no-ext + "." + v-ext-name + ".zip":U
                v-file-target     = p-target-dir + {&back-slash-char} + v-file-name-no-ext + "." + v-ext-name + ".zip":U
                */
                v-file-source-arj = p-source-dir + {&back-slash-char} + p-file-name + ".zip":U
                v-file-temp       = p-temp-dir   + {&back-slash-char} + p-file-name + ".zip":U
                v-file-target     = p-target-dir + {&back-slash-char} + p-file-name + ".zip":U
              .
              if v-send-log then do:
                assign
                  v-log-file-source-arj = p-source-dir + {&back-slash-char} + p-file-name-no-ext + ".LOG" + ".zip":U
                  v-log-file-temp       = p-temp-dir   + {&back-slash-char} + p-file-name-no-ext + ".LOG" + ".zip":U
                  v-log-file-target     = p-target-dir + {&back-slash-char} + p-file-name-no-ext + ".LOG" + ".zip":U
                .
              end.
              os-command silent
                value( v-arh-name )
                value( "-add -path=none -span=700 ":U )
                value( v-file-source-arj )
                value( p-fullfile-name )
              .
              if v-send-log then do:
                os-command silent
                  value( v-arh-name )
                  value( "-add -path=none -span=700 ":U )
                  value( v-log-file-source-arj )
                  value( v-log-file-source )
                .
              end.
            end.
            when integer({&esys-dm-erp-1C-RN}) then do:
              assign
                v-file-source-arj = p-source-dir + {&back-slash-char} + p-file-name-no-ext + ".zip":U
                v-file-temp       = p-temp-dir   + {&back-slash-char} + p-file-name-no-ext + ".zip":U
                v-file-target     = p-target-dir + {&back-slash-char} + p-file-name-no-ext + ".zip":U
              .
              /* в зависимости от параметра запаковать или только файл, или файл вместе с цифровой подписью */
              v-zip-command =
              if p-cert-enabled then
                 substitute( "&1 a -tzip -y &2 &3 &4&5&6.p7s":U
                   , v-arh-name
                   , v-file-source-arj
                   , p-fullfile-name
                   , p-source-dir, {&back-slash-char} , p-file-name-no-ext
                 )
              else
                 substitute( "&1 a -tzip -y &2 &3":U, v-arh-name, v-file-source-arj, p-fullfile-name )
              .
               
              os-command silent value( v-zip-command ) .
              /* проверим наличие заархивированного файла */
              if not availfile(v-file-source-arj)
              then do:
                return error substitute( "&1. Заархивированный файл &2 не найден или имеет нулевой размер.", vss-workfile, v-file-source-arj ).
              end.
              run write-to-log in p-parent-handle ( substitute( "Файл &1 заархивирован в &2)", p-fullfile-name, v-file-source-arj ) ).
            end.
            otherwise do:
              assign
                v-file-source-arj = p-source-dir + {&back-slash-char} + p-file-name-no-ext + ".zip":U
                v-file-temp       = p-temp-dir   + {&back-slash-char} + p-file-name-no-ext + ".zip":U
                v-file-target     = p-target-dir + {&back-slash-char} + p-file-name-no-ext + ".zip":U
                v-file-source-all = p-source-dir + {&back-slash-char} + p-file-name-no-ext + ".*":U
              .
              
              os-command silent
                value( v-arh-name )
                value( "-add -path=none ":U )
                value( v-file-source-arj )
                value( v-file-source-all )
                value( ">> pkzipc-log.txt" )
              .
              /* проверим наличие заархивированного файла */
              assign
                file-info:file-name = v-file-source-arj
              .
              if file-info:file-type = ?
                or not ( file-info:file-type begins "F":U )
              then do:
                return error substitute( "&1. Заархивированный файл &2 не найден.", vss-workfile, v-file-source-arj ).
              end.
              run write-to-log in p-parent-handle ( substitute( "Файл &1 заархивирован в &2)", p-fullfile-name, v-file-source-arj ) ).
            end.
          end.
        end.
      end. /*if p-arch = true then do:*/
      else do:
        assign
        /* 23/VII-2019  сумма v-file-name-no-ext + "." + v-ext-name есть p-file-name,
                        из которого они были получены снаружи  
        v-file-source-arj = p-source-dir + {&back-slash-char} + v-file-name-no-ext + "." + v-ext-name
        v-file-temp       = p-temp-dir   + {&back-slash-char} + v-file-name-no-ext + "." + v-ext-name
        v-file-target     = p-target-dir + {&back-slash-char} + v-file-name-no-ext + "." + v-ext-name
        */
        v-file-source-arj = p-source-dir + {&back-slash-char} + p-file-name
        v-file-temp       = p-temp-dir   + {&back-slash-char} + p-file-name
        v-file-target     = p-target-dir + {&back-slash-char} + p-file-name
        .
        run write-to-log in p-parent-handle ( substitute( "Отправка файла &1 (copy)", p-fullfile-name ) ).
        assign
          v-file-source-arj = p-fullfile-name
        .
      end.
      run del-file ( input v-file-temp ) no-error .
      if error-status :error then do:
        return error return-value .
      end.
      if v-send-log then do:
        run del-file ( input v-log-file-temp ) no-error .
        if error-status :error then do:
          return error return-value .
        end.
      end.
      run write-to-log in p-parent-handle ( substitute( "Копирование файла &1 во временную папку &2)", v-file-source-arj, v-file-temp ) ).
      os-copy value( v-file-source-arj ) value( v-file-temp ).
      if os-error <> 0 then do:
        run adm/os-err.p ( output v-err-mess ).
        return error substitute( "&1. Невозможно скопировать файл &2 в каталог &3&4&5", vss-workfile, v-file-temp, p-target-dir, {&new-line}, v-err-mess ) .
      end.
      if v-send-log then do:
        os-copy value( v-log-file-source-arj ) value( v-log-file-temp ).
        if os-error <> 0 then do:
          run adm/os-err.p ( output v-err-mess ).
          return error substitute( "&1. Невозможно скопировать файл &2 в каталог &3&4&5", vss-workfile, v-log-file-temp, p-target-dir, {&new-line}, v-err-mess ) .
        end.
      end.
      if p-arch = true then do:
        run write-to-log in p-parent-handle ( substitute( "Удаление файла &1)", v-file-source-arj ) ).
        run del-file ( input v-file-source-arj ) no-error .
        if error-status :error then do:
          return error return-value .
        end.
        if v-send-log then do:
          run del-file ( input v-log-file-source-arj ) no-error .
          if error-status :error then do:
            return error return-value .
          end.
        end.
        if p-delivery-method = integer({&esys-dm-erp-1C-RN})
        then do :
          /* Проверим, что созданный архив валиден */
          v-unzip-command = substitute("&1 -extract -silent -nofix -over=all &2 &3":U
                                      , search('exe/pkzipc.exe':U)
                                      , v-file-temp
                                      , p-temp-dir
                                      ) .
          os-command silent value( v-unzip-command ) .

          if searchfile(p-temp-dir + {&back-slash-char} + p-file-name-no-ext + ".xml":U) = ?
          then do :
            find first buf_esys-pck-sent exclusive-lock where
                      buf_esys-pck-sent.esys-id = p-esys-id
                  and buf_esys-pck-sent.db-num = p-db-num
                  and buf_esys-pck-sent.esps-cr-db-num = p-cr-db-num
                  and buf_esys-pck-sent.esps-pack-num = p-pck-num.
            assign
              buf_esys-pck-sent.esps-SendTxtDate = ?
              buf_esys-pck-sent.esps-sendtxttime = ""
              buf_esys-pck-sent.esps-sendtxttimeint = 0
              buf_esys-pck-sent.esps-crenum = buf_esys-pck-sent.esps-crenum - 1
              buf_esys-pck-sent.esps-total-recs = 0
            .
            run del-file ( input v-file-temp ) no-error .
            if error-status :error then do:
              return error return-value .
            end.
            run write-to-log in p-parent-handle (  substitute( "&1. Невозможно разархивировать созданный файл &2 . Ошибка архивации", vss-workfile, v-file-temp ) ).
            return . /* Не возвращаем ошибку, чтобы не было undo и в записи buf_esys-pck-sent.esps-SendTxtDate = ? сохранилось, чтобы при следующем сеансе пакет заново формировался */
          end .
          else do :
            run del-file ( input searchfile(p-temp-dir + {&back-slash-char} + p-file-name-no-ext + ".xml":U) ) no-error .
            if error-status :error then do:
              return error return-value .
            end.
            if p-cert-enabled
            then do :
              run del-file ( input searchfile(p-temp-dir + {&back-slash-char} + p-file-name-no-ext + ".p7s":U) ) no-error .
            end .
          end .
        end .
      end.

      run write-to-log in p-parent-handle ( substitute( "Перенос файла из временной папки &1 в &2)", v-file-temp, v-file-target ) ).
      run ren-file ( input v-file-temp
                    ,input v-file-target
                   ) no-error .
      if error-status :error then do:
        assign
          v-err-mess = return-value
        .
        run del-file ( input v-file-temp ) no-error .
        if error-status :error then do:
          assign
            v-err-mess = v-err-mess + {&new-line} + return-value
          .
        end.
        return error v-err-mess .
      end.
      if v-send-log then do:
        run ren-file ( input v-log-file-temp
                      ,input v-log-file-target
                    ) no-error .
        if error-status :error then do:
          assign
            v-err-mess = return-value
          .
          run del-file ( input v-log-file-temp ) no-error .
          if error-status :error then do:
            assign
              v-err-mess = v-err-mess + {&new-line} + return-value
            .
          end.
          return error v-err-mess .
        end.
      end.
      if p-action = "put"
      and (  p-delivery-method = integer({&esys-dm-nn})
          OR p-delivery-method = integer({&esys-dm-nnold})
          OR p-delivery-method = integer({&esys-dm-exite-edi})
          OR p-delivery-method = integer({&esys-dm-contour-edi})
          )
      then do:
        run ext-system-attr-value in this-procedure ( input p-esys-id
                                                     ,input p-db-num
                                                     ,input {&attr-esys-ftp-ip}
                                                     ,output v-ftp-ip
                                                     ,output v-type) no-error.
        run ext-system-attr-value in this-procedure ( input p-esys-id
                                                     ,input p-db-num
                                                     ,input {&attr-esys-ftp-login}
                                                     ,output v-ftp-login
                                                     ,output v-type) no-error.
        run ext-system-attr-value in this-procedure ( input p-esys-id
                                                     ,input p-db-num
                                                     ,input {&attr-esys-ftp-password}
                                                     ,output v-ftp-password
                                                     ,output v-type) no-error.
        run ext-system-attr-value in this-procedure ( input p-esys-id
                                                     ,input p-db-num
                                                     ,input {&attr-esys-ftp-path}
                                                     ,output v-ftp-path
                                                     ,output v-type) no-error.
        if p-delivery-method = integer({&esys-dm-exite-edi}) or p-delivery-method = integer({&esys-dm-contour-edi}) then do:
          run ext-system-attr-value in this-procedure ( input p-esys-id
                                                        ,input p-db-num
                                                        ,input {&attr-esys-ftp-path-in}
                                                        ,output v-ftp-path-in
                                                        ,output v-type) no-error.
          run ext-system-attr-value in this-procedure ( input p-esys-id
                                                        ,input p-db-num
                                                        ,input {&attr-esys-ftp-path-out}
                                                        ,output v-ftp-path-out
                                                        ,output v-type) no-error.
          v-flags = string({&INTERNET_FLAG_PASSIVE}).
        end.
        else do:
          v-ftp-path-in = "in".
          v-ftp-path-out = "out".
          v-flags = string(0).
        end.
       run get-log-file-name in p-parent-handle ( output log-file-name) no-error.
        assign
        v-parameter = v-ftp-ip + {&delim-par} +
                      v-ftp-login + {&delim-par} +
                      v-ftp-password + {&delim-par} +
                      v-flags + {&delim-par} + /*flags*/
                      (if v-ftp-path <> ''
                      then (trim (trim (trim(v-ftp-path
                                      , {&back-slash-char})
                                  ,{&slash-char})
                            ,{&back-slash-char}) + {&slash-char})
                      else '') +
                      v-ftp-path-out + {&slash-char} + p-file-name  + {&delim-par} +
                      p-target-dir + {&slash-char} + p-file-name + {&delim-par} +
                      string(no) + {&delim-par} +
                      log-file-name
        .
        run gbl/ftp-put.p ( input parparentproc
                          ,input this-procedure:handle
                          ,input p-log-handle
                          ,input v-parameter ) no-error.
        if error-status:error then do:
           run write-to-log in p-parent-handle ( input  substitute("Ошибки при передаче файла &1 по FTP"
                                                                  , p-file-name
                                                                  )).
        end.
        else do:
          if p-delivery-method <> integer({&esys-dm-exite-edi}) and p-delivery-method <> integer({&esys-dm-contour-edi}) then do:
          run cur-time in this-procedure ( output v-today, output v-time).
          find first buf_esys-pck-sent exclusive-lock where
                    buf_esys-pck-sent.esys-id = p-esys-id
                and buf_esys-pck-sent.db-num = p-db-num
                and buf_esys-pck-sent.esps-cr-db-num = p-cr-db-num
                and buf_esys-pck-sent.esps-pack-num = p-pck-num.
          assign
          buf_esys-pck-sent.esps-rcvd = yes
          buf_esys-pck-sent.esps-RcvdTimeInt    = v-time
          buf_esys-pck-sent.esps-RcvdTime       = string( v-time, "HH:MM:SS" )
          buf_esys-pck-sent.esps-rcvddate       = v-today
          .
        end.
        end.
        run del-file ( input v-file-target ) no-error .
        if error-status :error then do:
          return error return-value .
        end.
      end.
    end. /*if p-action = "put":U then do:*/
    if p-action = "get"
    or p-action = "fget"
    then do:

        
      /* 11/I-2019  для импорта из 1с распаковка файлов выполняется без копирования архива */
      if p-delivery-method = integer({&esys-dm-erp-1C-RN}) then do:
        if v-arch then do:
          if not availfile(p-fullfile-name)
          then do:
            run write-to-log in p-parent-handle ( substitute("Файл &1 не найден или пустой! Пропускаем..."
                                                            , p-fullfile-name)  ) .
          end .
          else do :
            if lookup( p-file-ext, "zip") <> 0 then v-unzip-command =
              substitute("&1 -extract -silent -nofix -over=all &2 &3":U
                        , v-arh-name
                        , p-fullfile-name
                        , p-target-dir
                        ) .
            else
            if lookup( p-file-ext, "arj") <> 0 then v-unzip-command =
              substitute("&1 e -y &2 &3":U
                        , v-arh-name
                        , p-fullfile-name
                        , p-target-dir
                        ) .
            run write-to-log in p-parent-handle ( substitute("Команда на распаковку &1: &2"
                                                            , p-file-ext, v-unzip-command)  ) .
            os-command silent value( v-unzip-command ) .
  
            if os-error <> 0 and log-manager:logfile-name ne ?
            then do:
                log-manager:write-message("Ошибка при распаковке os-error: " + string(os-error) , "!sxg-pack!"). 
            end.
            if searchfile(p-target-dir + {&back-slash-char} + p-file-name-no-ext + ".xml":U) = ?
            then do :
              run write-to-log in p-parent-handle ( substitute("Ошибка при распаковке! Файл &1 не является архивом, либо архив битый. Пропускаем..."
                                                            , p-fullfile-name)  ) .
            end .
            else do :
              /* @FUTU обосновать, что удаление архива произойдёт только после удачной распаковки */
              run del-file ( input p-fullfile-name ) no-error .
              if error-status :error then do:
                return error return-value .
              end.
            end .
          end.
        end. /*if v-arch then do:*/
        else do :
          run del-file ( input v-file-target ) no-error .
          if error-status :error then do:
            return error return-value .
          end.
        
          run ren-file ( input p-fullfile-name, input v-file-target ) no-error .
          if error-status :error then do:
            return error return-value .
          end.
        end .
      end . /* end_of распаковка файлов без копирования */
      else do :
        run ren-file ( input p-fullfile-name, input v-file-temp ) no-error .
        if error-status :error then do:
          return error return-value .
        end.
              
        run del-file ( input v-file-target ) no-error .
        if error-status :error then do:
          return error return-value .
        end.
        
        os-copy value( v-file-temp ) value( v-file-target ).
        if os-error <> 0 then do:
          run adm/os-err.p ( output v-err-mess ).
          return error substitute( "&1. Невозможно скопировать файл &2 в каталог &3&4&5", vss-workfile, v-file-temp, p-target-dir, {&new-line}, v-err-mess ).
        end.
        
        run del-file ( input v-file-temp ) no-error .
        if error-status :error then do:
          return error return-value .
        end.

        if v-arch then do:
        if lookup( p-file-ext, "zip") <> 0 then do:
          v-unzip-command = substitute("&1 -extract -silent -nofix -over=all &2 &3":U
                                      , v-arh-name
                                      , v-file-target
                                      , p-target-dir
                                      ) .
        end.
        else
        if lookup( p-file-ext, "arj") <> 0 then do:
          v-unzip-command = substitute("&1 e -y &2 &3":U
                                      , v-arh-name
                                      , v-file-target
                                      , p-target-dir
                                      ) .
        end.
          run write-to-log in p-parent-handle (  substitute("Команда на распаковку &1: &2", p-file-ext, v-unzip-command)  ) .
          os-command silent value( v-unzip-command ) .
        
          run del-file ( input v-file-target ) no-error .
          if error-status :error then do:
            return error return-value .
          end.
      end. /*if v-arch then do:*/

      end . /* end_of распаковка файлов с копированием */
          
    end. /*else put*/
  end. /*doe*/
end procedure. /* file */

procedure del-file :
  define input parameter p-del-file-name as character no-undo .
  do
  on error undo, return error
  :
    define variable v-ind      as integer   no-undo .
    define variable v-err-code as integer   no-undo .
    define variable v-err-mess as character no-undo .
    define variable v-str      as character no-undo .

    assign
      file-info:file-name = p-del-file-name
    .
    if file-info:file-type <> ? then do:
      if file-info:file-type begins "F":U then do:
        assign
          v-str = "файл"
        .
      end.
      else do:
        if file-info:file-type begins "D":U then do:
          assign
            v-str = "каталог"
          .
        end.
        else do:
          assign
            v-str = "не знаю что"
          .
        end.
      end.

      bl1:
      do v-ind = 1 to 60 :
        os-delete value( p-del-file-name ).
        assign
          v-err-code = os-error
          file-info:file-name = p-del-file-name
        .
        if v-err-code = 0
          or file-info:file-type = ?
        then do:
          leave bl1 .
        end.
        pause 1 no-message .
      end.
      if os-error <> 0 then do:
        run adm/os-err.p ( output v-err-mess ).
        return error substitute( "&1. Невозможно удалить &2 &3&4&5", vss-workfile, v-str, p-del-file-name, {&new-line}, v-err-mess ).
      end.
    end.
  end.
  return.
end procedure. /* del-file */

procedure ren-file :
  define input parameter p-file-source as character no-undo .
  define input parameter p-file-target as character no-undo .
  do
  on error undo, return error
  :
    define variable v-ind      as integer   no-undo .
    define variable v-err-code as integer   no-undo .
    define variable v-err-mess as character no-undo .

    run del-file ( input p-file-target ) no-error .
    if error-status :error then do:
      return error return-value .
    end.

    bl1:
    do v-ind = 1 to 60 :
      os-rename value( p-file-source ) value( p-file-target ).
      assign
        v-err-code = os-error
        file-info:file-name = p-file-source
      .
      if v-err-code = 0
        or file-info:file-type = ?
      then do:
        leave bl1 .
      end.
      pause 1 no-message .
    end.

    if v-err-code <> 0 then do:
      run adm/os-err.p ( output v-err-mess ).
      return error substitute( "&1. Невозможно переименовать файл &2 в &3&4&5", vss-workfile, p-file-source, p-file-target, {&new-line}, v-err-mess ).
    end.
  end.
end procedure. /* ren-file */

procedure cb_getnextfilename :
define input-output parameter p-rfile-name as character no-undo .
define input-output parameter p-lfile-name as character no-undo .

define buffer buf_temp-filelist for temp-filelist.

do
on error undo, return error
:
  find first buf_temp-filelist where
            buf_temp-filelist.full-name > p-rfile-name no-error .
  if available buf_temp-filelist then do:
    assign
    p-rfile-name = buf_temp-filelist.full-name
    p-lfile-name =  p0-source-dir + {&slash-char} + buf_temp-filelist.file-name
    .
  end.
  else do:
    assign
    p-rfile-name = ''
    p-lfile-name = ''
    .
  end.
end.

end procedure. /* cb_getnextfilename */


/* $Workfile: sxg-pack.p $ end */