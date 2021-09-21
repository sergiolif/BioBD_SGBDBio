from django.shortcuts import render
from django.db import connection


def index(request):
    context = {}

    if request.method == 'POST':

        searchfield = request.POST.get('searchfield')
        searchfield1 = request.POST.get('searchfield1')
        searchfield2 = request.POST.get('searchfield2')
        cbfunction = request.POST.get('cbFunction')

        if cbfunction is not None:
            if cbfunction == 'isDNA':
                cursor = connection.cursor()
                cursor.callproc('isDNA', [searchfield])
                result = cursor.fetchall()
                if result[0]:
                    result = "TRUE: É uma cadeia de DNA."
                elif not result[0]:
                    result = "FALSE: Não é uma cadeia de DNA."
                cursor.close()
            elif cbfunction == 'complement':
                cursor = connection.cursor()
                cursor.callproc('complement', [searchfield])
                result = cursor.fetchall()
                result = result[0]
                cursor.close()
            elif cbfunction == 'reverse':
                cursor = connection.cursor()
                cursor.callproc('reverse', [searchfield])
                result = cursor.fetchall()
                result = result[0]
                cursor.close()
            elif cbfunction == 'getGCcontent':
                cursor = connection.cursor()
                cursor.callproc('getGCcontent', [searchfield])
                result = cursor.fetchall()
                cursor.close()
            elif cbfunction == 'transcript':
                cursor = connection.cursor()
                cursor.callproc('transcript', [searchfield])
                result = cursor.fetchall()
                cursor.close()
            elif cbfunction == 'translation':
                cursor = connection.cursor()
                if searchfield1 is not None:
                    cursor.callproc('translation', [int(searchfield), searchfield1])
                    result = cursor.fetchall()
                elif searchfield1 is None:
                    result = "Precisa preencher o segundo campo de busca."
                cursor.close()
            elif cbfunction == 'searchORF':
                cursor = connection.cursor()
                if searchfield1 is not None and searchfield2 is not None:
                    cursor.callproc('searchORF', [int(searchfield), searchfield1, int(searchfield2)])
                    result = cursor.fetchall()
                elif searchfield1 is None and searchfield2 is None:
                    result = "Precisa preencher o segundo e o terceiro campo de busca."
                elif searchfield1 is None and searchfield2 is not None:
                    result = "Precisa preencher o segundo campo de busca."
                elif searchfield1 is not None and searchfield2 is None:
                    result = "Precisa preencher o terceiro campo de busca."
                cursor.close()
            elif cbfunction == 'getTaxonomyIdChildren':
                cursor = connection.cursor()
                cursor.callproc('getTaxonomyIdChildren', [int(searchfield)])
                result = cursor.fetchall()
                cursor.close()
            elif cbfunction == 'getTaxonomyIdChildrenSet':
                cursor = connection.cursor()
                cursor.callproc('getTaxonomyIdChildrenSet', [int(searchfield)])
                result = cursor.fetchall()
                cursor.close()
            elif cbfunction == 'getCountGenomeTaxonomy':
                cursor = connection.cursor()
                cursor.callproc('getCountGenomeTaxonomy', [int(searchfield)])
                result = cursor.fetchall()
                cursor.close()
            elif cbfunction == 'getCountProteinTaxonomy':
                cursor = connection.cursor()
                cursor.callproc('getCountProteinTaxonomy', [int(searchfield)])
                result = cursor.fetchall()
                cursor.close()
            elif cbfunction == 'getCountHitsProtein':
                cursor = connection.cursor()
                if searchfield1 is not None:
                    cursor.callproc('getCountHitsProtein', [int(searchfield), float(searchfield1)])
                    result = cursor.fetchall()
                elif searchfield1 is None:
                    result = "Precisa preencher o segundo campo de busca."
                cursor.close()
            elif cbfunction == 'getProteinTaxonomy':
                cursor = connection.cursor()
                cursor.callproc('getProteinTaxonomy', [int(searchfield)])
                result = cursor.fetchall()
                cursor.close()
            elif cbfunction == 'getSimilarProtein':
                cursor = connection.cursor()
                if searchfield1 is not None:
                    cursor.callproc('getSimilarProtein', [int(searchfield), int(searchfield1)])
                    result = cursor.fetchall()
                elif searchfield1 is None:
                    result = "Precisa preencher o segundo campo de busca."
                cursor.close()
            elif cbfunction == 'getSingleGene':
                cursor = connection.cursor()
                if searchfield1 is not None:
                    cursor.callproc('getSingleGene', [int(searchfield), int(searchfield1)])
                    result = cursor.fetchall()
                elif searchfield1 is None:
                    result = "Precisa preencher o segundo campo de busca."
                cursor.close()
            elif cbfunction == 'getOrthologousGene':
                cursor = connection.cursor()
                if searchfield1 is not None:
                    cursor.callproc('getOrthologousGene', [int(searchfield), int(searchfield1)])
                    result = cursor.fetchall()
                elif searchfield1 is None:
                    result = "Precisa preencher o segundo campo de busca."
                cursor.close()
            elif cbfunction == 'getParalogousGene':
                cursor = connection.cursor()
                cursor.callproc('getParalogousGene', [int(searchfield)])
                result = cursor.fetchall()
                cursor.close()
            else:
                print("FETCHING ERROR: No FunctionId Found ---> INVALID SEARCH")

            # print(result)

            context = {'result': result, 'searchfield': searchfield, 'searchfield1': searchfield1,
                       'searchfield2': searchfield2}

            return render(request, 'BioProjectTemplates/index.html', context)

    return render(request, 'BioProjectTemplates/index.html', context)
