/*
	Teste das funções
*/

SELECT
complement ('ACGGCTATTTAGAC'),            /* = TGCCGATAAATCTG */
reverse ('ACGGCTATTTAGAC'),               /* = CAGATTTATCGGCA */
getGCcontent('ACGGCTATTTAGACT'),          /* = 6 */
transcript('ACGGCTATTTAGACT'),            /* = ACGGCUAUUUAGACU */
translation(2,'ACGGCTATTTAGACT'),         /* = RLFR */
searchORF(1,'ACGAUGCUAUUUAGAUAGCUG', 10)  /* = AUGCUAUUUAGAUAG */
