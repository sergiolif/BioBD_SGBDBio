/*
	Funções do esquema físico
*/

/*
- Name: isDNA
- Input: sequence – nucleotide sequence
- Output: boolean – true or false
- Description: verify if sequence is a DNA sequence
*/

CREATE OR REPLACE FUNCTION isDNA(TEXT) RETURNS BOOLEAN AS
$$
	DECLARE
		original ALIAS FOR $1;
		dna BOOLEAN := TRUE;
		onechar VARCHAR;
		length INTEGER;
		mypos INTEGER := 1;
	BEGIN
		SELECT UPPER(original) INTO original;
		SELECT LENGTH(original) INTO length;
		LOOP
			EXIT WHEN ((mypos > length) OR dna = FALSE);
			SELECT substring(original FROM mypos FOR 1) INTO onechar;
			IF onechar <> 'A' AND onechar <> 'C' AND onechar <> 'G' AND onechar <> 'T' THEN
				dna := FALSE;
			END IF;
			mypos := mypos +1;
		END LOOP;
		RETURN dna;
	END
$$
LANGUAGE plpgsql IMMUTABLE RETURNS NULL ON NULL INPUT;


/*
- Name: complement
- Input: sequence – nucleotide sequence
- Output: sequence – nucleotide sequence
- Description: returns the complementary DNA strand
*/

CREATE OR REPLACE FUNCTION complement(TEXT) RETURNS TEXT AS
$$
	DECLARE
		original ALIAS FOR $1;
		complement TEXT := '';
		onechar VARCHAR;
		length INTEGER;
		mypos INTEGER := 1;
	BEGIN
		SELECT LENGTH(original) INTO length;
		LOOP
			EXIT WHEN mypos > length;
			SELECT substring(original FROM mypos FOR 1) INTO onechar;
			IF onechar = 'A' THEN
				onechar := 'T';
				ELSE IF onechar = 'C' THEN
					onechar := 'G';
					ELSE IF onechar = 'G' THEN
						onechar := 'C';
						ELSE IF onechar = 'T' THEN
							onechar := 'A';
						END IF;
					END IF;
				END IF;
			END IF;
			complement := complement || onechar;
			mypos := mypos +1;
		END LOOP;
		RETURN complement;
	END
$$
LANGUAGE plpgsql IMMUTABLE RETURNS NULL ON NULL INPUT;


/*
- Name: reverse
- Input: sequence – nucleotide sequence
- Output: sequence – nucleotide sequence
- Description: returns the reverse DNA strand (reading 3’ 5’
*/

CREATE OR REPLACE FUNCTION reverse(TEXT) RETURNS TEXT AS
$$
	DECLARE
		original ALIAS FOR $1;
		reversed TEXT := '\\';
		onechar VARCHAR;
		mypos INTEGER;
	BEGIN
		SELECT LENGTH(original) INTO mypos;
		LOOP
			EXIT WHEN mypos < 1;
			SELECT substring(original FROM mypos FOR 1) INTO onechar;
			reversed := reversed || onechar;
			mypos := mypos -1;
		END LOOP;
		RETURN reversed;
	END
$$
LANGUAGE plpgsql IMMUTABLE RETURNS NULL ON NULL INPUT;


/*
- Name: getGCcontent
- Input: sequence – nucleotide sequence
- Output: integer – amount of GC content
- Description: returns the amount of GC content of DNA sequence
*/

CREATE OR REPLACE FUNCTION getGCcontent(TEXT) RETURNS
INTEGER AS
$$
	DECLARE
		original ALIAS FOR $1;
		modify TEXT := '';
		length INTEGER;
	BEGIN
		SELECT REPLACE(original,'A','') INTO modify;
		SELECT REPLACE(modify,'T','') INTO modify;
		SELECT LENGTH(modify) INTO length;
		RETURN length;
	END
$$
LANGUAGE plpgsql IMMUTABLE RETURNS NULL ON NULL INPUT;


/*
- Name: transcript
- Input: sequence – nucleotide sequence (DNA)
- Output: sequence – nucleotide sequence (RNA)
- Description: returns the messenger RNA sequence
*/

CREATE OR REPLACE FUNCTION transcript(TEXT) RETURNS TEXT AS
$$
	DECLARE
		original ALIAS FOR $1;
		modify TEXT := '';
	BEGIN
		SELECT REPLACE(original,'T','U') INTO modify;
		RETURN modify;
	END
$$
LANGUAGE plpgsql IMMUTABLE RETURNS NULL ON NULL INPUT;


/*
- Name: translation
- Input: position – integer
		 sequence – nucleotide sequence (RNA)
- Output: sequence – amino acid sequence (Protein)
- Description: transforms a nucleotide sequence (RNA) in an amino acid
sequence (Protein).
*/

CREATE OR REPLACE FUNCTION translation(INTEGER,TEXT) RETURNS
TEXT AS
$$
	DECLARE
		pos ALIAS FOR $1;
		seq ALIAS FOR $2;
		tam INTEGER;
		subconvert RECORD;
		sub character varying(3);
		aminoacid TEXT := '';
	BEGIN
		SELECT TRANSCRIPT(seq) INTO seq;
		SELECT LENGTH(seq) INTO tam;
		LOOP
			EXIT WHEN pos+2 > tam;
			SELECT substring(seq FROM pos FOR 3) INTO sub;
			SELECT INTO subconvert * FROM code WHERE triplet = sub;
			aminoacid := aminoacid || subconvert.aa;
			pos := pos +3;
		END LOOP;
		RETURN aminoacid;
	END
$$
LANGUAGE plpgsql IMMUTABLE RETURNS NULL ON NULL INPUT;


/*
- Name: searchORF
- Input: position – integer
		 sequence – nucleotide sequence (RNA)
		 length - minimum size of ORF
- Output: sequence Collection – amino acid sequence (Protein)
- Description: search ORFs in a nucleotide sequence (RNA).
*/

CREATE OR REPLACE FUNCTION searchORF(INTEGER,TEXT,INTEGER)
RETURNS SETOF TEXT AS
$$
	DECLARE
		pos ALIAS FOR $1;
		seq ALIAS FOR $2;
		size ALIAS FOR $3;
		tam INTEGER;
		tamORF INTEGER;
		sub character varying(3);
		orf TEXT := '';
		found BOOLEAN := false;
	BEGIN
		SELECT TRANSCRIPT(seq) INTO seq;
		SELECT LENGTH(seq) INTO tam;
		LOOP
			EXIT WHEN pos+2 > tam;
			SELECT substring(seq FROM pos FOR 3) INTO sub;
			IF (sub = 'AUG') THEN
				found := true;
			END IF;
			IF (found) THEN
				orf := orf || sub;
			END IF;
			IF (sub = 'UAA' OR sub = 'UGA' OR sub = 'UAG') THEN
				found := false;
				SELECT LENGTH(orf) INTO tamORF;
				IF (tamORF >10) THEN
					RETURN QUERY SELECT orf;
				END IF;
				orf := '';
			END IF;
			pos := pos +3;
		END LOOP;
	END
$$
LANGUAGE plpgsql IMMUTABLE RETURNS NULL ON NULL INPUT;

/*
- Name: getTaxonomyIdChildren 
- Input: integer
- taxonomy_Id 
- Output: numeric collection 
- taxonomy_Id 
- Description: get taxonomy_Id children of a specific taxonomy_Id.
*/

CREATE OR REPLACE FUNCTION getTaxonomyIdChildren(INTEGER)
RETURNS SETOF NUMERIC AS
$$
WITH RECURSIVE path(id, parent_id) AS (
	 SELECT taxonomy_id, 
	 father FROM taxonomy t 
	 WHERE taxonomy_id = $1 
	 UNION 
	 SELECT t.taxonomy_id, t.father 
	 FROM taxonomy t, path as parentpath 
	 WHERE t.father = parentpath.id) 
SELECT id FROM path; 
$$ 
LANGUAGE "sql" IMMUTABLE;

/*
- Name: getTaxonomyIdChildrenSet 
- Input: integer 
- taxonomy_Id 
- Output: numeric collection 
- taxonomy_Id 
- Description: get taxonomy_Id children of a specific taxonomy_Id.
*/

CREATE OR REPLACE FUNCTION getTaxonomyIdChildrenSet (INTEGER)
RETURN SETOF NUMERIC AS
$$
	BEGIN
		RETURN QUERY select * from gettaxonomyidchildren($1);
	END
$$
LANGUAGE plpgsql IMMUTABLE RETURNS NULL ON NULL INPUT;

/*
- Name: getCountGenomeTaxonomy 
- Input: integer - taxonomy_Id 
- Output: bigint - amount of gbkid 
- Description: get the amount of gbkid belonging to a specific taxonomy_Id.
*/

CREATE OR REPLACE FUNCTION getCountGenomeTaxonomy (INTEGER)
RETURNS BIGINT AS
$$ 
SELECT count(*) FROM (
	 SELECT (gs.gbkid) FROM genomic_sequence gs 
	 WHERE gbkid like 'AC_%' and gs.taxonomy_id IN
	  (select * from gettaxonomyidchildrenset($1)) 
	UNION
	 SELECT (gs.gbkid) FROM genomic_sequence gs 
	 WHERE gbkid like 'NC_%' and gs.taxonomy_id IN
	  (select * from gettaxonomyidchildrenset($1)) 
) as t 
$$ 
LANGUAGE "sql" IMMUTABLE;

/*
- Name: getCountGenomeTaxonomy 
- Input: integer - taxonomy_Id 
- Output: bigint - amount of gbkid 
- Description: get the amount of gbkid belonging to a specific taxonomy_Id.
*/

CREATE OR REPLACE FUNCTION getCountGenomeTaxonomy (INTEGER) 
RETURNS BIGINT AS 
$$
SELECT count(*) FROM (
	 SELECT (gs.gbkid) FROM genomic_sequence gs 
	 WHERE gbkid like 'AC_%' and gs.taxonomy_id IN
	  (select * from gettaxonomyidchildrenset($1)) 
UNION
	 SELECT (gs.gbkid) FROM genomic_sequence gs 
	 WHERE gbkid like 'NC_%' and gs.taxonomy_id IN
	  (select * from gettaxonomyidchildrenset($1)) 
) as t 
$$ 
LANGUAGE "sql" IMMUTABLE;

/*
- Name: getCountProteinTaxonomy 
- Input: integer - taxonomy_Id 
- Output: bigint - amount of proteinid 
- Description: get the amount of proteinid belonging to a specific taxonomy_Id.
*/

CREATE OR REPLACE FUNCTION getCountProteinTaxonomy (INTEGER) 
RETURNS BIGINT AS 
$$ 
SELECT COUNT(p.proteinid) 
FROM protein p 
WHERE p.taxonomy_id IN 
(select * from gettaxonomyidchildrenset($1)); 
$$ 
LANGUAGE "sql" IMMUTABLE;

/*
- Name: getCountHitsProtein 
- Input: numeric - taxonomy_Id numeric - evalue 
- Output: integer - amount of hits 
- Description: gets the amount of hits in a protein given an e-value.
*/

CREATE OR REPLACE FUNCTION getCountHitsProtein (NUMERIC, DOUBLE PRECISION) 
RETURNS BIGINT AS 
$$ 
SELECT COUNT (*) FROM (
	 SELECT (hq.query_proteinid) FROM hits_pp hq 
	 WHERE hq.query_proteinid = $1 AND hq.e_value <= $2 
	 UNION ALL 
	 SELECT (hq.subject_proteinid) FROM hits_pp hq 
	 WHERE hq.subject_proteinid = $1 AND hq.e_value <= $2 
) as t; 
$$ 
LANGUAGE "sql" IMMUTABLE;

/*
- Name: getProteinTaxonomy 
- Input: integer - taxonomy_Id 
- Output: numeric collection - proteinid 
- Description: get the proteinid collection belonging to a specific taxonomy_Id.
*/

CREATE OR REPLACE FUNCTION getProteinTaxonomy (INTEGER) 
RETURNS SETOF NUMERIC AS 
$$ 
SELECT (p.proteinid) FROM protein p 
WHERE p.taxonomy_id IN 
(select * from gettaxonomyidchildrenset($1)); 
$$ 
LANGUAGE "sql" IMMUTABLE;

/*
- Name: getSimilarProtein 
- Input: integer - taxonomy_Id integer - taxonomy_Id 
- Output: numeric collection - proteinid 
- Description: get the similar proteinid collection belonging to a specific taxonomy_Id compared with other organism.
*/

CREATE OR REPLACE FUNCTION getSimilarProtein (INTEGER, INTEGER) 
RETURNS SETOF NUMERIC AS 
$$ 
DECLARE 
	org1 ALIAS FOR $1; 
	org2 ALIAS FOR $2; 
BEGIN
	RETURN QUERY 
		(SELECT query_proteinid FROM hits_pp
		 WHERE query_proteinid IN (
			  select * from explode_array(ARRAY(select * from 
			  getproteintaxonomy(org1)))) AND 
			  subject_proteinid IN (select * from 
			  explode_array(ARRAY(select * from 
			  getproteintaxonomy(org2))))) 
		 UNION
		  (SELECT subject_proteinid FROM hits_pp 
		  WHERE query_proteinid IN (
			   select * from explode_array(ARRAY(select * from 
			   getproteintaxonomy(org2)))) AND 
			   subject_proteinid IN (select * from 
			   explode_array(ARRAY(select * from 
			   getproteintaxonomy(org1))))); 
END 
$$ 
LANGUAGE plpgsql IMMUTABLE RETURNS NULL ON NULL INPUT;

/*
- Name: getSingleGene 
- Input: integer - taxonomy_Id 
- Output: numeric collection - proteinid 
- Description: gets single genes in a taxonomic group.
*/

CREATE OR REPLACE FUNCTION getSingleGene(INTEGER, INTEGER) 
RETURNS SETOF NUMERIC AS 
$$ 
DECLARE 
	org1 ALIAS FOR $1; 
	org2 ALIAS FOR $2; 
BEGIN 
	RETURN QUERY 
		(SELECT getproteintaxonomy (org1)) 
			EXCEPT 
		(SELECT getsimilarprotein(org1,org2)); 
END 
$$ 
LANGUAGE plpgsql IMMUTABLE RETURNS NULL ON NULL INPUT;

/*
- Name: getOrthologousGene 
- Input: integer - taxonomy_Id integer - taxonomy_Id 
- Output: numeric collection - proteinid 
- Description: get the orthologous genes to a specific taxonomy_Id.
*/

CREATE OR REPLACE FUNCTION getOrthologousGene (INTEGER, INTEGER) 
RETURNS SETOF NUMERIC AS 
$$ 
DECLARE 
	org1 ALIAS FOR $1; 
	org2 ALIAS FOR $2; 
BEGIN 
	RETURN QUERY 
		(SELECT subject_proteinid FROM hits_pp 
		WHERE query_proteinid IN ( 
			select * from explode_array(ARRAY(select * from 
			getproteintaxonomy(org1)))) AND 
			subject_proteinid IN (select * from 
			explode_array(ARRAY(select * from 
			getproteintaxonomy(org2))))) 
		UNION 
		(SELECT subject_proteinid , query_proteinid FROM hits_pp 
		WHERE query_proteinid IN ( 
			select * from explode_array(ARRAY(select * from 
			getproteintaxonomy(org2)))) AND 
			subject_proteinid IN (select * from 
			explode_array(ARRAY(select * from 
			getproteintaxonomy(org1))))); 
END 
$$ 
LANGUAGE plpgsql IMMUTABLE RETURNS NULL ON NULL INPUT;

/*
- Name: getParalogousGene 
 Input: integer - taxonomy_Id 
 - Output: numeric collection - proteinid 
 - Description: get the paralogous genes to a specific taxonomy_Id.
*/

CREATE OR REPLACE FUNCTION getParalogousGene(INTEGER) 
RETURNS SETOF NUMERIC AS 
$$ 
DECLARE 
	org ALIAS FOR $1; 
BEGIN 
	RETURN QUERY 
		(SELECT subject_proteinid FROM hits_pp 
		WHERE query_proteinid IN (select * from 
		explode_array(ARRAY(select * from 
		getproteintaxonomy(org)))) AND 
		subject_proteinid IN (select * from 
		explode_array(ARRAY(select * from 
		getproteintaxonomy(org))))); 
END 
$$ 
LANGUAGE plpgsql IMMUTABLE RETURNS NULL ON NULL INPUT;