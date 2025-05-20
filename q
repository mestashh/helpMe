@prefix ex: <http://example.org/ecommerce#> .
@prefix rdfs: <http://www.w3.org/2000/01/rdf-schema#> .
@prefix rdf: <http://www.w3.org/1999/02/22-rdf-syntax-ns#> .
@prefix xsd: <http://www.w3.org/2001/XMLSchema#> .

ex:Товар a rdfs:Class ;
    rdfs:label "Товар" ;
    rdfs:comment "Товар, доступный в интернет-магазине." .

ex:Категория a rdfs:Class ;
    rdfs:label "Категория" ;
    rdfs:comment "Категория, к которой принадлежат товары." .

ex:Покупатель a rdfs:Class ;
    rdfs:label "Покупатель" ;
    rdfs:comment "Покупатель, который приобретает товары в интернет-магазине." .

ex:Категорию a rdf:Property ;
    rdfs:label "Категорию" ;
    rdfs:domain ex:Товар ;
    rdfs:range ex:Категория ;
    rdfs:comment "Указывает категорию товара." .

ex:Цена a rdf:Property ;
    rdfs:label "Цена" ;
    rdfs:domain ex:Товар ;
    rdfs:range xsd:decimal ;
    rdfs:comment "Указывает цену товара." .

ex:Название a rdf:Property ;
    rdfs:label "Название" ;
    rdfs:domain ex:Товар ;
    rdfs:range xsd:string ;
    rdfs:comment "Указывает название товара." .

ex:ИмяПокупателя a rdf:Property ;
    rdfs:label "имеетИмяПокупателя" ;
    rdfs:domain ex:Покупатель ;
    rdfs:range xsd:string ;
    rdfs:comment "Указывает имя покупателя." .

ex:Email a rdf:Property ;
    rdfs:label "Email" ;
    rdfs:domain ex:Покупатель ;
    rdfs:range xsd:string ;
    rdfs:comment "Указывает адрес электронной почты покупателя." .

ex:Товар1 a ex:Товар ;
    ex:Название "Смартфон" ;
    ex:Цена "40000"^^xsd:decimal ;
    ex:Категорию ex:Категория1 .

ex:Категория1 a ex:Категория ;
    rdfs:label "Электроника" .

ex:Категория2 a ex:Категория ;
    rdfs:label "Канцтовары" .

ex:Покупатель1 a ex:Покупатель ;
    ex:ИмяПокупателя "Алиса Смирнова" ;
    ex:Email "alice@example.com" .

ex:Покупатель2 a ex:Покупатель ;
    ex:ИмяПокупателя "Алескандр Богута" ;
    ex:Email "bob@example.com" .

ex:Товар2 a ex:Товар ;
    ex:Название "Ноутбук" ;
    ex:Цена "150000"^^xsd:decimal ;
    ex:Категорию ex:Категория1 .

ex:Товар3 a ex:Товар ;
    ex:Название "Монитор" ;
    ex:Цена "50000"^^xsd:decimal ;
    ex:Категорию ex:Категория1 .

ex:Товар4 a ex:Товар ;
    ex:Название "Компьютерная мышь" ;
    ex:Цена "1650"^^xsd:decimal ;
    ex:Категорию ex:Категория1 .

ex:Товар5 a ex:Товар ;
    ex:Название "Ручка" ;
    ex:Цена "12"^^xsd:decimal ;
    ex:Категорию ex:Категория2 .

from rdflib import Graph, Namespace

g = Graph()
g.parse("вопрос.ttl", format="turtle")

ex = Namespace("http://example.org/ecommerce#")

query = """
PREFIX ex: <http://example.org/ecommerce#>
PREFIX rdfs: <http://www.w3.org/2000/01/rdf-schema#>
SELECT ?productName ?categoryName WHERE {
    ?product a ex:Товар ;
             ex:Название ?productName ;
             ex:Категорию ?category .
    ?category a ex:Категория ;
              rdfs:label ?categoryName .
}
"""

results = g.query(query)

print("Список товаров и соответствующих категорий:")
for row in results:
    print(f"Товар: {row.productName}, Категория: {row.categoryName}")

--------------------
from SPARQLWrapper import SPARQLWrapper, JSON
import pandas as pd

sparql = SPARQLWrapper("https://query.wikidata.org/sparql")

query = """
SELECT ?river ?riverLabel ?length ?regionLabel WHERE {
  ?river wdt:P31 wd:Q4022;
         wdt:P17 wd:Q159;   
         wdt:P2043  ?length; 
         wdt:P131 ?region
  SERVICE wikibase:label { bd:serviceParam wikibase:language "[AUTO_LANGUAGE],en". }
}
ORDER BY ?riverLabel
"""


sparql.setQuery(query)
sparql.setReturnFormat(JSON)

results = sparql.query().convert()

data = []
for result in results["results"]["bindings"]:
    river_name = result.get("riverLabel", {}).get("value", "N/A")
    length = result.get("length", {}).get("value", "N/A")
    region_name = result.get("regionLabel", {}).get("value", "N/A")
    data.append([river_name, length, region_name])

df = pd.DataFrame(data, columns=["River Name", "Length (km)", "Region"])

grouped_df = df.groupby("River Name").agg({
    "Length (km)": "first",  # Берем первую длину
    "Region": lambda x: ', '.join(x.unique())  # Объединяем уникальные регионы
}).reset_index()

print(grouped_df)
