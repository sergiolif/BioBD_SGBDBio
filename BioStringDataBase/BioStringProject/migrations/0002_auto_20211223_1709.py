# Generated by Django 3.1 on 2021-12-23 20:09

from django.db import migrations, models
import django.db.models.deletion


class Migration(migrations.Migration):

    dependencies = [
        ('BioStringProject', '0001_initial'),
    ]

    operations = [
        migrations.RemoveField(
            model_name='synonymous',
            name='id',
        ),
        migrations.AddField(
            model_name='orft',
            name='taxonomy_id',
            field=models.ForeignKey(default=1, on_delete=django.db.models.deletion.CASCADE, to='BioStringProject.taxonomy'),
            preserve_default=False,
        ),
        migrations.AddField(
            model_name='protein',
            name='taxonomy_id',
            field=models.ForeignKey(default=1, on_delete=django.db.models.deletion.CASCADE, to='BioStringProject.taxonomy'),
            preserve_default=False,
        ),
        migrations.AlterField(
            model_name='synonymous',
            name='taxonomy_id',
            field=models.ForeignKey(on_delete=django.db.models.deletion.CASCADE, primary_key=True, serialize=False, to='BioStringProject.taxonomy'),
        ),
    ]