block-level on error undo, throw.
/*

$Revision: f9f9d1396dd0, 1038, rls $
$Author: SSlivenko $
$Date: Fri Oct 06 18:30:18 2017 +0300 $
$Workfile: del-doc.p $
$Archive: str/del-doc.p $

Удаление документов + вывод информации о ходе процесса

Автор: Чернова Светлана Александровна
Дата создания: 10/10/06
Author: Svetlana Chernova
Creation date: 10/10/06

create: Суслов Алексей Юрьевич


*/

/* Parameter Definitions ---                                            */
define  input parameter parparentproc      as   widget-handle                no-undo.
define  input parameter pardoc-code        like ub.trn-doc.doc-code          no-undo.
define  input parameter pardb-num          like ub.db.db-num                 no-undo.
define  input parameter parfilename        as   character                    no-undo.
define  input parameter parcorr-inkas-code like ub.c-trn-doc.corr-inkas-code no-undo.
define  input parameter parcorr-fbr-code   like ub.c-trn-doc.corr-fbr-code   no-undo.
define  input parameter paruserid          as   character                    no-undo.
define  input parameter parphdoc-code      like ub.trn-doc.doc-code          no-undo.
define  input parameter parphchip-num      as   integer                      no-undo.
define output parameter parchip-num        as   integer                      no-undo.

/* VSS Variable Definitions ---                                         */
define variable vss-revision    as character no-undo initial "$Revision: f9f9d1396dd0, 1038, rls $":U.
define variable vss-author      as character no-undo initial "$Author: SSlivenko $":U.
define variable vss-date        as character no-undo initial "$Date: Fri Oct 06 18:30:18 2017 +0300 $":U.
define variable vss-workfile    as character no-undo initial "$Workfile: del-doc.p $":U.
define variable vss-archive     as character no-undo initial "$Archive: str/del-doc.p $":U.
define variable vss-description as character no-undo initial "Удаление документов + вывод информации о ходе процесса":U.

/* Global, Shared, Preprocessor Definitions ---                         */
{ cmp/vssrevis.i           }
{ cmp/trg-def.i            }
{ str/lib-trn.i            }
{ gbl/waitfram.i noprocess }
define variable v-vid-action as integer  no-undo .
define variable v-vid-param  as longchar no-undo .
{ str/initiator.i }
define variable varshift-date as date      no-undo.
define variable varshift-num  as integer   no-undo.
define variable varshift-name as character no-undo.
define variable v-mess        as character no-undo.
define variable v-boss        as character no-undo.
define variable v-contr       as character no-undo.
define variable v-status      as character no-undo.
define variable v-flag        as logical   no-undo.

find first ub.trn-doc no-lock where ub.trn-doc.doc-code = pardoc-code no-error.

if ub.trn-doc.status_ = {&fact}
then do:

  v-vid-action = 59.
  
  find first ub.clients no-lock where ub.clients.obj-type = {&prs} and ub.clients.obj-code = ub.trn-doc.boss no-error.
  v-boss = if available (ub.clients) then ub.clients.obj-name else "".
  v-contr = ub.trn-doc.cli-name.  
  
  { gbl/curshift.i
    ub.trn-doc.obj-type
    ub.trn-doc.obj-code
    varshift-date
    varshift-num
    varshift-name
    no-error
  }
  
end.

&scop proc-name lib-trn_del-doc
{&run_proc_lib-trn}
  (
     input parparentproc
  ,  input pardoc-code
  ,  input pardb-num
  ,  input parfilename
  ,  input parcorr-inkas-code
  ,  input parcorr-fbr-code
  ,  input paruserid
  ,  input parphdoc-code
  ,  input parphchip-num
  , output parchip-num
  ,  input this-procedure
  ) no-error.
  if error-status :error then do:

    if ub.trn-doc.status_ = {&fact}
    then do:
      v-mess = return-value.
      v-vid-param = "Initiator=" + "User" + {&delim-par} +
                    "ResponsiblePerson=" + v-boss + {&delim-par} +
                    "SHOP_NUM=" + string(ub.trn-doc.obj-code) + {&delim-par} +
                    "Contractor=" + v-contr + {&delim-par} +
                    "DocNum=" + string(ub.trn-doc.doc-code) + {&delim-par} +
                    "FactDate=" + (if string(ub.trn-doc.fact-date) = ? then '' else string(ub.trn-doc.fact-date)) + {&delim-par} +
                    "DocType=" + string(ub.trn-doc.doc-type) + {&delim-par} +
                    "SHIFT_NUM_DOC=" + (if string(ub.trn-doc.shift-num) = ? then '' else string(ub.trn-doc.shift-num)) + (if string(ub.trn-doc.shift-date) = ? then '' else string(ub.trn-doc.shift-date, "99999999")) + {&delim-par} +
                    "SHIFT_NUM=" + (if string(varshift-num) = ? then '' else string(varshift-num)) + (if string(varshift-date) = ? then '' else string(varshift-date, "99999999")) + {&delim-par} +
                    "Status=" + string(ub.trn-doc.status_) + (if ub.trn-doc.flag then "+" else "-" ) + {&delim-par} +
                    "RESULT=" + string( 1 ) + {&delim-par} + 
                    "Description=" + v-mess no-error.
    
      run trg/userlog.p (
            input {&nwsdochs_action_delete_err}
          , input {&table_trn-doc}
          , input ( buffer ub.trn-doc :handle )
          , input v-vid-action
          , input v-vid-param
      ) no-error.
    
    end.
    
    run waitfram-hide in this-procedure no-error.
    return error substitute( "&1 &2", v-mess, error-status :get-message( 1 ) ).
  end.

  find last ub.c-trn-doc no-lock where ub.c-trn-doc.doc-code = pardoc-code and ub.c-trn-doc.corr-user-db-num = pardb-num no-error.  
  if available (ub.c-trn-doc) and ub.c-trn-doc.status_ = {&fact}
  then do:
    v-vid-param = "Initiator=" + "User" + {&delim-par} +
                  "ResponsiblePerson=" + v-boss + {&delim-par} +
                  "SHOP_NUM=" + string(c-trn-doc.obj-code) + {&delim-par} +
                  "Contractor=" + v-contr + {&delim-par} +
                  "DocNum=" + string(c-trn-doc.doc-code) + {&delim-par} +
                  "FactDate=" + (if string(c-trn-doc.fact-date) = ? then '' else string(c-trn-doc.fact-date)) + {&delim-par} +
                  "DocType=" + string(c-trn-doc.doc-type) + {&delim-par} +
                  "SHIFT_NUM_DOC=" + (if string(c-trn-doc.shift-num) = ? then '' else string(c-trn-doc.shift-num)) + (if string(c-trn-doc.shift-date) = ? then '' else string(c-trn-doc.shift-date, "99999999")) + {&delim-par} +
                  "SHIFT_NUM=" + (if string(varshift-num) = ? then '' else string(varshift-num)) + (if string(varshift-date) = ? then '' else string(varshift-date, "99999999")) + {&delim-par} +
                  "Status=" + string(c-trn-doc.status_) + (if c-trn-doc.flag then "+" else "-" ) + {&delim-par} +
                  "RESULT=" + string( 0 ) + {&delim-par} + 
                  "Description=" no-error.
  
    run trg/userlog.p (
          input {&nwsdochs_action_delete}
        , input {&table_c-trn-doc}
        , input ( buffer ub.c-trn-doc :handle )
        , input v-vid-action
        , input v-vid-param
    ) no-error.

  end.
    

  run waitfram-hide in this-procedure no-error.

/* $Workfile: del-doc.p $   E n d */