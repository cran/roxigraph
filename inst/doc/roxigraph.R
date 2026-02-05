## ----include = FALSE----------------------------------------------------------
knitr::opts_chunk$set(
    collapse = TRUE,
    comment = "#>"
)

## ----setup--------------------------------------------------------------------
library(roxigraph)

# Create an in-memory store
store <- rdf_store()

## ----eval=FALSE---------------------------------------------------------------
# store <- rdf_store("/path/to/database")

## -----------------------------------------------------------------------------
turtle_data <- '
@prefix foaf: <http://xmlns.com/foaf/0.1/> .
@prefix ex: <http://example.org/> .

ex:alice a foaf:Person ;
         foaf:name "Alice" ;
         foaf:age 30 ;
         foaf:knows ex:bob .

ex:bob a foaf:Person ;
       foaf:name "Bob" ;
       foaf:age 25 .
'

rdf_load(store, turtle_data, format = "turtle")
rdf_size(store)

## -----------------------------------------------------------------------------
store2 <- rdf_store()
nt_data <- '<http://example.org/s> <http://example.org/p> "object" .'
rdf_load(store2, nt_data, format = "ntriples")

## ----eval=FALSE---------------------------------------------------------------
# rdf_load_file(store, "data.ttl", format = "turtle")
# rdf_load_file(store, "data.nt") # Format guessed from extension

## -----------------------------------------------------------------------------
# Find all people and their names
results <- sparql_query(store, "
  PREFIX foaf: <http://xmlns.com/foaf/0.1/>
  SELECT ?person ?name
  WHERE {
    ?person a foaf:Person ;
            foaf:name ?name .
  }
")
results

## -----------------------------------------------------------------------------
# Find people over 26
sparql_query(store, "
  PREFIX foaf: <http://xmlns.com/foaf/0.1/>
  SELECT ?name ?age
  WHERE {
    ?person foaf:name ?name ;
            foaf:age ?age .
    FILTER(?age > 26)
  }
  ORDER BY DESC(?age)
")

## -----------------------------------------------------------------------------
# Check if Alice exists
sparql_query(store, "
  PREFIX ex: <http://example.org/>
  ASK { ex:alice ?p ?o }
")

## -----------------------------------------------------------------------------
sparql_query(store, "
  PREFIX foaf: <http://xmlns.com/foaf/0.1/>
  SELECT (COUNT(?person) as ?count) (AVG(?age) as ?avg_age)
  WHERE {
    ?person a foaf:Person ;
            foaf:age ?age .
  }
")

## -----------------------------------------------------------------------------
# Add new data
sparql_update(store, "
  PREFIX foaf: <http://xmlns.com/foaf/0.1/>
  PREFIX ex: <http://example.org/>

  INSERT DATA {
    ex:carol a foaf:Person ;
             foaf:name 'Carol' ;
             foaf:age 28 .
  }
")

rdf_size(store)

## -----------------------------------------------------------------------------
# Add a triple
rdf_add(
    store, "<http://example.org/carol>",
    "<http://xmlns.com/foaf/0.1/knows>",
    "<http://example.org/alice>"
)

# Remove a triple
rdf_remove(
    store, "<http://example.org/carol>",
    "<http://xmlns.com/foaf/0.1/knows>",
    "<http://example.org/alice>"
)

## -----------------------------------------------------------------------------
# Export to N-Quads format
output <- rdf_serialize(store, format = "nquads")
cat(substr(output, 1, 500), "...\n")

