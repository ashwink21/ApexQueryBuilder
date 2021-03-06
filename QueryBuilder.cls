public class QueryBuilder {
    private List<String> selectCommands;
    private List<String> fromCommands;
    private List<Map<String, String>> whereCommands;
    private String sortByField;
    private String sortDirection;
    private String queryType;

    private static final String dirASC = 'ASC';
    private static final String dirDESC = 'DESC';
    private static final String typeSOQL = 'SOQL';
    private static final String typeSOSL = 'SOSL';

    public QueryBuilder() {
        reset();
    }

    public void reset() {
        selectCommands = new List<String>();
        fromCommands = new List<String>();
        whereCommands = new List<Map<String, String>>();

        // Set default sort direction.
        sortDirection = dirASC;

        // Set default query type.
        queryType = typeSOQL;
    }

    public void addSelectField(String field) {
        selectCommands.add(field);
    }

    public void addSelectField(QueryBuilder subquery) {
        selectCommands.add('(' + subquery.getQuery() + ')');
    }

    public void addFromObject(String obj) {
        fromCommands.add(obj);
    }

    public void addWhereClause(String clause) {
        addWhereClause(clause, 'AND');
    }

    public void addWhereClause(String clause, String delimiter) {
        Map<String, String> whereClause = new Map<String, String>();
        whereClause.put(delimiter, clause);
        whereCommands.add(whereClause);
    }

    public void addSortByField(String field) {
        sortByField = field;
    }

    public void setSOSL() {
        reset();
        queryType = typeSOSL;
    }

    public void setSOQL() {
        reset();
    }

    public void setSortASC() {
        sortDirection = dirASC;
    }

    public void setSortDESC() {
        sortDirection = dirDESC;
    }

    public String getQuery() {
        if (queryType == typeSOQL) {
            return getQuerySOQL();
        }
        return getQuerySOSL();
    }

    private String getQuerySOQL() {
        String whereClause = '';
        Boolean isFirst = true;
        String query = 'SELECT ' + String.join(selectCommands, ', ');
        query += ' FROM ' + String.join(fromCommands, ', ');
        if (whereCommands.size() > 0) {
            for ( Map<String, String> whereCommandSet : whereCommands ) {
                for ( String whereCommand : whereCommandSet.keySet() ) {
                    // Add where clause delimiter.
                    if (isFirst == true) {
                        isFirst = false;
                    } else {
                        whereClause += ' ' + whereCommand + ' ';
                    }
                    whereClause += whereCommandSet.get(whereCommand);
                }

            }
            query += ' WHERE ' + whereClause;
        }
        if (sortByField != null) {
            query += ' SORT BY ' + sortByField + ' ' + sortDirection;
        }

        return query;
    }

    private String getQuerySOSL() {
        String whereClause = '';
        Boolean isFirst = true;
        String query = 'FIND {';
        if (whereCommands.size() > 0) {
            for ( Map<String, String> whereCommandSet : whereCommands ) {
                for ( String whereCommand : whereCommandSet.keySet() ) {
                    // Add where clause delimiter.
                    if (isFirst == true) {
                        isFirst = false;
                    } else {
                        whereClause += ' ' + whereCommand + ' ';
                    }
                    whereClause += whereCommandSet.get(whereCommand);
                }

            }
            query += whereClause + '} IN ALL FIELDS RETURNING ' + String.join(fromCommands, ', ') + ' (' + String.join(selectCommands, ', ') + ')';
        }
        Return query;
    }
}
