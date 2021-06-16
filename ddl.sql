/*
	DDL do esquema físico
*/

/*
	Tabelas representando entidades do esquema conceitual
*/

DROP TABLE IF EXISTS taxonomy CASCADE;

CREATE TABLE taxonomy
(
	taxonomy_id numeric(10,0) PRIMARY KEY,
	name varchar(256),
	father numeric(10,0),
	tax_rank_id numeric(10,0),

	CONSTRAINT FK_taxonomy FOREIGN KEY (father) REFERENCES taxonomy(taxonomy_id)
);


DROP TABLE IF EXISTS protein CASCADE;

CREATE TABLE protein
(
	fiocruzid numeric(20,0) PRIMARY KEY,
	gbkid varchar(15),
	uniprotid varchar(10),
	length numeric(5,0),
	definition text,
	taxonomy_id numeric(10,0),

	CONSTRAINT FK_protein FOREIGN KEY (taxonomy_id) REFERENCES taxonomy(taxonomy_id)
);


DROP TABLE IF EXISTS orf_t CASCADE;

CREATE TABLE orf_t
(
	fiocruzid numeric(20,0) PRIMARY KEY,
	length numeric(5,0),
	taxonomy_id numeric(10,0),

	CONSTRAINT FK_orf_t FOREIGN KEY (taxonomy_id) REFERENCES taxonomy(taxonomy_id)
);


DROP TABLE IF EXISTS genomicsequence CASCADE;

CREATE TABLE genomicsequence
(
	gbkid varchar(20) PRIMARY KEY,
	gbkdefinition text,
	length numeric(10,0),
	mol_type varchar(32),
	status varchar(50),
	projectid numeric(10,0),
	seq_type varchar(30),
	gc_content numeric(2,0),
	taxonomy_id numeric(10,0),
	gbkdivision varchar(16),
	gi numeric(20,0)
);


DROP TABLE IF EXISTS cds CASCADE;

CREATE TABLE cds
(
	fiocruzid numeric(10,0),
	region varchar(255),
	gbkid varchar(20),
	geneid numeric(10,0)
);


DROP TABLE IF EXISTS gene CASCADE;

CREATE TABLE gene
(
	geneid numeric(10,0) PRIMARY KEY,
	transcriptid varchar(10),
	reg_start numeric(10,0),
	reg_stop numeric(10,0),
	strand char(1),
	index numeric(10,0),
	gc_content real
);


DROP TABLE IF EXISTS tax_rank CASCADE;

CREATE TABLE tax_rank
(
	tax_rank_id numeric(10,0) PRIMARY KEY,
	name varchar(50)
);


DROP TABLE IF EXISTS synonymous CASCADE;

CREATE TABLE synonymous
(
	taxonomy_id numeric(10,0),
	synonimum varchar(256),

	CONSTRAINT PK_synonymous PRIMARY KEY (taxonomy_id, synonimum),
	CONSTRAINT FK_synonymous FOREIGN KEY (taxonomy_id) REFERENCES taxonomy(taxonomy_id)
);


DROP TABLE IF EXISTS domain CASCADE;

CREATE TABLE domain
(
	domain_id numeric(7,0) PRIMARY KEY,
	name varchar(30),
	source varchar(10)
);


DROP TABLE IF EXISTS gene_ontology CASCADE;

CREATE TABLE gene_ontology
(
	gene_ontology_id numeric(8,0) PRIMARY KEY,
	name varchar(100),
	definition varchar(255)
);


DROP TABLE IF EXISTS enzyme CASCADE;

CREATE TABLE enzyme
(
	ec_id varchar(10) PRIMARY KEY,
	name varchar(150),
	description varchar(255),
	father varchar(10),

	CONSTRAINT PK_enzyme FOREIGN KEY (father) REFERENCES enzyme(ec_id)
);


DROP TABLE IF EXISTS relationship CASCADE;

CREATE TABLE relationship
(
	relationship_id numeric(5,0) PRIMARY KEY,
	relationship_type numeric(1,0),
	gene_ontology_id numeric(8,0),
	chi_gene_ontology_id numeric(8,0),

	CONSTRAINT PK_relationship FOREIGN KEY (chi_gene_ontology_id) REFERENCES gene_ontology(gene_ontology_id)
);


DROP TABLE IF EXISTS goannotation CASCADE;

CREATE TABLE goannotation
(
	gene_ontology_id numeric(8,0),
	fiocruzid numeric(20,0),
	sou_name varchar(20),
	sou_version varchar(10),

	CONSTRAINT PK_goannotation PRIMARY KEY (gene_ontology_id, fiocruzid),
	CONSTRAINT FK_goannotation FOREIGN KEY (gene_ontology_id) REFERENCES gene_ontology(gene_ontology_id)
);


DROP TABLE IF EXISTS domainannotation CASCADE;

CREATE TABLE domainannotation
(
	domain_id numeric(7,0),
	fiocruzid numeric(20,0),
	position varchar(15),
	sou_name varchar(20),
	sou_version varchar(10),
	/*position varchar(15),*/
	score numeric(5,0),

	CONSTRAINT PK_domainannotation PRIMARY KEY (domain_id, fiocruzid, position),
	CONSTRAINT FK_domainannotation FOREIGN KEY (domain_id) REFERENCES domain(domain_id)
);


DROP TABLE IF EXISTS enzymeannotation CASCADE;

CREATE TABLE enzymeannotation
(
	ec_id varchar(10),
	fiocruzid numeric(20,0),
	sou_name varchar(20),
	sou_version varchar(10),

	CONSTRAINT PK_enzymeannotation PRIMARY KEY (ec_id, fiocruzid)
);



/*
	Tabelas intermediárias geradas por causa de relacionamentos com cardinalidade (0,n)
*/

/*
	Relação entre tORFs
*/

DROP TABLE IF EXISTS hits_oo CASCADE;

CREATE TABLE hits_oo
(
	query_fiocruzid numeric(20,0),
	subject_fiocruzid numeric(20,0),
	sw_score numeric(5,0),
	bit_score numeric(8,0),
	e_value numeric(8,0),
	identity numeric(4,0),
	alignment_length numeric(5,0),
	query_start numeric(5,0),
	query_end numeric(5,0),
	subject_start numeric(5,0),
	subject_end numeric(5,0),
	query_gaps numeric(4,0),
	subject_gaps numeric(4,0),

	FOREIGN KEY (query_fiocruzid) REFERENCES orf_t(fiocruzid),
	FOREIGN KEY (subject_fiocruzid) REFERENCES orf_t(fiocruzid),

	CONSTRAINT PK_hits_oo PRIMARY KEY(query_fiocruzid, subject_fiocruzid)
);


/*
	Relação entre proteínas
*/

DROP TABLE IF EXISTS hits_pp CASCADE;

CREATE TABLE hits_pp
(
	query_fiocruzid numeric(20,0),
	subject_fiocruzid numeric(20,0),
	e_value double precision,
	sw_score numeric(8,0),
	bit_score numeric(9,1),
	identity numeric(6,5),
	alignment_length numeric(8,0),
	query_start numeric(8,0),
	query_end numeric(8,0),
	subject_start numeric(8,0),
	subject_end numeric(8,0),
	query_gaps numeric(7,0),
	subject_gaps numeric(7,0),

	FOREIGN KEY (query_fiocruzid) REFERENCES protein(fiocruzid),
	FOREIGN KEY (subject_fiocruzid) REFERENCES protein(fiocruzid),

	CONSTRAINT PK_hits_pp PRIMARY KEY(query_fiocruzid, subject_fiocruzid)
);


/*
	Relação entre tORFs e proteínas
*/

DROP TABLE IF EXISTS hits_op CASCADE;

CREATE TABLE hits_op
(
	query_fiocruzid numeric(20,0),
	subject_fiocruzid numeric(20,0),
	sw_score numeric(5,0),
	bit_score numeric(8,0),
	e_value numeric(8,0),
	identity numeric(4,0),
	alignment_length numeric(5,0),
	query_start numeric(5,0),
	query_end numeric(5,0),
	subject_start numeric(5,0),
	subject_end numeric(5,0),
	query_gaps numeric(4,0),
	subject_gaps numeric(4,0),

	FOREIGN KEY (query_fiocruzid) REFERENCES orf_t(fiocruzid),
	FOREIGN KEY (subject_fiocruzid) REFERENCES protein(fiocruzid),

	CONSTRAINT PK_hits_op PRIMARY KEY(query_fiocruzid, subject_fiocruzid)
);


/*
	Tabela contendo a tradução do código genético
*/

DROP TABLE IF EXISTS code CASCADE;

CREATE TABLE code
(
	triplet char(3) PRIMARY KEY,
	aa char(1)
);

