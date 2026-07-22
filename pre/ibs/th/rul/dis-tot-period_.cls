block-level on error undo, throw.
class Ibs.Th.Rul.Dis-tot-period_ inherits Ibs.Th.Rul.Dis-tot_:
    define variable vss-include-info0 as character format "x(65)" no-undo initial "@(#)$Workfile: dis-tot-period_.cls $ $Revision: aea5316774be, 0, rls $".
  CONSTRUCTOR PUBLIC dis-tot-period_(
                               input parparentproc as widget-handle
                              ,input p-parent-handle as handle
                              ,input p-log-handle as handle
                              ,input p-gc-handle as handle
                              ,input p-cont-handle as handle
                              ,input p-lock as integer
                              ,input p-wait as integer
                              ,input p-temp as integer
                              ,input p-dtm-code as integer
                            ):
    super( p-parent-handle
          ,p-parent-handle
          ,p-log-handle
          ,p-gc-handle
          ,p-cont-handle
          ,p-lock
          ,p-wait
          ,p-temp).
    dtm-code = p-dtm-code.
  end constructor.
  method public logical find_dis-tot-period_ ( p-d-card as character
                                      , p-sum-id as character
                                          ):
     define variable glog as logical no-undo .
     define buffer buf_prop-ref for ub.prop-ref.
     find first buf_prop-ref no-lock where
                buf_prop-ref.dtm-code = dtm-code
            and buf_prop-ref.sum-id = p-sum-id no-error .
     if error-status:error then do:
        undo, return error substitute( "&1. Не найден Идентификатор итогов &2 в справочнике итогов&3"
                                       , vss-include-info0
                                       , p-sum-id
                                       , chr(10)
                                       ).
     end.
     dt-code = buf_prop-ref.dt-code.
     glog = super:find_dis-tot_ ( p-d-card ) no-error .
     if error-status:error then do:
       undo, return error return-value .
     end.
     return glog.
   end method.
  method public logical create_dis-tot-period_ ( input p-d-card as character
                                             ,input p-sum-id as character
                                             ):
     define variable glog as logical no-undo .
     define buffer buf_prop-ref for ub.prop-ref.
     find first buf_prop-ref no-lock where
                buf_prop-ref.dtm-code = dtm-code
            and buf_prop-ref.sum-id = p-sum-id no-error .
     if error-status:error then do:
        undo, return error substitute( "&1. Не найден Идентификатор итогов &2 в справочнике итогов&3"
                                       , vss-include-info0
                                       , p-sum-id
                                       , chr(10)
                                       ).
     end.
     dt-code = buf_prop-ref.dt-code.
     glog = super:create_dis-tot_ ( p-d-card ) no-error .
     if error-status:error then do:
       undo, return error return-value .
     end.
     return glog.
  end.
end class.
