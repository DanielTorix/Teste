/********************************************************************************************************************
    @purpose
        The FW_QueryBuilder class provides an object oriented way of building queries without having to do write them
        manually by hand. It relies rather heavily on the describe calls and is therefor not always a good replacement
        for inline SOQL.

        Currently this class support most basic SOQL queries including:
        - querying over relationships
        - subselect queries
        - where clauses; both as string and OO-style
        - agregation

        The current version does not yet cache all calls to describe therefore you should avoid adding feilds by name
        but instead use the SObject.FieldName syntax which is support for most fields in salesforce with the exception
        of master-detail relationships (Order.OrderItems, etc)

        This class can be configured both with verbose logging and field level security checks:
        - (Boolean) FW_QueryBuilder.checkSecurity (default=false)
        - (Boolean) FW_QueryBuilder.verboseLogging (default=false)

    -----------------------------------------------------------------------------------------------------------------
*********************************************************************************************************************/
public class FW_QueryBuilder implements FW_IQuerySpecification, FW_ISObjectSelector { // No explicit sharing declaration - inherit from caller
    private Schema.SObjectType objectType;
    private Schema.DescribeSObjectResult objectDescribeResult;
    private Set<SelectedField> selectFields;
    private Set<SelectedField> groupByFields;
    private Set<SelectedField> groupByRollupFields;
    private Map<String, SortField> orderByFields;
    private Map<String, FW_QueryBuilder> joins;
    private Map<String, FW_QueryBuilder> subQueries;
    private FW_QueryBuilder parent;
    private String whereClause;
    private Integer offsetClause;
    private Integer limitClause;
    private Boolean checkSecurity = false;
    public static Boolean verboseLogging = false;
                                        
    /**
     * FW_QueryBuilder description
     * @param  type type description
     * @return      return description
     */
    public FW_QueryBuilder(SObjectType type) {
        this.objectType = type;
        this.selectFields = new Set<SelectedField>();
        this.groupByFields = new Set<SelectedField>();
        this.groupByRollupFields = new Set<SelectedField>();
        this.subQueries = new Map<String, FW_QueryBuilder>();
        this.joins = new Map<String, FW_QueryBuilder>();
        this.orderByFields= new Map<String, SortField>();
    }

    /**
     * FW_QueryBuilder description
     * @param  type   type description
     * @param  fields fields description
     * @return        return description
     */
    public FW_QueryBuilder(SObjectType type, List<SObjectField> fields) {
        this(type);
        this.selectFields(fields);
    }

    /**
     * getSObjectType description
     * @return   return description
     */
    public Schema.SObjectType getSObjectType() {
        return objectType;
    }

    /**
     * getParent description
     * @return   return description
     */
    public FW_QueryBuilder getParent() {
        return this.parent;
    }

    /**
     * getSObjectFieldList description
     * @return   return description
     */
    public List<Schema.SObjectField> getSObjectFieldList() {
        List<Schema.SObjectField> fieldList = new List<Schema.SObjectField>();
        for (SelectedField field : selectFields) {
            fieldList.add(field.field);
        }
        return fieldList;
    }

    /**
     * selectField description
     * @param  field field description
     * @return       return description
     */
    public FW_QueryBuilder selectField(SObjectField field) {
        addField(field);
        return this;
    }

    /**
     * selectField description
     * @param  field       field description
     * @param  aggregation aggregation description
     * @return             return description
     */
    public FW_QueryBuilder selectField(SObjectField field, AggregateOperation aggregation) {
        addField(field).aggregation = aggregation;
        return this;
    }

    /**
     * selectFieldAs description
     * @param  field       field description
     * @param  aggregation aggregation description
     * @param  alias       alias description
     * @return             return description
     */
    public FW_QueryBuilder selectFieldAs(SObjectField field, AggregateOperation aggregation, string alias) {
        SelectedField selField = addField(field);
        selField.aggregation = aggregation;
        selField.alias = alias;
        return this;
    }

    /**
     * selectFields description
     * @param  fields fields description
     * @return        return description
     */
    public FW_QueryBuilder selectFields(List<SObjectField> fields) {
        for (SObjectField field : fields) {
            addField(field);
        }
        return this;
    }
    
    /**
     * selectFields description
     * @param  List<String> fields
     * @return        return description
    */
    public FW_QueryBuilder selectFields(List<String> fields) {
        for (String field : fields) {
            SelectedField selectedField = new SelectedField(field);
            if(checkSecurity && selectedField.isAccessible()) {
                throw new NoAccessException();
            }
            this.selectFields.add(selectedField);
        }
        return this;
    }

    /**
     * selectFields description
     * @param  relationship relationship description
     * @param  fields       fields description
     * @return              return description
     */
    public FW_QueryBuilder selectFields(SObjectField relationship, List<SObjectField> fields) {
        return this.join(relationship, fields);
    }

    /**
     * selectParentFields description
     * @param  relationship relationship description
     * @param  fields       fields description
     * @return              return description
     */
    public FW_QueryBuilder selectParentFields(SObjectField relationship, List<SObjectField> fields) {
        return this.selectFields(relationship, fields);
    }

    /**
     * selectFields description
     * @param  relationship relationship description
     * @param  selector     selector description
     * @return              return description
     */
    public FW_QueryBuilder selectFields(SObjectField relationship, FW_ISObjectSelector selector) {
        return this.join(relationship, selector);
    }

    /**
     * selectFields description
     * @param  relationship relationship description
     * @param  query        query description
     * @return              return description
     */
    public FW_QueryBuilder selectFields(SObjectField relationship, FW_QueryBuilder query) {
        return this.join(relationship, query);
    }
    
    /**
     * join description
     * @param  relationship relationship description
     * @param  fields       fields description
     * @return              return description
     */
    public FW_QueryBuilder join(SObjectField relationship, List<SObjectField> fields) {
        return this.join(relationship, new FW_QueryBuilder(relationship.getDescribe().getReferenceTo()[0], fields));
    }

    /**
     * join description
     * @param  relationship relationship description
     * @param  selector     selector description
     * @return              return description
     */
    public FW_QueryBuilder join(SObjectField relationship, FW_ISObjectSelector selector) {
        if (selector instanceof FW_SObjectSelector) {
            return this.join(relationship, ((FW_SObjectSelector)selector).queryBuilder);
        }
        return this.join(relationship, new FW_QueryBuilder(selector.getSObjectType(), selector.getSObjectFieldList()));
    }

    /**
     * join description
     * @param  relationship relationship description
     * @param  query        query description
     * @return              return description
     */
    public FW_QueryBuilder join(SObjectField relationship, FW_QueryBuilder query) {
        DescribeFieldResult relDesc = relationship.getDescribe();
        if (checkSecurity && !relDesc.isAccessible()) {
            throw new NoAccessException();
        }
        joins.put(relDesc.getRelationshipName(), query);
        return this;
    }
    
    /**
     * join description
     * @param  relationship relationship description
     * @param  query        query description
     * @return              return description
    */
    public FW_QueryBuilder getJoins(SObjectField relationship) {
        DescribeFieldResult relDesc = relationship.getDescribe();
        return joins.get(relDesc.getRelationshipName());
    }

    /**
     * selectSubquery description
     * @param  relationshipName relationshipName description
     * @param  selector         selector description
     * @return                  return description
     */
    public FW_QueryBuilder selectSubquery(String relationshipName, FW_ISObjectSelector selector) {
        Schema.ChildRelationship rel = this.getChildRelationship(relationshipName);
        if (rel == null) {
            throw new NoSuchRelationshipException(String.valueOf(this.objectType), relationshipName);
        }
        return this.selectSubquery(rel, selector);
    }

    /**
     * selectSubquery description
     * @param  rel      rel description
     * @param  selector selector description
     * @return          return description
     */
    public FW_QueryBuilder selectSubquery(Schema.ChildRelationship rel, FW_ISObjectSelector selector) {
        if (selector instanceof FW_SObjectSelector) {
            return this.selectSubquery(rel, ((FW_SObjectSelector)selector).queryBuilder);
        }
        return this.selectSubquery(rel, selector.getSObjectFieldList());
    }

    /**
     * selectSubquery description
     * @param  relationshipName relationshipName description
     * @param  fields           fields description
     * @return                  return description
     */
    public FW_QueryBuilder selectSubquery(String relationshipName, List<SObjectField> fields) {
        Schema.ChildRelationship rel = this.getChildRelationship(relationshipName);
        if (rel == null) {
            throw new NoSuchRelationshipException(String.valueOf(this.objectType), relationshipName);
        }
        return this.selectSubquery(rel, fields);
    }

    /**
     * selectSubquery description
     * @param  rel    rel description
     * @param  fields fields description
     * @return        return description
     */
    public FW_QueryBuilder selectSubquery(Schema.ChildRelationship rel, List<SObjectField> fields) {
        FW_QueryBuilder subqueryBuilder = this.subQueries.get(rel.getRelationshipName());
        if (subqueryBuilder == null) {
            subqueryBuilder = new FW_QueryBuilder(rel.getChildSObject());
            this.subQueries.put(rel.getRelationshipName(), subqueryBuilder);
        }
        subqueryBuilder.parent = this; // link to parent FW_QueryBuilder instance
        subqueryBuilder.selectFields(fields);
        return subqueryBuilder;
    }

    /**
     * selectSubquery description
     * @param  rel   rel description
     * @param  query query description
     * @return       return description
     */
    public FW_QueryBuilder selectSubquery(Schema.ChildRelationship rel, FW_QueryBuilder query) {
        this.subQueries.put(rel.getRelationshipName(), query);
        return query;
    }

    /**
     * selectFields description
     * @param  raltionshipOrFieldName raltionshipOrFieldName description
     * @param  fields                 fields description
     * @return                        return description
     */
    public FW_QueryBuilder selectFields(String raltionshipOrFieldName, List<SObjectField> fields) {
        Schema.ChildRelationship rel = this.getChildRelationship(raltionshipOrFieldName);
        if (rel != null) {
            selectSubquery(rel, fields);
            return this;
        }
        Schema.SObjectField field = this.getField(raltionshipOrFieldName);
        if (field != null) {
            return selectFields(field, fields);
        }
        throw new NoSuchRelationshipException(String.valueOf(this.objectType), raltionshipOrFieldName);
    }
    
    private SelectedField addField(SObjectField field) {
        SelectedField selectedField = new SelectedField(field);
        if(checkSecurity && selectedField.isAccessible()) {
            throw new NoAccessException();
        }
        this.selectFields.add(selectedField);
        return selectedField;
    }

    /**
     * getSubquery description
     * @param  raltionshipName raltionshipName description
     * @return                 return description
     */
    public FW_QueryBuilder getSubquery(String raltionshipName) {
        return this.subQueries.get(raltionshipName);
    }

    /**
     * setWhere description
     * @param  whereClause whereClause description
     * @return             return description
     */
    public FW_QueryBuilder setWhere(String whereClause) {
        this.whereClause = whereClause;
        return this;
    }

    /**
     * whereLike description
     * @param  field field description
     * @param  value value description
     * @return       return description
     */
    public FW_QueryBuilder whereLike(SObjectField field, Object value) {
        return whereLike(String.valueOf(field), value);
    }

    /**
     * whereLike description
     * @param  fieldName fieldName description
     * @param  value     value description
     * @return           return description
     */
    public FW_QueryBuilder whereLike(String fieldName, Object value) {
        return addToWhere(fieldName, 'LIKE', formatValue(value));
    }

    /**
     * whereEquals description
     * @param  field field description
     * @param  value value description
     * @return       return description
     */
    public FW_QueryBuilder whereEquals(SObjectField field, Object value) {
        return whereEquals(String.valueOf(field), value);
    }

    /**
     * whereEquals description
     * @param  fieldName fieldName description
     * @param  value     value description
     * @return           return description
     */
    public FW_QueryBuilder whereEquals(String fieldName, Object value) {
        return addToWhere(fieldName, '=', formatValue(value));
    }

    /**
     * whereNotEquals description
     * @param  field field description
     * @param  value value description
     * @return       return description
     */
    public FW_QueryBuilder whereNotEquals(SObjectField field, Object value) {
        return addToWhere(String.valueOf(field), '!=', formatValue(value));
    }

    /**
     * whereNotEquals description
     * @param  fieldName fieldName description
     * @param  value     value description
     * @return           return description
     */
    public FW_QueryBuilder whereNotEquals(String fieldName, Object value) {
        return addToWhere(fieldName, '!=', formatValue(value));
    }

    /**
     * whereIn description
     * @param  field  field description
     * @param  values values description
     * @return        return description
     */
    public FW_QueryBuilder whereIn(SObjectField field, List<Object> values) {
         return whereIn(String.valueOf(field), values);
    }

    /**
     * whereIn description
     * @param  fieldName fieldName description
     * @param  values    values description
     * @return           return description
     */
    public FW_QueryBuilder whereIn(String fieldName, List<Object> values) {
        return addToWhere(fieldName, 'in', '(' + joinAndFormatValues(values) + ')');
    }

    /**
     * whereNotIn description
     * @param  field  field description
     * @param  values values description
     * @return        return description
     */
    public FW_QueryBuilder whereNotIn(SObjectField field, List<Object> values) {
         return whereNotIn(String.valueOf(field), values);
    }

    /**
     * whereNotIn description
     * @param  fieldName fieldName description
     * @param  values    values description
     * @return           return description
     */
    public FW_QueryBuilder whereNotIn(String fieldName, List<Object> values) {
        return addToWhere(fieldName, 'not in', '(' + joinAndFormatValues(values) + ')');
    }

    private FW_QueryBuilder addToWhere(String fieldName, String operator, String comparend) {
        this.whereClause = this.whereClause == null ? '' : this.whereClause + ' AND ';
        this.whereClause += fieldName + ' ' + operator + ' ' + comparend;
        return this;
    }

    /**
     * groupBy description
     * @param  field field description
     * @return       return description
     */
    public FW_QueryBuilder groupBy(SObjectField field) {
        this.groupByFields.add(new SelectedField(field));
        return this;
    }

    /**
     * groupBy description
     * @param  field field description
     * @return       return description
     */
    public FW_QueryBuilder groupBy(String field) {
        this.groupByFields.add(new SelectedField(field));
        return this;
    }

    /**
     * groupBy description
     * @param  fields fields description
     * @return        return description
     */
    public FW_QueryBuilder groupBy(List<SObjectField> fields) {
        for (SObjectField field : fields) {
            this.groupByFields.add(new SelectedField(field));
        }
        return this;
    }


    /**
     * groupBy description
     * @param  field field description
     * @return       return description
     */
    public FW_QueryBuilder groupByRollUp(SObjectField field) {
        this.groupByRollupFields.add(new SelectedField(field));
        return this;
    }

    /**
     * groupBy description
     * @param  field field description
     * @return       return description
     */
    public FW_QueryBuilder groupByRollUp(String field) {
        this.groupByRollupFields.add(new SelectedField(field));
        return this;
    }

    /**
     * groupBy description
     * @param  fields fields description
     * @return        return description
     */
    public FW_QueryBuilder groupByRollUp(List<String> fields) {
        for (String field : fields) {
            this.groupByRollupFields.add(new SelectedField(field));
        }
        return this;
    }

    /**
     * orderByDesc description
     * @param  field field description
     * @return       return description
     */
    public FW_QueryBuilder orderByDesc(SObjectField field) {
        return this.orderByDesc(String.valueOf(field));
    }

    /**
     * orderByDesc description
     * @param  field field description
     * @return       return description
     */
    public FW_QueryBuilder orderByDesc(String field) {
        return this.orderBy(field, SortOrder.DESCENDING, null);
    }

    /**
     * orderByDesc description
     * @param  field     field description
     * @param  nullsLast nullsLast description
     * @return           return description
     */
    public FW_QueryBuilder orderByDesc(String field, Boolean nullsLast) {
        return this.orderBy(field, SortOrder.DESCENDING, nullsLast);
    }

    /**
     * orderByParentFieldDesc description
     * @param  field     field description
     * @param  nullsLast nullsLast description
     * @return           return description
     */
    public FW_QueryBuilder orderByParentFieldDesc(SObjectField relationship, SObjectField field) {
        return this.orderByParentField(relationship, field, SortOrder.DESCENDING);
    } 

    /**
     * orderByAsc description
     * @param  field field description
     * @return       return description
     */
    public FW_QueryBuilder orderByAsc(SObjectField field) {
        // Note: Default sortin is asc but adding it for conv.
        return this.orderByAsc(String.valueOf(field));
    }

    /**
     * orderByAsc description
     * @param  field field description
     * @return       return description
     */
    public FW_QueryBuilder orderByAsc(String field) {
        // Note: Default sortin is asc but adding it for conv.
        return this.orderBy(field, SortOrder.ASCENDING, null);
    }

    /**
     * orderByAsc description
     * @param  field     field description
     * @param  nullsLast nullsLast description
     * @return           return description
     */
    public FW_QueryBuilder orderByAsc(String field, Boolean nullsLast) {
        // Note: Default sortin is asc but adding it for conv.
        return this.orderBy(field, SortOrder.ASCENDING, nullsLast);
    }

    /**
     * orderByParentFieldAsc description
     * @param  field     field description
     * @param  nullsLast nullsLast description
     * @return           return description
     */
    public FW_QueryBuilder orderByParentFieldAsc(SObjectField relationship, SObjectField field) {        
        return this.orderByParentField(relationship, field, SortOrder.ASCENDING);
    }

    /**
     * orderByParentFieldDesc description
     * @param  field     field description
     * @param  nullsLast nullsLast description
     * @return           return description
     */
    public FW_QueryBuilder orderByParentField(SObjectField relationship, SObjectField field, SortOrder direction) {
        return this.orderBy(this.getParentField(relationship, field), direction, null);
    }

    /**
     * getParentField          get a single field from a parent
     * @param  relationship     the field that is the relationship
     * @param  fields           list of fields to get from parent
     * @return                  return a string in the format RelationshipName.Field
     */
    public String getParentField(SObjectField relationship, SObjectField field) {
        return this.getParentFields(relationship, new SObjectField[]{field})[0];
    }

    /**
     * getParentFields          get a list of fields from a parent
     * @param  relationship     the field that is the relationship
     * @param  fields           list of fields to get from parent
     * @return                  return a list of strings in the format RelationshipName.Field
     */
    public List<String> getParentFields(SObjectField relationship, List<SObjectField> fields) {
        //Generate an empty Query Builder, where we add only the relationship fields, so that we can return them as strings
        return new FW_QueryBuilder(this.objectType).join(relationship, fields).getFieldList();
    }

    /**
     * orderBy description
     * @param  field field description
     * @return       return description
     */
    public FW_QueryBuilder orderBy(SObjectField field){
        return this.orderBy(String.valueOf(field), null, null);
    }

    /**
     * orderBy description
     * @param  field field description
     * @return       return description
     */
    public FW_QueryBuilder orderBy(String field){
        return this.orderBy(field, null, null);
    }

    /**
     * orderBy description
     * @param  field     field description
     * @param  direction direction description
     * @return           return description
     */
    public FW_QueryBuilder orderBy(String field, SortOrder direction){
        return this.orderBy(field, direction, null);
    }

    /**
     * orderBy description
     * @param  field     field description
     * @param  direction direction description
     * @param  nullsLast nullsLast description
     * @return           return description
     */
    public FW_QueryBuilder orderBy(String field, SortOrder direction, Boolean nullsLast){
        this.orderByFields.put(field, new SortField(field, direction, nullsLast));
        return this;
    }

    /**
        *  Method name:     setLimit
        *  @description:    method to set the limit in the query
        *  @param:          {Integer} value - limit value
        *  @return:         {FW_QueryBuilder} return querybuilder with the limit defined
     */
    public FW_QueryBuilder setLimit(Integer value){
        this.limitClause = value;
        return this;
    }

    /**
        *  Method name:     setOffSet
        *  @description:    method to set the offset in the query
        *  @param:          {Integer} value - offset value
        *  @return:         {FW_QueryBuilder} return querybuilder with the offset defined
     */
    public FW_QueryBuilder setOffSet(Integer value){
        this.offsetClause = value;
        return this;
    }

    private List<String> getFieldList() {
        List<String> newFields = fieldSetToStringList(this.selectFields);
        for (String relName : joins.keySet()) {
            for (String field : joins.get(relName).getFieldList()) {
                newFields.add(relName + '.' + field);
            }
        }
        for (String relName : subQueries.keySet()) {
            newFields.add('(' + subQueries.get(relName).getQuery(relName) + ')');
        }
        return newFields;
    }

    private List<String> getOrdeByFieldList() {
        List<String> sortList = new List<String>();
        for (SortField sortSpec : orderByFields.values()) {
            sortList.add(sortSpec.toString());
        }
        return sortList;
    }

    private List<String> fieldSetToStringList(Set<SelectedField> fields) {
        List<String> stringList = new List<String>();
        for (SelectedField field : fields) {
            stringList.add(field.toString());
        }
        return stringList;
    }

    /**
     * getQuery description
     * @return   return description
     */
    public String getQuery() {
        return getQuery(String.valueOf(objectType));
    }

    private String getQuery(String fromObjectOrRelation) {
        String queryString = 'SELECT ';
        queryString += String.join(getFieldList(), ',');
        queryString +=' FROM ' + fromObjectOrRelation;
        if (whereClause != null) {
            queryString += ' WHERE ' + whereClause;
        }
        if (!groupByFields.isEmpty()) {
            queryString += ' GROUP BY ' + String.join(fieldSetToStringList(groupByFields), ',');
        } else if (!groupByRollupFields.isEmpty()) {
            queryString += ' GROUP BY ROLLUP (' + String.join(fieldSetToStringList(groupByRollupFields), ',') + ')';
        }
         if (!orderByFields.isEmpty()) {
            queryString += ' ORDER BY ' + String.join(getOrdeByFieldList(), ',');
        }
        if (limitClause != null) {
            queryString += ' LIMIT ' + limitClause;
        }
        if (offsetClause != null) {
            queryString += ' OFFSET ' + offsetClause;
        }
        if (verboseLogging) {
            System.debug('QueryBuilder.getQuery: ' + queryString);
        }
        return queryString;
    }

    /**
        *  Method name:     getCountQuery
        *  @description:    returns a query to count how many records would be retrieved
     */
    public String getCountQuery(){
        String queryString = 'SELECT count() ';
        queryString +=' FROM ' + String.valueOf(objectType);
        if (whereClause != null) {
            queryString += ' WHERE ' + whereClause;
        }
        if (limitClause != null) {
            queryString += ' LIMIT ' + limitClause;
        }
        return queryString;
    }

    private Schema.ChildRelationship getChildRelationship(String relationshipName){
        for (Schema.ChildRelationship childRel : getObjectDescribe().getChildRelationships()) {
            if (childRel.getRelationshipName() == relationshipName){
                return childRel;
            }
        }
        return null;
    }

    private Schema.SObjectField getField(String name){
        Map<String, Schema.SObjectField> fields = getObjectDescribe().fields.getMap();
        return fields.get(name.toLowerCase());
    }

    private String joinAndFormatValues(List<Object> values) {
        String result = '';
        if (values.isEmpty()) {
            result = formatValue(result);
        } else {
            for(Object value : values) {
                result += formatValue(value) + ',';
            }
            result = result.removeEnd(',');
        }
        return result;
    }

    private String formatValue(Object value) {
        if (value == null) {
            return 'null';
        }
        if (value instanceof Boolean) {
            return String.valueOf(value);
        }
        String escapedValue = String.escapeSingleQuotes(String.valueOf(value));
        return '\'' + escapedValue + '\'';
    }

    private Schema.DescribeSObjectResult getObjectDescribe() {
        // Cache desribe results in the class to speed up checks on relationships when needed
        if(this.objectDescribeResult == null) {
            this.objectDescribeResult = objectType.getDescribe();
        }
        return this.objectDescribeResult;
    }

    public void setcheckSecurity(Boolean checkSecurity){
        this.checkSecurity=checkSecurity;
    }

    class SelectedField {
        public SelectedField(Schema.SObjectField field) {
            this.field = field;
            this.fieldName = String.valueOf(field);
        }

        public SelectedField(String field) {
            this.fieldName = field;
        }

        public Integer hashCode() {
            Integer hashCode = System.hashCode(fieldName);
            if (aggregation != null) {
                hashCode += System.hashCode(aggregation);
            }
            return hashCode;
        }

        public override String toString() {
            String name = fieldName;
            if (aggregation != null) {
                name = aggregation + '(' + name + ')';
            }
            if (alias != null) {
                name += ' ' + alias;
            }
            return name;
        }

        public Boolean isAccessible() {
            return getDescribe() != null ? getDescribe().isAccessible() : true;
        }

        public DescribeFieldResult getDescribe() {
            if (describeResult == null && field != null) {
                describeResult = field.getDescribe();
            }
            return describeResult;
        }

        public String fieldName { get; private set; }
        public String alias { get; set; }
        public AggregateOperation aggregation { get; set; }

        private Schema.DescribeFieldResult describeResult;
        private Schema.SObjectField field;
    }

    class SortField {
        public SortField(String field, SortOrder direction, Boolean nullsLast) {
            this.fieldName = field;
            this.direction = direction;
            this.nullsLast = nullsLast;
        }

        public override String toString() {
            String sortSpec = fieldName;
            if (direction == SortOrder.DESCENDING) {
                sortSpec += ' DESC';
            } else if(direction == SortOrder.ASCENDING) {
                sortSpec += ' ASC';
            }
            if (nullsLast == true) {
                sortSpec += ' NULLS LAST';
            }
            return sortSpec;
        }

        public String fieldName { get; private set; }

        /**
         * Specifies whether the results are ordered in ascending (ASC) or descending (DESC) order. Default order is ascending.
         */
        public SortOrder direction { get; set; }

        /**
         * Orders null records at the beginning (NULLS FIRST) or end (NULLS LAST) of the results. By default, null values are sorted first.
         */
        public Boolean nullsLast { get; set; }
    }

    public enum AggregateOperation {
        COUNT,
        COUNT_DISTINCT,
        MIN,
        MAX,
        AVG,
        SUM
    }

    public enum SortOrder {
        ASCENDING, // use full wordts instead of ASC and DESC as both are reserved words
        DESCENDING
    }

    public class NoSuchRelationshipException extends Exception{
        public NoSuchRelationshipException(String objectName, String relationshipName) {
            this.setMessage(
                'No relationship with the name ' + relationshipName +
                ' exists on object ' + objectName +
                '; check your API version or relationship-name as passed to the query builder');
        }
    }
}