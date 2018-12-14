import FluentPostgreSQL

extension QueryBuilder where
    Database: QuerySupporting,
    Database.QueryFilter: SQLExpression,
    Database.QueryField == Database.QueryFilter.ColumnIdentifier,
    Database.QueryFilterMethod == Database.QueryFilter.BinaryOperator,
    Database.QueryFilterValue == Database.QueryFilter
{
    /// Applies an ST_Touches filter to this query. Usually you will use the filter operators to do this.
    ///
    ///     let users = try User.query(on: conn)
    ///         .filterGeometryTouches(\.area, path)
    ///         .all()
    ///
    /// - parameters:
    ///     - key: Swift `KeyPath` to a field on the model to filter.
    ///     - value: Geometry value to filter by.
    /// - returns: Query builder for chaining.
    @discardableResult
    public func filterGeometryTouches<T>(_ key: KeyPath<Result, T>, _ filter: GISGeometry) -> Self
        where T: GISGeometry
    {
        return filterGeometryTouches(Database.queryField(.keyPath(key)), Database.queryFilterValueGeometry(filter))
    }
    
    /// Applies an ST_Touches filter to this query. Usually you will use the filter operators to do this.
    ///
    ///     let users = try User.query(on: conn)
    ///         .filterGeometryTouches(area, \.path)
    ///         .all()
    ///
    /// - parameters:
    ///     - value: Geometry value to filter by.
    ///     - key: Swift `KeyPath` to a field on the model to filter.
    /// - returns: Query builder for chaining.
    @discardableResult
    public func filterGeometryTouches<T>(_ value: GISGeometry, _ key: KeyPath<Result, T>) -> Self
        where T: GISGeometry
    {
        return filterGeometryTouches(Database.queryFilterValueGeometry(value), Database.queryField(.keyPath(key)))
    }
    
    /// Applies an ST_Touches filter to this query. Usually you will use the filter operators to do this.
    ///
    ///     let users = try User.query(on: conn)
    ///         .filterGeometryTouches("area", path)
    ///         .all()
    ///
    /// - parameters:
    ///     - field: Name to a field on the model to filter.
    ///     - value: Value to filter by.
    /// - returns: Query builder for chaining.
    @discardableResult
    private func filterGeometryTouches(_ field: Database.QueryField, _ value: Database.QueryFilterValue) -> Self {
        return self.filter(custom: Database.queryGeometryTouches(field, value))
    }
    
    /// Applies an ST_Touches filter to this query. Usually you will use the filter operators to do this.
    ///
    ///     let users = try User.query(on: conn)
    ///         .filterGeometryTouches(area, "path")
    ///         .all()
    ///
    /// - parameters:
    ///     - value: Value to filter by.
    ///     - field: Name to a field on the model to filter.
    /// - returns: Query builder for chaining.
    @discardableResult
    private func filterGeometryTouches(_ value: Database.QueryFilterValue, _ field: Database.QueryField) -> Self {
        return self.filter(custom: Database.queryGeometryTouches(value, field))
    }
}

extension QuerySupporting where
    QueryFilter: SQLExpression,
    QueryField == QueryFilter.ColumnIdentifier,
    QueryFilterMethod == QueryFilter.BinaryOperator,
    QueryFilterValue == QueryFilter
{
    /// Creates an instance of `QueryFilter` for ST_Touches from a field and value.
    ///
    /// - parameters:
    ///     - field: Field to filter.
    ///     - value: Value type.
    public static func queryGeometryTouches(_ field: QueryField, _ value: QueryFilterValue) -> QueryFilter {
        let args: [QueryFilter.Function.Argument] = [
            GenericSQLFunctionArgument<PostgreSQLExpression>.expression(PostgreSQLExpression.column(field as! PostgreSQLColumnIdentifier)),
            GenericSQLFunctionArgument<PostgreSQLExpression>.expression(value as! PostgreSQLExpression),
            ] as! [QueryFilter.Function.Argument]
        return .function("ST_Touches", args)
    }
    
    /// Creates an instance of `QueryFilter` for ST_Touches from a field and value.
    ///
    /// - parameters:
    ///     - value: Value type.
    ///     - field: Field to filter.
    public static func queryGeometryTouches(_ value: QueryFilterValue, _ field: QueryField) -> QueryFilter {
        let args: [QueryFilter.Function.Argument] = [
            GenericSQLFunctionArgument<PostgreSQLExpression>.expression(value as! PostgreSQLExpression), GenericSQLFunctionArgument<PostgreSQLExpression>.expression(PostgreSQLExpression.column(field as! PostgreSQLColumnIdentifier)),
            ] as! [QueryFilter.Function.Argument]
        return .function("ST_Touches", args)
    }
}
