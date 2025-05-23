import FluentKit
import WKCodable

public struct GeographicPoint2D: Codable, Equatable, CustomStringConvertible, Sendable {
    /// The point's x coordinate.
    public var longitude: Double

    /// The point's y coordinate.
    public var latitude: Double

    /// Create a new `GISGeographicPoint2D`
    public init(longitude: Double, latitude: Double) {
        self.longitude = longitude
        self.latitude = latitude
    }
}

extension GeographicPoint2D: GeometryConvertible, GeometryCollectable {
    /// Convertible type
    public typealias GeometryType = Point

    public init(geometry point: GeometryType) {
        self.init(longitude: point.x, latitude: point.y)
    }

    public var geometry: GeometryType {
        .init(vector: [self.longitude, self.latitude], srid: FluentPostGISSrid)
    }

    public var baseGeometry: any Geometry {
        self.geometry
    }
}
