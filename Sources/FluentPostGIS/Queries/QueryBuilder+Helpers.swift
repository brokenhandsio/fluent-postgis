import FluentSQL
import WKCodable

extension QueryBuilder {
    static func queryExpressionGeometry<T: GeometryConvertible>(_ geometry: T) -> any SQLExpression {
        let geometryText = WKTEncoder().encode(geometry.geometry)
        return SQLFunction("ST_GeomFromEWKT", args: [SQLLiteral.string(geometryText)])
    }

    static func queryExpressionGeography<T: GeometryConvertible>(_ geometry: T) -> any SQLExpression {
        let geometryText = WKTEncoder().encode(geometry.geometry)
        return SQLFunction("ST_GeogFromText", args: [SQLLiteral.string(geometryText)])
    }

    static func path<M, F>(_ field: KeyPath<M, F>) -> any SQLExpression
        where M: Schema, F: QueryableProperty, F.Model == M
    {
        let schema = SQLIdentifier(M.schemaOrAlias)
        let path = SQLIdentifier(M.path(for: field).map(\.description).joined(separator: "_"))
        return SQLColumn(path, table: schema)
    }
}

extension QueryBuilder {
    func filter(function: String, args: [any SQLExpression]) -> Self {
        self.filter(.sql(SQLFunction(function, args: args)))
    }

    func sort(function: String, args: [any SQLExpression]) -> Self {
        self.sort(.sql(SQLFunction(function, args: args)))
    }
}
