select replace(
		replace(
			replace(
				replace(
                    replace(
                        replace(
                            replace(
                                replace(
                                    replace(
                                   		replace(
                                        	replace(lower(responsabile), 'arch.', ''), 
				                		'avvocato', ''),
			                		'avv,', ''),
		                		'avv.', ''),
		                		'il direttore del settore dott.', ''),
                    		'direttore settore entrate dott.', ''),
                		'dott.ssa', ''),
            		'dott.', ''),
        		'dr.ssa', ''),
    		'dr.',''),		
'ing.', ''

) as nominativo_responsabile

from openbo_landing.lt_incarichi_di_collaborazione;





Il Direttore Del Settore Dott.
Ing.
