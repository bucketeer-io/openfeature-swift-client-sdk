import Testing
import Foundation
import Bucketeer
import OpenFeature
@testable import BucketeerOpenFeature

@Suite("Value Extenstion Tests")
struct ValueExtTests {
    @Test func toBKTValue() async throws {
        let testCases: [(Value, BKTValue)] = [
            (.boolean(true), .boolean(true)),
            (.string("string"), .string("string")),
            (.double(1.0), .number(1.0)),
            (.list([.boolean(true), .string("string")]), .list([.boolean(true), .string("string")])),
            (.structure(["key1": .boolean(true), "key2": .string("string")]),
            .dictionary(["key1": .boolean(true), "key2": .string("string")])),
            (.null, .null),
            (.integer(1), .number(1.0)),
            (.date(Date(timeIntervalSince1970: 101)), .number(101.0))
        ]

        for (value, expected) in testCases {
            let actual = value.toBKTValue()
            #expect(actual == expected)
        }
    }

    @Test func toString() async throws {
        let testCases: [(Value, String)] = [
            (.boolean(true), "true"),
            (.string("string"), "string"),
            (.double(1.0), "1.0"),
            (.integer(1), "1"),
            (.list([.boolean(true), .string("string")]), "true, string"),
            (.structure(["a": .boolean(true), "b": .string("string")]), "b: string, a: true"),
            (.date(Date(timeIntervalSince1970: 101)), "1970-01-01 00:01:41 +0000"),
            (.null, "null")]

        for (value, expected) in testCases {
            let actual = value.toString()
            #expect(actual == expected)
        }
    }
}
