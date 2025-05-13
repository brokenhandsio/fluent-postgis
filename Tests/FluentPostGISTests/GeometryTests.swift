@testable import FluentPostGIS
import XCTest

final class GeometryTests: FluentPostGISTestCase {
    func testPoint() async throws {
        let point = GeometricPoint2D(x: 1, y: 2)

        let user = UserLocation(location: point)
        try await user.save(on: self.db)

        let fetched = try await UserLocation.find(1, on: self.db)
        XCTAssertEqual(fetched?.location, point)

        let all = try await UserLocation.query(on: self.db)
            .filterGeometryDistanceWithin(\.$location, user.location, 1000)
            .all()
        XCTAssertEqual(all.count, 1)
    }

    func testLineString() async throws {
        let point = GeometricPoint2D(x: 1, y: 2)
        let point2 = GeometricPoint2D(x: 2, y: 3)
        let point3 = GeometricPoint2D(x: 3, y: 2)
        let lineString = GeometricLineString2D(points: [point, point2, point3, point])

        let user = UserPath(path: lineString)
        try await user.save(on: self.db)

        let fetched = try await UserPath.find(1, on: self.db)
        XCTAssertEqual(fetched?.path, lineString)
    }

    func testPolygon() async throws {
        let point = GeometricPoint2D(x: 1, y: 2)
        let point2 = GeometricPoint2D(x: 2, y: 3)
        let point3 = GeometricPoint2D(x: 3, y: 2)
        let lineString = GeometricLineString2D(points: [point, point2, point3, point])
        let polygon = GeometricPolygon2D(
            exteriorRing: lineString,
            interiorRings: [lineString, lineString]
        )

        let user = UserArea(area: polygon)
        try await user.save(on: self.db)

        let fetched = try await UserArea.find(1, on: self.db)
        XCTAssertEqual(fetched?.area, polygon)
    }

    func testGeometryCollection() async throws {
        let point = GeometricPoint2D(x: 1, y: 2)
        let point2 = GeometricPoint2D(x: 2, y: 3)
        let point3 = GeometricPoint2D(x: 3, y: 2)
        let lineString = GeometricLineString2D(points: [point, point2, point3, point])
        let polygon = GeometricPolygon2D(
            exteriorRing: lineString,
            interiorRings: [lineString, lineString]
        )
        let geometries: [any GeometryCollectable] = [point, point2, point3, lineString, polygon]
        let geometryCollection = GeometricGeometryCollection2D(geometries: geometries)

        let user = UserCollection(collection: geometryCollection)
        try await user.save(on: self.db)

        let fetched = try await UserCollection.find(1, on: self.db)
        XCTAssertEqual(fetched?.collection, geometryCollection)
    }
}
