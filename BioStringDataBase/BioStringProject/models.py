from django.db import models


class Taxonomy(models.Model):

    taxonomy_id = models.IntegerField(primary_key=True)
    name = models.TextField(max_length=256)
    father = models.ForeignKey('self', on_delete=models.CASCADE)
    tax_rank_id = models.IntegerField()

    def __str__(self):
        return self.name


class Protein(models.Model):

    proteinid = models.IntegerField()
    gbkid = models.TextField(max_length=15)
    uniprotid = models.TextField(max_length=20, primary_key=True)
    length = models.IntegerField()
    definition = models.TextField()
    taxonomy_id = models.ForeignKey(Taxonomy, on_delete=models.CASCADE)

    def __str__(self):
        return self.proteinid


class OrfT(models.Model):

    orftid = models.IntegerField(primary_key=True)
    length = models.IntegerField()
    taxonomy_id = models.ForeignKey(Taxonomy, on_delete=models.CASCADE)

    def __str__(self):
        return self.orftid


class GenomicSequence(models.Model):

    gbkid = models.TextField(max_length=20, primary_key=True)
    gbkdefinition = models.TextField()
    length = models.IntegerField()
    mol_type = models.TextField(max_length=32)
    status = models.TextField(max_length=50)
    projectid = models.IntegerField()
    seq_type = models.TextField(max_length=30)
    gc_content = models.IntegerField()
    taxonomy_id = models.IntegerField()
    gbkdivision = models.TextField(max_length=16)
    gi = models.IntegerField()

    def __str__(self):
        return self.gbkid


class Cds(models.Model):

    cdsid = models.IntegerField(primary_key=True)
    region = models.TextField(max_length=255)
    gbkid = models.TextField(max_length=20)
    geneid = models.IntegerField()

    def __str__(self):
        return self.cdsid


class Gene(models.Model):

    geneid = models.IntegerField(primary_key=True)
    transcriptid = models.TextField(max_length=10)
    reg_start = models.IntegerField()
    reg_stop = models.IntegerField()
    strand = models.CharField(max_length=1)
    index = models.IntegerField()
    gc_content = models.TextField(max_length=1)

    def __str__(self):
        return self.geneid


class TaxRank(models.Model):

    tax_rank_id = models.IntegerField(primary_key=True)
    name = models.TextField(max_length=50)

    def __str__(self):
        return self.name


class Synonymous(models.Model):

    taxonomy_id = models.ForeignKey(Taxonomy, primary_key=True, on_delete=models.CASCADE)
    synonimum = models.TextField(max_length=256)

    def __str__(self):
        return self.taxonomy_id


class Domain(models.Model):

    domain_id = models.IntegerField(primary_key=True)
    name = models.TextField(max_length=30)
    source = models.TextField(max_length=10)

    def __str__(self):
        return self.name


class GeneOntology(models.Model):

    gene_ontology_id = models.IntegerField(primary_key=True)
    name = models.TextField(max_length=100)
    defition = models.TextField(max_length=255)

    def __str__(self):
        return self.name


class Enzyme(models.Model):

    ec_id = models.TextField(max_length=10, primary_key=True)
    name = models.TextField(max_length=150)
    description = models.TextField(max_length=255)
    father = models.ForeignKey('self', max_length=10, on_delete=models.CASCADE)

    def __str__(self):
        return self.name


class Relationship(models.Model):

    relationship_id = models.IntegerField(primary_key=True)
    relationship_type = models.IntegerField()
    gene_ontology_id = models.IntegerField()
    chi_gene_ontology_id = models.ForeignKey(GeneOntology, on_delete=models.CASCADE)

    def __str__(self):
        return self.relationship_id


class GoAnnotation(models.Model):

    gene_ontology_id = models.ForeignKey(GeneOntology, primary_key=True, on_delete=models.CASCADE)
    goannotationid = models.IntegerField()
    sou_name = models.TextField(max_length=20)
    sou_version = models.TextField(max_length=10)

    def __str__(self):
        return self.goannotationid


class DomainAnnotation(models.Model):

    domain_id = models.ForeignKey(Domain, max_length=7, primary_key=True, on_delete=models.CASCADE)
    domainannotationid = models.IntegerField()
    position = models.TextField(max_length=15)
    sou_name = models.TextField(max_length=20)
    sou_version = models.TextField(max_length=10)
    score = models.IntegerField()

    def __str__(self):
        return self.domainannotationid


class EnzymeAnnotation(models.Model):

    ec_id = models.TextField(max_length=10, primary_key=True)
    enzymeannotationid = models.IntegerField()
    sou_name = models.TextField(max_length=20)
    sou_version = models.TextField(max_length=10)

    def __str__(self):
        return self.enzymeannotationid


class HitsOO:

    query_orftid = models.ForeignKey(OrfT, primary_key=True, on_delete=models.CASCADE)
    subject_orftid = models.ForeignKey(OrfT, on_delete=models.CASCADE)
    sw_score = models.IntegerField()
    bit_score = models.IntegerField()
    e_value = models.IntegerField()
    identity = models.IntegerField()
    alignment_length = models.IntegerField()
    query_start = models.IntegerField()
    query_end = models.IntegerField()
    subject_start = models.IntegerField()
    subject_end = models.IntegerField()
    query_gaps = models.IntegerField()
    subject_gaps = models.IntegerField()

    def __str__(self):
        return self.query_orftid


class HitsPP:

    query_proteinid = models.ForeignKey(Protein, primary_key=True, on_delete=models.CASCADE)
    subject_proteinid = models.ForeignKey(Protein, on_delete=models.CASCADE)
    e_value = models.IntegerField()
    sw_score = models.IntegerField()
    bit_score = models.IntegerField()
    identity = models.IntegerField()
    alignment_length = models.IntegerField()
    query_start = models.IntegerField()
    query_end = models.IntegerField()
    subject_start = models.IntegerField()
    subject_end = models.IntegerField()
    query_gaps = models.IntegerField()
    subject_gaps = models.IntegerField()

    def __str__(self):
        return self.query_proteinid


class HitsOP:

    query_orftid = models.ForeignKey(OrfT, primary_key=True, on_delete=models.CASCADE)
    subject_proteinid = models.ForeignKey(Protein, on_delete=models.CASCADE)
    sw_score = models.IntegerField()
    bit_score = models.IntegerField()
    e_value = models.IntegerField()
    identity = models.IntegerField()
    alignment_length = models.IntegerField()
    query_start = models.IntegerField()
    query_end = models.IntegerField()
    subject_start = models.IntegerField()
    subject_end = models.IntegerField()
    query_gaps = models.IntegerField()
    subject_gaps = models.IntegerField()

    def __str__(self):
        return self.query_orftid


class Code(models.Model):

    triplet = models.CharField(max_length=3, primary_key=True)
    aa = models.CharField(max_length=1)

    def __str__(self):
        return self.triplet
