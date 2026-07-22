/* экспорт в 1С чеков открытия и закрытия смены */
{cmp\str-glbl.i}
{cmp\library.i}
{gbl\objsrv.i}
{str\trdcalib.i}

procedure proc-exp-1s: 

FIND FIRST ub.chk-doc-attr WHERE ub.chk-doc-attr.attr-code  = "CHFlag1S" 
                             and ub.chk-doc-attr.attr-value = "no" 
                             NO-ERROR. 
IF AVAILABLE ub.chk-doc-attr THEN DO:

      FIND FIRST chk-doc WHERE ub.chk-doc-attr.doc-code = chk-doc.doc-code NO-ERROR.
      IF AVAILABLE chk-doc THEN DO:

           { gbl/rum-runa.i
           parparentproc
           this-procedure:handle
           p-log-handle
           {&edoc-proc_event_shift}
           " buffer chk-doc:handle"
           " buffer chk-doc:handle"
           ''
           ''
           no-error
           } 

          if error-status:error then  do :
            message " Ошибка выгрузки чеков в 1С " skip return-value skip error-status:get-message(1) view-as alert-box.
          end.
     END.
END. 

end procedure. 



