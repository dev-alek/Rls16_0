          assign 
                        v-group_qnty      = v-group_qnty +  tmp#bs.qnty
                        v-group_sumcost   = v-group_sumcost +  tmp#bs.sumcost 
                        v-group_sumsale   = v-group_sumsale +  tmp#bs.sumsale
                        v-group_kassaqnty = v-group_kassaqnty +  tmp#bs.kassaqnty
                        v-group_kassasale = v-group_kassasale +  tmp#bs.kassasale
                        v-group_kasscost  = v-group_kasscost +  tmp#bs.kassacost
                        v-effect = v-group_kassasale  -  v-group_kasscost
                        v-ostatok-end = v-ostatok-end + tmp#bs.rest_end
                        v-ostatok-start = v-ostatok-start + tmp#bs.rest_start
                         v-sumcost = v-sumcost + tmp#bs.sumcost_vn  
                        v-sumsale = v-sumsale + tmp#bs.sumsale_vn
v-qnty_vn = v-qnty_vn + tmp#bs.qnty_vn 
v-midcost = v-sumcost / v-qnty_vn
v-midsale = v-sumsale / v-qnty_vn
v-rub_nac = v-midsale - v-midcost
v-proc_nac = v-rub_nac / v-midcost * 100
.
/* = v-ostatok-end / (v-group_qnty / (x-date-end - x-date-start + 1 )                           */
/* = (ostatok_start_day + ostatok_end_day)  / 2 / v-group_qnty / (x-date-end - x-date-start + 1)*/
/*                                                                                              */
                 if x-tog-shift = no then 
    do: 
        assign
           v-period_rel = v-ostatok-end / (v-group_qnty / (x-date-end - x-date-start + 1 ) )
            v-turnday    = ((v-ostatok-start + v-ostatok-end) / 2) / (  v-group_qnty / (x-date-end - x-date-start + 1) ).
    end.
    else 
    do: 
        find last  shift-obj where shift-obj.obj-code = v-obj-code and   shift-obj.obj-type = v-obj-type  and shift-obj.shift-date = x-Date-Start and shift-obj.shift-num   >= x-Shift-Start no-lock no-error .
        if shift-obj.close-date = ?  then shift-obj.close-date = today.
        assign
                        
        v-period_rel = v-ostatok-end / ( v-group_qnty / ( shift-obj.close-date - x-date-start + 1 )  )
  v-turnday   = ((v-ostatok-start + v-ostatok-end) / 2) / ( v-group_qnty / ( shift-obj.close-date - x-date-start + 1) ).
    end.
                        .