block-level on error undo, throw.
/*

$Revision: aea5316774be, 0, rls $
$Author: expertek $
$Date: Mon Jan 27 18:27:46 2014 +0400 $
$Workfile: get-ibmf.p $
$Archive: str/get-ibmf.p $

Сканирование файлов с касс IBM, MARIA по директории in_ + spl

Автор: Бахтадзе Наталья Викторовна
Дата создания: 02/22/06
Author: Bakhtadze Natalya
Creation date: 02/22/06

*/


define input parameter parparentproc as widget-handle no-undo .
define input parameter p-log-handle  as handle no-undo .
define input parameter p-obj-type like ub.clients.obj-type no-undo .
define input parameter p-obj-code like ub.clients.obj-code no-undo .
define input parameter p-host-code like ub.sysconf.host-code no-undo .
define input parameter p-pos-type  like ub.cash-desk.pos-type no-undo .
define input parameter p-in_ as character no-undo .
define input parameter p-spl as character no-undo .
define input parameter p-sav   as character no-undo .
define input parameter p-other as character no-undo .
define input-output parameter p-view-log as logical no-undo init yes.


define variable vss-revision    as character no-undo init "$Revision: aea5316774be, 0, rls $":U .
define variable vss-author      as character no-undo init "$Author: expertek $":U .
define variable vss-date        as character no-undo init "$Date: Mon Jan 27 18:27:46 2014 +0400 $":U .
define variable vss-workfile    as character no-undo init "$Workfile: get-ibmf.p $":U .
define variable vss-archive     as character no-undo init "$Archive: str/get-ibmf.p $":U .
define variable vss-description as character no-undo init "Сканирование файлов с касс IBM, MARIA по директории in_ + spl".
{ cmp/vssrevis.i }
{ cmp/str-glbl.i }

{ str/get-chkf.i }
{ str/tekkatsk.i }

define variable log-file-name as character no-undo init "get-chkf.log".
define variable v-sav-prefix as character no-undo .
define variable v-secondary-subject as character no-undo .
define variable v-subject as character no-undo .
define variable v-file as character no-undo .
define variable v-dop as character no-undo .
define variable v-cash-num as integer no-undo .
define variable v-close-shift as logical no-undo .
define variable filename2 as character no-undo .

input stream DirStream from os-dir ( p-in_ + p-spl ) .
_repeat:
REPEAT :
  import stream DirStream file path atr.
  if ( substring( file, 1, 2 ) = "fl" ) AND
      can-do( "f", atr )  /* see "os-dir" help : f - Regular file or FIFO pipe */
  then do:
    run write-log-and-file in p-log-handle (
          input 1
        , input log-file-name
        , input 1
        , input substitute( "Обработка спул-файла &1"
                            , path
                          )
                                      ).
    CASE p-pos-type:
      when {&cd-type-maria} then do:
        assign
        v-subject = entry(2, file, '.')
        v-dop = entry(1, file, '.')
        v-cash-num = (if num-entries(v-dop, '-':U) < 2
                      then 0
                      else integer(entry(2, entry(1, v-dop, '_'), '-':U)))
        no-error .
        if error-status:error then do:
          NEXT _repeat.
        end.
        IF LOOKUP(STRING(INTEGER(V-SUBJECT)), {&spool-objects}) > 0 then do:
          if index(string(integer(v-subject)), {&secondary-objects}) > 0 then next _repeat.
          if tekka-is-closed-shift-journal ( input integer(v-subject) ) > 0 then do:
            assign
            v-close-shift = yes.
          end.
          else do:
            assign
            v-close-shift = no.
          end.
          if tekka-is-petrol-journal ( input integer(v-subject) ) then do:
            assign
            v-sav-prefix = 'p'.
          END.
          ELSE DO:
            assign
            v-sav-prefix = ''.
          END.
        end.
        else do:
          v-sav-prefix = ?.
        end.
        if v-sav-prefix <> ? then
        run str/get-mari.p
                      (input parparentproc
                      ,input p-log-handle
                      ,input p-obj-type
                      ,input p-obj-code
                      ,input p-host-code
                      ,input p-pos-type
                      ,input v-cash-num
                      ,input path
                      ,input v-close-shift
                      ,input p-other
                      ,input-output p-view-log
                      ) no-error .
      end.
      otherwise do:
        v-sav-prefix = '':U.
        run str/get-ibm.p
                      (input parparentproc
                      ,input p-log-handle
                      ,input p-obj-type
                      ,input p-obj-code
                      ,input p-host-code
                      ,input p-pos-type
                      ,input path
                      ,input-output p-view-log
                      ) no-error .
      end.
    END CASE.
    if error-status:error
    or return-value = 'error':U then do:
      if error-status:error then
      run write-log-and-file in p-log-handle (
            input 1
          , input log-file-name
          , input 1
          , input substitute( "!!!При обработке файла &1 произошла ошибка:&2&3 &4&2файл остается в директории &5 и считается необработанным"
                              , path
                              , {&new-line}
                              , error-status:get-message(1)
                              , return-value
                              , ( p-in_ + p-spl )
                            )
                                      ).
    end.
    else do:
      if v-sav-prefix = ? then do:
        v-file = p-sav + {&slash-char} + entry(1, file, '_') + '_' + entry(2, file, '.')  + '.html':U.
        os-rename value( path )
        value( v-file).
        run rep/killspac.p ( input-output v-file).
        run gbl/open_url.p ( v-file) no-error .
      end.
      else do:
        os-append value( path )
        value( p-sav + "\" + v-sav-prefix + string( day( today ), "99" ) + "_" +
                  string( month( today ), "99" ) + "_" +
                  string( year( today ) modulo 100, "99" ) + ".spl" ) .
        os-delete value( path ) .
        if index({&object-groups }, string(integer(v-subject)) + '-' ) > 0 then do:
          /*16- и '16-42,17-43,':U*/
          /*17- и '16-42,17-43,':U*/
          assign
          v-secondary-subject = substring({&object-groups}, index({&object-groups}, string(integer(v-subject)) + '-'))
          v-secondary-subject = entry(2, v-secondary-subject, '-')
          v-secondary-subject = entry(1, v-secondary-subject)
          .
          filename2 = replace( path, ('.' + v-subject), ('.' + v-secondary-subject)).
          os-append value( filename2 )
          value( p-sav + "\" + v-sav-prefix + string( day( today ), "99" ) + "_" +
                    string( month( today ), "99" ) + "_" +
                    string( year( today ) modulo 100, "99" ) + ".spl" ) .
          os-delete value( filename2 ) .
        end.
      end.
    end.
  end.
END .
input stream DirStream close.