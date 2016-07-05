#! /bin/bash -


# This is a list of aliases for queries that used to exist in the database, but no longer do.
# These will be removed as part of the execution of the script.
readonly DefunctQueries='
ilsLADataObjects
ilsLACollections
'

# The current set of specific queries along with there aliases are stored in two separate arrays.
# A query and alias pair share a common index.
declare -a aliases queries


add_sq()
{
  aliases[${#aliases[*]}]="$1"
  queries[${#queries[*]}]="$2"
}


readonly ListingQueryTmpl="
WITH user_lookup AS (SELECT u.user_id AS user_id FROM r_user_main u WHERE u.user_name = ?),
     parent      AS (SELECT c.coll_id AS coll_id, c.coll_name AS coll_name
                       FROM r_coll_main c
                       WHERE c.coll_name = ?)
SELECT p.full_path, p.base_name, p.data_size, p.create_ts, p.modify_ts, p.access_type_id, p.type
  FROM (SELECT c.coll_name                       AS dir_name,
               c.coll_name || '/' || d.data_name AS full_path,
               d.data_name                       AS base_name,
               d.create_ts                       AS create_ts,
               d.modify_ts                       AS modify_ts,
               'dataobject'                      AS type,
               d.data_size                       AS data_size,
               a.access_type_id                  AS access_type_id
          FROM r_data_main d
            JOIN r_coll_main c ON c.coll_id = d.coll_id
            JOIN r_objt_access a ON d.data_id = a.object_id
            JOIN r_user_main u ON a.user_id = u.user_id,
            user_lookup,
            parent
          WHERE u.user_id = user_lookup.user_id AND c.coll_id = parent.coll_id
        UNION
        SELECT c.parent_coll_name                     AS dir_name,
               c.coll_name                            AS full_path,
               regexp_replace(c.coll_name, '.*/', '') AS base_name,
               c.create_ts                            AS create_ts,
               c.modify_ts                            AS modify_ts,
               'collection'                           AS type,
               0                                      AS data_size,
               a.access_type_id                       AS access_type_id
          FROM r_coll_main c
            JOIN r_objt_access a ON c.coll_id = a.object_id
            JOIN r_user_main u ON a.user_id = u.user_id,
            user_lookup,
            parent
          WHERE u.user_id = user_lookup.user_id
            AND c.parent_coll_name = parent.coll_name
            AND c.coll_type != 'linkPoint') AS p
  ORDER BY p.type ASC, %s %s
  LIMIT ?
  OFFSET ?"


mk_listing_query() 
{
  local sortCol="$1"
  local sortOrder="$2"

  printf "$ListingQueryTmpl" "$sortCol" "$sortOrder"
}


add_sq IPCUserCollectionPerms '
SELECT a.access_type_id, u.user_name
  FROM r_coll_main c
    JOIN r_objt_access a ON c.coll_id = a.object_id
    JOIN r_user_main u ON a.user_id = u.user_id
  WHERE c.parent_coll_name = ? AND c.coll_name = ?
  LIMIT ?
  OFFSET ?'

add_sq IPCUserDataObjectPerms "
SELECT DISTINCT o.access_type_id, u.user_name
  FROM r_user_main u, r_data_main d, r_coll_main c, r_tokn_main t, r_objt_access o
  WHERE c.coll_name = ?
    AND d.data_name = ?
    AND c.coll_id = d.coll_id
    AND o.object_id = d.data_id
    AND t.token_namespace = 'access_type'
    AND u.user_id = o.user_id
    AND o.access_type_id = t.token_id
  LIMIT ?
  OFFSET ?"

add_sq IPCEntryListingPathSortASC "$(mk_listing_query 'p.full_path' ASC)"

add_sq IPCEntryListingPathSortDESC "$(mk_listing_query 'p.full_path' DESC)"

add_sq IPCEntryListingNameSortASC "$(mk_listing_query 'p.base_name' ASC)"

add_sq IPCEntryListingNameSortDESC "$(mk_listing_query 'p.base_name' DESC)"

add_sq IPCEntryListingLastModSortASC "$(mk_listing_query 'p.modify_ts' ASC)"

add_sq IPCEntryListingLastModSortDESC "$(mk_listing_query 'p.modify_ts' DESC)"

add_sq IPCEntryListingSizeSortASC "$(mk_listing_query 'p.data_size' ASC)"

add_sq IPCEntryListingSizeSortDESC "$(mk_listing_query 'p.data_size' DESC)"

add_sq IPCEntryListingCreatedSortASC "$(mk_listing_query 'p.create_ts' ASC)"

add_sq IPCEntryListingCreatedSortDESC "$(mk_listing_query 'p.create_ts' DESC)"

add_sq IPCCountDataObjectsAndCollections "
WITH user_lookup AS (SELECT u.user_id AS user_id FROM r_user_main u WHERE u.user_name = ?),
     parent      AS (SELECT c.coll_id AS coll_id, c.coll_name AS coll_name
                       FROM r_coll_main c
                       WHERE c.coll_name = ?)
SELECT COUNT(p.*)
  FROM (SELECT c.coll_name      AS dir_name,
               d.data_path      AS full_path,
               d.data_name      AS base_name,
               d.create_ts      AS create_ts,
               d.modify_ts      AS modify_ts,
               'dataobject'     AS type,
               d.data_size      AS data_size,
               a.access_type_id AS access_type_id
          FROM r_data_main d
            JOIN r_coll_main c ON c.coll_id = d.coll_id
            JOIN r_objt_access a ON d.data_id = a.object_id
            JOIN r_user_main u ON a.user_id = u.user_id,
            user_lookup,
            parent
          WHERE u.user_id = user_lookup.user_id
            AND c.coll_id = parent.coll_id
        UNION
        SELECT c.parent_coll_name                     AS dir_name,
               c.coll_name                            AS full_path,
               regexp_replace(c.coll_name, '.*/', '') AS base_name,
               c.create_ts                            AS create_ts,
               c.modify_ts                            AS modify_ts,
               'collection'                           AS type,
               0                                      AS data_size,
               a.access_type_id                       AS access_type_id
          FROM r_coll_main c
            JOIN r_objt_access a ON c.coll_id = a.object_id
            JOIN r_user_main u ON a.user_id = u.user_id,
            user_lookup,
            parent
          WHERE u.user_id = user_lookup.user_id
            AND c.parent_coll_name = parent.coll_name
            AND c.coll_type != 'linkPoint') AS p"

add_sq IPCListCollectionsUnderPath "
WITH user_lookup AS (SELECT u.user_id AS user_id FROM r_user_main u WHERE u.user_name = ?),
     parent      AS (SELECT c.coll_id AS coll_id, c.coll_name AS coll_name
                       FROM r_coll_main c
                      WHERE c.coll_name = ?)
SELECT c.parent_coll_name                     AS dir_name,
       c.coll_name                            AS full_path,
       regexp_replace(c.coll_name, '.*/', '') AS base_name,
       c.create_ts                            AS create_ts,
       c.modify_ts                            AS modify_ts,
       'collection'                           AS type,
       0                                      AS data_size,
       a.access_type_id                       AS access_type_id
  FROM r_coll_main c
    JOIN r_objt_access a ON c.coll_id = a.object_id
    JOIN r_user_main u ON a.user_id = u.user_id,
    user_lookup,
    parent
  WHERE u.user_id = user_lookup.user_id
    AND c.parent_coll_name = parent.coll_name
    AND c.coll_type != 'linkPoint'"

add_sq IPCCountDataObjectsUnderPath "
WITH user_lookup AS (SELECT u.user_id AS user_id FROM r_user_main u WHERE u.user_name = ?),
     parent      AS (SELECT c.coll_id AS coll_id, c.coll_name AS coll_name
                       FROM r_coll_main c
                       WHERE c.coll_name = ?)
SELECT COUNT(*)
  FROM r_data_main d
    JOIN r_coll_main c ON c.coll_id = d.coll_id
    JOIN r_objt_access a ON d.data_id = a.object_id
    JOIN r_user_main u ON a.user_id = u.user_id,
    user_lookup,
    parent
  WHERE u.user_id = user_lookup.user_id AND c.coll_id = parent.coll_id"

add_sq IPCCountCollectionsUnderPath "
WITH user_lookup AS (SELECT u.user_id AS user_id FROM r_user_main u WHERE u.user_name = ?),
     parent      AS (SELECT c.coll_id AS coll_id, c.coll_name AS coll_name
                       FROM r_coll_main c
                       WHERE c.coll_name = ?)
SELECT COUNT(*)
  FROM r_coll_main c
    JOIN r_objt_access a ON c.coll_id = a.object_id
    JOIN r_user_main u ON a.user_id = u.user_id,
    user_lookup,
    parent
  WHERE u.user_id = user_lookup.user_id
    AND c.parent_coll_name = parent.coll_name
    AND c.coll_type != 'linkPoint'"

add_sq ilsLADataObjects "
SELECT s.coll_name, 
       s.data_name, 
       s.create_ts, 
       s.modify_ts, 
       s.data_id, 
       s.data_size, 
       s.data_repl_num, 
       s.data_owner_name, 
       s.data_owner_zone, 
       u.user_name, 
       u.user_id, 
       a.access_type_id,  
       u.user_type_name, 
       u.zone_name 
  FROM (SELECT c.coll_name, 
               d.data_name, 
               d.create_ts, 
               d.modify_ts, 
               d.data_id, 
               d.data_repl_num, 
               d.data_size, 
               d.data_owner_name, 
               d.data_owner_zone 
          FROM r_coll_main c JOIN r_data_main d ON c.coll_id = d.coll_id  
          WHERE c.coll_name = ?  
          ORDER BY d.data_name) s 
    JOIN r_objt_access a ON s.data_id = a.object_id 
    JOIN r_user_main u ON a.user_id = u.user_id 
  ORDER BY s.coll_name, s.data_name, u.user_name, a.access_type_id DESC 
  LIMIT ? 
  OFFSET ?"

add_sq ilsLACollections "
SELECT c.parent_coll_name, 
       c.coll_name, 
       c.create_ts, 
       c.modify_ts, 
       c.coll_id, 
       c.coll_owner_name, 
       c.coll_owner_zone,
       c.coll_type, 
       u.user_name, 
       u.zone_name, 
       a.access_type_id, 
       u.user_id 
  FROM r_coll_main c 
    JOIN r_objt_access a ON c.coll_id = a.object_id 
    JOIN r_user_main u ON a.user_id = u.user_id 
  WHERE c.parent_coll_name = ? 
  ORDER BY c.coll_name, u.user_name, a.access_type_id DESC 
  LIMIT ? 
  OFFSET ?"

add_sq DataObjInCollReCur "
WITH coll AS (SELECT coll_id, coll_name 
                FROM r_coll_main 
                WHERE R_COLL_MAIN.coll_name = ? OR R_COLL_MAIN.coll_name LIKE ?)  
SELECT DISTINCT d.data_id, 
                (SELECT coll_name FROM coll WHERE coll.coll_id = d.coll_id) coll_name, 
                d.data_name, 
                d.data_repl_num, 
                d.resc_name, 
                d.data_path 
  FROM r_data_main d 
  WHERE d.coll_id = ANY(ARRAY(SELECT coll_id FROM coll)) 
  ORDER BY coll_name, d.data_name, d.data_repl_num"

for queryAlias in $DefunctQueries
do
  printf 'deleting query %s\n' "$queryAlias"
	iadmin rsq "$queryAlias" 2>/dev/null
done

for i in ${!aliases[*]}
do
  queryAlias=${aliases[$i]}
  printf 'creating query %s\n' "$queryAlias"
  iadmin rsq "$queryAlias" 2>/dev/null
	iadmin asq "${queries[$i]}" "$queryAlias"
done
